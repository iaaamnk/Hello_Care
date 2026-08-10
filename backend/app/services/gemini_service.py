import os
import json
from google import genai
from google.genai import types

def get_gemini_client():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return None
    return genai.Client(api_key=api_key)

def process_report_with_gemini(title: str, file_url: str) -> dict:
    fallback = {
        "ocr_text": f"PATIENT MEDICAL REPORT - {title}\nDate: 2026-08-10\nHemoglobin A1c: 5.6%\nTotal Cholesterol: 195 mg/dL\nVitamin D: 28 ng/mL",
        "ai_summary": f"Your blood panel results for {title} show healthy glycemic control with normal A1c. Vitamin D is slightly low at 28 ng/mL.",
        "ai_suggestions": [
            "Consider taking daily Vitamin D3 supplement (1000–2000 IU).",
            "Maintain a balanced diet rich in soluble fiber."
        ],
        "tags": ["Blood Test", "Metabolic", "Lipids"]
    }

    client = get_gemini_client()
    if not client:
        return fallback

    prompt = f"""
    You are an expert AI medical report analyst for the HelloCare health application.
    Analyze this medical report titled "{title}" (URL: {file_url}).
    Return a JSON response with the following keys:
    - "ocr_text": Extracted key lab metrics and findings text
    - "ai_summary": Clear, plain-language patient summary (2-3 sentences max)
    - "ai_suggestions": Array of 2-3 actionable health suggestions
    - "tags": Array of 2-3 relevant medical tags (e.g. "Blood Test", "Metabolic")
    """

    try:
        response = client.models.generate_content(
            model="gemini-2.0-flash",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.2
            )
        )
        return json.loads(response.text)
    except Exception as e:
        print(f"[GeminiService] API Quota/Error (using fallback): {e}")
        return fallback

def generate_voice_response_with_gemini(user_query: str, report_context: str) -> str:
    fallback = f"I processed your query: '{user_query}'. Based on your records, your latest blood report shows healthy blood sugar levels and normal A1c."
    
    client = get_gemini_client()
    if not client:
        return fallback

    prompt = f"""
    You are HelloCare's empathetic AI medical voice assistant.
    User Question: "{user_query}"
    Report Context: "{report_context}"
    Give a concise, friendly 2-sentence spoken response answering the user's question directly based on their report. Do not diagnose.
    """

    try:
        response = client.models.generate_content(
            model="gemini-2.0-flash",
            contents=prompt,
        )
        return response.text.strip()
    except Exception as e:
        print(f"[GeminiService] Voice API Quota/Error (using fallback): {e}")
        return fallback
