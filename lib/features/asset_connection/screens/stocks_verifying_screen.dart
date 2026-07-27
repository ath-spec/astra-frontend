import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/asset_connection_provider.dart';

/// Screen displaying OTP verification spinning loader (Image 2).
/// Automatically transitions to StocksSearchingScreen after verification.
class StocksVerifyingScreen extends ConsumerStatefulWidget {
  const StocksVerifyingScreen({super.key});

  @override
  ConsumerState<StocksVerifyingScreen> createState() => _StocksVerifyingScreenState();
}

class _StocksVerifyingScreenState extends ConsumerState<StocksVerifyingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        ref.read(assetConnectionProvider.notifier).startStocksSearch();
        context.pushReplacement('/stocks-searching');
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
              // White Arc Spinner (Image 2)
              const SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Color(0xFF20232C),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verifying OTP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please be patient this might take a while',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                ),
              ),
              const Spacer(),
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
              const SizedBox(height: 12),
              // SEBI Disclaimer (Image 2)
              const Text(
                'DIPL, a registered SEBI Portfolio Manager with registration -\nINP000007377 will fetch data via account aggregator with\nyour consent.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  height: 1.4,
                ),
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
