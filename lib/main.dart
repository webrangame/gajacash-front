import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/screens/splash_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catches Flutter widget-tree exceptions
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  // Catches async exceptions
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('PlatformDispatcher error: $error\n$stack');
    return true;
  };

  // Friendly error screen instead of red screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return _AppErrorWidget(message: details.exceptionAsString());
  };

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Splash has dark green bg → use light icons; carousel restores dark
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const GajaCashApp());
}

class GajaCashApp extends StatelessWidget {
  const GajaCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GajaCash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

class _AppErrorWidget extends StatelessWidget {
  final String message;
  const _AppErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5FAF7),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.alertCircle,
                  color: Color(0xFF006633),
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1D1B),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please go back or restart the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF006633),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  final nav = Navigator.maybeOf(context);
                  if (nav != null && nav.canPop()) nav.pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006633),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
