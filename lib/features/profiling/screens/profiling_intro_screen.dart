import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profiling_provider.dart';

class ProfilingIntroScreen extends ConsumerStatefulWidget {
  const ProfilingIntroScreen({super.key});

  @override
  ConsumerState<ProfilingIntroScreen> createState() => _ProfilingIntroScreenState();
}

class _ProfilingIntroScreenState extends ConsumerState<ProfilingIntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isReady = true;
          });
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    if (!_isReady) return;
    ref.read(profilingProvider.notifier).reset();
    context.push('/profiling-questions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40.0 > 0 ? constraints.maxHeight - 40.0 : 0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),

                      // Podium & Rupee Coin Illustration
                      Center(
                        child: SizedBox(
                          height: 220,
                          width: 260,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Back triangle / geometric shape
                              Positioned(
                                left: 20,
                                bottom: 0,
                                child: Container(
                                  width: 100,
                                  height: 110,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF131826),
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(80)),
                                  ),
                                ),
                              ),
                              // Right circle arc
                              Positioned(
                                right: 20,
                                bottom: 0,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF131826),
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(90)),
                                  ),
                                ),
                              ),
                              // Left bar
                              Positioned(
                                left: 60,
                                bottom: 0,
                                child: Container(
                                  width: 50,
                                  height: 130,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E2433),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                              ),
                              // Center tall podium
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 66,
                                  height: 160,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color(0xFF252D3D), Color(0xFF141923)],
                                    ),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                              ),
                              // Right bar
                              Positioned(
                                right: 60,
                                bottom: 0,
                                child: Container(
                                  width: 50,
                                  height: 90,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF191F2B),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                              ),
                              // Rupee Coin on top of center podium
                              Positioned(
                                bottom: 146,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFFF1F5F9), Color(0xFF94A3B8)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '₹',
                                      style: TextStyle(
                                        color: Color(0xFF0B0F19),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Title
                      const Text(
                        'Unlock your financial\nintelligence',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      const Text(
                        'Get personalized recommendations and financial planning tailored just for you.',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Get Started CTA Button (Animated fill bar)
                      GestureDetector(
                        onTap: _isReady ? _onGetStarted : null,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isReady
                                  ? const [
                                      Color(0xFFFFFFFF),
                                      Color(0xFF5BA1F7),
                                      Color(0xFF031E6B),
                                      Color(0xFF241714),
                                    ]
                                  : const [
                                      Color(0xFFF3F4F6),
                                      Color(0xFFD1D5DB),
                                      Color(0xFF9CA3AF),
                                      Color(0xFF6B7280),
                                    ],
                              stops: const [0.0, 0.25, 0.7, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                'GET STARTED',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
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
                      const SizedBox(height: 20),

                      // Security footer
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield, size: 16, color: Color(0xFF64748B)),
                            SizedBox(width: 8),
                            Text(
                              'Your data is 100% safe & secure',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
