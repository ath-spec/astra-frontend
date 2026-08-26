import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../providers/auth_provider.dart';

/// Splash Screen displaying ASTRA branding and fading-in ISO certification badge.
/// First attempts to restore an existing session (stored auth token validated
/// against `GET /api/auth/me`); if that succeeds, skips onboarding entirely
/// and goes straight to home. Otherwise falls through to the normal
/// video-preload → intro/login flow.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _restoreSessionThenNavigate();
  }

  Future<void> _restoreSessionThenNavigate() async {
    final restored = await ref.read(authProvider.notifier).restoreSession();
    if (!mounted) return;
    if (restored) {
      context.go('/');
      return;
    }
    await _preloadVideoAndNavigate();
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
