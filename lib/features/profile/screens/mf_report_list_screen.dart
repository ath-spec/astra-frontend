import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MfReportListScreen extends StatelessWidget {
  final String title;

  const MfReportListScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
        final List<Map<String, String>> years = [
      {'fy': 'FY 2026-27', 'desc': "from april '26 to mar '27"},
      {'fy': 'FY 2025-26', 'desc': "from april '25 to mar '26"},
      {'fy': 'FY 2024-25', 'desc': "from april '24 to mar '25"},
      {'fy': 'FY 2023-24', 'desc': "from april '23 to mar '24"},
      {'fy': 'FY 2022-23', 'desc': "from april '22 to mar '23"},
      {'fy': 'FY 2021-22', 'desc': "from april '21 to mar '22"},
      {'fy': 'FY 2020-21', 'desc': "from april '20 to mar '21"},
      {'fy': 'FY 2019-20', 'desc': "from april '19 to mar '20"},
      {'fy': 'FY 2018-19', 'desc': "from april '18 to mar '19"},
      {'fy': 'FY 2017-18', 'desc': "from april '17 to mar '18"},
    ];

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
                          title.toUpperCase(),
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

            // List of Reports
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(24.w),
                itemCount: years.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final data = years[index];
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC), // very light gray/blue fill
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: const Color(0xFF0F172A), width: 1.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['fy']!,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              data['desc']!,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: const Color(0xFF0F172A), width: 1.0),
                          ),
                          child: Text(
                            'Download',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
