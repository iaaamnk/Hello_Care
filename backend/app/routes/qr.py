import json
import uuid
from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException, status
from app.schemas import QrGenerateRequest
from app.db import db

router = APIRouter(prefix="/qr", tags=["QR Share Tokens"])

@router.post("/generate")
def generate_qr_token(req: QrGenerateRequest):
    patient_id = req.patientId or "p_sarah_101"
    raw_token = f"HC-SHARE-{patient_id}-{str(uuid.uuid4())[:8]}"
    expires_at = (datetime.now() + timedelta(minutes=req.validityMinutes or 15)).isoformat()

    share_record = {
        "id": str(uuid.uuid4()),
        "patient_id": patient_id,
        "token_hash": raw_token,
        "granted_report_ids": req.reportIds or ["rep_001"],
        "expires_at": expires_at,
        "created_at": datetime.now().isoformat()
    }
    db.share_tokens.append(share_record)

    return {
        "token": raw_token,
        "expiresAt": expires_at,
        "reportCount": len(share_record["granted_report_ids"])
    }

@router.get("/resolve/{token}")
def resolve_qr_token(token: str):
    # Support direct JSON payload string resolution
    if token.startswith("{") and token.endswith("}"):
        try:
            data = json.loads(token)
            return {
                "valid": True,
                "patientName": data.get("patientName", "Sarah Connor"),
                "patientId": data.get("patientId", "p_sarah_101"),
                "allergies": data.get("allergies", ["Penicillin", "Peanuts"]),
                "conditions": data.get("conditions", ["Mild Asthma", "Vitamin D Deficiency"]),
                "emergencyContact": data.get("emergencyContact", "+1 (555) 234-5678"),
                "grantedReports": data.get("grantedReports", [
                    {
                        "id": "rep_001",
                        "title": "Comprehensive Blood & Lipid Panel",
                        "fileType": "pdf",
                        "aiSummary": "Blood panel results show healthy sugar control & normal cholesterol. Vitamin D slightly low.",
                        "ocrText": "Hemoglobin A1c: 5.6%\nTotal Cholesterol: 195 mg/dL\nVitamin D: 28 ng/mL"
                    }
                ])
            }
        except Exception:
            pass

    token_record = next((t for t in db.share_tokens if t["token_hash"] == token), None)

    if token_record and datetime.fromisoformat(token_record["expires_at"]) < datetime.now():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"valid": False, "error": "TOKEN_EXPIRED"}
        )

    patient_id = "p_sarah_101"
    if token_record:
        patient_id = token_record["patient_id"]
    elif token.startswith("HC-SHARE-"):
        parts = token.split("-")
        if len(parts) >= 3:
            patient_id = parts[2]

    patient = next((u for u in db.users if u["id"] == patient_id), None)
    profile = next((p for p in db.patient_profiles if p["user_id"] == patient_id), None)

    patient_reports = [r for r in db.reports if r.get("patient_id") == patient_id]
    if not patient_reports:
        patient_reports = db.reports

    return {
        "valid": True,
        "patientName": patient.get("full_name", "Sarah Connor") if patient else "Sarah Connor",
        "patientId": patient_id,
        "allergies": profile.get("allergies", ["Penicillin", "Peanuts"]) if profile else ["Penicillin", "Peanuts"],
        "conditions": profile.get("chronic_conditions", ["Mild Asthma", "Vitamin D Deficiency"]) if profile else ["Mild Asthma", "Vitamin D Deficiency"],
        "emergencyContact": profile.get("emergency_contact", "+1 (555) 234-5678") if profile else "+1 (555) 234-5678",
        "grantedReports": patient_reports
    }
