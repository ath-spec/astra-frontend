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

enum _Bucket { out, inLine, under, unrated }

_Bucket _bucketOf(String rank) {
  switch (rank.toUpperCase()) {
    case 'TOP':
    case 'OUTPERFORMING':
    case 'OUT-PERFORMING':
      return _Bucket.out;
    case 'UNDERPERFORMER':
    case 'UNDERPERFORMING':
    case 'UNDER-PERFORMING':
      return _Bucket.under;
    case 'UNRATED':
    case '':
      return _Bucket.unrated;
    default:
      return _Bucket.inLine;
  }
}

class MutualFundPerformanceSheet extends StatefulWidget {
  final int initialIndex;
  final PerformanceData? data;

  const MutualFundPerformanceSheet({
    super.key,
    this.initialIndex = 0,
    this.data,
  });

  @override
  State<MutualFundPerformanceSheet> createState() =>
      _MutualFundPerformanceSheetState();
}

class _MutualFundPerformanceSheetState extends State<MutualFundPerformanceSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
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

  double get _totalMf =>
      _funds.fold<double>(0, (sum, f) => sum + f.currentValue);

  List<FundPerformanceData> _bucket(_Bucket b) =>
      _funds.where((f) => _bucketOf(f.performanceRank) == b).toList();

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
              Tab(text: 'Out-Performing'),
              Tab(text: 'In Line Performing'),
              Tab(text: 'Under-Performing'),
              Tab(text: 'Unrated'),
            ],
          ),

          Expanded(
            child: widget.data == null
                ? _buildSkeleton()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBucketTab(
                        bucket: _Bucket.out,
                        title: 'OUT-PERFORMING FUNDS',
                        infoText: 'Out-performing funds ',
                        infoDesc:
                            'have delivered higher returns than their benchmark.We simulate your investments in the benchmark to estimate excess gains.',
                        emptyInfoText: 'Out-performing funds',
                        emptyInfoDesc:
                            ' have delivered higher returns than their benchmark.We simulate your investments in the benchmark to estimate excess gains.',
                      ),
                      _buildBucketTab(
                        bucket: _Bucket.inLine,
                        title: 'IN LINE PERFORMING FUNDS',
                        infoText: 'In line performing funds ',
                        infoDesc:
                            'have delivered returns closely matching their benchmark.',
                        emptyInfoText: 'In line performing funds',
                        emptyInfoDesc:
                            ' have delivered returns closely matching their benchmark.',
                      ),
                      _buildBucketTab(
                        bucket: _Bucket.under,
                        title: 'UNDER-PERFORMING FUNDS',
                        infoText: 'Under-performing funds ',
                        infoDesc:
                            'have delivered lower returns than their benchmark.We simulate your investments in the benchmark to estimate the shortfall.',
                        emptyInfoText: 'Under-performing funds',
                        emptyInfoDesc:
                            ' have delivered lower returns than their benchmark.We simulate your investments in the benchmark to estimate the shortfall.',
                      ),
                      _buildBucketTab(
                        bucket: _Bucket.unrated,
                        title: 'UNRATED FUNDS',
                        infoText: 'Unrated funds ',
                        infoDesc:
                            'cannot yet be evaluated against a benchmark.This may happen while a benchmark is being mapped or if there isn\'t enough history.',
                        emptyInfoText: 'Unrated funds',
                        emptyInfoDesc:
                            ' cannot yet be evaluated against a benchmark.This may happen while a benchmark is being mapped or if there isn\'t enough history.',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBucketTab({
    required _Bucket bucket,
    required String title,
    required String infoText,
    required String infoDesc,
    required String emptyInfoText,
    required String emptyInfoDesc,
  }) {
    final items = _bucket(bucket);
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
                '(${pct.toStringAsFixed(2)})% of mutual fund portfolio',
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
                    fontSize: 14,
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
          ShimmerBar(
            width: MediaQuery.of(context).size.width,
            height: 72,
          ),
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

  Color _rankColor(String rank) {
    switch (_bucketOf(rank)) {
      case _Bucket.out:
        return const Color(0xFF38A169);
      case _Bucket.under:
        return const Color(0xFFE53E3E);
      case _Bucket.inLine:
      case _Bucket.unrated:
        return const Color(0xFF64748B);
    }
  }

  String _rankSubtitle(FundPerformanceData f) {
    final r = f.returnsPct;
    final sign = r >= 0 ? '+' : '';
    return '$sign${r.toStringAsFixed(1)}% return';
  }

  Widget _buildFundItem({
    required FundPerformanceData fund,
    bool isLast = false,
  }) {
    final name = fund.schemeName.isEmpty ? 'Fund' : fund.schemeName;
    final accent = _rankColor(fund.performanceRank);
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
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: accent,
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
                      _rankSubtitle(fund),
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: accent,
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
