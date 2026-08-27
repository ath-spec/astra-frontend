import 'package:flutter/material.dart';
import '../../../../fund_profile/screens/your_fund_profile_screen.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/portfolio_analysis_models.dart';

String _formatInr(double value) {
  final rounded = value.round();
  final isNegative = rounded < 0;
  final digits = rounded.abs().toString();
  String formatted;
  if (digits.length <= 3) {
    formatted = digits;
  } else {
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final headFormatted = head.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (m) => '${m[1]},',
    );
    formatted = '$headFormatted,$tail';
  }
  return '${isNegative ? '-' : ''}₹$formatted';
}

String _pct(double v) => '${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}%';

class ExpensiveFundsSheet extends StatefulWidget {
  final int initialIndex;
  final PerformanceData? data;

  const ExpensiveFundsSheet({super.key, this.initialIndex = 0, this.data});

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

  List<FundPerformanceData> get _funds =>
      widget.data?.fundsPerformance ?? const <FundPerformanceData>[];

  Set<String> get _expensiveKeys {
    final ex = widget.data?.expensiveFunds ?? const <ExpensiveFundData>[];
    return ex
        .map((e) => e.schemeCode.isNotEmpty ? e.schemeCode : e.schemeName)
        .where((k) => k.isNotEmpty)
        .toSet();
  }

  bool _isExpensive(FundPerformanceData f) {
    final key = f.schemeCode.isNotEmpty ? f.schemeCode : f.schemeName;
    return _expensiveKeys.contains(key);
  }

  double get _totalMf =>
      _funds.fold<double>(0, (sum, f) => sum + f.currentValue);

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
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            indicatorColor: const Color(0xFF0F172A),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
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
            child: widget.data == null
                ? _buildSkeleton()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListTab(
                        items: _funds.where((f) => !_isExpensive(f)).toList(),
                        title: 'LOW COST FUNDS',
                        infoText: 'Low cost funds ',
                        infoDesc:
                            'have a relatively low expense ratio. Lower fees help maximize the returns you keep over time.',
                        emptyInfoText: 'Low cost funds',
                        emptyInfoDesc:
                            ' have a relatively low expense ratio. Lower fees help maximize the returns you keep over time.',
                      ),
                      _buildListTab(
                        items: _funds.where(_isExpensive).toList(),
                        title: 'EXPENSIVE FUNDS',
                        infoText: 'Expensive funds ',
                        infoDesc:
                            'have a relatively high expense ratio. Higher fees can reduce the returns you keep over time.',
                        emptyInfoText: 'Expensive funds',
                        emptyInfoDesc:
                            ' have a relatively high expense ratio. Higher fees can reduce the returns you keep over time.',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTab({
    required List<FundPerformanceData> items,
    required String title,
    required String infoText,
    required String infoDesc,
    required String emptyInfoText,
    required String emptyInfoDesc,
  }) {
    if (items.isEmpty) {
      return _buildEmptyStateTab(
        title: title,
        infoText: emptyInfoText,
        infoDesc: emptyInfoDesc,
      );
    }

    final bucketValue =
        items.fold<double>(0, (sum, f) => sum + f.currentValue);
    final pct = _totalMf > 0 ? (bucketValue / _totalMf * 100) : 0.0;

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
            children: [
              Text(
                _formatInr(bucketValue),
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${pct.toStringAsFixed(1)})% of mutual fund portfolio',
                style: const TextStyle(
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
                    text: infoText,
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
          const SizedBox(height: 32),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MUTUAL FUNDS (${items.length})',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const Text(
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
          for (int i = 0; i < items.length; i++)
            _buildFundItem(
              fund: items[i],
              isLast: i == items.length - 1,
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

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBar(width: 160, height: 10),
          const SizedBox(height: 16),
          const ShimmerBar(width: 200, height: 20),
          const SizedBox(height: 24),
          ShimmerBar(width: MediaQuery.of(context).size.width, height: 72),
          const SizedBox(height: 32),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          for (int i = 0; i < 3; i++) ...[
            Row(
              children: const [
                ShimmerBar(width: 40, height: 40, borderRadius: 20),
                SizedBox(width: 16),
                Expanded(child: ShimmerBar(width: double.infinity, height: 12)),
                SizedBox(width: 16),
                ShimmerBar(width: 64, height: 12),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ],
      ),
    );
  }

  Widget _buildFundItem({
    required FundPerformanceData fund,
    bool isLast = false,
  }) {
    final name = fund.schemeName.isEmpty ? 'Fund' : fund.schemeName;
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
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
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
                      'Expense ratio: ${_pct(fund.expenseRatio)}',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatInr(fund.currentValue),
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
