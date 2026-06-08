import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gajacash_sample/features/onboarding/screens/onboarding_carousel_screen.dart';

// Official GajaCash brand colors for splash
const _kSplashGreenDark = Color(0xFF004D25);
const _kSplashGreenMid = Color(0xFF006633);
const _kSplashGreenLight = Color(0xFF7DC9A0);
const _kGoldYellow = Color(0xFFF5C142);

// Elephant mascot image (same used across the app)
const _kMascotUrl =
    'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/46988f10-aac0-46de-95d1-0dea926ebd5e_3840w.png';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideDown;

  @override
  void initState() {
    super.initState();

    // Override status bar to white icons on dark background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideDown = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();

    // Navigate to Onboarding Carousel after 2.8 seconds
    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        // Restore normal status bar style
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
        Get.off(
          () => const OnboardingCarouselScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _kSplashGreenDark,
              _kSplashGreenMid,
              _kSplashGreenLight,
            ],
            stops: [0.0, 0.40, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Stack(
              children: [
                // ── Logo: top-left aligned ────────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: Transform.translate(
                        offset: Offset(0, _slideDown.value),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(28, 36, 24, 0),
                          child: _GajaCashWordmark(),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Spinner: vertically centered ─────────────────────────
                Positioned.fill(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          // Dark green ring matching design
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF003D1F),
                          ),
                          backgroundColor: Color(0x40FFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Elephant mascot peeking from bottom ───────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Center(
                      child: Image.network(
                        _kMascotUrl,
                        width: size.width * 0.62,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Two-tone wordmark: bold white "Gaja" + bold golden "Cash"
class _GajaCashWordmark extends StatelessWidget {
  const _GajaCashWordmark();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Gaja',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'Cash',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: _kGoldYellow,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
