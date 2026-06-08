import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/screens/onboarding/phone_entry_screen.dart';
import 'package:gajacash_sample/widgets/primary_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';




class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_SlideData> _slides = const [
    _SlideData(
      title: 'Over 8,000 Locations\nIslandwide',
      description: 'Your cash. Anytime, anywhere.',
      imageUrl:
          'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/c8fb5fa9-3c3a-454c-86ff-24557ee474e9_800w.png',
    ),
    _SlideData(
      title: 'Skip the ATM Queues',
      description: 'Quick cash access for real-life situations.',
      imageUrl:
          'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/5c9c43a1-2e42-401c-92df-6429bef221ab_800w.png',
    ),
    _SlideData(
      title: 'Cash is King',
      description: 'Keep your business, your business\nwith GajaCash.',
      imageUrl:
          'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/f5b4b9b6-fc99-41c2-b07a-7412e30826e0_800w.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Restore dark icons for light background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onLoginRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PhoneEntryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.phoneFrameBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Carousel (no top logo — illustration fills from top) ─────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) =>
                    _SlideWidget(slide: _slides[index]),
              ),
            ),

            // ── Page Dots ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => _Dot(isActive: i == _currentPage),
                ),
              ),
            ),

            // ── Login / Register Button (gold/yellow) ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
              child: PrimaryButton(
                text: 'Login / Register',
                onPressed: _onLoginRegister,
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
          // ── Illustration (full bleed, no card box) ───────────────────
          Expanded(
            child: Image.network(
              slide.imageUrl,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stack) => Center(
                child: Icon(
                  LucideIcons.imageOff,
                  color: AppColors.primaryGreen.withValues(alpha: 0.4),
                  size: 64,
                ),
              ),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
          ),

          const SizedBox(height: 28),

          // ── Title ─────────────────────────────────────────────────────
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // ── Description ───────────────────────────────────────────────
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.55,
              color: AppColors.primaryText.withValues(alpha: 0.55),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: isActive ? 28 : 10,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGreen
            : AppColors.clayShadowColor,
        borderRadius: BorderRadius.circular(5),
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
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String imageUrl;
}
