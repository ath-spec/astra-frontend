import 'package:flutter/material.dart';

class AllocationFactorInfoSheet extends StatefulWidget {
  final int initialIndex;

  const AllocationFactorInfoSheet({super.key, required this.initialIndex});

  @override
  State<AllocationFactorInfoSheet> createState() => _AllocationFactorInfoSheetState();
}

class _AllocationFactorInfoSheetState extends State<AllocationFactorInfoSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Stable',
    'Low Volatility',
    'Medium Volatility',
    'High Volatility',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            labelColor: const Color(0xFF0F172A),
            unselectedLabelColor: const Color(0xFF64748B),
            labelStyle: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: const Color(0xFF0F172A),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            dividerColor: Colors.transparent,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStableTab(),
                _buildEmptyTab('Low Volatility Assets'),
                _buildEmptyTab('Medium Volatility Assets'),
                _buildHighVolatilityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStableTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STABLE ASSETS',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '₹3,058',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '1.0% of total holdings',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
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
                    text: 'Stable assets: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(
                    text: 'Includes banks, FDs, and liquid or overnight funds. These are usually the steadiest part of a portfolio, meant to keep things grounded and accessible.',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'BANKS (1)',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                'CURRENT BALANCE',
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
          
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          
          Row(
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
                    'i',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE53E3E), // ICICI red-ish
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ICICI Bank',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '.. 5705',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '₹3,058',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighVolatilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'HIGH VOLATILITY',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFE53E3E)),
            ],
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
                '99.0% of total holdings',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
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
                    text: 'High volatility assets ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(
                    text: 'include equities and certain mutual funds. They can swing significantly in value over the short term but offer the potential for higher returns in the long run.',
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
                'MUTUAL FUNDS (4)',
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
          ),
          _buildFundItem(
            name: 'Quantum Gold ETF FoF',
            value: '₹99,025',
            color: const Color(0xFF1E3A8A),
          ),
          _buildFundItem(
            name: 'Tata Gold ETF FoF',
            value: '₹9,377',
            color: const Color(0xFF4338CA),
          ),
          _buildFundItem(
            name: 'HDFC Silver ETF FoF',
            value: '₹186',
            color: const Color(0xFF0284C7),
            isLast: true,
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
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
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
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
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
        if (!isLast) ...[
          const SizedBox(height: 20),
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DottedLinePainter(),
          ),
          const SizedBox(height: 20),
        ]
      ],
    );
  }

  Widget _buildEmptyTab(String title) {
    return Center(
      child: Text(
        'No $title currently.',
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 14,
          color: Color(0xFF64748B),
        ),
      ),
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
