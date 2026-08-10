import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../services/firestore_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<AppointmentModel> _appointments = [];
  List<DoctorModel> _doctors = [];
  bool _isLoading = false;

  List<AppointmentModel> get appointments => _appointments;
  List<DoctorModel> get doctors => _doctors;
  bool get isLoading => _isLoading;

  Future<void> fetchAppointments(String userId, bool isDoctor) async {
    _isLoading = true;
    notifyListeners();

    try {
      _appointments = await _firestoreService.getAppointments(userId, isDoctor);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDoctors() async {
    try {
      _doctors = await _firestoreService.getDoctors();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> bookAppointment({
    required String patientId,
    required DoctorModel doctor,
    required DateTime scheduledAt,
    String notes = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newAppt = AppointmentModel(
        id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        doctorId: doctor.uid,
        doctorName: doctor.name,
        doctorSpecialization: doctor.specialization,
        scheduledAt: scheduledAt,
        status: 'confirmed',
        notes: notes,
      );

      await _firestoreService.createAppointment(newAppt);
      _appointments.insert(0, newAppt);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
