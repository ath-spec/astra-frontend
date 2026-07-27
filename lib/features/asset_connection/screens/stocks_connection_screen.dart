import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/asset_connection_provider.dart';

/// Screen matching Image 5 for Stocks demat account connection via 6-digit OTP.
/// Features top progress bar (2 of 3), Stocks badge, 6-digit input, and teal floating toast.
class StocksConnectionScreen extends ConsumerStatefulWidget {
  const StocksConnectionScreen({super.key});

  @override
  ConsumerState<StocksConnectionScreen> createState() => _StocksConnectionScreenState();
}

class _StocksConnectionScreenState extends ConsumerState<StocksConnectionScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  int _timerSeconds = 59;
  Timer? _countdownTimer;
  Timer? _toastTimer;
  bool _showToast = true;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
    _startTimer();
    // Auto hide toast after 6 seconds using cancelable Timer
    _toastTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _timerSeconds = 59;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        if (mounted) setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onOtpChanged() {
    setState(() {});
    if (_otpController.text.length == 6) {
      _verifyOtp();
    }
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _focusNode.dispose();
    _countdownTimer?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }

  void _verifyOtp() {
    FocusScope.of(context).unfocus();
    _countdownTimer?.cancel();
    _toastTimer?.cancel();
    ref.read(assetConnectionProvider.notifier).verifyStocksOtp(_otpController.text);
    context.pushReplacement('/stocks-verifying');
  }

  void _skip() {
    FocusScope.of(context).unfocus();
    _countdownTimer?.cancel();
    _toastTimer?.cancel();
    ref.read(assetConnectionProvider.notifier).continueWithoutStocks();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authProvider.notifier).pendingPhone;
    final isEnabled = _otpController.text.length == 6;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F19),
        body: SafeArea(
          child: Stack(
            children: [
              // Main Screen Content
              Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Top Progress Bar & Skip Button (2 of 3)
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: 0.66, // 2 of 3 filled
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D9488), // Teal progress
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            '2 of 3',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: _skip,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Stocks Badge Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161922),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.show_chart_rounded, color: Colors.white70, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Stocks',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Headline & Subtitle
                      const Text(
                        'Fetch Stock holdings from\ndemat accounts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enter the 6-digit OTP sent by Finvu to +91-\n$phone.',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // 6-digit OTP Input Box
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF13161F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? const Color(0xFF0D9488) // Teal focus
                                : Colors.white.withValues(alpha: 0.12),
                            width: _focusNode.hasFocus ? 1.5 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter 6 digit OTP',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            TextField(
                              controller: _otpController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 6.0,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                                hintText: '------',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  letterSpacing: 6.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Resend & Verify Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _timerSeconds == 0 ? _startTimer : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF161922),
                                disabledBackgroundColor: const Color(0xFF161922),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white38,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(
                                _timerSeconds > 0 ? 'Resend ($_timerSeconds)' : 'Resend OTP',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isEnabled ? _verifyOtp : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEnabled ? Colors.white : const Color(0xFF1A1D26),
                                disabledBackgroundColor: const Color(0xFF1A1D26),
                                foregroundColor: isEnabled ? Colors.black : Colors.white24,
                                disabledForegroundColor: Colors.white24,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Verify OTP',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Consent Text
                      const Text(
                        'By proceeding, you agree to fetch your data from Account Aggregator in accordance with our Terms & Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 100), // Space for floating toast and footer
                    ],
                  ),
                ),
              ),
            ),

              // Floating Teal Toast & Footer
              Positioned(
                bottom: 16,
                left: 24,
                right: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showToast)
                      AnimatedOpacity(
                        opacity: _showToast ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488), // Teal toast background
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'OTP sent to $phone',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Powered by FINVU Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Powered by ',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Icon(Icons.change_history_rounded, color: const Color(0xFF3B82F6), size: 14),
                        const Text(
                          ' FINVU',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
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
}
