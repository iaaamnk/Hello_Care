import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final ApiService _apiService = ApiService();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final TextEditingController _tokenInputController = TextEditingController();
  bool _isResolving = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _tokenInputController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned || _isResolving) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        _hasScanned = true;
        _resolveToken(barcode.rawValue!);
        break;
      }
    }
  }

  void _resolveToken(String rawToken) async {
    setState(() => _isResolving = true);
    final resolvedData = await _apiService.resolveQrToken(rawToken);

    if (mounted) {
      setState(() => _isResolving = false);
      context.push('/view-patient-reports', extra: resolvedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Patient QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                'Instant Medical History Access',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Point device camera at patient\'s QR code to scan live, or paste token below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                        errorBuilder: (context, error, child) {
                          return Container(
                            color: Colors.black,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videocam_off, color: Colors.redAccent, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'Camera Error: ${error.errorCode.name}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Please allow camera permissions or enter token below.',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _tokenInputController,
                decoration: const InputDecoration(
                  labelText: 'Enter or Paste QR Code / Share Token',
                  hintText: 'e.g. HC-SHARE-patient_456... or {"patientName": ...}',
                  prefixIcon: Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_isResolving)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: () {
                    final text = _tokenInputController.text.trim();
                    if (text.isNotEmpty) {
                      _resolveToken(text);
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Resolve Token / Code'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
