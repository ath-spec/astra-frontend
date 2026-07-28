import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/why_pan_overlay.dart';

class _PanInputFormatter extends TextInputFormatter {
  final void Function(int index, bool wasNumber) onInvalidInput;
  final VoidCallback onValidInput;

  _PanInputFormatter({
    required this.onInvalidInput,
    required this.onValidInput,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toUpperCase();
    final buffer = StringBuffer();
    bool hadInvalid = false;

    for (int i = 0; i < text.length && i < 10; i++) {
      final char = text[i];
      if (i < 5) {
        if (RegExp(r'[A-Z]').hasMatch(char)) {
          buffer.write(char);
        } else if (RegExp(r'[0-9]').hasMatch(char)) {
          hadInvalid = true;
          onInvalidInput(i, true);
        } else {
          hadInvalid = true;
          onInvalidInput(i, false);
        }
      } else if (i < 9) {
        if (RegExp(r'[0-9]').hasMatch(char)) {
          buffer.write(char);
        } else if (RegExp(r'[A-Z]').hasMatch(char)) {
          hadInvalid = true;
          onInvalidInput(i, false);
        } else {
          hadInvalid = true;
          onInvalidInput(i, false);
        }
      } else if (i == 9) {
        if (RegExp(r'[A-Z]').hasMatch(char)) {
          buffer.write(char);
        } else if (RegExp(r'[0-9]').hasMatch(char)) {
          hadInvalid = true;
          onInvalidInput(i, true);
        } else {
          hadInvalid = true;
          onInvalidInput(i, false);
        }
      }
    }

    if (!hadInvalid && oldValue.text != newValue.text) {
      onValidInput();
    }

    final newString = buffer.toString();
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

/// PAN verification screen representing the secondary onboarding step.
/// Validates 10 alphanumeric uppercase characters (5 letters, 4 digits, 1 letter)
/// and collects Account Aggregator / MF Central consent.
class PanVerificationScreen extends ConsumerStatefulWidget {
  const PanVerificationScreen({super.key});

  @override
  ConsumerState<PanVerificationScreen> createState() =>
      _PanVerificationScreenState();
}

class _PanVerificationScreenState extends ConsumerState<PanVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _panController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isConsented = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String? _group1Error;
  String? _group2Error;
  String? _group3Error;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    _panController.addListener(_onPanChanged);
    _focusNode.addListener(() {
      setState(() {});
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _onPanChanged() {
    setState(() {});
  }

  void _onInvalidPanInput(int index, bool wasNumber) {
    _errorTimer?.cancel();
    setState(() {
      if (index < 5) {
        _group1Error = 'Letters only';
        _group2Error = null;
        _group3Error = null;
      } else if (index < 9) {
        _group1Error = null;
        _group2Error = 'Numbers only';
        _group3Error = null;
      } else {
        _group1Error = null;
        _group2Error = null;
        _group3Error = 'Letters only';
      }
    });
    _errorTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _group1Error = null;
          _group2Error = null;
          _group3Error = null;
        });
      }
    });
  }

  void _onValidPanInput() {
    if (_group1Error != null || _group2Error != null || _group3Error != null) {
      _errorTimer?.cancel();
      setState(() {
        _group1Error = null;
        _group2Error = null;
        _group3Error = null;
      });
    }
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _panController.removeListener(_onPanChanged);
    _panController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showWhyPanOverlay() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WhyPanOverlay(),
    );
  }

  void _submit() {
    final pan = _panController.text.trim();
    if (pan.length == 10 && _isConsented) {
      final authNotifier = ref.read(authProvider.notifier);
      authNotifier.verifyPan(pan, phone: authNotifier.pendingPhone);
      context.push('/pan-otp');
    }
  }

  Widget _buildPanSlot(int index, String char, bool isActive, {bool isError = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 42,
          child: Center(
            child: Text(
              char,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 36,
                fontWeight: FontWeight.w600,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [
                      Color(0xFF5BA1F7),
                      Color(0xFF031E6B),
                      Color(0xFF241714),
                    ],
                    stops: [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 22,
          height: isActive || isError ? 2.5 : 2.0,
          decoration: BoxDecoration(
            color: isError
                ? const Color(0xFFDC2626)
                : isActive
                    ? const Color(0xFF031E6B)
                    : const Color(0xFF9CA3AF),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildGroup({
    required List<Widget> slots,
    required String label,
    String? errorText,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: slots),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF9CA3AF),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDC2626),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final text = _panController.text.trim();
    final isEnabled = text.length == 10 && _isConsented && !isLoading;

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
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF111827),
                      size: 20,
                    ),
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
                            'PAN VERIFICATION',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your PAN',
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
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                letterSpacing: 0.8,
                                color: Color(0xFF9CA3AF),
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      "ALL INVESTMENTS LINKED TO YOUR PAN & MOBILE WILL BE FETCHED. ",
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: GestureDetector(
                                    onTap: _showWhyPanOverlay,
                                    behavior: HitTestBehavior.opaque,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 2.0,
                                      ),
                                      child: Text(
                                        "WHY PAN?",
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                          letterSpacing: 0.8,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Interactive 3-group PAN character input
                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(_focusNode);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) => FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: SizedBox(
                                      width: constraints.maxWidth,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Group 1: 5 letters
                                          _buildGroup(
                                            label: 'LETTERS',
                                            errorText: _group1Error,
                                            slots: List.generate(5, (index) {
                                              final char = text.length > index
                                                  ? text[index]
                                                  : '';
                                              final isActive =
                                                  _focusNode.hasFocus &&
                                                  text.length == index;
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  right: index < 4 ? 4.0 : 0,
                                                ),
                                                child: _buildPanSlot(
                                                  index,
                                                  char,
                                                  isActive,
                                                  isError: _group1Error != null,
                                                ),
                                              );
                                            }),
                                          ),
                                          // Group 2: 4 numbers
                                          _buildGroup(
                                            label: 'NUMBERS',
                                            errorText: _group2Error,
                                            slots: List.generate(4, (i) {
                                              final index = i + 5;
                                              final char = text.length > index
                                                  ? text[index]
                                                  : '';
                                              final isActive =
                                                  _focusNode.hasFocus &&
                                                  text.length == index;
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  right: i < 3 ? 4.0 : 0,
                                                ),
                                                child: _buildPanSlot(
                                                  index,
                                                  char,
                                                  isActive,
                                                  isError: _group2Error != null,
                                                ),
                                              );
                                            }),
                                          ),
                                          // Group 3: 1 letter
                                          _buildGroup(
                                            label: 'LETTER',
                                            errorText: _group3Error,
                                            slots: [
                                              _buildPanSlot(
                                                9,
                                                text.length > 9 ? text[9] : '',
                                                _focusNode.hasFocus &&
                                                    text.length == 9,
                                                isError: _group3Error != null,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Hidden 1x1 TextField capturing keyboard input without receiving direct hit tests
                                IgnorePointer(
                                  child: Opacity(
                                    opacity: 0,
                                    child: SizedBox(
                                      width: 1,
                                      height: 1,
                                      child: TextField(
                                        controller: _panController,
                                        focusNode: _focusNode,
                                        enabled: !isLoading,
                                        enableInteractiveSelection: false,
                                        keyboardType: TextInputType.text,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        inputFormatters: [
                                          _PanInputFormatter(
                                            onInvalidInput: _onInvalidPanInput,
                                            onValidInput: _onValidPanInput,
                                          ),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Section: Consent Checkbox & Continue Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Consent Checkbox & Text from Image 1
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => setState(
                                      () => _isConsented = !_isConsented,
                                    ),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 12,
                                  bottom: 12,
                                  top: 2,
                                  left: 4,
                                ),
                                child: SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: Transform.scale(
                                    scale: 0.75,
                                    child: Checkbox(
                                      value: _isConsented,
                                      onChanged: isLoading
                                          ? null
                                          : (val) => setState(
                                              () => _isConsented = val ?? false,
                                            ),
                                      activeColor: const Color(0xFF111827),
                                      checkColor: Colors.white,
                                      side: const BorderSide(
                                        color: Color(0xFF9CA3AF),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'DMMono',
                                    color: Color(0xFF6B7280),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    height: 1.6,
                                    letterSpacing: 0.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'I authorise '.toUpperCase(),
                                    ),
                                    TextSpan(
                                      text: 'Astra Investments (AIPL)'
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF111827),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' to fetch my data via Account Aggregator & '
                                              .toUpperCase(),
                                    ),
                                    TextSpan(
                                      text: 'Astra Distribution (ADSPL)'
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF111827),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' to fetch via MF Central. We will securely fetch your data from aggregators you have already consented to, helping us complete this faster.'
                                              .toUpperCase(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Continue Button
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
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (isLoading)
                                    const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    const Text(
                                      'CONTINUE',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  if (!isLoading)
                                    const Positioned(
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
}
