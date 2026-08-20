import uuid
from datetime import datetime
from fastapi import APIRouter, HTTPException, status
from app.schemas import AppointmentBookRequest
from app.db import db

router = APIRouter(prefix="/appointments", tags=["Appointments"])

@router.get("")
def list_appointments():
    return {"appointments": db.get_appointments()}

@router.post("", status_code=status.HTTP_201_CREATED)
def book_appointment(req: AppointmentBookRequest):
    req = req.sanitize()
    existing_appts = db.get_appointments(doctor_id=req.doctorId)

    def normalize_time(t):
        if hasattr(t, 'isoformat'):
            t = t.isoformat()
        t = str(t).replace("+00:00", "Z")
        return t.rstrip("Z")

    target_time = normalize_time(req.scheduledAt)
    conflict = next(
        (a for a in existing_appts if normalize_time(a.get("scheduled_at")) == target_time and a.get("status") != "cancelled"),
        None
    )

    if conflict:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={
                "error": "DOUBLE_BOOKING_PREVENTED",
                "message": "This doctor is already booked at the requested time slot. Select another slot."
            }
        )

    appointment = {
        "id": str(uuid.uuid4()),
        "patient_id": req.patientId or "p_sarah_101",
        "patient_name": req.patientName or "Sarah Connor",
        "doctor_id": req.doctorId,
        "scheduled_at": req.scheduledAt,
        "status": "confirmed",
        "notes": req.notes or "General consultation",
        "created_at": datetime.now().isoformat()
    }
    success = db.insert_appointment(appointment)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={
                "error": "DOUBLE_BOOKING_PREVENTED",
                "message": "This doctor is already booked at the requested time slot. Select another slot."
            }
        )

    return {
        "message": "Appointment scheduled successfully.",
        "appointment": appointment
    }
