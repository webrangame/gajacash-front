import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/screens/home_screen.dart';
import 'package:gajacash_sample/core/widgets/custom_back_button.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
import 'package:gajacash_sample/core/widgets/speech_bubble.dart';
import 'package:gajacash_sample/core/widgets/custom_text_field.dart';
import 'package:gajacash_sample/features/onboarding/widgets/otp_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  bool _isOtpSheetVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showOtpSheet() {
    setState(() {
      _isOtpSheetVisible = true;
    });
  }

  void _hideOtpSheet() {
    setState(() {
      _isOtpSheetVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.phoneFrameBg,
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
                      const CustomBackButton(),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 12.0,),
                            // Mascot and Bubble Area
                            _buildMascotArea(),
                            
                            const SizedBox(height: 24),
                            
                            // Form Section
                            _buildFormSection(),
                            
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Login Button fixed at the bottom
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: PrimaryButton(
                    text: "Login",
                    onPressed: () {
                      _showOtpSheet();
                    },
                  ),
                ),
              ],
            ),
            
            // OTP Sheet overlay
            if (_isOtpSheetVisible)
              GestureDetector(
                onTap: _hideOtpSheet,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
              ),
              
            OtpSheet(
              isVisible: _isOtpSheetVisible,
              onClose: _hideOtpSheet,
              onContinue: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotArea() {
    return Column(
      children: [
        // Speech Bubble
        const SpeechBubble(
          texts: [
            "Welcome back! Please enter\nyour details to log into\nyour account.",
            "Make sure to keep your\npassword secure and do not\nshare it."
          ],
        ),
        const SizedBox(height: 8),
        // Mascot
        Image.asset(
          'assets/images/ele_blind.png',
          width: 180,
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
          "Login",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Enter your credentials to continue",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryGreen.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),
        
        // Username Input
        CustomTextField(
          controller: _usernameController,
          hint: "Gajatag / Phone Number",
          icon: LucideIcons.user,
        ),
        const SizedBox(height: 16),
        
        // Password Input
        CustomTextField(
          controller: _passwordController,
          hint: "Password",
          icon: LucideIcons.lock,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        
        // Remember me & Forgot password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.phoneFrameBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.clayShadowColor,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(-2, -2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: _rememberMe
                        ? const Icon(LucideIcons.check, size: 14, color: AppColors.primaryGreen)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Remember me",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "Forgot password?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

}
