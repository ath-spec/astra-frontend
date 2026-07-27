import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'see_how_it_works_overlay.dart';

/// Phone number onboarding form with 10-digit validation and custom keypad support.
/// Replaces email/password form to match ASTRA mobile onboarding specs.
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isHoveredButton = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_phoneController.text.length == 10) {
      ref.read(authProvider.notifier).setPendingPhone(_phoneController.text);
      context.push('/pan');
    }
  }

  void _showSeeHowItWorks() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SeeHowItWorksOverlay(
        onGetStarted: () {
          _focusNode.requestFocus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final isEnabled = _phoneController.text.length == 10 && !isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (authState is AuthError) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authState.message,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Phone Number Input Box
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Phone Number',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  const Text(
                    '+91  ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      focusNode: _focusNode,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        hintText: '8826473535',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.15),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  if (_phoneController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _phoneController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Conditional Get Started Button with press feedback
        MouseRegion(
          onEnter: (_) => setState(() => _isHoveredButton = true),
          onExit: (_) => setState(() => _isHoveredButton = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0.0, _isHoveredButton && isEnabled ? -2.0 : 0.0, 0.0),
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
                      'Get Started ->',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // See how it works Link
        Center(
          child: GestureDetector(
            onTap: _showSeeHowItWorks,
            child: const Text(
              'See how it works',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
