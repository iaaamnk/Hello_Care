import 'package:flutter/material.dart';

class ViewPatientReportsScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const ViewPatientReportsScreen({super.key, required this.patientData});

  @override
  Widget build(BuildContext context) {
    final patientName = patientData['patientName'] ?? 'Sarah Connor';
    final allergies = List<String>.from(patientData['allergies'] ?? []);
    final conditions = List<String>.from(patientData['conditions'] ?? []);
    final reports = List<Map<String, dynamic>>.from(patientData['grantedReports'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shared History: $patientName'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFFF0FDFA),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Verified QR Share Grant',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Patient: $patientName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('Allergies: ${allergies.join(", ")}', style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 4),
                    Text('Conditions: ${conditions.join(", ")}', style: const TextStyle(color: Color(0xFF334155))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Granted Medical Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...reports.map((rep) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            rep['fileType'] == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rep['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('AI Summary: ${rep['aiSummary']}', style: const TextStyle(height: 1.4)),
                      const Divider(height: 20),
                      Text('Raw OCR Snippet: ${rep['ocrText']}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
