class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime scheduledAt;
  final String status; // 'pending' | 'confirmed' | 'completed' | 'cancelled'
  final String notes;

  AppointmentModel({
    required this.id,
    required this.patientId,
    this.patientName = 'Sarah Connor',
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.scheduledAt,
    this.status = 'pending',
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'scheduledAt': scheduledAt.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? json['patient_id'] ?? '',
      patientName: json['patientName'] ?? json['patient_name'] ?? 'Sarah Connor',
      doctorId: json['doctorId'] ?? json['doctor_id'] ?? '',
      doctorName: json['doctorName'] ?? json['doctor_name'] ?? 'Dr. Evelyn Harper',
      doctorSpecialization: json['doctorSpecialization'] ?? json['doctor_specialization'] ?? 'Specialist',
      scheduledAt: json['scheduledAt'] != null || json['scheduled_at'] != null
          ? DateTime.parse(json['scheduledAt'] ?? json['scheduled_at'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
    );
  }
}
