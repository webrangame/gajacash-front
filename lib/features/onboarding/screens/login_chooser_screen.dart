import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/core/widgets/custom_back_button.dart';
import 'package:gajacash_sample/core/widgets/speech_bubble.dart';
import 'package:gajacash_sample/features/onboarding/screens/phone_entry_screen.dart';

class LoginChooserScreen extends StatelessWidget {
  const LoginChooserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.phoneFrameBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  CustomBackButton(
                    onTap: () => Get.back(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Mascot and Bubble Area
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Speech Bubble
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: const SpeechBubble(
                              text: 'This is NOT a real screen users will see. This is for demo purposes only! Choose a login flow to test.',
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Mascot Image
                          Flexible(
                            child: Transform.translate(
                              offset: const Offset(0, 10),
                              child: Transform.scale(
                                scale: 0.9,
                                child: Image.asset(
                                  'assets/images/ele_phone.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form Section (Buttons)
                    Container(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LoginFlowButton(
                            icon: LucideIcons.userPlus,
                            text: 'Phone Number → Register',
                            onTap: () {
                              Get.to(() => const PhoneEntryScreen());
                            },
                          ),
                          const SizedBox(height: 16),
                          _LoginFlowButton(
                            icon: LucideIcons.lock,
                            text: 'Phone Number → Password',
                            onTap: () {
                              // TODO: Navigate to Phone -> Password flow
                            },
                          ),
                          const SizedBox(height: 16),
                          _LoginFlowButton(
                            icon: LucideIcons.fingerprint,
                            text: 'PIN / Biometric Login',
                            onTap: () {
                              // TODO: Navigate to PIN/Biometric flow
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _LoginFlowButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _LoginFlowButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  State<_LoginFlowButton> createState() => _LoginFlowButtonState();
}

class _LoginFlowButtonState extends State<_LoginFlowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.phoneFrameBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _isPressed
                ? const [
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
                  ]
                : const [
                    BoxShadow(
                      color: AppColors.clayShadowColor,
                      offset: Offset(6, 6),
                      blurRadius: 12,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-6, -6),
                      blurRadius: 12,
                    ),
                  ],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: AppColors.primaryGreen,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
