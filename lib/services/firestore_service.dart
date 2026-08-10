import '../models/report_model.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';

class FirestoreService {
  // Initial empty patient reports
  final List<ReportModel> _mockReports = [];

  // Initial sample doctors
  final List<DoctorModel> _mockDoctors = [
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

  // Initial sample appointments
  final List<AppointmentModel> _mockAppointments = [
    AppointmentModel(
      id: 'apt_201',
      patientId: 'patient_456',
      doctorId: 'doc_1',
      doctorName: 'Dr. Evelyn Harper',
      doctorSpecialization: 'Cardiologist',
      scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
      status: 'confirmed',
      notes: 'Routine cardiac assessment post lipid test.',
    )
  ];

  Future<List<ReportModel>> getPatientReports(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockReports.where((r) => r.patientId == patientId || patientId == 'patient_456').toList();
  }

  Future<void> saveReport(ReportModel report) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _mockReports.insert(0, report);
  }

  Future<List<DoctorModel>> getDoctors() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockDoctors;
  }

  Future<List<AppointmentModel>> getAppointments(String userId, bool isDoctor) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (isDoctor) {
      return _mockAppointments;
    }
    return _mockAppointments.where((a) => a.patientId == userId || userId == 'patient_456').toList();
  }

  Future<void> createAppointment(AppointmentModel appointment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockAppointments.insert(0, appointment);
  }
}
