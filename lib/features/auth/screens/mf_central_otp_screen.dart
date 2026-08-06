import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MfCentralOtpScreen extends StatefulWidget {
  final bool isOnboarding;
  const MfCentralOtpScreen({super.key, this.isOnboarding = false});

  @override
  State<MfCentralOtpScreen> createState() => _MfCentralOtpScreenState();
}

class _MfCentralOtpScreenState extends State<MfCentralOtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _onSkip() {
    context.go('/home'); // Or just '/' depending on app routing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No mutual funds added as the connection was skipped.'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onAuthenticate() {
    context.pushReplacement('/mf-central-cas', extra: {'isOnboarding': widget.isOnboarding});
  }

  Widget _buildSecurityListItem({required IconData icon, required Color iconColor, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final double scale = size.width / 375.0; // Base width is 375
    final double logicalHeight = (size.height - padding.top - padding.bottom) / scale;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grey background
      resizeToAvoidBottomInset: false, // Prevents choppy layout rebuilds
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 375,
            height: logicalHeight,
            child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF0F172A)),
                    ),
                  ),
                  TextButton(
                    onPressed: _onSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: (MediaQuery.viewInsetsOf(context).bottom / scale) + 24,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Logo Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/core/images/mfcentral_logo.webp',
                          height: 72,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Data being fetched for:\nPersonal Finance Management',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3B82F6),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // OTP Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.security, color: Color(0xFF9333EA), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Enter your 6-digit OTP',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // OTP Input Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: 42,
                                height: 46,
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onTap: () {
                                    int targetIndex = -1;
                                    for (int i = 0; i < 6; i++) {
                                      if (_otpControllers[i].text.isEmpty) {
                                        targetIndex = i;
                                        break;
                                      }
                                    }
                                    if (targetIndex == -1) targetIndex = 5;
                                    if (index != targetIndex) {
                                      _focusNodes[targetIndex].requestFocus();
                                    }
                                  },
                                  onChanged: (value) => _onOtpChanged(value, index),
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 32),
                          // Authenticate Button
                          ElevatedButton(
                            onPressed: _onAuthenticate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA855F7), // Purple color
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Authenticate with OTP',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Security Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.verified_user, color: Color(0xFF1D4ED8), size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Secure Authentication for Portfolio Access',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D4ED8),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSecurityListItem(
                            icon: Icons.info,
                            iconColor: const Color(0xFFEF4444),
                            text: 'We do not store your OTP or sensitive credentials',
                          ),
                          _buildSecurityListItem(
                            icon: Icons.star,
                            iconColor: const Color(0xFFEF4444),
                            text: 'Data is end to end encrypted and securely shared only on authentication of OTP by Investor',
                          ),
                          _buildSecurityListItem(
                            icon: Icons.info,
                            iconColor: const Color(0xFF64748B),
                            text: 'Access is limited to Personal Finance Management only',
                          ),
                          _buildSecurityListItem(
                            icon: Icons.check,
                            iconColor: const Color(0xFF22C55E),
                            text: 'Consent artifact is valid for one time data sharing',
                          ),
                          _buildSecurityListItem(
                            icon: Icons.check,
                            iconColor: const Color(0xFF22C55E),
                            text: 'MF Central follows an every time consent model for sharing the data',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Bottom Fixed Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: Colors.white,
              child: Column(
                children: const [
                  Text(
                    'STEP 1 OF 2',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter OTP',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
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
  );
  }
}


