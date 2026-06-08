import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';

import 'package:gajacash_sample/screens/onboarding/verification_code_screen.dart';
import 'package:gajacash_sample/widgets/primary_button.dart';
import 'package:gajacash_sample/widgets/safe_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isConfirmationVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      _buildIconButton(LucideIcons.arrowLeft, () => Navigator.of(context).pop()),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mascot and Bubble
                            _buildMascotSection(),

                            const SizedBox(height: 24),

                            // Form Section
                            _buildFormSection(),

                            const SizedBox(height: 48),

                            PrimaryButton(
                              text: "Continue",
                              onPressed: () {
                                final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
                                if (phone.length >= 7) {
                                  setState(() {
                                    _isConfirmationVisible = true;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please enter a valid phone number (at least 7 digits)")),
                                  );
                                }
                              },
                            ),
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Backdrop and Confirmation Sheet
            if (_isConfirmationVisible) _buildBackdrop(),
            _buildConfirmationSheet(),
          ],
        ),
      ),
    );
  }



  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.phoneFrameBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.clayShadowColor.withValues(alpha: 0.8),
              offset: const Offset(6, 6),
              blurRadius: 12,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-6, -6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 28),
      ),
    );
  }

  Widget _buildMascotSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Speech Bubble
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.clayShadowColor,
                offset: Offset(8, 8),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-8, -8),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Text(
                "If you already have an account, we’ll prompt you to log in. If not, we’ll guide you through a quick registration.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Mascot
        SafeNetworkImage(
          url: 'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/3949ca8a-5a94-4a43-975c-ee58d9336fe5_3840w.png',
          width: 200,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mobile number",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Enter your mobile number",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryGreen.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        // Input Field
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.phoneFrameBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.clayShadowColor,
                offset: Offset(4, 4),
                blurRadius: 8,
              ), // Inset shadow simulation
              BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              // Country Code
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.1))),
                ),
                child: Row(
                  children: [
                    Image.network(
                      'https://flagcdn.com/w40/lk.png',
                      width: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.flag, size: 24, color: AppColors.primaryGreen),
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : const Icon(Icons.flag, size: 24, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "+94",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.primaryGreen),
                  ],
                ),
              ),
              // TextField
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                  decoration: const InputDecoration(
                    hintText: "777-XXX-XXX",
                    hintStyle: TextStyle(color: Colors.black26),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackdrop() {
    return GestureDetector(
      onTap: () => setState(() => _isConfirmationVisible = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isConfirmationVisible ? 1.0 : 0.0,
        child: Container(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _buildConfirmationSheet() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: _isConfirmationVisible ? 0 : -400,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.phoneFrameBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text(
              "Is this number correct?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We'll send you a confirmation code there",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("+94 ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(_phoneController.text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ],
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: "Confirm",
              onPressed: () async {
                var cleanPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
                if (cleanPhone.startsWith('0')) {
                  cleanPhone = cleanPhone.substring(1);
                }
                if (!cleanPhone.startsWith('94')) {
                  cleanPhone = '94$cleanPhone';
                }
                final phone = cleanPhone;
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                );
                
                try {
                  final response = await ApiService().sendOtp(phone);
                  if (mounted) {
                    Navigator.pop(context); // Pop loader
                    if (response.statusCode == 200) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerificationCodeScreen(phoneNumber: phone),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to send OTP code")),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context); // Pop loader
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to send SMS: ${e.toString()}")),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _isConfirmationVisible = false),
              child: const Text("Go back", style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
