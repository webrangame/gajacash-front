import 'package:gajacash_sample/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/screens/onboarding/onboarding_carousel_screen.dart';
import 'package:gajacash_sample/widgets/language_card.dart';
import 'package:gajacash_sample/widgets/primary_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  String selectedLanguage = "Sinhala";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Spacer
                        const SizedBox(height: 16),
                        
                        // Mascot and Bubble
                        SizedBox(
                          height: 300,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              // Speech Bubble
                              Positioned(
                                left: 0,
                                top: 40,
                                width: 220,
                                child: _buildSpeechBubble(),
                              ),
                              // Mascot
                              Positioned(
                                bottom: 0,
                                right: -10,
                                child: SafeNetworkImage(url:
                                  'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/46988f10-aac0-46de-95d1-0dea926ebd5e_800w.png?w=800&q=80',
                                  width: 180,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Language Grid
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            LanguageCard(
                              title: "English",
                              icon: const Icon(LucideIcons.languages, size: 32, color: AppColors.primaryGreen),
                              isSelected: selectedLanguage == "English",
                              onTap: () => setState(() => selectedLanguage = "English"),
                            ),
                            LanguageCard(
                              title: "Sinhala",
                              icon: const Text("සි", style: TextStyle(fontSize: 30, color: Colors.white)),
                              isSelected: selectedLanguage == "Sinhala",
                              onTap: () => setState(() => selectedLanguage = "Sinhala"),
                            ),
                            LanguageCard(
                              title: "Tamil",
                              icon: const Text("த", style: TextStyle(fontSize: 30)),
                              isSelected: selectedLanguage == "Tamil",
                              onTap: () => setState(() => selectedLanguage = "Tamil"),
                            ),
                            LanguageCard(
                              title: "Hindi",
                              icon: const Text("अ", style: TextStyle(fontSize: 30)),
                              isSelected: selectedLanguage == "Hindi",
                              onTap: () => setState(() => selectedLanguage = "Hindi"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Next Button
                        PrimaryButton(
                          text: "Save Changes",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OnboardingCarouselScreen()),
                            );
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
      ),
    );
  }



  Widget _buildSpeechBubble() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
          child: const Text(
            "Hi! I am Gaja. Please select your preferred language",
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
        // Tail
        Positioned(
          right: -10,
          top: 0,
          child: CustomPaint(
            size: const Size(20, 20),
            painter: SpeechBubbleTailPainter(),
          ),
        ),
      ],
    );
  }
}

class SpeechBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
