import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/module_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/voice_assistant_dialog.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final uid = user?.uid ?? 'patient_456';
      Provider.of<ReportProvider>(context, listen: false).fetchReports(uid);
      Provider.of<AppointmentProvider>(context, listen: false).fetchAppointments(uid, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final reportProvider = Provider.of<ReportProvider>(context);
    final moduleProvider = Provider.of<ModuleProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
              child: Icon(Icons.person, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name ?? 'Alex'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Patient Dashboard',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over, color: Colors.blueAccent),
            tooltip: 'Voice Assistant',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const VoiceAssistantDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_rounded),
            tooltip: 'Share QR',
            onPressed: () => context.push('/qr-share'),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Customize Modules',
            onPressed: () => _showModuleConfigDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Persistent Health Status Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      const Color(0xFF14B8A6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Health Status: Active Sync',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reportProvider.reports.length} reports logged • ${appointmentProvider.appointments.length} upcoming consultation',
                            style: TextStyle(color: Colors.white.withAlpha(230), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard Modules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/upload-report'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Report'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Dynamic reorderable modular grid
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  moduleProvider.reorderModules(oldIndex, newIndex);
                },
                children: moduleProvider.modules.map((m) {
                  return Container(
                    key: ValueKey(m.moduleId),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildModuleWidget(context, m.moduleId),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleWidget(BuildContext context, String moduleId) {
    final reportProvider = Provider.of<ReportProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    switch (moduleId) {
      case 'reports':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.folder_outlined, color: Color(0xFF0F766E)),
                        SizedBox(width: 8),
                        Text('Recent Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.push('/upload-report'),
                      child: const Text('Upload'),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                if (reportProvider.reports.isEmpty)
                  const Text('No reports uploaded yet.', style: TextStyle(color: Colors.grey))
                else
                  Column(
                    children: reportProvider.reports.take(2).map((rep) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            rep.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text(rep.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(rep.aiSummary, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () => context.push('/report-detail', extra: rep),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      case 'ai_summary':
        return Card(
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
                    const Text('AI Aggregated Health Insight',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F766E))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reportProvider.aggregatedSummary.isNotEmpty
                      ? reportProvider.aggregatedSummary
                      : 'AI is aggregating your medical insights...',
                  style: const TextStyle(height: 1.4, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context.push('/ai-summary-full'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Full Analysis'),
                  ),
                )
              ],
            ),
          ),
        );
      case 'appointments':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.event_outlined, color: Color(0xFF0F766E)),
                    SizedBox(width: 8),
                    Text('Upcoming Consultation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                if (appointmentProvider.appointments.isEmpty)
                  const Text('No upcoming appointments.', style: TextStyle(color: Colors.grey))
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withAlpha(20),
                          child: Icon(Icons.medical_services, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointmentProvider.appointments.first.doctorName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                appointmentProvider.appointments.first.doctorSpecialization,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            appointmentProvider.appointments.first.status.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        )
                      ],
                    ),
                  )
              ],
            ),
          ),
        );
      case 'doctors':
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person_search_outlined, color: Color(0xFF0F766E), size: 30),
            title: const Text('Find & Book Doctors', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Search specialists, check schedules & book online'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/doctor-search'),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showModuleConfigDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<ModuleProvider>(
          builder: (context, moduleProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customize Home Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Toggle modules to show or hide them on your homepage.'),
                  const SizedBox(height: 16),
                  ...moduleProvider.allModules.map((m) {
                    return CheckboxListTile(
                      title: Text(m.label),
                      value: m.pinned,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (_) => moduleProvider.togglePin(m.moduleId),
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
