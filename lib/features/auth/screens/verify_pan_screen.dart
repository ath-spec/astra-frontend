import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/link_different_pan_bottom_sheet.dart';

class VerifyPanScreen extends ConsumerStatefulWidget {
  const VerifyPanScreen({super.key});

  @override
  ConsumerState<VerifyPanScreen> createState() => _VerifyPanScreenState();
}

class _VerifyPanScreenState extends ConsumerState<VerifyPanScreen> {
  bool _enableWhatsapp = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a subtle gradient background to match the glassy look around the card
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
              if (context.canPop()) {
                context.pop();
              }
            }
          },
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Verify your PAN\ndetails to proceed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'We required your PAN to fetch your investment\naccounts securely',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'NAME',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Yugal Bharadwaj',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  CustomPaint(
                                    size: const Size(double.infinity, 1),
                                    painter: _DottedLinePainter(),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'PAN NUMBER',
                                            style: TextStyle(
                                              fontFamily: 'DMSans',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.5,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'DRGPB0250M',
                                            style: TextStyle(
                                              fontFamily: 'DMSans',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showLinkDifferentPanBottomSheet(context);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            'Edit PAN number',
                                            style: TextStyle(
                                              fontFamily: 'DMSans',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2563EB),
                                              decoration: TextDecoration.underline,
                                              decorationColor: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFF8FAFC).withValues(alpha: 0.5),
                                    const Color(0xFFF1F5F9),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 18,
                                    color: Color(0xFF64748B),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Securely fetched from CRED',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _enableWhatsapp = !_enableWhatsapp;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _enableWhatsapp,
                                onChanged: (val) {
                                  setState(() {
                                    _enableWhatsapp = val ?? true;
                                  });
                                },
                                activeColor: const Color(0xFF0F172A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Enable Whatsapp messages to get updates on\npayments, orders, and other alerts',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF334155),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/mf-fetch-confirm');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm and proceed',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'SEBI-registered intermediary – Arevuk',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
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
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    double startX = 0;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


