import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isDoctor => _user?.isDoctor ?? false;
  bool get isPatient => _user?.isPatient ?? true;

  UserProvider() {
    // Default guest/demo initial state: logged out or optional patient demo
  }

  Future<void> login(String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.login(email, password, role);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signupPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required DateTime dob,
    required List<String> allergies,
    required List<String> conditions,
    required String emergencyContact,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signupPatient(
        name: name,
        email: email,
        password: password,
        phone: phone,
        dob: dob,
        allergies: allergies,
        conditions: conditions,
        emergencyContact: emergencyContact,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signupDoctor({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String specialization,
    required String licenseNumber,
    required String clinicName,
    required double consultationFee,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signupDoctor(
        name: name,
        email: email,
        password: password,
        phone: phone,
        specialization: specialization,
        licenseNumber: licenseNumber,
        clinicName: clinicName,
        consultationFee: consultationFee,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
