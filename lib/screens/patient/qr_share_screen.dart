import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';

import '../../providers/report_provider.dart';

class QrShareScreen extends StatefulWidget {
  const QrShareScreen({super.key});

  @override
  State<QrShareScreen> createState() => _QrShareScreenState();
}

class _QrShareScreenState extends State<QrShareScreen> {
  final ApiService _apiService = ApiService();
  String? _qrToken;
  DateTime? _expiresAt;
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    _generateToken();
  }

  void _generateToken() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final reportsData = reportProvider.reports.map((r) => r.toJson()).toList();

    final res = await _apiService.generateQrToken(
      user?.uid ?? 'patient_456',
      reportProvider.reports.map((r) => r.id).toList(),
      15,
      patientName: user?.name ?? 'Sarah Connor',
      allergies: user?.allergies ?? ['Penicillin', 'Peanuts'],
      conditions: user?.conditions ?? ['Mild Asthma', 'Vitamin D Deficiency'],
      reports: reportsData.isNotEmpty ? reportsData : null,
    );
    if (mounted) {
      setState(() {
        _qrToken = res['token'];
        _expiresAt = DateTime.parse(res['expiresAt']);
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Medical History')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Doctor QR Share Grant',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Allow doctors to scan this code for instant, scoped access to your medical history without manual forms.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              if (_isGenerating)
                const CircularProgressIndicator()
              else if (_qrToken != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: QrImageView(
                    data: _qrToken!,
                    version: QrVersions.auto,
                    size: 220.0,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Token expires at: ${_expiresAt?.toLocal().toString().split('.')[0]}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ],
                  ),
                )
              ],
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _generateToken,
                icon: const Icon(Icons.refresh),
                label: const Text('Generate New Scoped QR Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
