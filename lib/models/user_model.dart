class UserModel {
  final String uid;
  final String role; // 'patient' | 'doctor'
  final String name;
  final String email;
  final String phone;
  final DateTime dob;
  // Patient-only
  final List<String> allergies;
  final List<String> conditions;
  final String emergencyContact;
  // Doctor-only
  final String specialization;
  final String licenseNumber;
  final String clinicName;
  final double consultationFee;

  UserModel({
    required this.uid,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    this.allergies = const [],
    this.conditions = const [],
    this.emergencyContact = '',
    this.specialization = '',
    this.licenseNumber = '',
    this.clinicName = '',
    this.consultationFee = 0.0,
  });

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob.toIso8601String(),
      'allergies': allergies,
      'conditions': conditions,
      'emergencyContact': emergencyContact,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'clinicName': clinicName,
      'consultationFee': consultationFee,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      role: json['role'] ?? 'patient',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : DateTime.now(),
      allergies: List<String>.from(json['allergies'] ?? []),
      conditions: List<String>.from(json['conditions'] ?? []),
      emergencyContact: json['emergencyContact'] ?? '',
      specialization: json['specialization'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      clinicName: json['clinicName'] ?? '',
      consultationFee: (json['consultationFee'] ?? 0.0).toDouble(),
    );
  }
}
