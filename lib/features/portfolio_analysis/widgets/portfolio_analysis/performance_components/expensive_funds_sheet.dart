import 'package:flutter/material.dart';
import '../../../../fund_profile/screens/your_fund_profile_screen.dart';

class ExpensiveFundsSheet extends StatefulWidget {
  final int initialIndex;

  const ExpensiveFundsSheet({super.key, this.initialIndex = 0});

  @override
  State<ExpensiveFundsSheet> createState() => _ExpensiveFundsSheetState();
}

class _ExpensiveFundsSheetState extends State<ExpensiveFundsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // TabBar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            indicatorColor: const Color(0xFF0F172A),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
            unselectedLabelColor: const Color(0xFF94A3B8),
            tabs: const [
              Tab(text: 'Low Cost Funds'),
              Tab(text: 'Expensive Funds'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLowCostTab(),
                _buildEmptyStateTab(
                  title: 'EXPENSIVE FUNDS',
                  infoText: 'Expensive funds',
                  infoDesc:
                      ' have a relatively high expense ratio. Higher fees can reduce the returns you keep over time.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowCostTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LOW COST FUNDS',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '₹3,45,126',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(100.0)% of mutual fund portfolio',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
                children: [
                  TextSpan(
                    text: 'Low cost funds ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(
                    text:
                        'have a relatively low expense ratio. Lower fees help maximize the returns you keep over time.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'MUTUAL FUNDS (2)',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                'HOLDINGS VALUE',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildFundItem(
            name: 'Canara Robeco Large Cap Fund',
            value: '₹2,36,538',
            color: const Color(0xFF0EA5E9),
            subtitle: 'Expense ratio: 0.5%',
            subtitleColor: const Color(0xFF64748B),
          ),
          _buildFundItem(
            name: 'Quantum Gold ETF FoF',
            value: '₹1,08,588',
            color: const Color(0xFF1E3A8A),
            subtitle: 'Expense ratio: 0.2%',
            subtitleColor: const Color(0xFF64748B),
            isLast: true,
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyStateTab({
    required String title,
    required String infoText,
    required String infoDesc,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '₹0',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(0.0)% of mutual fund portfolio',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
                children: [
                  TextSpan(
                    text: '$infoText ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(text: infoDesc),
                ],
              ),
            ),
          ),

          const SizedBox(height: 64),

          // Empty State
          Center(
            child: Column(
              children: const [
                Icon(
                  Icons.dashboard_customize_outlined,
                  size: 64,
                  color: Color(0xFFCBD5E1),
                ),
                SizedBox(height: 24),
                Text(
                  'No holdings found',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'We couldn\'t find any holdings related\nto your filters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildFundItem({
    required String name,
    required String value,
    required Color color,
    required String subtitle,
    required Color subtitleColor,
    bool isLast = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const YourFundProfileScreen(),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DottedLinePainter(),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    double dashWidth = 3;
    double dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
