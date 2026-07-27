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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                            color: Color(0xFF2D3748),
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
                          height: 110,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E2433),
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
                                fontSize: 32,
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
              const SizedBox(height: 36),

              // Heading
              const Text(
                'Answer a few questions to\nget your analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'This will take less than 30 seconds',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Get Started CTA Button (Animated fill bar)
              GestureDetector(
                onTap: _isReady ? _onGetStarted : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2433),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            // White progress fill bar from left to right
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _controller.value,
                                heightFactor: 1.0,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Button Text
                            Center(
                              child: Text(
                                'Get started',
                                style: TextStyle(
                                  color: _isReady ? const Color(0xFF0B0F19) : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Security footer
              const Row(
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
