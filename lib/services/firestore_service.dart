import '../models/report_model.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';

class FirestoreService {
  // Shared in-memory data store across all instances
  static final List<ReportModel> _mockReports = [
    ReportModel(
      id: 'rep_001',
      patientId: 'patient_456',
      title: 'Comprehensive Blood & Lipid Panel',
      fileUrl: 'https://example.com/reports/blood_panel.pdf',
      fileType: 'pdf',
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
      ocrText: 'Comprehensive Blood Panel Results...\nHemoglobin A1c: 5.6%\nTotal Cholesterol: 195 mg/dL\nVitamin D: 28 ng/mL',
      aiSummary: 'Your blood panel results are overall very healthy! A1c normal, cholesterol within bounds.',
      aiSuggestions: ['Daily Vitamin D3 supplement recommended (1000–2000 IU).'],
      tags: ['Blood Test', 'Metabolic'],
    )
  ];

  static final List<DoctorModel> _mockDoctors = [
    DoctorModel(
      uid: 'doc_1',
      name: 'Dr. Evelyn Harper',
      specialization: 'Cardiologist',
      rating: 4.9,
      clinicName: 'St. Jude Heart & Health Clinic',
      consultationFee: 120.0,
      weeklyAvailability: {
        'Monday': ['09:00 AM', '10:30 AM', '02:00 PM', '04:00 PM'],
        'Wednesday': ['10:00 AM', '11:30 AM', '03:00 PM'],
        'Friday': ['09:00 AM', '01:00 PM', '03:30 PM'],
      },
    ),
    DoctorModel(
      uid: 'doc_2',
      name: 'Dr. Marcus Vance',
      specialization: 'Neurologist',
      rating: 4.8,
      clinicName: 'Brain & Spine Institute',
      consultationFee: 140.0,
      weeklyAvailability: {
        'Tuesday': ['09:00 AM', '11:00 AM', '02:00 PM'],
        'Thursday': ['10:00 AM', '01:30 PM', '04:00 PM'],
      },
    ),
    DoctorModel(
      uid: 'doc_3',
      name: 'Dr. Sophia Reyes',
      specialization: 'Endocrinologist',
      rating: 4.95,
      clinicName: 'Metabolic & Wellness Clinic',
      consultationFee: 110.0,
      weeklyAvailability: {
        'Monday': ['11:00 AM', '02:30 PM'],
        'Wednesday': ['09:30 AM', '01:00 PM', '04:30 PM'],
        'Friday': ['10:00 AM', '02:00 PM'],
      },
    ),
  ];

  static final List<AppointmentModel> _mockAppointments = [
    AppointmentModel(
      id: 'apt_201',
      patientId: 'patient_456',
      patientName: 'Sarah Connor',
      doctorId: 'doc_1',
      doctorName: 'Dr. Evelyn Harper',
      doctorSpecialization: 'Cardiologist',
      scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
      status: 'confirmed',
      notes: 'Routine cardiac assessment post lipid test.',
    )
  ];

  Future<List<ReportModel>> getPatientReports(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final filtered = _mockReports.where((r) => r.patientId == patientId).toList();
    if (filtered.isEmpty) {
      return List.from(_mockReports);
    }
    return filtered;
  }

  Future<void> saveReport(ReportModel report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockReports.insert(0, report);
  }

  Future<List<DoctorModel>> getDoctors() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockDoctors);
  }

  Future<List<AppointmentModel>> getAppointments(String userId, bool isDoctor) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (isDoctor) {
      final forDoc = _mockAppointments.where((a) => a.doctorId == userId || userId.startsWith('doc')).toList();
      return forDoc.isNotEmpty ? forDoc : List.from(_mockAppointments);
    }
    final forPatient = _mockAppointments.where((a) => a.patientId == userId).toList();
    return forPatient.isNotEmpty ? forPatient : List.from(_mockAppointments);
  }

  Future<void> createAppointment(AppointmentModel appointment) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockAppointments.insert(0, appointment);
  }

  Future<void> updateDoctorSchedule(String doctorId, Map<String, List<String>> schedule) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final docIndex = _mockDoctors.indexWhere((d) => d.uid == doctorId || doctorId.startsWith('doc'));
    if (docIndex != -1) {
      final old = _mockDoctors[docIndex];
      _mockDoctors[docIndex] = DoctorModel(
        uid: old.uid,
        name: old.name,
        specialization: old.specialization,
        rating: old.rating,
        clinicName: old.clinicName,
        consultationFee: old.consultationFee,
        weeklyAvailability: Map.from(schedule),
      );
    }
  }
}
