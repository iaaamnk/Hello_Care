from pydantic import BaseModel, Field, EmailStr
from typing import List, Optional
import html

def sanitize_text(text: Optional[str]) -> Optional[str]:
    if not text:
        return text
    # Escape HTML to prevent XSS injection
    cleaned = html.escape(text.strip())
    # Limit max length to prevent payload overflow
    return cleaned[:1000]

class SignupRequest(BaseModel):
    email: EmailStr
    fullName: str = Field(..., min_length=2, max_length=100)
    role: str = Field(..., pattern="^(patient|doctor)$")
    phone: Optional[str] = Field(None, max_length=20)
    specialty: Optional[str] = Field(None, max_length=100)
    hospital: Optional[str] = Field(None, max_length=150)

    def sanitize(self):
        self.fullName = sanitize_text(self.fullName)
        self.phone = sanitize_text(self.phone)
        self.specialty = sanitize_text(self.specialty)
        self.hospital = sanitize_text(self.hospital)
        return self

class LoginRequest(BaseModel):
    email: EmailStr
    password: Optional[str] = Field("password", max_length=128)

class ReportUploadRequest(BaseModel):
    title: str = Field(..., min_length=2, max_length=150)
    fileUrl: str = Field(..., max_length=1000)
    patientId: Optional[str] = Field("p_sarah_101", max_length=64)

    def sanitize(self):
        self.title = sanitize_text(self.title)
        self.fileUrl = sanitize_text(self.fileUrl)
        self.patientId = sanitize_text(self.patientId)
        return self

class AppointmentBookRequest(BaseModel):
    doctorId: str = Field(..., max_length=64)
    scheduledAt: str = Field(..., max_length=64)
    patientId: Optional[str] = Field("p_sarah_101", max_length=64)
    notes: Optional[str] = Field("General consultation", max_length=500)

    def sanitize(self):
        self.doctorId = sanitize_text(self.doctorId)
        self.scheduledAt = sanitize_text(self.scheduledAt)
        self.patientId = sanitize_text(self.patientId)
        self.notes = sanitize_text(self.notes)
        return self

class VoiceTurnRequest(BaseModel):
    speechText: str = Field(..., min_length=1, max_length=500)
    patientId: Optional[str] = Field("p_sarah_101", max_length=64)

    def sanitize(self):
        self.speechText = sanitize_text(self.speechText)
        self.patientId = sanitize_text(self.patientId)
        return self

class QrGenerateRequest(BaseModel):
    patientId: Optional[str] = Field("p_sarah_101", max_length=64)
    reportIds: Optional[List[str]] = Field(default_factory=lambda: ["rep_001"])
    validityMinutes: Optional[int] = Field(15, ge=1, le=1440)
