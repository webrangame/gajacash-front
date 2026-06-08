import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gajacash_sample/features/onboarding/screens/onboarding_carousel_screen.dart';
import 'package:gajacash_sample/core/constants/app_assets.dart';
import 'package:gajacash_sample/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showSpinner = false;
  Timer? _spinnerTimer;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Override status bar to dark icons on light background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Show spinner after 2 seconds
    _spinnerTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showSpinner = true;
        });
      }
    });

    // Navigate to Onboarding Carousel after 6 seconds (2s wait + 4s loading)
    _navTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, anim, secondary) => const OnboardingCarouselScreen(),
            transitionsBuilder: (context, anim, secondary, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _spinnerTimer?.cancel();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.phoneFrameBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.splashBackground),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: _showSpinner
            ? const Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.0,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
