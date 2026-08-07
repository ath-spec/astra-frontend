import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FoliosBottomSheet extends StatelessWidget {
  const FoliosBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
        return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Folios',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '1 folio',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildDashedDivider(),
                SizedBox(height: 24.h),
                Text(
                  '₹2,36,538.56',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      'Folio no. 17762024046',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Text(
                        'EXTERNAL',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48.h), // bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 4.0;
        final dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9)),
              ),
            );
          }),
        );
      },
    );
  }
}
