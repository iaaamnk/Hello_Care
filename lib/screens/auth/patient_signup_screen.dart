import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _emergencyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Patient Account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Enter your details & medical profile for personalized AI care.'),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 20),
              const Text('Medical History Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Known Allergies (comma separated)',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                  hintText: 'e.g. Penicillin, Peanuts',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conditionsController,
                decoration: const InputDecoration(
                  labelText: 'Existing Conditions (comma separated)',
                  prefixIcon: Icon(Icons.medical_information_outlined),
                  hintText: 'e.g. Asthma, High Blood Pressure',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emergencyController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Phone',
                  prefixIcon: Icon(Icons.contact_phone_outlined),
                ),
              ),
              const SizedBox(height: 24),
              if (userProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _handleSignup,
                  child: const Text('Complete Registration'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignup() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final allergies = _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final conditions = _conditionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    await userProvider.signupPatient(
      name: _nameController.text.isNotEmpty ? _nameController.text : 'Patient User',
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      dob: DateTime(1995, 6, 15),
      allergies: allergies,
      conditions: conditions,
      emergencyContact: _emergencyController.text,
    );

    if (mounted) {
      context.go('/patient');
    }
  }
}
