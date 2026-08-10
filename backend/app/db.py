import uuid
from datetime import datetime, timedelta

class MockDB:
    def __init__(self):
        self.reset()

    def reset(self):
        self.users = [
            {
                "id": "p_sarah_101",
                "email": "sarah@example.com",
                "full_name": "Sarah Connor",
                "role": "patient",
                "created_at": datetime.now().isoformat()
            },
            {
                "id": "d_house_202",
                "email": "drhouse@example.com",
                "full_name": "Dr. Gregory House",
                "role": "doctor",
                "created_at": datetime.now().isoformat()
            }
        ]

        self.patient_profiles = [
            {
                "id": "prof_p1",
                "user_id": "p_sarah_101",
                "phone": "+1 (555) 234-5678",
                "blood_group": "O+",
                "allergies": ["Penicillin", "Peanuts"],
                "chronic_conditions": ["Mild Asthma", "Vitamin D Deficiency"],
                "emergency_contact": "+1 (555) 999-0000"
            }
        ]

        self.doctor_profiles = [
            {
                "id": "prof_d1",
                "user_id": "d_house_202",
                "specialty": "Diagnostic Medicine & Cardiology",
                "hospital": "Princeton-Plainsboro Teaching Hospital",
                "rating": 4.9,
                "experience_years": 15,
                "consultation_fee": 150.00
            }
        ]

        self.reports = [
            {
                "id": "rep_001",
                "patient_id": "p_sarah_101",
                "title": "Comprehensive Blood & Lipid Panel",
                "file_url": "https://example.com/reports/blood_panel.pdf",
                "file_type": "pdf",
                "status": "ready",
                "ocr_text": "Comprehensive Blood Panel Results...\nHemoglobin A1c: 5.6%\nTotal Cholesterol: 195 mg/dL\nVitamin D: 28 ng/mL",
                "ai_summary": "Your blood panel results are overall very healthy! A1c normal, cholesterol within bounds.",
                "ai_suggestions": ["Daily Vitamin D3 supplement recommended (1000–2000 IU)."],
                "tags": ["Blood Test", "Metabolic"],
                "uploaded_at": (datetime.now() - timedelta(days=2)).isoformat(),
                "updated_at": (datetime.now() - timedelta(days=2)).isoformat()
            }
        ]

        self.availability_slots = [
            {
                "id": "slot_1",
                "doctor_id": "d_house_202",
                "slot_time": (datetime.now() + timedelta(days=1)).isoformat(),
                "is_available": True
            },
            {
                "id": "slot_2",
                "doctor_id": "d_house_202",
                "slot_time": (datetime.now() + timedelta(days=2)).isoformat(),
                "is_available": True
            }
        ]

        self.appointments = []
        self.share_tokens = []
        self.voice_sessions = []
        self.jobs = []

db = MockDB()
