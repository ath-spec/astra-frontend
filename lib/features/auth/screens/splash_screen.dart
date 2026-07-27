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
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    // Automatically transition to login/onboarding after 2.5s
    _navigationTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            'ASTRA',
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              color: Color(0xFF111827),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 6.0,
            ),
          ),
        ),
      ),
    );
  }
}
