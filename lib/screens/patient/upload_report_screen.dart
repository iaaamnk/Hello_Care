import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/report_provider.dart';
import '../../providers/user_provider.dart';

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({super.key});

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedFileType = 'pdf';
  bool _isUploading = false;
  String? _selectedFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Medical Report')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Medical Report',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Upload your lab results or diagnostic scan to generate AI plain-language summaries.'),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Report Title',
                  prefixIcon: Icon(Icons.title_rounded),
                  hintText: 'e.g. Comprehensive Blood Test',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Report Content / Lab Metrics (Optional)',
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'Paste or type raw report text, e.g.:\nHemoglobin A1c: 5.8%\nTotal Cholesterol: 190 mg/dL\nVitamin D: 22 ng/mL',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Document Type:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.picture_as_pdf, size: 18), SizedBox(width: 6), Text('PDF Document')],
                      ),
                      selected: _selectedFileType == 'pdf',
                      selectedColor: Theme.of(context).primaryColor.withAlpha(30),
                      onSelected: (_) => setState(() => _selectedFileType = 'pdf'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.image, size: 18), SizedBox(width: 6), Text('Image Scan')],
                      ),
                      selected: _selectedFileType == 'image',
                      selectedColor: Theme.of(context).primaryColor.withAlpha(30),
                      onSelected: (_) => setState(() => _selectedFileType = 'image'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 36, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFileName ?? 'Tap to select or capture file',
                        style: TextStyle(
                          color: _selectedFileName != null ? Colors.black : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Supports PDF, PNG, JPG up to 10MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_isUploading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Uploading report & running Gemini 3.6 AI transcriber...'),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _handleUpload,
                  child: const Text('Upload & Transcribe with Gemini AI'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _selectedFileType == 'pdf' ? ['pdf', 'txt'] : ['png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result != null && result.files.single.name.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        _selectedFileName = file.name;
        if (file.bytes != null && _contentController.text.isEmpty) {
          try {
            final text = String.fromCharCodes(file.bytes!);
            if (text.trim().isNotEmpty && text.contains(RegExp(r'[a-zA-Z0-9]'))) {
              _contentController.text = text;
            }
          } catch (_) {}
        }
      });
    }
  }

  void _handleUpload() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a report title')),
      );
      return;
    }

    setState(() => _isUploading = true);
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    final newReport = await reportProvider.uploadAndProcessReport(
      patientId: user?.uid ?? 'patient_456',
      title: _titleController.text,
      fileUrl: 'https://example.com/reports/${_selectedFileName ?? 'doc.pdf'}',
      fileType: _selectedFileType,
      fileContent: _contentController.text.trim().isNotEmpty ? _contentController.text.trim() : null,
    );

    if (mounted) {
      setState(() => _isUploading = false);
      context.replace('/report-detail', extra: newReport);
    }
  }
}
