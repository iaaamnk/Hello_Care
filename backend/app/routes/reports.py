import uuid
from datetime import datetime
from typing import Optional
from fastapi import APIRouter, HTTPException, Query, status
from app.schemas import ReportUploadRequest
from app.db import db
from app.services.job_worker import job_worker

router = APIRouter(prefix="/reports", tags=["Reports"])

@router.get("")
def list_reports(patientId: Optional[str] = Query("p_sarah_101")):
    reports = [r for r in db.reports if r.get("patient_id") == patientId]
    return {"reports": reports}

@router.post("", status_code=status.HTTP_202_ACCEPTED)
def upload_report(req: ReportUploadRequest):
    report_id = str(uuid.uuid4())
    new_report = {
        "id": report_id,
        "patient_id": req.patientId or "p_sarah_101",
        "title": req.title,
        "file_url": req.fileUrl,
        "file_type": "pdf",
        "status": "uploaded",
        "ocr_text": None,
        "ai_summary": None,
        "ai_suggestions": [],
        "tags": [],
        "uploaded_at": datetime.now().isoformat()
    }
    db.reports.append(new_report)

    # Enqueue job into DB-backed queue worker
    job = job_worker.enqueue("PROCESS_REPORT_OCR_AI", {
        "reportId": report_id,
        "title": req.title,
        "fileUrl": req.fileUrl
    })

    return {
        "message": "Report uploaded successfully. Async processing enqueued.",
        "report": new_report,
        "job": {
            "id": job["id"],
            "status": job["status"]
        }
    }

@router.get("/{report_id}/status")
def get_report_status(report_id: str):
    report = next((r for r in db.reports if r["id"] == report_id), None)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")

    return {
        "id": report["id"],
        "status": report["status"],
        "updatedAt": report.get("updated_at", report["uploaded_at"]),
        "summary": report.get("ai_summary")
    }
