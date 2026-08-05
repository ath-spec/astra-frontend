import 'package:flutter/material.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfCollectionScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imagePath;

  const MfCollectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
  });

  @override
  State<MfCollectionScreen> createState() => _MfCollectionScreenState();
}

class _MfCollectionScreenState extends State<MfCollectionScreen> {
  String _returnPeriod = '3Y'; // '1Y', '3Y', '5Y'

  final List<Map<String, dynamic>> _mockFunds = [
    {
      'name': 'Quant Value Fund',
      'category': 'Equity • Value',
      'returns': {'1Y': '45.12%', '3Y': '22.56%', '5Y': '18.42%'},
    },
    {
      'name': 'Axis Value Fund',
      'category': 'Equity • Value',
      'returns': {'1Y': '38.54%', '3Y': '18.73%', '5Y': '15.20%'},
    },
    {
      'name': 'HSBC Value Fund',
      'category': 'Equity • Value',
      'returns': {'1Y': '36.20%', '3Y': '18.40%', '5Y': '14.90%'},
    },
    {
      'name': 'DSP Value Fund',
      'category': 'Equity • Value',
      'returns': {'1Y': '34.11%', '3Y': '17.53%', '5Y': '14.50%'},
    },
    {
      'name': 'LIC MF Value Fund',
      'category': 'Equity • Value',
      'returns': {'1Y': '32.90%', '3Y': '17.51%', '5Y': '13.80%'},
    },
    {
      'name': 'HDFC Value Fund',
      'category': 'Equity • Value',
      'returns': {'1Y': '31.40%', '3Y': '17.03%', '5Y': '14.10%'},
    },
    {
      'name': 'Aditya Birla Sun Life Value Fund',
      'category': 'Equity • Value',
      'returns': {'1Y': '29.80%', '3Y': '16.98%', '5Y': '13.50%'},
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 40,
                height: 40,
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1E1E1E)),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
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
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1E1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                color: Color(0xFF64748B), // Slate 500
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Graphic
                      if (widget.imagePath != null)
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: Image.asset(
                            widget.imagePath!,
                            fit: BoxFit.contain,
                          ),
                        )
                      else
                        const SizedBox(
                          width: 140,
                          height: 140,
                          child: Icon(Icons.pie_chart, color: Color(0xFF00C75A), size: 60),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Fund List
                  ..._mockFunds.map((fund) => _buildFundRow(fund)).toList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildFundRow(Map<String, dynamic> fund) {
    return Column(
      children: [
        InkWell(
          onTap: () => MfFundProfileScreen.showModal(context, fund['name']),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                        fund['name'].toString().substring(0, 1),
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars, color: Colors.deepOrange, size: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund['name'],
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fund['category'],
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        color: Color(0xFF64748B),
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
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C75A),
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
