import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/asset_connection_provider.dart';

/// Screen displaying bank accounts search with skeleton list and magnifying glass (Image 5).
/// Automatically transitions to HomeScreen (Dashboard) when complete.
class BanksSearchingScreen extends ConsumerStatefulWidget {
  const BanksSearchingScreen({super.key});

  @override
  ConsumerState<BanksSearchingScreen> createState() => _BanksSearchingScreenState();
}

class _BanksSearchingScreenState extends ConsumerState<BanksSearchingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        ref.read(assetConnectionProvider.notifier).showFoundBanks();
        context.pushReplacement('/banks-linking');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),
              // Skeleton search graphic (Image 5)
              const _BankSkeletonSearchGraphic(),
              const SizedBox(height: 36),
              const Text(
                'Securely looking for bank\naccounts linked to your mobile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You can select which accounts to track in\nnext step.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              // Quick finish CTA
              ElevatedButton(
                onPressed: () {
                  _timer?.cancel();
                  ref.read(assetConnectionProvider.notifier).showFoundBanks();
                  context.pushReplacement('/banks-linking');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue to Bank Accounts ↗',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              // Security Shield Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your data is 100% protected',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // FINVU Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Powered by ',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                  Row(
                    children: [
                      Icon(Icons.polyline_rounded, color: const Color(0xFF3B82F6), size: 18),
                      const SizedBox(width: 4),
                      const Text(
                        'FINVU',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankSkeletonSearchGraphic extends StatelessWidget {
  const _BankSkeletonSearchGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 4 Skeleton Rows
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final opacity = 1.0 - (index * 0.22);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF161922).withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF20232C).withValues(alpha: opacity),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF292C37).withValues(alpha: opacity),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF292C37).withValues(alpha: opacity),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF20232C).withValues(alpha: opacity),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          // Magnifying Glass Overlay
          Positioned(
            right: 40,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Color(0xFF0D9488),
                size: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
