import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MfHoldingsEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ctaText;
  final String imagePath;
  final VoidCallback? onCtaTapped;

  const MfHoldingsEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.imagePath,
    this.onCtaTapped,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = screenWidth < 420 ? screenWidth / 420 : 1.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: const Color.fromARGB(255, 224, 224, 224)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 210, // Increased size, touching edge directly
              height: 210,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: onCtaTapped,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        ctaText.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
