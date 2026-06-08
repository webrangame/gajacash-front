import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/screens/phone_entry_screen.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
import 'package:gajacash_sample/features/onboarding/onboarding_carousel_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingCarouselScreen extends StatelessWidget {
  const OnboardingCarouselScreen({super.key});

  static const List<_SlideData> _slides = [
    _SlideData(
      title: 'Over 8,000 Locations\nIslandwide',
      description: 'Your cash. Anytime, anywhere.',
      imagePath: 'assets/images/onboarding1.png',
    ),
    _SlideData(
      title: 'Skip the ATM Queues',
      description: 'Quick cash access for real-life situations.',
      imagePath: 'assets/images/onboarding2.png',
    ),
    _SlideData(
      title: 'Cash is King',
      description: 'Keep your business, your business\nwith GajaCash.',
      imagePath: 'assets/images/onboarding3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final controller = Get.put(OnboardingCarouselController());

    // System UI Overlay brightness adjustments
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // E8F4ED phone frame background
      body: SafeArea(
        child: Column(
          children: [
            // ── Status Bar Area ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 32, right: 32, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 28,
                        height: 16,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Header Controls (Neumorphic Back Button) ─────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: const [
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
                      child: const Center(
                        child: Icon(
                          LucideIcons.arrowLeft,
                          color: AppColors.primaryGreen,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Carousel ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) => _SlideWidget(slide: _slides[index]),
              ),
            ),

            // ── Page Dots (Neumorphic Morphing with Obx) ─────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (i) => _Dot(isActive: i == controller.currentPage),
                  ),
                ),
              ),
            ),

            // ── Login / Register Button (gold/yellow) ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: PrimaryButton(
                text: 'Login / Register',
                onPressed: () => Get.to(() => const PhoneEntryScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Individual carousel slide
// ────────────────────────────────────────────────────────────────────────────
class _SlideWidget extends StatelessWidget {
  const _SlideWidget({required this.slide});

  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Illustration (full bleed, loaded from local assets) ──────────
          Expanded(
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  slide.imagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Title ─────────────────────────────────────────────────────
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineMedium?.copyWith(
              color: context.colorScheme.primary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // ── Description ───────────────────────────────────────────────
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.55,
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Animated page indicator dot
// ────────────────────────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  const _Dot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: const ElasticInCurve(0.9), // Smooth morphing feel
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 12,
      width: isActive ? 32 : 12,
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary : AppColors.clayShadowColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 1,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Data model for a slide
// ────────────────────────────────────────────────────────────────────────────
class _SlideData {
  const _SlideData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;
}
