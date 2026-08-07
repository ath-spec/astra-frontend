import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MfWatchlistEmptyState extends StatelessWidget {
  final VoidCallback? onCtaTapped;

  const MfWatchlistEmptyState({
    super.key,
    this.onCtaTapped,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = screenWidth < 420 ? screenWidth / 420 : 1.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          bottom: 80.0, // Offsets visual weight of the text
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              height: 220,
              child: Image.asset(
                'lib/core/images/wishlistempty.webp',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Column(
              children: [
                Text(
                  "Nothing bookmarked",
                  textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Tap the bookmark on any fund to track its NAV and returns here - no pressure to buy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  GestureDetector(
                    onTap: onCtaTapped,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        "Explore All Funds".toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
