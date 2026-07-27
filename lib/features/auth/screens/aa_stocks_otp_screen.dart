import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

/// Screen matching Image 0 & Image 1 for Account Aggregator Stocks OTP verification.
/// Features 6-digit OTP input with zero IME cursor positioning bugs and an SMS consent modal.
class AaStocksOtpScreen extends ConsumerStatefulWidget {
  const AaStocksOtpScreen({super.key});

  @override
  ConsumerState<AaStocksOtpScreen> createState() => _AaStocksOtpScreenState();
}

class _AaStocksOtpScreenState extends ConsumerState<AaStocksOtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  int _timerSeconds = 30;
  Timer? _countdownTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isModalShown = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
    _focusNode.addListener(() => setState(() {}));
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _timerSeconds = 30;
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
    if (_otpController.text.length == 6 && !_isModalShown) {
      _showConsentModal();
    }
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _focusNode.dispose();
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_otpController.text.length == 6 && !_isModalShown) {
      _showConsentModal();
    }
  }

  void _proceedToNext() {
    ref.read(authProvider.notifier).verifyAccountAggregator();
    context.push('/aa-stocks-fetching');
  }

  void _showConsentModal() {
    _isModalShown = true;
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildConsentModal(context),
    ).then((_) {
      _isModalShown = false;
    });
  }

  Widget _buildConsentModal(BuildContext context) {
    final otpText = _otpController.text.padRight(6, '0');
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Allow Astra to read the message below and enter the code?',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'DMMono',
                  fontSize: 12,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Astra Advisory Solutions requires your consent to fetch financial information. Use OTP ',
                  ),
                  TextSpan(
                    text: otpText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const TextSpan(
                    text: ' on Finvu AA to approve. Do not share OTP',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _proceedToNext();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Deny',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _proceedToNext();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Allow',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB)),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authProvider.notifier).pendingPhone;
    final displayPhone = phone.isEmpty ? '6291328703' : phone;
    final text = _otpController.text;
    final isEnabled = text.length == 6;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Back Arrow and Skip
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF111827),
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    TextButton(
                      onPressed: () => context.push('/connect-assets'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 1),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF9CA3AF),
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            "Next up, let's connect your stocks",
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -0.8,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Your stocks and ETFs linked to +91 $displayPhone and PAN ••••370H will be fetched securely",
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildDashedDivider(),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Text(
                                "Enter the OTP sent to +91 $displayPhone",
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 6-digit OTP input boxes with IME cursor fix
                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(_focusNode);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(6, (index) {
                                    final char =
                                        text.length > index ? text[index] : '';
                                    final isActive =
                                        _focusNode.hasFocus &&
                                        text.length == index;
                                    return Container(
                                      width: 48,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isActive
                                              ? const Color(0xFF031E6B)
                                              : const Color(0xFFE5E7EB),
                                          width: isActive ? 1.5 : 1.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        char,
                                        style: const TextStyle(
                                          fontFamily: 'SpaceGrotesk',
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                // Hidden 1x1 TextField capturing keyboard input without receiving direct hit tests
                                IgnorePointer(
                                  child: Opacity(
                                    opacity: 0,
                                    child: SizedBox(
                                      width: 1,
                                      height: 1,
                                      child: TextField(
                                        controller: _otpController,
                                        focusNode: _focusNode,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(6),
                                        ],
                                        style: const TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 1,
                                        ),
                                        cursorColor: Colors.transparent,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          fillColor: Colors.transparent,
                                          filled: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _timerSeconds == 0 ? _startTimer : null,
                            child: Text(
                              _timerSeconds > 0
                                  ? 'Resend OTP in ${_timerSeconds}s'
                                  : 'Resend OTP',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _timerSeconds > 0
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF031E6B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Confirm and proceed Button
                          GestureDetector(
                            onTapDown: isEnabled
                                ? (_) => _animationController.forward()
                                : null,
                            onTapUp: isEnabled
                                ? (_) => _animationController.reverse()
                                : null,
                            onTapCancel: isEnabled
                                ? () => _animationController.reverse()
                                : null,
                            onTap: isEnabled ? _submit : null,
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: _scaleAnimation.value,
                                child: child,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isEnabled
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
                                      'CONFIRM AND PROCEED',
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
                          ),
                          const SizedBox(height: 48),
                          // Footer
                          Center(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'powered by RBI-regulated account aggregator ',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.change_history_rounded,
                                          color: const Color(0xFF1E3A8A),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 2),
                                        const Text(
                                          'FINVU',
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
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.security_rounded,
                                      color: Color(0xFF10B981),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'trusted by 3 crore citizens',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280),
                                      ),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
