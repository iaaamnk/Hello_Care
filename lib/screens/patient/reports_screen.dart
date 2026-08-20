import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/report_provider.dart';

import '../../providers/user_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshReports();
    });
  }

  Future<void> _refreshReports() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    await Provider.of<ReportProvider>(context, listen: false).fetchReports(user?.uid ?? 'patient_456');
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    final tags = ['All', 'Blood Test', 'Metabolic', 'Lipids', 'Cardiology', 'Radiology'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReports,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: () => context.push('/upload-report'),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReports,
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search reports by title or tag...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => reportProvider.setSearchQuery(val),
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tags.length,
              itemBuilder: (context, i) {
                final tag = tags[i];
                final isSelected = reportProvider.selectedTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor.withAlpha(40),
                    checkmarkColor: Theme.of(context).primaryColor,
                    onSelected: (_) => reportProvider.setSelectedTag(tag),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: reportProvider.reports.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insert_drive_file_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No matching medical reports found.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reportProvider.reports.length,
                    itemBuilder: (context, index) {
                      final rep = reportProvider.reports[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              rep.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Text(rep.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(rep.aiSummary, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                children: rep.tags
                                    .map((t) => Chip(
                                          label: Text(t, style: const TextStyle(fontSize: 10)),
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              )
                            ],
                          ),
                          onTap: () => context.push('/report-detail', extra: rep),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/upload-report'),
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Upload Report'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
