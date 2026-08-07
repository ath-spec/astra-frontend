import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';

class MfFetchLoadingScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;
  const MfFetchLoadingScreen({super.key, this.isOnboarding = false});

  @override
  ConsumerState<MfFetchLoadingScreen> createState() => _MfFetchLoadingScreenState();
}

class _MfFetchLoadingScreenState extends ConsumerState<MfFetchLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _proceedTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _proceedTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _onProceed();
      }
    });
  }

  @override
  void dispose() {
    _proceedTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onProceed() {
    _proceedTimer?.cancel();
    ref.read(assetConnectionProvider.notifier).connectMutualFunds();
    if (widget.isOnboarding) {
      context.pushReplacement('/aa-stocks-otp', extra: {'isOnboarding': true});
    } else {
      context.go('/'); // Replaces the stack, returning home
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final double scale = size.width / 375.0; // Base width is 375
    final double logicalHeight = (size.height - padding.top - padding.bottom) / scale;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            _onProceed();
          }
        },
        child: SafeArea(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 375,
              height: logicalHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Fetching your funds...',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Skeleton Loader
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.5 + (_pulseController.value * 0.5),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          style: BorderStyle.solid,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 180,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              
              // Warning text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AnimatedHourglass(),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'This process can take upto 10 mins. Proceed to connecting Stocks.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Proceed Button
              GestureDetector(
                onTap: _onProceed,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFF0F172A),
                  ),
                  child: const Text(
                    'Proceed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'powered by MFC',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.touch_app, size: 16, color: Color(0xFF0F172A)),
                  Text(
                    'mf central',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
              ),
            ),
      ),
    ),
  );
}
}

class _AnimatedHourglass extends StatefulWidget {
  const _AnimatedHourglass({super.key});

  @override
  State<_AnimatedHourglass> createState() => _AnimatedHourglassState();
}

class _AnimatedHourglassState extends State<_AnimatedHourglass> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Phase 1: Flip 180 degrees quickly (first 25% of animation)
        if (_controller.value < 0.25) {
          final progress = _controller.value / 0.25;
          final curve = Curves.easeInOutCubic.transform(progress);
          return Transform.rotate(
            angle: curve * 3.141592653589793, // 180 degrees
            child: const Icon(Icons.hourglass_bottom, color: Color(0xFFF97316), size: 18),
          );
        } else {
          // Phase 2: Sand falling (crossfade from top-heavy to bottom-heavy)
          final progress = (_controller.value - 0.25) / 0.75;
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 1.0 - progress,
                child: const Icon(Icons.hourglass_top, color: Color(0xFFF97316), size: 18),
              ),
              Opacity(
                opacity: progress,
                child: const Icon(Icons.hourglass_bottom, color: Color(0xFFF97316), size: 18),
              ),
            ],
          );
        }
      },
    );
  }
}
