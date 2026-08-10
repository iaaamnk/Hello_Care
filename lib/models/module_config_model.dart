class ModuleConfigModel {
  final String moduleId;
  final String label;
  final bool pinned;
  final int order;

  ModuleConfigModel({
    required this.moduleId,
    required this.label,
    required this.pinned,
    required this.order,
  });

  ModuleConfigModel copyWith({
    String? moduleId,
    String? label,
    bool? pinned,
    int? order,
  }) {
    return ModuleConfigModel(
      moduleId: moduleId ?? this.moduleId,
      label: label ?? this.label,
      pinned: pinned ?? this.pinned,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'label': label,
      'pinned': pinned,
      'order': order,
    };
  }

  factory ModuleConfigModel.fromJson(Map<String, dynamic> json) {
    return ModuleConfigModel(
      moduleId: json['moduleId'] ?? '',
      label: json['label'] ?? '',
      pinned: json['pinned'] ?? true,
      order: json['order'] ?? 0,
    );
  }
}
