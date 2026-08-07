import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../order_details/screens/order_details_screen.dart';

class OrdersBottomSheet extends StatelessWidget {
  const OrdersBottomSheet({super.key});

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
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
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
                  'orders',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'following is a record of all past orders in the\nCanara Robeco Large Cap Growth Direct Plan',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Divider(color: const Color(0xFFF1F5F9), thickness: 1),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                _buildOrderRow(context, '₹22,501.87', '12 Feb \'26'),
                _buildOrderRow(context, '₹124.99', '2 Feb \'26'),
                _buildOrderRow(context, '₹369.98', '27 Jan \'26'),
                _buildOrderRow(context, '₹100', '20 Jan \'26'),
                _buildOrderRow(context, '₹100', '19 Jan \'26'),
                _buildOrderRow(context, '₹100', '19 Jan \'26'),
                _buildOrderRow(context, '₹299.99', '29 Dec \'25'),
                SizedBox(height: 24.h), // bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(BuildContext context, String amount, String date) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderDetailsScreen(),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'BUY',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    date,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amount,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'COMPLETED',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Icon(
                      Icons.chevron_right,
                      size: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildDashedDivider(),
        ],
      ),
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
