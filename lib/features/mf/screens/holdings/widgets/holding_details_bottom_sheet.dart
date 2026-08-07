import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'holding_item.dart';
import 'package:astra_frontend/core/widgets/dashed_line.dart'; // Using the dashed line widget

class HoldingDetailsBottomSheet extends StatelessWidget {
  final HoldingItem item;
  final NumberFormat formatCurrency;

  const HoldingDetailsBottomSheet({
    super.key,
    required this.item,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
        final isPosRet = item.returns >= 0;
    final isPos1D = item.oneDayChange >= 0;
    final lifetimeXirr = item.xirr - 0.53; // Mocked slightly lower than current XIRR for realism

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 24.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Holding details',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 20),

              // Current value
              _buildDetailRow(
                label: 'Current value',
                value: formatCurrency.format(item.current),
                valueColor: const Color(0xFF0F172A),
                
              ),
              SizedBox(height: 16.h),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 16.h),

              // Invested
              _buildDetailRow(
                label: 'Invested',
                value: formatCurrency.format(item.invested),
                valueColor: const Color(0xFF0F172A),
                
              ),
              SizedBox(height: 16.h),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 16.h),

              // Total returns
              _buildDetailRow(
                label: 'Total returns',
                value: '${isPosRet ? '+' : ''} ${formatCurrency.format(item.returns)} (${item.returnsPercent.toStringAsFixed(2)}%)',
                valueColor: isPosRet ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                
              ),
              SizedBox(height: 16.h),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 16.h),

              // 1D change
              _buildDetailRow(
                label: '1D change',
                value: '${isPos1D ? '↑' : '↓'} ${formatCurrency.format(item.oneDayChange.abs())} (${item.oneDayChangePercent.abs().toStringAsFixed(2)}%)',
                valueColor: isPos1D ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                
              ),
              SizedBox(height: 20),
              
              // Dashed divider
              const DashedLine(
                color: Color(0xFFE2E8F0),
                height: 1,
                dashWidth: 4,
                dashSpace: 4,
              ),
              SizedBox(height: 24.h),

              // XIRR Section Title
              Text(
                'XIRR',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 20),

              // Current XIRR
              _buildXirrRow(
                label: 'Current XIRR',
                value: '${item.xirr.toStringAsFixed(2)}%',
                subtext: 'Tracks only your current holdings, excluding past redemptions',
                
              ),
              SizedBox(height: 16.h),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 16.h),

              // Lifetime XIRR
              _buildXirrRow(
                label: 'Lifetime XIRR',
                value: '${lifetimeXirr.toStringAsFixed(2)}%',
                subtext: 'Tracks all your investments and redemptions since you started, including units you redeemed.',
                
              ),
              SizedBox(height: 32.h),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value, required Color valueColor, }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF334155),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildXirrRow({required String label, required String value, required String subtext, }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          subtext,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
