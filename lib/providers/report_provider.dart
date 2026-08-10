import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();

  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String _aggregatedSummary = '';
  String _searchQuery = '';
  String _selectedTag = 'All';

  List<ReportModel> get reports {
    return _reports.where((r) {
      final matchesSearch = r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesTag = _selectedTag == 'All' || r.tags.contains(_selectedTag);
      return matchesSearch && matchesTag;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String get aggregatedSummary => _aggregatedSummary;
  String get searchQuery => _searchQuery;
  String get selectedTag => _selectedTag;

  Future<void> fetchReports(String patientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reports = await _firestoreService.getPatientReports(patientId);
      _aggregatedSummary = await _apiService.getAggregatedSummary(_reports);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReportModel> uploadAndProcessReport({
    required String patientId,
    required String title,
    required String fileUrl,
    required String fileType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final processResult = await _apiService.processReport(fileUrl, title, patientId);

      final newReport = ReportModel(
        id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        title: title,
        fileUrl: fileUrl,
        fileType: fileType,
        uploadedAt: DateTime.now(),
        ocrText: processResult['ocrText'] ?? '',
        aiSummary: processResult['aiSummary'] ?? '',
        aiSuggestions: List<String>.from(processResult['aiSuggestions'] ?? []),
        tags: List<String>.from(processResult['tags'] ?? ['General']),
      );

      await _firestoreService.saveReport(newReport);
      _reports.insert(0, newReport);
      _aggregatedSummary = await _apiService.getAggregatedSummary(_reports);
      return newReport;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedTag(String tag) {
    _selectedTag = tag;
    notifyListeners();
  }
}
