import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';

class PanOtpVerificationScreen extends ConsumerStatefulWidget {
  const PanOtpVerificationScreen({super.key});

  @override
  ConsumerState<PanOtpVerificationScreen> createState() => _PanOtpVerificationScreenState();
}

class _PanOtpVerificationScreenState extends ConsumerState<PanOtpVerificationScreen> with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  int _timerSeconds = 45;
  Timer? _countdownTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _otpController.addListener(() => setState(() {}));
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
    _timerSeconds = 45;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        if (mounted) setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_otpController.text.length == 6) {
      context.go('/connect-assets');
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authProvider.notifier).pendingPhone;
    final isEnabled = _otpController.text.length == 6;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 20),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  ),
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
                            'Enter the OTP.',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -1.0,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: _otpController,
                                focusNode: _focusNode,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.left,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 12.0,
                                  color: Color(0xFF111827),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '000000',
                                  hintStyle: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 12.0,
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'WE TEXTED +91 ${phone.isEmpty ? '83207 60088' : phone}',
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              onTap: _timerSeconds == 0 ? _startTimer : null,
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "DIDN'T GET IT? ",
                                      style: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _timerSeconds > 0 ? 'RESEND IN ${_timerSeconds}S' : 'RESEND NOW',
                                      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
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
                ),
              ),
              // Continue Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: GestureDetector(
                      onTapDown: isEnabled ? (_) => _animationController.forward() : null,
                      onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
                      onTapCancel: isEnabled ? () => _animationController.reverse() : null,
                      onTap: isEnabled ? _submit : null,
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isEnabled
                                  ? [
                                      const Color(0xFFE6E6FA),
                                      const Color(0xFF8634DE),
                                    ]
                                  : [
                                      const Color(0xFF9CA3AF),
                                      const Color(0xFF6B7280),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                'CONTINUE',
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
