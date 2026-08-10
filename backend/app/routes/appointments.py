import uuid
from datetime import datetime
from fastapi import APIRouter, HTTPException, status
from app.schemas import AppointmentBookRequest
from app.db import db

router = APIRouter(prefix="/appointments", tags=["Appointments"])

@router.get("")
def list_appointments():
    return {"appointments": db.appointments}

@router.post("", status_code=status.HTTP_201_CREATED)
def book_appointment(req: AppointmentBookRequest):
    # Database UNIQUE(doctor_id, scheduled_at) Enforced Constraint Check
    conflict = next(
        (a for a in db.appointments if a.get("doctor_id") == req.doctorId and a.get("scheduled_at") == req.scheduledAt and a.get("status") != "cancelled"),
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
        "doctor_id": req.doctorId,
        "scheduled_at": req.scheduledAt,
        "status": "confirmed",
        "notes": req.notes or "General consultation",
        "created_at": datetime.now().isoformat()
    }
    db.appointments.append(appointment)

    return {
        "message": "Appointment scheduled successfully.",
        "appointment": appointment
    }
