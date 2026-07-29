import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

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
    _preloadVideoAndNavigate();
  }

  Future<void> _preloadVideoAndNavigate() async {
    // We initialize the video here to skip the loading spinner on the IntroScreen.
    // By preloading it in the background of the Splash Screen, the transition is completely seamless.
    final controller = VideoPlayerController.asset('lib/core/videos/make_this_image_in_cool_video.mp4');
    
    try {
      // 1. Wait for both a minimum splash screen duration (so it doesn't flash too fast) 
      // 2. AND for the video to fully initialize.
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 1500)),
        controller.initialize().timeout(const Duration(seconds: 10)),
      ]);
      
      if (!mounted) return;
      // Pass the fully loaded, ready-to-play controller
      context.go('/intro', extra: controller);
    } catch (e) {
      debugPrint('[SplashScreen] Video preload failed: $e');
      if (!mounted) return;
      // If it fails (e.g. codec timeout), proceed anyway without it. 
      // IntroScreen will handle the null fallback / error state.
      context.go('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,  // white icons on dark gradient
        statusBarBrightness: Brightness.dark,        // iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
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
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
