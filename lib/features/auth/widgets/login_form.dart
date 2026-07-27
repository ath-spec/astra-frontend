import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isConsented = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        launchUrl(Uri.parse('https://www.zeyro.in/terms'));
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        launchUrl(Uri.parse('https://www.zeyro.in/privacy'));
      };
  }

  void _onPhoneChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_phoneController.text.length == 10 && _isConsented) {
      ref.read(authProvider.notifier).setPendingPhone(_phoneController.text);
      context.push('/otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final isEnabled =
        _phoneController.text.length == 10 && _isConsented && !isLoading;

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                if (authState is AuthError) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      authState.message,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  "What's your number?",
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -1.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'INDIA',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1D5DB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+91',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Transform.translate(
                  offset: const Offset(-4, 0),
                  child: TextField(
                    controller: _phoneController,
                    focusNode: _focusNode,
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: Color(0xFF111827),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '9876543210',
                      hintStyle: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "WE'LL TEXT YOU A CODE.",
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 40),
                  // Terms of Service Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: isLoading ? null : () => setState(() => _isConsented = !_isConsented),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          // Expand the touch area out to the right and bottom
                          padding: const EdgeInsets.only(right: 12, bottom: 12, top: 2, left: 4),
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
                                activeColor: Color(0xFF111827),
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
                            style: TextStyle(
                              fontFamily: 'DMMono',
                              color: Color(0xFF6B7280),
                              fontSize: 8,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              letterSpacing: 0.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'By continuing, I agree to the '
                                    .toUpperCase(),
                              ),
                              TextSpan(
                                text: 'terms of service'.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: _termsRecognizer,
                              ),
                              TextSpan(
                                text:
                                    ' agreement and provide my consent for collection, verification, and processing of my information as described in the '
                                        .toUpperCase(),
                              ),
                              TextSpan(
                                text: 'privacy policy.'.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: _privacyRecognizer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Submit Button
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
                              Text(
                                'CONTINUE',
                                style: const TextStyle(
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
        ),
      ],
    );
  }
}
