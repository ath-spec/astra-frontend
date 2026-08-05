import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';

/// Screen matching Image 2 for Account Aggregator Stocks data fetching state.
/// Displays animated loader, skeleton cards, and automatically transitions to status UI.
class AaStocksFetchingScreen extends ConsumerStatefulWidget {
  const AaStocksFetchingScreen({super.key});

  @override
  ConsumerState<AaStocksFetchingScreen> createState() => _AaStocksFetchingScreenState();
}

class _AaStocksFetchingScreenState extends ConsumerState<AaStocksFetchingScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showStatus = false;
  final bool _hasDemat = true; // Happy case: demat is fetched

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showStatus = true;
        });
        _timer = Timer(const Duration(milliseconds: 2000), () {
          if (mounted) {
            // Happy path: Set stocks as connected before moving to banks searching
            ref.read(assetConnectionProvider.notifier).connectFoundStocks();
            context.pushReplacement('/banks-searching');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildSkeletonCard(int index) {
    final widthFactor = 1.0 - (index * 0.1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authProvider.notifier).pendingPhone;
    final displayPhone = phone.isEmpty ? '6291328703' : phone;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar removed as requested
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // Always show the Fetching UI text
                        const Text(
                          'Securely fetching your stocks and ETFs',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            height: 1.15,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 22),
                        RichText(
                          textAlign: TextAlign.left,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: "HANG TIGHT. WE'RE SECURELY PULLING YOUR ACCOUNTS, THIS SHOULD ONLY TAKE A MOMENT. ",
                              ),
                              TextSpan(
                                text: 'ACCOUNT AGGREGATOR',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Status Box appears without replacing the main UI
                        if (_showStatus) ...[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  _hasDemat
                                      ? Icons.check_circle_rounded
                                      : Icons.info_outline_rounded,
                                  color: _hasDemat
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF9CA3AF),
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _hasDemat
                                            ? 'Demat connected'
                                            : 'No Demat found',
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'POWERED BY RBI-REGULATED ACCOUNT AGGREGATOR ',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 9,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.change_history_rounded,
                            color: Color(0xFF1E3A8A),
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'FINARKEIN',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3A8A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
