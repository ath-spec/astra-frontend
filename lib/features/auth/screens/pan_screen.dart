import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/why_pan_overlay.dart';

/// PAN verification screen representing the secondary onboarding step.
/// Validates 10 alphanumeric uppercase characters and collects Account Aggregator consent.
class PanVerificationScreen extends ConsumerStatefulWidget {
  const PanVerificationScreen({super.key});

  @override
  ConsumerState<PanVerificationScreen> createState() => _PanVerificationScreenState();
}

class _PanVerificationScreenState extends ConsumerState<PanVerificationScreen> {
  final _panController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isConsented = false;
  bool _isHoveredButton = false;

  @override
  void initState() {
    super.initState();
    _panController.addListener(_onPanChanged);
  }

  void _onPanChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _panController.removeListener(_onPanChanged);
    _panController.dispose();
    _focusNode.dispose();
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
      context.go('/connect-assets');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final isEnabled = _panController.text.trim().length == 10 && _isConsented && !isLoading;

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
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter your PAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle with clickable Why PAN?
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF), height: 1.4),
                        children: [
                          const TextSpan(text: 'All investments linked to your PAN & mobile\nwill be fetched '),
                          TextSpan(
                            text: 'Why PAN?',
                            style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = _showWhyPanOverlay,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // PAN Number Input Box
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF13161F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? const Color(0xFF6366F1)
                              : Colors.white.withValues(alpha: 0.12),
                          width: _focusNode.hasFocus ? 1.5 : 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter your PAN Number',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          TextField(
                            controller: _panController,
                            focusNode: _focusNode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'ABCDE1234F',
                              hintStyle: TextStyle(
                                color: Colors.white24,
                                letterSpacing: 1.5,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.only(top: 4),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                              LengthLimitingTextInputFormatter(10),
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => newValue.copyWith(
                                  text: newValue.text.toUpperCase(),
                                ),
                              ),
                            ],
                            onChanged: (val) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Helper Text / Info
                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Your PAN is encrypted and securely stored',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Authorization Checkbox & Consent Text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isConsented,
                          onChanged: isLoading
                              ? null
                              : (val) => setState(() => _isConsented = val ?? false),
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                              height: 1.45,
                            ),
                            children: [
                              const TextSpan(text: 'I authorise '),
                              const TextSpan(
                                text: 'Astra Investments (AIPL)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' to fetch my data via Account Aggregator & '),
                              const TextSpan(
                                text: 'Astra Distribution (ADSPL)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text:
                                    ' to fetch via MF Central. We will securely fetch your data from aggregators you have already consented to, helping us complete this faster. ',
                              ),
                              TextSpan(
                                text: 'Know more',
                                style: const TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = _showWhyPanOverlay,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Continue Button
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHoveredButton = true),
                    onExit: (_) => setState(() => _isHoveredButton = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      transform: Matrix4.translationValues(
                          0.0, _isHoveredButton && isEnabled ? -2.0 : 0.0, 0.0),
                      child: ElevatedButton(
                        onPressed: isEnabled ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEnabled ? Colors.white : const Color(0xFF20232C),
                          disabledBackgroundColor: const Color(0xFF20232C),
                          foregroundColor: isEnabled ? Colors.black : Colors.white24,
                          disabledForegroundColor: Colors.white24,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: isEnabled && _isHoveredButton ? 8 : 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
    ));
  }
}
