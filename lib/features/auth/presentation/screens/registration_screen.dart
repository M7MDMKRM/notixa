import 'package:flutter/material.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../../../core/design_system/notixa_app_bar.dart';
import '../../../../core/design_system/notixa_button.dart';
import '../../../../core/design_system/notixa_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;

  const RegistrationScreen({super.key, required this.onRegisterSuccess});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onRegisterSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NotixaAppBar(title: 'Create Notixa Account'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join Notixa 🚀',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Start recording smart voice notes and tracking expenses easily.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 28),

              NotixaTextField(
                controller: _nameController,
                hintText: 'Your full name',
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline, color: NotixaPalette.primary),
              ),
              const SizedBox(height: 18),

              NotixaTextField(
                controller: _emailController,
                hintText: 'name@example.com',
                labelText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: NotixaPalette.primary),
              ),
              const SizedBox(height: 18),

              NotixaTextField(
                controller: _passwordController,
                hintText: 'At least 8 characters',
                labelText: 'Password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: NotixaPalette.primary),
              ),
              const SizedBox(height: 28),

              NotixaButton(
                label: 'Create Account',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
