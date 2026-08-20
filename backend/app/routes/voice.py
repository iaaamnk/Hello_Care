from fastapi import APIRouter, HTTPException, Response, Request
from app.schemas import VoiceTurnRequest, VoiceQueryRequest
from app.services.voice_pipeline import VoicePipeline

router = APIRouter(prefix="/voice", tags=["Voice Pipeline"])

@router.post("/session/start")
def start_voice_session(req: dict = {}):
    patient_id = req.get("patientId", "p_sarah_101")
    result = VoicePipeline.process_turn(None, "Hello", "in_app", patient_id)
    return {
        "message": "Voice session initialized",
        "sessionId": result["sessionId"],
        "greeting": result["spokenResponse"]
    }

@router.post("/session/{session_id}/turn")
def process_voice_turn(session_id: str, req: VoiceTurnRequest):
    result = VoicePipeline.process_turn(session_id, req.speechText, "in_app", req.patientId or "p_sarah_101")
    return result

@router.post("/query")
def voice_query(req: VoiceQueryRequest):
    req = req.sanitize()
    return VoicePipeline.process_voice_query(
        speech_text=req.speechText,
        user_id=req.userId or "p_sarah_101",
        portal=req.portal or "patient"
    )

@router.post("/inbound")
def twilio_inbound_webhook():
    twiml = """<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Gather input="speech" action="/api/v1/voice/gather" method="POST">
        <Say>Welcome to HelloCare Patient Assistant. How can I help you today?</Say>
    </Gather>
    <Say>We didn't receive any input. Goodbye!</Say>
</Response>"""
    return Response(content=twiml, media_type="text/xml")

@router.post("/gather")
async def twilio_gather_webhook(request: Request):
    form_data = await request.form()
    speech_result = form_data.get("SpeechResult", "tell me my latest report summary")
    call_sid = form_data.get("CallSid", "phone_session_1")

    pipeline_result = VoicePipeline.process_turn(call_sid, speech_result, "twilio_phone")

    twiml = f"""<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say>{pipeline_result['spokenResponse']}</Say>
    <Gather input="speech" action="/api/v1/voice/gather" method="POST">
        <Say>Is there anything else I can help you with?</Say>
    </Gather>
</Response>"""
    return Response(content=twiml, media_type="text/xml")
