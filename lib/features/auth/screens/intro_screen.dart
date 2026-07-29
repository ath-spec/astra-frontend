import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

// Industry-standard sealed state for async video initialization
sealed class _VideoState {}

final class _VideoLoading extends _VideoState {}

final class _VideoReady extends _VideoState {}

final class _VideoError extends _VideoState {
  final String message;
  _VideoError(this.message);
}

class IntroScreen extends StatefulWidget {
  final VideoPlayerController? preloadedController;
  const IntroScreen({super.key, this.preloadedController});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  _VideoState _videoState = _VideoLoading();

  static const _videoAssetPath =
      'lib/core/videos/make_this_image_in_cool_video.mp4';
  static const _initTimeout = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _initVideo();

    // Emil Design Engineering: Interactive CTA scale animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  Future<void> _initVideo() async {
    if (widget.preloadedController != null) {
      _videoController = widget.preloadedController!;
      _videoController.addListener(_onVideoControllerUpdate);
      _videoController.setLooping(true);
      _videoController.setVolume(0.0);
      _videoController.play();
      if (mounted) {
        setState(() => _videoState = _VideoReady());
      }
      return;
    }

    _videoController = VideoPlayerController.asset(_videoAssetPath);
    _videoController.addListener(_onVideoControllerUpdate);

    try {
      // Industry standard: wrap initialization in a timeout to prevent
      // the spinner hanging forever on slow/broken codec pipelines.
      await _videoController.initialize().timeout(
        _initTimeout,
        onTimeout: () => throw TimeoutException(
          'Video initialization timed out after ${_initTimeout.inSeconds}s',
        ),
      );

      if (!mounted) return;

      _videoController.setLooping(true);
      _videoController.setVolume(0.0);
      _videoController.play();

      setState(() => _videoState = _VideoReady());
    } catch (e) {
      if (!mounted) return;
      // Surface the error — never swallow failures silently
      debugPrint('[IntroScreen] Video init failed: $e');
      setState(() => _videoState = _VideoError(e.toString()));
    }
  }

  void _onVideoControllerUpdate() {
    // Seamless loop hack to avoid the black flash on Android.
    // By seeking to 0 just before EOF, we prevent the hardware decoder from hard-resetting.
    final pos = _videoController.value.position;
    final dur = _videoController.value.duration;
    if (dur != Duration.zero && pos >= dur - const Duration(milliseconds: 50)) {
      _videoController.seekTo(Duration.zero);
    }

    // Guard: react to unexpected controller errors after init
    if (_videoController.value.hasError && _videoState is! _VideoError) {
      if (mounted) {
        setState(
          () => _videoState = _VideoError(
            _videoController.value.errorDescription ?? 'Playback error',
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoControllerUpdate);
    _videoController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onContinue() {
    context.push('/login');
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 6,
      width: isActive ? 24 : 6,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF031E6B) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SKIP button (padded, constrained) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return TextButton(
                        onPressed: () {
                          ref.read(authProvider.notifier).skipLogin();
                          context.go('/');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'SKIP',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // --- PageView: FULL WIDTH, no horizontal padding ---
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // PAGE 1: Heading and Video
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            "meet your financial superintelligence",
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -1.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                              bottom: 60.0,
                              left: 24.0,
                              right: 24.0,
                            ),
                            child: Center(
                              child: Builder(
                                builder: (context) {
                                  if (_videoState is _VideoLoading) {
                                    return const SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF031E6B),
                                      ),
                                    );
                                  }

                                  if (_videoState is _VideoReady) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black, width: 2),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRect(
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            alignment: Alignment.topCenter,
                                            child: SizedBox(
                                                width: _videoController
                                                    .value
                                                    .size
                                                    .width,
                                                height: _videoController
                                                    .value
                                                    .size
                                                    .height,
                                                child: VideoPlayer(
                                                  _videoController,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    );
                                  }

                                  final e = _videoState as _VideoError;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Color(0xFF031E6B),
                                        size: 40,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Could not load video',
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 14,
                                          color: Color(0xFF031E6B),
                                        ),
                                      ),
                                      if (e.message.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          e.message,
                                          style: const TextStyle(
                                            fontFamily: 'DMMono',
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -35),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              "BUILT TO THINK BEYOND\nTODAY'S MARKET",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'DMMono',
                                fontSize: 10,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),

                    // PAGE 2: Placeholder Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Advanced Insights",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Dive deep into the market with cutting-edge data and realtime analytics.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // PAGE 3: Logo and CTA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          Center(
                            child: Image.asset(
                              'lib/core/images/logo_text_only.png',
                              width: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Welcome to the future of wealth management.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Bottom Bar (padded, constrained) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Page Indicators
                      AnimatedOpacity(
                        opacity: _currentPage == 2 ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_buildDot(0), _buildDot(1), _buildDot(2)],
                        ),
                      ),
                      // CTA Button
                      AnimatedOpacity(
                        opacity: _currentPage == 2 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: _currentPage != 2,
                          child: GestureDetector(
                            onTapDown: (_) => _animationController.forward(),
                            onTapUp: (_) => _animationController.reverse(),
                            onTapCancel: () => _animationController.reverse(),
                            onTap: _onContinue,
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: _scaleAnimation.value,
                                child: child,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
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
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: const [
                                    Text(
                                      'GET STARTED',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Positioned(
                                      right: 20,
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple timeout exception used for cleaner error messages
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);
  @override
  String toString() => message;
}

