import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/widgets/primary_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SimpleRegistrationScreen extends StatefulWidget {
  final String phoneNumber;
  const SimpleRegistrationScreen({super.key, required this.phoneNumber});

  @override
  State<SimpleRegistrationScreen> createState() => _SimpleRegistrationScreenState();
}

class _SimpleRegistrationScreenState extends State<SimpleRegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
              const SizedBox(height: 8),
              Text(
                "Registering for ${widget.phoneNumber}",
                style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 32),
              _buildInput("First Name", _firstNameController, LucideIcons.user),
              const SizedBox(height: 16),
              _buildInput("Last Name", _lastNameController, LucideIcons.user),
              const SizedBox(height: 16),
              _buildInput("Password", _passwordController, LucideIcons.lock, isPassword: true),
              const SizedBox(height: 48),
              PrimaryButton(
                text: "Register",
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    await ApiService().register(
                      phone: widget.phoneNumber,
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      password: _passwordController.text,
                    );

                    if (mounted) {
                      navigator.pop(); // Pop loader
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Registration successful!")),
                      );
                      navigator.pop(); // Go back to login
                    }
                  } catch (e) {
                    if (mounted) {
                      navigator.pop(); // Pop loader
                      messenger.showSnackBar(
                        SnackBar(content: Text("Registration failed: ${e.toString()}")),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.phoneFrameBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: AppColors.primaryGreen.withValues(alpha: 0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
