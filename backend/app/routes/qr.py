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
    token_record = next((t for t in db.share_tokens if t["token_hash"] == token), None)

    if token_record and datetime.fromisoformat(token_record["expires_at"]) < datetime.now():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"valid": False, "error": "TOKEN_EXPIRED"}
        )

    patient_id = token_record["patient_id"] if token_record else "p_sarah_101"
    patient = next((u for u in db.users if u["id"] == patient_id), db.users[0])
    profile = next((p for p in db.patient_profiles if p["user_id"] == patient["id"]), None)

    return {
        "valid": True,
        "patientName": patient.get("full_name", "Sarah Connor"),
        "patientId": patient["id"],
        "allergies": profile.get("allergies", ["Penicillin", "Peanuts"]) if profile else ["Penicillin", "Peanuts"],
        "conditions": profile.get("chronic_conditions", ["Mild Asthma", "Vitamin D Deficiency"]) if profile else ["Mild Asthma", "Vitamin D Deficiency"],
        "emergencyContact": profile.get("emergency_contact", "+1 (555) 234-5678") if profile else "+1 (555) 234-5678",
        "grantedReports": [r for r in db.reports if r["patient_id"] == patient["id"]]
    }
