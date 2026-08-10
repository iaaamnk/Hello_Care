import uuid
from datetime import datetime, timedelta
from app.db import db
from app.services.gemini_service import generate_voice_response_with_gemini

class VoicePipeline:
    @staticmethod
    def execute_function_call(function_name: str, args: dict, patient_id: str) -> dict:
        if function_name == "get_latest_report_summary":
            target_pid = patient_id or "p_sarah_101"
            patient_reports = [r for r in db.reports if r.get("patient_id") == target_pid and r.get("status") == "ready"]
            if not patient_reports:
                return {"found": False, "message": "No medical reports found for patient."}
            latest = patient_reports[-1]
            return {
                "found": True,
                "reportTitle": latest["title"],
                "uploadedAt": latest["uploaded_at"],
                "summary": latest["ai_summary"],
                "suggestions": latest["ai_suggestions"]
            }

        elif function_name == "list_available_slots":
            slots = [s for s in db.availability_slots if s.get("is_available")]
            return {
                "availableSlotsCount": len(slots),
                "slots": [
                    {
                        "id": s["id"],
                        "doctorId": s["doctor_id"],
                        "time": s["slot_time"]
                    }
                    for s in slots
                ]
            }

        elif function_name == "book_appointment":
            target_doctor_id = args.get("doctorId") or "d_house_202"
            target_time = args.get("scheduledAt") or (datetime.now() + timedelta(days=1)).isoformat()

            # Enforce DB level unique constraint
            conflict = next(
                (a for a in db.appointments if a.get("doctor_id") == target_doctor_id and a.get("scheduled_at") == target_time),
                None
            )

            if conflict:
                return {
                    "success": False,
                    "error": "DOUBLE_BOOKING_PREVENTED",
                    "message": "That slot is already booked for Dr. Gregory House."
                }

            new_appt = {
                "id": str(uuid.uuid4()),
                "patient_id": patient_id or "p_sarah_101",
                "doctor_id": target_doctor_id,
                "scheduled_at": target_time,
                "status": "confirmed",
                "notes": "Booked via Voice Pipeline Assistant",
                "created_at": datetime.now().isoformat()
            }

            db.appointments.append(new_appt)

            # Mark slot unavailable
            slot_obj = next((s for s in db.availability_slots if s.get("slot_time") == target_time), None)
            if slot_obj:
                slot_obj["is_available"] = False

            return {
                "success": True,
                "appointmentId": new_appt["id"],
                "doctor": "Dr. Gregory House",
                "scheduledAt": target_time,
                "message": "Appointment successfully confirmed."
            }

        return {"error": "Unknown function call"}

    @classmethod
    def process_turn(cls, session_id: str, speech_text: str, channel: str = "in_app", patient_id: str = "p_sarah_101") -> dict:
        session = next((s for s in db.voice_sessions if s["id"] == session_id), None)
        if not session:
            session = {
                "id": session_id or str(uuid.uuid4()),
                "patient_id": patient_id,
                "channel": channel,
                "transcript": [],
                "dialog_state": {"step": "greeting"},
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            db.voice_sessions.append(session)

        session["transcript"].append({
            "role": "user",
            "content": speech_text,
            "timestamp": datetime.now().isoformat()
        })

        lower_query = speech_text.lower()
        function_call_result = None
        spoken_response = ""
        executed_function = None

        if "report" in lower_query or "blood test" in lower_query or "summary" in lower_query:
            executed_function = "get_latest_report_summary"
            function_call_result = cls.execute_function_call(executed_function, {}, patient_id)
            spoken_response = f"According to your latest report ({function_call_result.get('reportTitle')}): {function_call_result.get('summary')}"
        elif "slot" in lower_query or "available" in lower_query or "when can i see" in lower_query:
            executed_function = "list_available_slots"
            function_call_result = cls.execute_function_call(executed_function, {}, patient_id)
            spoken_response = f"Dr. Gregory House has {function_call_result.get('availableSlotsCount')} available slot(s). Next available is tomorrow."
        elif "book" in lower_query or "appointment" in lower_query or "schedule" in lower_query:
            executed_function = "book_appointment"
            slot_time = (datetime.now() + timedelta(days=1)).isoformat()
            function_call_result = cls.execute_function_call(executed_function, {"scheduledAt": slot_time}, patient_id)
            if function_call_result.get("success"):
                spoken_response = f"I have scheduled your appointment with Dr. Gregory House!"
            else:
                spoken_response = "Sorry, that appointment slot is already taken. Would you like me to find another available slot?"
        else:
            spoken_response = "Hello! I am your HelloCare voice assistant. You can ask me about your recent medical test reports or schedule an appointment with Dr. House."

        session["transcript"].append({
            "role": "assistant",
            "content": spoken_response,
            "executedFunction": executed_function,
            "functionCallResult": function_call_result,
            "timestamp": datetime.now().isoformat()
        })
        session["updated_at"] = datetime.now().isoformat()

        return {
            "sessionId": session["id"],
            "channel": session["channel"],
            "spokenResponse": spoken_response,
            "executedFunction": executed_function,
            "functionCallResult": function_call_result,
            "transcriptCount": len(session["transcript"]),
            "audioUrl": f"https://api.hellocare.demo/tts/mock-audio-{int(datetime.now().timestamp())}.mp3"
        }
