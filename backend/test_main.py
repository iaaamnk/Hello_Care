import pytest
import asyncio
from fastapi.testclient import TestClient
from main import app
from app.db import db
from app.services.job_worker import job_worker

client = TestClient(app)

@pytest.fixture(autouse=True)
def reset_db():
    db.reset()

def test_signup():
    response = client.post("/api/v1/auth/signup", json={
        "email": "newpatient@example.com",
        "fullName": "John Doe",
        "role": "patient"
    })
    assert response.status_code == 201
    assert response.json()["user"]["email"] == "newpatient@example.com"

def test_reports_async_job():
    response = client.post("/api/v1/reports", json={
        "title": "Lipid Panel",
        "fileUrl": "https://example.com/lipid.pdf"
    })
    assert response.status_code == 202
    data = response.json()
    assert "job" in data
    assert data["report"]["status"] == "uploaded"

    asyncio.run(job_worker.process_next_job())

    status_res = client.get(f"/api/v1/reports/{data['report']['id']}/status")
    assert status_res.status_code == 200
    assert status_res.json()["status"] == "ready"

def test_double_booking_prevention():
    import random
    from datetime import datetime, timedelta
    random_days = random.randint(30, 300)
    random_hour = random.randint(8, 18)
    random_min = random.choice([0, 15, 30, 45])
    slot_time = (datetime.now() + timedelta(days=random_days, hours=random_hour, minutes=random_min)).strftime("%Y-%m-%dT%H:%M:00Z")

    r1 = client.post("/api/v1/appointments", json={
        "doctorId": "d_house_202",
        "scheduledAt": slot_time
    })
    assert r1.status_code == 201

    r2 = client.post("/api/v1/appointments", json={
        "doctorId": "d_house_202",
        "scheduledAt": slot_time
    })
    assert r2.status_code == 409

def test_voice_pipeline():
    start_res = client.post("/api/v1/voice/session/start", json={})
    assert start_res.status_code == 200
    session_id = start_res.json()["sessionId"]

    turn_res = client.post(f"/api/v1/voice/session/{session_id}/turn", json={
        "speechText": "Summarize my latest report"
    })
    assert turn_res.status_code == 200
    assert turn_res.json()["executedFunction"] == "get_latest_report_summary"
