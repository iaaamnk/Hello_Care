import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Profile & Clinic Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                    child: Icon(Icons.medical_services, size: 44, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'Dr. Evelyn Harper',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(user?.specialization ?? 'Cardiologist',
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _infoTile(Icons.verified_outlined, 'License Number', user?.licenseNumber ?? 'MD-892401'),
                    const Divider(height: 20),
                    _infoTile(Icons.local_hospital_outlined, 'Clinic Name', user?.clinicName ?? 'St. Jude Heart Clinic'),
                    const Divider(height: 20),
                    _infoTile(Icons.attach_money, 'Consultation Fee', '\$${(user?.consultationFee ?? 120.0).toStringAsFixed(2)}'),
                    const Divider(height: 20),
                    _infoTile(Icons.phone_outlined, 'Contact Phone', user?.phone ?? '+1 (555) 019-2831'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
                await userProvider.logout();
                if (context.mounted) {
                  context.go('/role-selection');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out Doctor Portal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0F766E)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        )
      ],
    );
  }
}
