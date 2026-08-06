import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/link_different_pan_bottom_sheet.dart';
import '../widgets/mf_central_ogin_bottom_sheet.dart';

class MfFetchConfirmScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;
  const MfFetchConfirmScreen({super.key, this.isOnboarding = false});

  @override
  ConsumerState<MfFetchConfirmScreen> createState() =>
      _MfFetchConfirmScreenState();
}

class _MfFetchConfirmScreenState extends ConsumerState<MfFetchConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider.notifier);
    final phone = authState.pendingPhone.isNotEmpty
        ? authState.pendingPhone
        : '6351539934';
    final pan = authState.pendingPan.isNotEmpty
        ? authState.pendingPan
        : 'QWERTY0250M';

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final double scale = size.width / 375.0; // Base width is 375
    final double logicalHeight = (size.height - padding.top - padding.bottom) / scale;

    return Scaffold(
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
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 300) {
              if (context.canPop()) {
                context.pop();
              }
            }
          },
          child: SafeArea(
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 375,
                height: logicalHeight,
                child: Stack(
                  children: [
                Center(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      4,
                    ), // User requested border radius 4
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 80,
                          width: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: -0.15,
                              child: Container(
                                width: 60,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFF64748B),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF94A3B8),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          bottomLeft: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.currency_rupee,
                                      size: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E), // Green 500
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_downward,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Let's connect Mutual Funds",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'An OTP will be sent to your number to fetch\nyour holdings via MF Central.',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Inner Card matching the uploaded image design
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            4,
                          ), // User requested border radius 4
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PHONE NUMBER',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '+91 $phone',
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await context.push('/mf-edit-phone');
                                          setState(() {});
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: const Padding(
                                          padding: EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            'Edit number',
                                            style: TextStyle(
                                              fontFamily: 'DMSans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(
                                                0xFF2563EB,
                                              ), // Blue color like the image
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Color(
                                                0xFF2563EB,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Dashed Divider
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final boxWidth = constraints.constrainWidth();
                                  const dashWidth = 4.0;
                                  const dashHeight = 1.0;
                                  final dashCount = (boxWidth / (2 * dashWidth))
                                      .floor();
                                  return Flex(
                                    direction: Axis.horizontal,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(dashCount, (_) {
                                      return const SizedBox(
                                        width: dashWidth,
                                        height: dashHeight,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PAN NUMBER',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        pan,
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final shouldEdit = await showLinkDifferentPanBottomSheet(
                                            context,
                                          );
                                          if (shouldEdit == true && mounted) {
                                            context.pushReplacement('/pan', extra: {'isOnboarding': widget.isOnboarding});
                                          } else {
                                            setState(() {});
                                          }
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: const Padding(
                                          padding: EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            'Edit PAN number',
                                            style: TextStyle(
                                              fontFamily: 'DMSans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2563EB),
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Color(
                                                0xFF2563EB,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Footer gradient section
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(4),
                                ), // Match border radius 4
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00F1F5F9), // Transparent slate
                                    Color(0xFFF1F5F9), // Solid slate
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'powered by ',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Image.asset(
                                    'lib/core/images/mfcentral_logo.webp',
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          showMfCentralLoginBottomSheet(context, isOnboarding: widget.isOnboarding);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              4,
                            ), // User requested border radius 4
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm and proceed', // Matched button text from image
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
              Positioned(
                top: 16,
                left: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF0F172A),
                    size: 22,
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                ),
              ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
}
}
