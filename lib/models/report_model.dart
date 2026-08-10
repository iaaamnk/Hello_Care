class ReportModel {
  final String id;
  final String patientId;
  final String title;
  final String fileUrl; // URL or local path
  final String fileType; // 'image' | 'pdf'
  final DateTime uploadedAt;
  final String ocrText;
  final String aiSummary;
  final List<String> aiSuggestions;
  final List<String> tags;

  ReportModel({
    required this.id,
    required this.patientId,
    required this.title,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
    this.ocrText = '',
    this.aiSummary = '',
    this.aiSuggestions = const [],
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'title': title,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'uploadedAt': uploadedAt.toIso8601String(),
      'ocrText': ocrText,
      'aiSummary': aiSummary,
      'aiSuggestions': aiSuggestions,
      'tags': tags,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      title: json['title'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? 'pdf',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
      ocrText: json['ocrText'] ?? '',
      aiSummary: json['aiSummary'] ?? '',
      aiSuggestions: List<String>.from(json['aiSuggestions'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
