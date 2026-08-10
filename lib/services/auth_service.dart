import '../models/user_model.dart';

class AuthService {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  // Mock Authentication / Registration
  Future<UserModel> login(String email, String password, String role) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (role == 'doctor') {
      _currentUser = UserModel(
        uid: 'doc_123',
        role: 'doctor',
        name: 'Dr. Evelyn Harper',
        email: email.isNotEmpty ? email : 'dr.evelyn@hellocare.org',
        phone: '+1 (555) 019-2831',
        dob: DateTime(1984, 5, 14),
        specialization: 'Cardiologist',
        licenseNumber: 'MD-892401',
        clinicName: 'St. Jude Heart & Health Clinic',
        consultationFee: 120.0,
      );
    } else {
      _currentUser = UserModel(
        uid: 'patient_456',
        role: 'patient',
        name: 'Alex Morgan',
        email: email.isNotEmpty ? email : 'alex.m@hellocare.org',
        phone: '+1 (555) 839-2041',
        dob: DateTime(1992, 11, 23),
        allergies: ['Penicillin', 'Peanuts'],
        conditions: ['Mild Asthma', 'Vitamin D Deficiency'],
        emergencyContact: '+1 (555) 912-4029 (Spouse)',
      );
    }
    return _currentUser!;
  }

  Future<UserModel> signupPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required DateTime dob,
    required List<String> allergies,
    required List<String> conditions,
    required String emergencyContact,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      uid: 'patient_${DateTime.now().millisecondsSinceEpoch}',
      role: 'patient',
      name: name,
      email: email,
      phone: phone,
      dob: dob,
      allergies: allergies,
      conditions: conditions,
      emergencyContact: emergencyContact,
    );
    return _currentUser!;
  }

  Future<UserModel> signupDoctor({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String specialization,
    required String licenseNumber,
    required String clinicName,
    required double consultationFee,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      uid: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      role: 'doctor',
      name: name,
      email: email,
      phone: phone,
      dob: DateTime(1985, 1, 1),
      specialization: specialization,
      licenseNumber: licenseNumber,
      clinicName: clinicName,
      consultationFee: consultationFee,
    );
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }
}
