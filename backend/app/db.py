import os
import uuid
import json
from datetime import datetime, timedelta

try:
    import psycopg2
    from psycopg2.extras import RealDictCursor
    PSYCOPG2_AVAILABLE = True
except ImportError:
    PSYCOPG2_AVAILABLE = False


def to_uuid(id_str: str) -> str:
    if not id_str:
        return str(uuid.uuid4())
    try:
        return str(uuid.UUID(str(id_str)))
    except (ValueError, TypeError, AttributeError):
        return str(uuid.uuid5(uuid.NAMESPACE_DNS, str(id_str)))


class SupabaseDB:
    def __init__(self):
        self.db_url = os.environ.get("DATABASE_URL")

    def get_connection(self):
        if not self.db_url or not PSYCOPG2_AVAILABLE:
            return None
        try:
            conn = psycopg2.connect(self.db_url, cursor_factory=RealDictCursor)
            return conn
        except Exception as e:
            print(f"[SupabaseDB] Connection notice (using fallback): {e}")
            return None

    def fetch_all(self, query: str, params: tuple = ()):
        conn = self.get_connection()
        if not conn:
            return None
        try:
            with conn:
                with conn.cursor() as cur:
                    cur.execute(query, params)
                    return [dict(row) for row in cur.fetchall()]
        except Exception as e:
            print(f"[SupabaseDB] Query Error: {e}")
            return None
        finally:
            conn.close()

    def execute(self, query: str, params: tuple = ()):
        conn = self.get_connection()
        if not conn:
            return False
        try:
            with conn:
                with conn.cursor() as cur:
                    cur.execute(query, params)
            return True
        except Exception as e:
            print(f"[SupabaseDB] Execute Error: {e}")
            return False
        finally:
            conn.close()


