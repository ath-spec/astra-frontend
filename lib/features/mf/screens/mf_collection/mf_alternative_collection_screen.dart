import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfAlternativeCollectionScreen extends StatefulWidget {
  final String title;
  final String subtitle;

  const MfAlternativeCollectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<MfAlternativeCollectionScreen> createState() => _MfAlternativeCollectionScreenState();
}

class _MfAlternativeCollectionScreenState extends State<MfAlternativeCollectionScreen> {
  String _returnPeriod = '3Y'; // '1Y', '3Y', '5Y'

  final List<Map<String, dynamic>> _mockFunds = [
    {
      'name': 'Union Liquid Fund',
      'category': 'Debt • Liquid',
      'returns': {'1Y': '7.0%', '3Y': '5.8%', '5Y': '5.2%'},
      'initial': 'U',
    },
    {
      'name': 'Nippon India Arbitrage Fund',
      'category': 'Alternative to FD',
      'returns': {'1Y': '7.8%', '3Y': '6.1%', '5Y': '5.5%'},
      'initial': 'N',
    },
    {
      'name': 'SBI Equity Savings Fund',
      'category': 'Alternative to FD',
      'returns': {'1Y': '9.2%', '3Y': '8.1%', '5Y': '7.3%'},
      'initial': 'S',
    },
    {
      'name': 'HDFC Liquid Fund',
      'category': 'Debt • Liquid',
      'returns': {'1Y': '7.1%', '3Y': '5.9%', '5Y': '5.3%'},
      'initial': 'H',
    },
    {
      'name': 'Kotak Equity Arbitrage',
      'category': 'Alternative to FD',
      'returns': {'1Y': '7.5%', '3Y': '6.0%', '5Y': '5.4%'},
      'initial': 'K',
    },
  ];

  void _cycleReturnPeriod() {
    setState(() {
      if (_returnPeriod == '1Y') {
        _returnPeriod = '3Y';
      } else if (_returnPeriod == '3Y') {
        _returnPeriod = '5Y';
      } else {
        _returnPeriod = '1Y';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
        return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(4.r),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: const Color(0xFF1E1E1E)),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  // Header Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E1E1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                color: const Color(0xFF64748B), // Slate 500
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Graphic
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.account_balance, color: const Color(0xFFDC2626), size: 40),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  // Fund List
                  ..._mockFunds.map((fund) => _buildFundRow(fund)).toList(),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFundRow(Map<String, dynamic> fund) {
    return Column(
      children: [
        InkWell(
          onTap: () => MfFundProfileScreen.showModal(context, fund['name']),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                // Logo
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Center(
                        child: Text(
                          fund['initial'],
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.stars, color: const Color(0xFFDC2626), size: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fund['name'],
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        fund['category'],
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Returns
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    fund['returns'][_returnPeriod],
                    key: ValueKey<String>('${fund['name']}_$_returnPeriod'),
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00C75A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Dashed border (simulated with a standard very light border for now)
        Container(
          height: 1,
          color: const Color(0xFFF8F9FA),
        ),
      ],
    );
  }
}
