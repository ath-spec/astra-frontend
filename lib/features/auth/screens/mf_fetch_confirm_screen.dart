import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            child: Builder(
              builder: (context) => SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 24.h,
                ),
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      4,
                    ), // User requested border radius 4
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
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: const Color(0xFF64748B),
                                    width: 2.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12.w,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF94A3B8),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4.r),
                                          bottomLeft: Radius.circular(4.r),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
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
                                padding: EdgeInsets.all(4.w),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E), // Green 500
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
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
                      SizedBox(height: 24.h),
                      Text(
                        "Let's connect Mutual Funds",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
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
                      SizedBox(height: 32.h),
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
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PHONE NUMBER',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '+91 $phone',
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 12.sp,
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
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 2.h),
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
                              padding: EdgeInsets.symmetric(
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
                                      return SizedBox(
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
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PAN NUMBER',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        pan,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 12.sp,
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
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 2.h),
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
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(4.r),
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
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'powered by ',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 11.sp,
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
                      SizedBox(height: 32.h),
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
                        child: Text(
                          'Confirm and proceed', // Matched button text from image
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14.sp,
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
                top: 16.h,
                left: 8.w,
                child: IconButton(
                  icon: Icon(
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
