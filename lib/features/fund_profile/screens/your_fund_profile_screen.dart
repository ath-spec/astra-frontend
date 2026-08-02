import 'package:flutter/material.dart';
import '../widgets/orders_bottom_sheet.dart';
import '../widgets/folios_bottom_sheet.dart';
import '../../mf/screens/fund_profile/mf_fund_profile_screen.dart';

class YourFundProfileScreen extends StatelessWidget {
  const YourFundProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We will use MediaQuery to get relative scale, but stick strictly to requested font sizes.
    final screenWidth = MediaQuery.of(context).size.width;
    final s = screenWidth / 375.0; // Base scale on iPhone 11/13 Pro width

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(context, s),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * s),
                      child: Column(
                        children: [
                          SizedBox(height: 16 * s),
                          _buildHeader(context, s),
                          SizedBox(height: 32 * s),
                          _buildValueCard(s),
                          _buildDetailsList(s),
                          SizedBox(height: 32 * s),
                          Divider(
                            color: const Color(0xFFE2E8F0),
                            thickness: 1,
                          ),
                          SizedBox(height: 24 * s),
                          _buildMoreDetailsSection(context, s),
                          SizedBox(height: 120 * s), // Padding for sticky bottom CTA
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildStickyBottomCTA(s),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24 * s, 16 * s, 24 * s, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40 * s,
                height: 40 * s,
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
                  size: 16 * s,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            width: 56 * s,
            height: 56 * s,
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
                  fontSize: 10 * s, // Strict size
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

  Widget _buildHeader(BuildContext context, double s) {
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
                  fontSize: 14 * s, // Strict size
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 4 * s),
              Icon(
                Icons.chevron_right,
                size: 16 * s,
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          'Equity • Large-Cap',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10 * s, // Strict size
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 12 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star, // Mocking the red dot/asterisk
                size: 8 * s,
                color: const Color(0xFFEF4444),
              ),
              SizedBox(width: 6 * s),
              Text(
                'HIGH VOLATILITY FUND',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10 * s, // Strict size
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

  Widget _buildValueCard(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8 * s),
          topRight: Radius.circular(8 * s),
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
              fontSize: 10 * s, // Strict size
              color: const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            '₹2,36,538.56',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14 * s, // Strict size (constrained from huge to 14)
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8 * s),
          bottomRight: Radius.circular(8 * s),
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
          _buildDetailRow(s, 'Invested', '₹2,25,026'),
          _buildDashedDivider(s),
          _buildDetailRow(s, 'Total returns', '₹11,511.77 (5.12%)', valueColor: const Color(0xFF059669)),
          _buildDashedDivider(s),
          _buildDetailRow(s, 'XIRR', '3.23%', valueColor: const Color(0xFF059669), hasArrow: true),
          _buildDashedDivider(s),
          _buildDetailRow(s, 'No. of units', '3,244.7'),
          _buildDashedDivider(s),
          _buildDetailRow(s, 'Current Scheme NAV', '₹72.9'),
          _buildDashedDivider(s),
          _buildDetailRow(s, 'Average holdings NAV', '₹69.35'),
          _buildDashedDivider(s),
          _buildDetailRow(s, 'Scheme Plan', 'Growth'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(double s, String label, String value, {Color? valueColor, bool hasArrow = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10 * s, // Strict size
                  color: const Color(0xFF64748B),
                ),
              ),
              if (hasArrow) ...[
                SizedBox(width: 4 * s),
                Icon(Icons.keyboard_arrow_down, size: 16 * s, color: const Color(0xFF64748B)),
              ],
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10 * s, // Strict size
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider(double s) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 4.0 * s;
        final dashHeight = 1.0 * s;
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

  Widget _buildMoreDetailsSection(BuildContext context, double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MORE DETAILS',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10 * s, // Strict size
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 16 * s),
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
          child: _buildListTile(s, 'Orders', '46 completed orders'),
        ),
        _buildDashedDivider(s),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => const FoliosBottomSheet(),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: _buildListTile(s, 'Folios', '1 folio'),
        ),
      ],
    );
  }

  Widget _buildListTile(double s, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * s),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 14 * s,
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12 * s, // Strict size
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10 * s, // Strict size
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 16 * s,
            color: const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomCTA(double s) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(24 * s, 16 * s, 24 * s, 24 * s),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48 * s,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4 * s),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Manage',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10 * s, // Strict size matching other CTAs
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: SizedBox(
                  height: 48 * s,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: const Color(0xFF0F172A), width: 1.5 * s),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4 * s),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Invest more',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10 * s, // Strict size matching other CTAs
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
