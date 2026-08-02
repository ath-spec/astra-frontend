import 'package:flutter/material.dart';
import '../../mf/screens/fund_profile/mf_fund_profile_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final s = screenWidth / 375.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, s),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainCard(context, s),
                    SizedBox(height: 32 * s),
                    _buildExpandableSection(s, 'More details'),
                    _buildDivider(s),
                    _buildSupportSection(s),
                    _buildDivider(s),
                  ],
                ),
              ),
            ),
            _buildBottomSupportButton(s),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24 * s, 16 * s, 24 * s, 8 * s),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          GestureDetector(
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
          Center(
            child: Text(
              'Order details',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, double s) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * s),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top half (Fund info) - Clickable
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
            child: Padding(
              padding: EdgeInsets.all(16 * s),
              child: Row(
                children: [
                  // Logo with star badge
                  SizedBox(
                    width: 44 * s,
                    height: 44 * s,
                    child: Stack(
                      children: [
                        Container(
                          width: 40 * s,
                          height: 40 * s,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'CANARA\nROBECO',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 6 * s,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F8387),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(2 * s),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.brightness_high,
                              size: 12 * s,
                              color: const Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Canara Robeco Large Cap Fund',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        SizedBox(height: 2 * s),
                        Text(
                          'Equity • Large-Cap',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10 * s,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16 * s,
                    color: const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
          
          Divider(color: const Color(0xFFE2E8F0), height: 1, thickness: 1),
          
          // Bottom half (Order info)
          Padding(
            padding: EdgeInsets.all(16 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Buy order',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10 * s,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(2 * s),
                      ),
                      child: Text(
                        'EXTERNAL',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 8 * s,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹100',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14 * s, // Max allowed font size
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(2 * s),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 8 * s,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Completion date',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12 * s,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(width: 6 * s),
                        Icon(
                          Icons.info_outline,
                          size: 14 * s,
                          color: const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                    Text(
                      '20 Jan \'26',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(double s, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14 * s, // Strict max size
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20 * s,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent_outlined,
                size: 20 * s,
                color: Colors.black,
              ),
              SizedBox(width: 12 * s),
              Text(
                'Need help? Contact support',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Icon(
            Icons.chevron_right,
            size: 20 * s,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(double s) {
    return Divider(
      color: const Color(0xFFE2E8F0),
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildBottomSupportButton(double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24 * s, 16 * s, 24 * s, 24 * s),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(4 * s),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headset_mic_outlined,
              size: 16 * s,
              color: Colors.black,
            ),
            SizedBox(width: 8 * s),
            Text(
              'Support',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12 * s, // CTA size
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
