import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  State<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseController = TextEditingController();
  final _clinicController = TextEditingController();
  final _feeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Doctor Account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Register your medical credential profile & clinic information.'),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Doctor Full Name', prefixIcon: Icon(Icons.person_outline)),
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
                decoration: const InputDecoration(labelText: 'Contact Phone', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 20),
              const Text('Professional Qualifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Medical Specialization',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                  hintText: 'e.g. Cardiologist, Neurologist',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: 'Medical License Number',
                  prefixIcon: Icon(Icons.verified_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _clinicController,
                decoration: const InputDecoration(
                  labelText: 'Clinic / Hospital Name',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _feeController,
                decoration: const InputDecoration(
                  labelText: 'Consultation Fee (\$) ',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              if (userProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _handleSignup,
                  child: const Text('Register Doctor Account'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignup() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final fee = double.tryParse(_feeController.text) ?? 100.0;

    await userProvider.signupDoctor(
      name: _nameController.text.isNotEmpty ? _nameController.text : 'Dr. Doctor',
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      specialization: _specializationController.text.isNotEmpty ? _specializationController.text : 'General Physician',
      licenseNumber: _licenseController.text.isNotEmpty ? _licenseController.text : 'MD-9999',
      clinicName: _clinicController.text.isNotEmpty ? _clinicController.text : 'HelloCare Clinic',
      consultationFee: fee,
    );

    if (mounted) {
      context.go('/doctor');
    }
  }
}
