import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/orders_bottom_sheet.dart';
import '../widgets/folios_bottom_sheet.dart';
import '../../mf/screens/fund_profile/mf_fund_profile_screen.dart';
import '../../mf/screens/holdings/widgets/holding_item.dart';
import '../../mf/screens/holdings/widgets/holding_instrument_card.dart';
import '../widgets/holding_fund_insights.dart';

class YourFundProfileScreen extends StatelessWidget {
  const YourFundProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We will use MediaQuery to get relative but stick strictly to requested font sizes.
    final screenWidth = MediaQuery.of(context).size.width;
        return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),
                          _buildHeader(context),
                          SizedBox(height: 32.h),
                          _buildValueCard(),
                          _buildDetailsList(),
                          SizedBox(height: 32.h),
                          Divider(
                            color: const Color(0xFFE2E8F0),
                            thickness: 1,
                          ),
                          SizedBox(height: 24.h),
                          _buildMoreDetailsSection(context),
                          SizedBox(height: 24.h),
                          // Injecting mock deep dive data here for demonstration
                          HoldingInstrumentCard(
                            data: HoldingDeepDiveData(
                              primaryRole: 'Core Growth',
                              secondaryRole: 'Capital Preservation',
                              contribution: 'Provides stability and consistent growth by investing in established, large-cap companies. Acts as an anchor for the equity portion of your portfolio.',
                            ),
                          ),
                          SizedBox(height: 24.h),
                          HoldingFundInsights(
                            isPositiveImpact: true,
                            whatItDoesRightNow: 'Currently provides a solid foundation of large-cap equity exposure, balancing out the higher volatility of your mid and small-cap holdings.',
                            whatBuyingMoreWillDo: 'Adding more to this fund will pull your overall portfolio slightly towards the "Capital Preservation" and "Income" vectors, reducing overall portfolio volatility while maintaining steady growth.',
                          ),
                          SizedBox(height: 120), // Padding for sticky bottom CTA
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildStickyBottomCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            width: 56.w,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'CANARA\nROBECO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10, // Strict size
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0E7490),
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MfFundProfileScreen(fundId: '1'),
              ),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Canara Robeco Large Cap Fund',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14.sp, // Strict size
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Equity • Large-Cap',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10, // Strict size
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star, // Mocking the red dot/asterisk
                size: 8,
                color: const Color(0xFFEF4444),
              ),
              SizedBox(width: 6.w),
              Text(
                'HIGH VOLATILITY FUND',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10, // Strict size
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Value',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10, // Strict size
              color: const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '₹2,36,538.56',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14.sp, // Strict size (constrained from huge to 14)
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8.r),
          bottomRight: Radius.circular(8.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Invested', '₹2,25,026'),
          _buildDashedDivider(),
          _buildDetailRow('Total returns', '₹11,511.77 (5.12%)', valueColor: const Color(0xFF059669)),
          _buildDashedDivider(),
          _buildDetailRow('XIRR', '3.23%', valueColor: const Color(0xFF059669), hasArrow: true),
          _buildDashedDivider(),
          _buildDetailRow('No. of units', '3,244.7'),
          _buildDashedDivider(),
          _buildDetailRow('Current Scheme NAV', '₹72.9'),
          _buildDashedDivider(),
          _buildDetailRow('Average holdings NAV', '₹69.35'),
          _buildDashedDivider(),
          _buildDetailRow('Scheme Plan', 'Growth'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool hasArrow = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10, // Strict size
                  color: const Color(0xFF64748B),
                ),
              ),
              if (hasArrow) ...[
                SizedBox(width: 4.w),
                Icon(Icons.keyboard_arrow_down, size: 16, color: const Color(0xFF64748B)),
              ],
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10, // Strict size
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F172A),
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

  Widget _buildMoreDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MORE DETAILS',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10, // Strict size
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const OrdersBottomSheet(),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: _buildListTile('Orders', '46 completed orders'),
        ),
        _buildDashedDivider(),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => const FoliosBottomSheet(),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: _buildListTile('Folios', '1 folio'),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 14,
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12.sp, // Strict size
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10, // Strict size
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomCTA() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Manage',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10, // Strict size matching other CTAs
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: const Color(0xFF0F172A), width: 1.5.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Invest more',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10, // Strict size matching other CTAs
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
