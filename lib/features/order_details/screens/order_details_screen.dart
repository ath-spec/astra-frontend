import 'package:flutter/material.dart';
import '../../mf/screens/fund_profile/mf_fund_profile_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
        return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainCard(context),
                    SizedBox(height: 32),
                    _buildExpandableSection('More details'),
                    _buildDivider(),
                    _buildSupportSection(),
                    _buildDivider(),
                  ],
                ),
              ),
            ),
            _buildBottomSupportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
          Center(
            child: Text(
              'Order details',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Logo with star badge
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
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
                              fontSize: 6,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F8387),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.brightness_high,
                              size: 12,
                              color: const Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Canara Robeco Large Cap Fund',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Equity • Large-Cap',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
          
          Divider(color: const Color(0xFFE2E8F0), height: 1, thickness: 1),
          
          // Bottom half (Order info)
          Padding(
            padding: EdgeInsets.all(16),
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
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'EXTERNAL',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹100',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14, // Max allowed font size
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Completion date',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                    Text(
                      '20 Jan \'26',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
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

  Widget _buildExpandableSection(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14, // Strict max size
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent_outlined,
                size: 20,
                color: Colors.black,
              ),
              SizedBox(width: 12),
              Text(
                'Need help? Contact support',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0xFFE2E8F0),
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildBottomSupportButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headset_mic_outlined,
              size: 16,
              color: Colors.black,
            ),
            SizedBox(width: 8),
            Text(
              'Support',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12, // CTA size
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
