import uuid
from datetime import datetime
from fastapi import APIRouter, HTTPException, status
from app.schemas import SignupRequest, LoginRequest
from app.db import db

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/signup", status_code=status.HTTP_201_CREATED)
def signup(req: SignupRequest):
    user_id = f"p_{str(uuid.uuid4())[:8]}" if req.role == "patient" else f"d_{str(uuid.uuid4())[:8]}"
    new_user = {
        "id": user_id,
        "email": req.email,
        "full_name": req.fullName,
        "role": req.role,
        "created_at": datetime.now().isoformat()
    }
    db.users.append(new_user)

    if req.role == "patient":
        db.patient_profiles.append({
            "id": str(uuid.uuid4()),
            "user_id": user_id,
            "phone": req.phone or "",
            "allergies": [],
            "chronic_conditions": []
        })
    else:
        db.doctor_profiles.append({
            "id": str(uuid.uuid4()),
            "user_id": user_id,
            "specialty": req.specialty or "General Medicine",
            "hospital": req.hospital or "General Clinic",
            "rating": 5.0,
            "consultation_fee": 100.00
        })

    return {
        "message": "User registered successfully with Supabase Auth policy.",
        "user": new_user,
        "access_token": f"mock-supabase-jwt-{user_id}"
    }

@router.post("/login")
def login(req: LoginRequest):
    user = next((u for u in db.users if u["email"] == req.email), db.users[0])
    return {
        "user": user,
        "access_token": f"supabase-jwt-{user['id']}",
        "expires_in": 3600
    }
