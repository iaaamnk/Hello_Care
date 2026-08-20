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
    reports = db.get_reports(patient_id=patientId)
    return {"reports": reports}

@router.post("", status_code=status.HTTP_202_ACCEPTED)
def upload_report(req: ReportUploadRequest):
    req = req.sanitize()
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
    saved_report = db.insert_report(new_report)

    # Enqueue job into DB-backed queue worker
    job = job_worker.enqueue("PROCESS_REPORT_OCR_AI", {
        "reportId": saved_report["id"],
        "title": req.title,
        "fileUrl": req.fileUrl,
        "fileContent": req.fileContent
    })

    return {
        "message": "Report uploaded successfully. Async processing enqueued.",
        "report": saved_report,
        "job": {
            "id": job["id"],
            "status": job["status"]
        }
    }

@router.get("/{report_id}/status")
def get_report_status(report_id: str):
    report = db.get_report_by_id(report_id)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")

    return {
        "id": report["id"],
        "status": report["status"],
        "updatedAt": report.get("updated_at", report.get("uploaded_at")),
        "ocrText": report.get("ocr_text"),
        "aiSummary": report.get("ai_summary"),
        "aiSuggestions": report.get("ai_suggestions"),
        "tags": report.get("tags")
    }

@router.get("/{report_id}")
def get_report(report_id: str):
    report = db.get_report_by_id(report_id)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return {"report": report}

