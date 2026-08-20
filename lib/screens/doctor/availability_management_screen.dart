import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/user_provider.dart';

class AvailabilityManagementScreen extends StatefulWidget {
  const AvailabilityManagementScreen({super.key});

  @override
  State<AvailabilityManagementScreen> createState() => _AvailabilityManagementScreenState();
}

class _AvailabilityManagementScreenState extends State<AvailabilityManagementScreen> {
  final Map<String, List<String>> _schedule = {
    'Monday': ['09:00 AM', '10:30 AM', '02:00 PM', '04:00 PM'],
    'Tuesday': ['09:00 AM', '11:00 AM'],
    'Wednesday': ['10:00 AM', '11:30 AM', '03:00 PM'],
    'Thursday': ['01:30 PM', '04:00 PM'],
    'Friday': ['09:00 AM', '01:00 PM', '03:30 PM'],
  };

  void _syncScheduleWithProvider() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final doctorId = user?.uid ?? 'doc_1';
    Provider.of<AppointmentProvider>(context, listen: false).updateSchedule(doctorId, _schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Weekly Schedule')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _schedule.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () => _addSlot(entry.key),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: entry.value.map((slot) {
                        return Chip(
                          label: Text(slot),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () {
                            setState(() => entry.value.remove(slot));
                            _syncScheduleWithProvider();
                          },
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _addSlot(String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && mounted) {
      final formattedTime = picked.format(context);
      setState(() {
        if (!(_schedule[day]?.contains(formattedTime) ?? false)) {
          _schedule[day]?.add(formattedTime);
        }
      });
      _syncScheduleWithProvider();
    }
  }
}
