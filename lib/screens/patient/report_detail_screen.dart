import 'package:flutter/material.dart';
import '../../models/report_model.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _showOriginalText = false;

  @override
  Widget build(BuildContext context) {
    final rep = widget.report;

    return Scaffold(
      appBar: AppBar(
        title: Text(rep.title),
        actions: [
          IconButton(
            icon: Icon(_showOriginalText ? Icons.auto_awesome : Icons.article_outlined),
            tooltip: _showOriginalText ? 'Show AI Summary' : 'View Raw OCR',
            onPressed: () => setState(() => _showOriginalText = !_showOriginalText),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Mock Container
            Container(
              height: 220,
              color: Colors.grey.shade200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    rep.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                    size: 56,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Previewing ${rep.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Uploaded on ${rep.uploadedAt.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showOriginalText ? 'Extracted OCR Text' : 'AI Plain-Language Summary',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () => setState(() => _showOriginalText = !_showOriginalText),
                        icon: Icon(_showOriginalText ? Icons.auto_awesome : Icons.description_outlined, size: 16),
                        label: Text(_showOriginalText ? 'View AI Summary' : 'View Raw Text'),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_showOriginalText)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        rep.ocrText.isNotEmpty ? rep.ocrText : 'No raw text extracted.',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5),
                      ),
                    )
                  else ...[
                    Card(
                      color: const Color(0xFFF0FDFA),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                const Text(
                                  'AI Summary',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              rep.aiSummary,
                              style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'AI Recommendations & Next Steps',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...rep.aiSuggestions.map(
                      (sug) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFF14B8A6), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(sug, style: const TextStyle(fontSize: 14, height: 1.4)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
