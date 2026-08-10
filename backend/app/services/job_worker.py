import asyncio
import uuid
from datetime import datetime
from app.db import db

from app.services.gemini_service import process_report_with_gemini

class JobWorker:
    def __init__(self):
        self.is_polling = False
        self.task = None

    async def start(self, interval_seconds: float = 1.5):
        if self.is_polling:
            return
        self.is_polling = True
        self.task = asyncio.create_task(self._poll_loop(interval_seconds))
        print("[JobWorker] FastAPI async DB job worker started.")

    async def stop(self):
        self.is_polling = False
        if self.task:
            self.task.cancel()
        print("[JobWorker] Queue worker stopped.")

    def enqueue(self, job_type: str, payload: dict) -> dict:
        job = {
            "id": str(uuid.uuid4()),
            "type": job_type,
            "payload": payload,
            "status": "pending",
            "attempts": 0,
            "run_at": datetime.now().isoformat(),
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }
        db.jobs.append(job)
        print(f"[JobWorker] Job {job['id']} ({job_type}) enqueued.")
        return job

    async def _poll_loop(self, interval_seconds: float):
        while self.is_polling:
            await self.process_next_job()
            await asyncio.sleep(interval_seconds)

    async def process_next_job(self):
        now_str = datetime.now().isoformat()
        pending_job = None
        for j in db.jobs:
            if j["status"] == "pending" and j["run_at"] <= now_str:
                pending_job = j
                break

        if not pending_job:
            return

        pending_job["status"] = "processing"
        pending_job["attempts"] += 1
        pending_job["updated_at"] = datetime.now().isoformat()

        try:
            print(f"[JobWorker] Processing job {pending_job['id']} ({pending_job['type']})...")

            if pending_job["type"] == "PROCESS_REPORT_OCR_AI":
                report_id = pending_job["payload"].get("reportId")
                title = pending_job["payload"].get("title", "Medical Report")
                file_url = pending_job["payload"].get("fileUrl", "")

                report = next((r for r in db.reports if r["id"] == report_id), None)
                if report:
                    report["status"] = "ocr_processing"
                    await asyncio.sleep(0.2)

                    # Call Gemini API Processor
                    gemini_result = process_report_with_gemini(title, file_url)

                    report["status"] = "summarizing"
                    await asyncio.sleep(0.2)

                    report["ocr_text"] = gemini_result.get("ocr_text")
                    report["ai_summary"] = gemini_result.get("ai_summary")
                    report["ai_suggestions"] = gemini_result.get("ai_suggestions", [])
                    report["tags"] = gemini_result.get("tags", ["Blood Test"])
                    report["status"] = "ready"
                    report["updated_at"] = datetime.now().isoformat()

            pending_job["status"] = "completed"
            pending_job["result"] = {"success": True}
            pending_job["updated_at"] = datetime.now().isoformat()
            print(f"[JobWorker] Job {pending_job['id']} completed successfully.")

        except Exception as e:
            print(f"[JobWorker] Job {pending_job['id']} failed: {e}")
            pending_job["status"] = "failed"
            pending_job["error"] = str(e)
            pending_job["updated_at"] = datetime.now().isoformat()

            report_id = pending_job.get("payload", {}).get("reportId")
            if report_id:
                report = next((r for r in db.reports if r["id"] == report_id), None)
                if report:
                    report["status"] = "failed"
                    report["error_message"] = str(e)

job_worker = JobWorker()
