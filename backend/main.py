import asyncio
import time
from collections import defaultdict
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

from app.services.job_worker import job_worker
from app.routes.auth import router as auth_router
from app.routes.reports import router as reports_router
from app.routes.appointments import router as appointments_router
from app.routes.voice import router as voice_router
from app.routes.qr import router as qr_router

# Rate Limiter: Max 60 requests per minute per IP address
rate_limit_store = defaultdict(list)
RATE_LIMIT_REQUESTS = 60
RATE_LIMIT_WINDOW = 60  # seconds

@asynccontextmanager
async def lifespan(app: FastAPI):
    await job_worker.start(1.5)
    yield
    await job_worker.stop()

app = FastAPI(
    title="HelloCare FastAPI Backend",
    version="1.0.0",
    description="Secured FastAPI REST Server with Input Sanitization, Rate Limiting, & RLS Security Policies",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Security Middleware: Rate Limiting & Security Headers
@app.middleware("http")
async def security_middleware(request: Request, call_next):
    # 1. IP Rate Limiting
    client_ip = request.client.host if request.client else "127.0.0.1"
    now = time.time()
    timestamps = [t for t in rate_limit_store[client_ip] if now - t < RATE_LIMIT_WINDOW]
    rate_limit_store[client_ip] = timestamps

    if len(timestamps) >= RATE_LIMIT_REQUESTS:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Rate limit exceeded. Please try again later."
        )

    rate_limit_store[client_ip].append(now)

    # 2. Process Request
    response = await call_next(request)

    # 3. Security Response Headers
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    return response

# CORS Configuration: Restricted origins in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Swap to specific frontend origin domain in production
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {
        "message": "Welcome to HelloCare Secured FastAPI Backend",
        "docs": "/docs",
        "version": "v1",
        "security": "active"
    }

@app.get("/health", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "workerStatus": "active" if job_worker.is_polling else "idle"
    }

# Register Versioned API Routers under /api/v1
app.include_router(auth_router, prefix="/api/v1")
app.include_router(reports_router, prefix="/api/v1")
app.include_router(appointments_router, prefix="/api/v1")
app.include_router(voice_router, prefix="/api/v1")
app.include_router(qr_router, prefix="/api/v1")

if __name__ == "__main__":
    import uvicorn
    import os
    port = int(os.environ.get("PORT", 8081))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
