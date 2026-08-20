import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/doctor_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/payment_mock_dialog.dart';

class BookAppointmentScreen extends StatefulWidget {
  final DoctorModel doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  String? _selectedDay;
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    if (widget.doctor.weeklyAvailability.isNotEmpty) {
      _selectedDay = widget.doctor.weeklyAvailability.keys.first;
      if (widget.doctor.weeklyAvailability[_selectedDay]!.isNotEmpty) {
        _selectedTimeSlot = widget.doctor.weeklyAvailability[_selectedDay]!.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor;

    return Scaffold(
      appBar: AppBar(title: Text('Book Consultation: ${doc.name}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                        child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(doc.specialization, style: TextStyle(color: Theme.of(context).primaryColor)),
                            Text(doc.clinicName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Select Available Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: doc.weeklyAvailability.keys.map((day) {
                  final isSelected = _selectedDay == day;
                  return ChoiceChip(
                    label: Text(day),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor.withAlpha(30),
                    onSelected: (_) {
                      setState(() {
                        _selectedDay = day;
                        _selectedTimeSlot = doc.weeklyAvailability[day]?.first;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Select Time Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              if (_selectedDay != null && doc.weeklyAvailability[_selectedDay] != null)
                Wrap(
                  spacing: 8,
                  children: doc.weeklyAvailability[_selectedDay]!.map((slot) {
                    final isSelected = _selectedTimeSlot == slot;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: isSelected,
                      selectedColor: Theme.of(context).primaryColor.withAlpha(30),
                      onSelected: (_) => setState(() => _selectedTimeSlot = slot),
                    );
                  }).toList(),
                )
              else
                const Text('No slots available for selected day.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_selectedDay != null && _selectedTimeSlot != null) ? _proceedToPayment : null,
                child: Text('Proceed to Checkout (\$${doc.consultationFee.toStringAsFixed(0)})'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _proceedToPayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => PaymentMockDialog(
        doctorName: widget.doctor.name,
        doctorSpecialization: widget.doctor.specialization,
        amount: widget.doctor.consultationFee,
        appointmentTime: DateTime.now(),
      ),
    );

    if (confirmed == true && mounted) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

      await appointmentProvider.bookAppointment(
        patientId: user?.uid ?? 'patient_456',
        patientName: user?.name ?? 'Sarah Connor',
        doctor: widget.doctor,
        scheduledAt: DateTime.now().add(const Duration(days: 2)),
        notes: 'Requested consultation for $_selectedDay at $_selectedTimeSlot',
      );

      if (mounted) {
        context.go('/patient');
      }
    }
  }
}
