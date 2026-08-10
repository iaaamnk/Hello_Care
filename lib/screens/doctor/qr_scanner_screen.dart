import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final ApiService _apiService = ApiService();
  bool _isResolving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Patient QR Code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                'Instant Medical History Access',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Align the patient\'s shared QR code within the frame to resolve short-lived encrypted report download URLs.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(240),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white, size: 64),
                          SizedBox(height: 12),
                          Text('Camera Scanner Active', style: TextStyle(color: Colors.white)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isResolving)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _simulateScanSuccess,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Simulate Scan Patient QR Token'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateScanSuccess() async {
    setState(() => _isResolving = true);
    final mockToken = 'HC-SHARE-patient_456-1700000';
    final resolvedData = await _apiService.resolveQrToken(mockToken);

    if (mounted) {
      setState(() => _isResolving = false);
      context.push('/view-patient-reports', extra: resolvedData);
    }
  }
}
