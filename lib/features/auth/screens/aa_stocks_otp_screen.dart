import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/edit_number_overlay.dart';

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
  String? _overridePhone; // Set when user changes number via edit overlay

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
    if (_otpController.text.length == 6) {
      _proceedToNext();
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
    if (_otpController.text.length == 6) {
      _proceedToNext();
    }
  }

  void _proceedToNext() {
    ref.read(authProvider.notifier).verifyAccountAggregator();
    context.push('/aa-stocks-fetching');
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
    final displayPhone = _overridePhone ?? (phone.isEmpty ? '6291328703' : phone);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF111827),
                        size: 20,
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (context.canPop()) context.pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                    child: TextButton(
                      onPressed: () => context.push('/banks-linking'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                      ),
                      child: const Text(
                        'SKIP',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8
                        ),
                      ),
                    ),
                  ),
                ],
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
                            "Next up,\nlet's connect your stocks",
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -1.0,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "YOUR STOCKS AND ETFs LINKED TO +91 $displayPhone WILL BE FETCHED SECURELY.",
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                              height: 1.4,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  children: [
                                    const TextSpan(text: "ENTER THE OTP SENT TO "),
                                    TextSpan(
                                      text: "+91 $displayPhone",
                                      style: const TextStyle(
                                        color: Color(0xFF111827),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (ctx) => EditNumberOverlay(
                                      currentNumber: displayPhone,
                                      onConfirm: (newNumber) {
                                        setState(() {
                                          _overridePhone = newNumber;
                                          _otpController.clear();
                                        });
                                        _startTimer();
                                      },
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 6-digit OTP input field
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
                          const SizedBox(height: 32),
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
                                      text: _timerSeconds > 0
                                          ? 'RESEND IN ${_timerSeconds}S'
                                          : 'RESEND NOW',
                                      style: const TextStyle(
                                        color: Color(0xFF111827),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: GestureDetector(
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
