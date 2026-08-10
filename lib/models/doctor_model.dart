class DoctorModel {
  final String uid;
  final String name;
  final String specialization;
  final double rating;
  final String clinicName;
  final double consultationFee;
  final Map<String, List<String>> weeklyAvailability; // Day -> ['09:00 AM', '10:00 AM']

  DoctorModel({
    required this.uid,
    required this.name,
    required this.specialization,
    this.rating = 4.8,
    this.clinicName = 'HelloCare Medical Center',
    this.consultationFee = 75.0,
    required this.weeklyAvailability,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'specialization': specialization,
      'rating': rating,
      'clinicName': clinicName,
      'consultationFee': consultationFee,
      'weeklyAvailability': weeklyAvailability,
    };
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> avail = {};
    if (json['weeklyAvailability'] != null) {
      (json['weeklyAvailability'] as Map<String, dynamic>).forEach((key, val) {
        avail[key] = List<String>.from(val);
      });
    }
    return DoctorModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      rating: (json['rating'] ?? 4.8).toDouble(),
      clinicName: json['clinicName'] ?? 'HelloCare Medical Center',
      consultationFee: (json['consultationFee'] ?? 75.0).toDouble(),
      weeklyAvailability: avail,
    );
  }
}
