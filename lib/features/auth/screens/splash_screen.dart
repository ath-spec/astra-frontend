import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash Screen displaying ASTRA branding and fading-in ISO certification badge.
/// Navigates automatically to the phone onboarding screen after 2.5 seconds.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds to show the beautiful full-screen gradient splash
    // before transitioning to the app.
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF5BA1F7),
              Color(0xFF031E6B),
              Color(0xFF241714),
            ],
            stops: [0.0, 0.25, 0.7, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Image.asset(
            'lib/core/images/logo_text_only.png',
            width: 200, // Fixed width so it never gets too zoomed in
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