class UnifiedDatabaseManager:
    def __init__(self):
        self.supabase = SupabaseDB()
        self.reset_mock()
        self._ensure_seed_users()

    def reset(self):
        self.reset_mock()
        self._ensure_seed_users()

    def _ensure_seed_users(self):
        # Ensure default patient and doctor users exist in Supabase DB for FK constraints
        seed_users = [
            (to_uuid("p_sarah_101"), "sarah@example.com", "Sarah Connor", "patient"),
            (to_uuid("patient_456"), "patient456@example.com", "Patient 456", "patient"),
            (to_uuid("d_house_202"), "drhouse@example.com", "Dr. Gregory House", "doctor")
        ]
        for uid, email, name, role in seed_users:
            self.supabase.execute(
                "INSERT INTO users (id, email, full_name, role) VALUES (%s, %s, %s, %s) ON CONFLICT (id) DO NOTHING",
                (uid, email, name, role)
            )

    def reset_mock(self):
        self.users = [
            {
                "id": to_uuid("p_sarah_101"),
                "email": "sarah@example.com",
                "full_name": "Sarah Connor",
                "role": "patient",
                "created_at": datetime.now().isoformat()
            },
            {
                "id": to_uuid("d_house_202"),
                "email": "drhouse@example.com",
                "full_name": "Dr. Gregory House",
                "role": "doctor",
                "created_at": datetime.now().isoformat()
            }
        ]

        self.patient_profiles = [
            {
                "id": "prof_p1",
                "user_id": to_uuid("p_sarah_101"),
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
                "user_id": to_uuid("d_house_202"),
                "specialty": "Diagnostic Medicine & Cardiology",
                "hospital": "Princeton-Plainsboro Teaching Hospital",
                "rating": 4.9,
                "experience_years": 15,
                "consultation_fee": 150.00
            }
        ]

        self.reports = [
            {
                "id": to_uuid("rep_001"),
                "patient_id": to_uuid("p_sarah_101"),
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
                "doctor_id": to_uuid("d_house_202"),
                "slot_time": (datetime.now() + timedelta(days=1)).isoformat(),
                "is_available": True
            },
            {
                "id": "slot_2",
                "doctor_id": to_uuid("d_house_202"),
                "slot_time": (datetime.now() + timedelta(days=2)).isoformat(),
                "is_available": True
            }
        ]

        self.appointments = [
            {
                "id": "apt_201",
                "patient_id": to_uuid("p_sarah_101"),
                "patient_name": "Sarah Connor",
                "doctor_id": to_uuid("d_house_202"),
                "scheduled_at": (datetime.now() + timedelta(days=2)).isoformat(),
                "status": "confirmed",
                "notes": "Routine cardiac checkup post lipid test",
                "created_at": datetime.now().isoformat()
            }
        ]
        self.share_tokens = []
        self.voice_sessions = []
        self.jobs = []

    def get_users(self):
        res = self.supabase.fetch_all("SELECT id, email, full_name, role, created_at FROM users")
        return res if res is not None else self.users

    def insert_user(self, user):
        clean_id = to_uuid(user["id"])
        user["id"] = clean_id
        success = self.supabase.execute(
            "INSERT INTO users (id, email, full_name, role) VALUES (%s, %s, %s, %s) ON CONFLICT (email) DO NOTHING",
            (clean_id, user["email"], user["full_name"], user["role"])
        )
        if not success:
            self.users.append(user)
        return user

    def get_reports(self, patient_id=None):
        if patient_id:
            clean_patient_id = to_uuid(patient_id)
            res = self.supabase.fetch_all("SELECT * FROM reports WHERE patient_id = %s ORDER BY uploaded_at DESC", (clean_patient_id,))
        else:
            res = self.supabase.fetch_all("SELECT * FROM reports ORDER BY uploaded_at DESC")
        if res is not None and len(res) > 0:
            return res
        return self.reports

    def get_report_by_id(self, report_id: str):
        clean_id = to_uuid(report_id)
        res = self.supabase.fetch_all("SELECT * FROM reports WHERE id = %s", (clean_id,))
        if res and len(res) > 0:
            return res[0]
        return next((r for r in self.reports if r["id"] in (report_id, clean_id)), None)

    def insert_report(self, report):
        clean_id = to_uuid(report["id"])
        raw_pid = report.get("patient_id") or "p_sarah_101"
        clean_patient_id = to_uuid(raw_pid)
        report["id"] = clean_id
        report["patient_id"] = clean_patient_id

        # Ensure patient user row exists in Supabase users table
        self.supabase.execute(
            "INSERT INTO users (id, email, full_name, role) VALUES (%s, %s, %s, %s) ON CONFLICT (id) DO NOTHING",
            (clean_patient_id, f"patient_{clean_patient_id[:8]}@example.com", "Sarah Connor", "patient")
        )

        ai_sug = report.get("ai_suggestions", [])
        if isinstance(ai_sug, list):
            ai_sug_json = json.dumps(ai_sug)
        else:
            ai_sug_json = str(ai_sug)

        success = self.supabase.execute(
            "INSERT INTO reports (id, patient_id, title, file_url, file_type, status, ocr_text, ai_summary, ai_suggestions, tags) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) "
            "ON CONFLICT (id) DO UPDATE SET "
            "status = EXCLUDED.status, ocr_text = EXCLUDED.ocr_text, "
            "ai_summary = EXCLUDED.ai_summary, ai_suggestions = EXCLUDED.ai_suggestions, "
            "tags = EXCLUDED.tags, updated_at = CURRENT_TIMESTAMP",
            (
                clean_id,
                clean_patient_id,
                report["title"],
                report["file_url"],
                report.get("file_type", "pdf"),
                report.get("status", "uploaded"),
                report.get("ocr_text"),
                report.get("ai_summary"),
                ai_sug_json,
                report.get("tags", [])
            )
        )
        
        # Always maintain in-memory mock as well
        existing_idx = next((i for i, r in enumerate(self.reports) if r["id"] in (report["id"], clean_id)), None)
        if existing_idx is not None:
            self.reports[existing_idx] = report
        else:
            self.reports.append(report)

        return report

    def update_report(self, report_id: str, updates: dict):
        clean_id = to_uuid(report_id)
        # Update local memory
        report = next((r for r in self.reports if r["id"] in (report_id, clean_id)), None)
        if report:
            report.update(updates)

        set_clauses = []
        params = []
        for k, v in updates.items():
            if k == "ai_suggestions" and isinstance(v, list):
                v = json.dumps(v)
            set_clauses.append(f"{k} = %s")
            params.append(v)
        
        if set_clauses:
            params.append(clean_id)
            sql = f"UPDATE reports SET {', '.join(set_clauses)}, updated_at = CURRENT_TIMESTAMP WHERE id = %s"
            self.supabase.execute(sql, tuple(params))

    def get_appointments(self, doctor_id=None, patient_id=None):
        query = "SELECT * FROM appointments"
        params = []
        if doctor_id:
            query += " WHERE doctor_id = %s"
            params.append(to_uuid(doctor_id))
        elif patient_id:
            query += " WHERE patient_id = %s"
            params.append(to_uuid(patient_id))
        query += " ORDER BY scheduled_at ASC"

        res = self.supabase.fetch_all(query, tuple(params))
        return res if res is not None else self.appointments

    def insert_appointment(self, appt):
        clean_id = to_uuid(appt["id"])
        clean_p_id = to_uuid(appt["patient_id"])
        clean_d_id = to_uuid(appt["doctor_id"])
        appt["id"] = clean_id
        appt["patient_id"] = clean_p_id
        appt["doctor_id"] = clean_d_id

        # Ensure users exist
        self.supabase.execute("INSERT INTO users (id, email, full_name, role) VALUES (%s, %s, %s, %s) ON CONFLICT (id) DO NOTHING", (clean_p_id, f"patient_{clean_p_id[:8]}@example.com", appt.get("patient_name", "Sarah Connor"), "patient"))
        self.supabase.execute("INSERT INTO users (id, email, full_name, role) VALUES (%s, %s, %s, %s) ON CONFLICT (id) DO NOTHING", (clean_d_id, f"doc_{clean_d_id[:8]}@example.com", "Doctor", "doctor"))

        success = self.supabase.execute(
            "INSERT INTO appointments (id, patient_id, patient_name, doctor_id, scheduled_at, status, notes) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (
                clean_id,
                clean_p_id,
                appt.get("patient_name", "Sarah Connor"),
                clean_d_id,
                appt["scheduled_at"],
                appt.get("status", "confirmed"),
                appt.get("notes", "")
            )
        )
        if not success:
            existing = next((a for a in self.appointments if a.get("doctor_id") == clean_d_id and str(a.get("scheduled_at")) == str(appt["scheduled_at"])), None)
            if existing:
                return False
            self.appointments.append(appt)
            return False
        else:
            self.appointments.append(appt)
            return True

    def insert_share_token(self, token_rec):
        clean_id = to_uuid(token_rec["id"])
        clean_p_id = to_uuid(token_rec["patient_id"])
        token_rec["id"] = clean_id
        token_rec["patient_id"] = clean_p_id

        success = self.supabase.execute(
            "INSERT INTO share_tokens (id, patient_id, token_hash, granted_report_ids, expires_at) "
            "VALUES (%s, %s, %s, %s, %s)",
            (
                clean_id,
                clean_p_id,
                token_rec["token_hash"],
                [to_uuid(rid) for rid in token_rec.get("granted_report_ids", [])],
                token_rec["expires_at"]
            )
        )
        if not success:
            self.share_tokens.append(token_rec)
        return token_rec


db = UnifiedDatabaseManager()

