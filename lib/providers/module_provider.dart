import 'package:flutter/foundation.dart';
import '../models/module_config_model.dart';

class ModuleProvider extends ChangeNotifier {
  final List<ModuleConfigModel> _modules = [
    ModuleConfigModel(moduleId: 'reports', label: 'Medical Reports', pinned: true, order: 0),
    ModuleConfigModel(moduleId: 'ai_summary', label: 'AI Health Summary', pinned: true, order: 1),
    ModuleConfigModel(moduleId: 'appointments', label: 'Upcoming Appointments', pinned: true, order: 2),
    ModuleConfigModel(moduleId: 'doctors', label: 'Find Doctors', pinned: true, order: 3),
  ];

  List<ModuleConfigModel> get modules {
    final list = _modules.where((m) => m.pinned).toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<ModuleConfigModel> get allModules => _modules;

  void togglePin(String moduleId) {
    final index = _modules.indexWhere((m) => m.moduleId == moduleId);
    if (index != -1) {
      final current = _modules[index];
      _modules[index] = current.copyWith(pinned: !current.pinned);
      notifyListeners();
    }
  }

  void reorderModules(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _modules.removeAt(oldIndex);
    _modules.insert(newIndex, item);
    for (int i = 0; i < _modules.length; i++) {
      _modules[i] = _modules[i].copyWith(order: i);
    }
    notifyListeners();
  }
}
