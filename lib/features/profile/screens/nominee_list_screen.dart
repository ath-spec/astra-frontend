import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NomineeListScreen extends StatelessWidget {
  const NomineeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(left: 24.w, top: 16.h, right: 24.w, bottom: 24.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44.w,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 44.w), // balance the back button
                        child: Text(
                          'NOMINEES',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              height: 1,
              color: const Color(0xFFF1F5F9),
            ),

            // Main Content (Empty State)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration placeholder
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_search_rounded,
                          size: 64,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    
                    // Title
                    Text(
                      'No nominees yet',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    
                    // Subtitle
                    Text(
                      'Add a nominee to your mutual fund investments.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48.h),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: EdgeInsets.all(24.w),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Add a nominee',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
