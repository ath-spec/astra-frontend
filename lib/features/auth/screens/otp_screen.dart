import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

/// OTP verification screen matching Images 3, 4, 5.
/// Demonstrates 4-digit OTP input, simulated SMS notification banner, and verification spinner/checkmark.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _showBanner = true;
  int _timerSeconds = 25;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
    _startTimer();
    // Auto-hide simulated SMS banner after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() => _showBanner = false);
      }
    });
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _timerSeconds = 25;
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
    if (_otpController.text.length == 4 && !_isVerifying && !_isVerified) {
      _verifyOtp();
    }
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _focusNode.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text != '1924' && _otpController.text != '1234') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP 1924 as shown in SMS banner')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isVerifying = true);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isVerifying = false;
      _isVerified = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.push('/pan');
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authProvider.notifier).pendingPhone;
    final isEnabled = _otpController.text.length == 4 && !_isVerifying && !_isVerified;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F19),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              FocusScope.of(context).unfocus();
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Main Screen Content
              if (_isVerifying)
                _buildSpinnerView()
              else if (_isVerified)
                _buildVerifiedView()
              else
                _buildInputView(phone, isEnabled),

              // Top Simulated SMS Notification Banner
              if (_showBanner && !_isVerifying && !_isVerified)
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    opacity: _showBanner ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF374151).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.sms_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'astra-S',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'now',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '1924 is your OTP to log on to your Astra account...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
                            onPressed: () => setState(() => _showBanner = false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputView(String phone, bool isEnabled) {
    return Center(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            const Text(
              'Verify your phone number',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 4-digit OTP sent to\n+91 $phone',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            // OTP Input Box
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF13161F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _focusNode.hasFocus ? const Color(0xFF6366F1) : Colors.white.withValues(alpha: 0.12),
                  width: _focusNode.hasFocus ? 1.5 : 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter 4 digit OTP',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  TextField(
                    controller: _otpController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8.0,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      hintText: '----',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        letterSpacing: 8.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Resend & Verify OTP Buttons Row
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
                      backgroundColor: isEnabled ? const Color(0xFF2B2F3D) : const Color(0xFF1A1D26),
                      disabledBackgroundColor: const Color(0xFF1A1D26),
                      foregroundColor: Colors.white,
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
            // WhatsApp Consent Footer
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, height: 1.4),
                children: [
                  const TextSpan(text: 'By proceeding you give consent to receive\ncommunication on WhatsApp and agree to our '),
                  TextSpan(
                    text: 'Terms of use',
                    style: const TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'Privacy policy',
                    style: const TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' & '),
                  TextSpan(
                    text: 'ADSPL account creation',
                    style: const TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSpinnerView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Verifying OTP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2DD4BF), // Teal checkmark circle
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Color(0xFF0B0F19), size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'Number Verified',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
