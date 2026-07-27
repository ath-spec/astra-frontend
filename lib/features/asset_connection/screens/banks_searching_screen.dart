import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/arch_background.dart';
import '../providers/asset_connection_provider.dart';

/// Screen 2 of Banks Flow: Fetching Screen (Image 3) in clean light mode.
/// Displays pulsing dots, skeleton account cards, and auto-navigates to HomeScreen.
class BanksSearchingScreen extends ConsumerStatefulWidget {
  const BanksSearchingScreen({super.key});

  @override
  ConsumerState<BanksSearchingScreen> createState() => _BanksSearchingScreenState();
}

class _BanksSearchingScreenState extends ConsumerState<BanksSearchingScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        ref.read(assetConnectionProvider.notifier).completeBankLinking();
        final state = ref.read(assetConnectionProvider);
        if (state.hasUnlinkedAccounts) {
          // Some accounts were not selected — loop back to linking screen
          ref.read(assetConnectionProvider.notifier).resetSelectionForUnlinked();
          context.go('/banks-linking', extra: true); // extra=true means returnMode
        } else {
          // All accounts linked or none left — done
          context.go('/');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Subtle 3D Architectural Dome Background Graphic
          const ArchBackground(height: 380),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 140),

                        // Animated Pulsing Dots
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _pulseAnimation.value,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: List.generate(3, (i) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF64748B),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Title
                        const Text(
                          'Securely fetching your Banks',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: Color(0xFF0F172A),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.0,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        const Text(
                          "Hang tight. We're securely pulling your accounts,\nthis should only take a moment.",
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Skeleton Cards Graphic (matching Image 3)
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                // Background stacked card 2
                                Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: Container(
                                    height: 80,
                                    width: 280,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                // Background stacked card 1
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Container(
                                    height: 80,
                                    width: 310,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                // Foreground main skeleton card
                                Padding(
                                  padding: const EdgeInsets.only(top: 32),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Circle skeleton
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFE2E8F0),
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Lines skeleton
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 140,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE2E8F0),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                width: 80,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Pill skeleton
                                        Container(
                                          width: 50,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE2E8F0),
                                            borderRadius: BorderRadius.circular(7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Clock status text
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_filled_rounded,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Securely fetching all your accounts. This may take a few seconds.',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: const Color(0xFF64748B).withValues(alpha: 0.9),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'powered by RBI-regulated account aggregator ',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
              Text(
                'FINVU',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF10B981),
                size: 14,
              ),
              const SizedBox(width: 6),
              const Text(
                'trusted by 3 crore citizens',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
