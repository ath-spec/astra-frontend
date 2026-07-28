import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen displayed when the app loses internet connection mid-onboarding or mid-session.
/// Allows retrying and resuming from the exact point of disconnection without losing state.
class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key, this.returnRoute});

  final String? returnRoute;

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isRetrying = false;
  Timer? _retryTimer;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _onRetry() {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isRetrying = false);
        if (widget.returnRoute != null && widget.returnRoute!.isNotEmpty) {
          context.go(widget.returnRoute!);
        } else if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFEF2F2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 32,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Connection Lost',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: Color(0xFF0F172A),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We could not connect to the internet.\nDon\'t worry, your progress has been securely saved locally.',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF475569),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isRetrying ? null : _onRetry,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: _isRetrying ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                          ),
                          child: Center(
                            child: _isRetrying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'RETRY CONNECTION',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Text(
                            'Your data is 100% safe & secure',
                            style: TextStyle(
                              fontFamily: 'DMMono',
                              color: Color(0xFF9CA3AF),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
