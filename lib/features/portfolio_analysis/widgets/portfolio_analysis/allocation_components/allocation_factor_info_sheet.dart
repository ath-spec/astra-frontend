import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/portfolio_analysis_providers.dart';
import '../../../data/portfolio_analysis_models.dart';

String _formatInr(double value) {
  final rounded = value.round();
  final neg = rounded < 0;
  final digits = rounded.abs().toString();
  String out;
  if (digits.length <= 3) {
    out = digits;
  } else {
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    out =
        '${head.replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+(?!\d))'), (m) => '${m[1]},')},$tail';
  }
  return '${neg ? '-₹' : '₹'}$out';
}

class _TabSpec {
  final String label;
  final String volatility; // STABLE / LOW / MEDIUM / HIGH
  final String heading;
  final String blurbBold;
  final String blurbRest;
  const _TabSpec(this.label, this.volatility, this.heading, this.blurbBold,
      this.blurbRest);
}

const _tabSpecs = <_TabSpec>[
  _TabSpec('Stable', 'STABLE', 'STABLE ASSETS', 'Stable assets: ',
      'Includes banks, FDs, and liquid or overnight funds. These are usually the steadiest part of a portfolio, meant to keep things grounded and accessible.'),
  _TabSpec('Low Volatility', 'LOW', 'LOW VOLATILITY', 'Low volatility assets ',
      'include conservative hybrid and short-duration debt funds. They move gently and cushion the overall portfolio.'),
  _TabSpec('Medium Volatility', 'MEDIUM', 'MEDIUM VOLATILITY',
      'Medium volatility assets ',
      'include balanced and large-cap oriented funds. They carry moderate swings in exchange for steadier long-term growth.'),
  _TabSpec('High Volatility', 'HIGH', 'HIGH VOLATILITY',
      'High volatility assets ',
      'include equities and certain mutual funds. They can swing significantly in value over the short term but offer the potential for higher returns in the long run.'),
];

const _typeLabel = {
  'BANK': 'BANKS',
  'FD': 'FIXED DEPOSITS',
  'MF': 'MUTUAL FUNDS',
  'STOCK': 'STOCKS',
};

const _typeValueHeader = {
  'BANK': 'CURRENT BALANCE',
  'FD': 'PRINCIPAL',
  'MF': 'HOLDINGS VALUE',
  'STOCK': 'HOLDINGS VALUE',
};

class AllocationFactorInfoSheet extends ConsumerStatefulWidget {
  final int initialIndex;

  const AllocationFactorInfoSheet({super.key, required this.initialIndex});

  @override
  ConsumerState<AllocationFactorInfoSheet> createState() =>
      _AllocationFactorInfoSheetState();
}

class _AllocationFactorInfoSheetState
    extends ConsumerState<AllocationFactorInfoSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabSpecs.length,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, _tabSpecs.length - 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allocAsync = ref.watch(portfolioAllocationProvider);
    final alloc = allocAsync.valueOrNull;

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
            tabs: _tabSpecs.map((t) => Tab(text: t.label)).toList(),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: alloc == null
                ? (allocAsync.isLoading
                    ? _buildSkeleton()
                    : const SizedBox.shrink())
                : TabBarView(
                    controller: _tabController,
                    children:
                        _tabSpecs.map((t) => _buildTab(t, alloc)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(_TabSpec spec, AllocationData alloc) {
    final items = alloc.holdings
        .where((h) => h.volatility == spec.volatility)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No ${spec.label.toLowerCase()} assets currently.',
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    final bucketValue = items.fold<double>(0, (s, h) => s + h.value);
    final holdingsTotal =
        alloc.holdings.fold<double>(0, (s, h) => s + h.value);
    final pct = holdingsTotal > 0 ? bucketValue / holdingsTotal * 100 : 0.0;

    // Group by instrument type, preserving a stable display order.
    final order = ['BANK', 'FD', 'MF', 'STOCK'];
    final grouped = <String, List<HoldingBreakdownData>>{};
    for (final h in items) {
      grouped.putIfAbsent(h.type, () => []).add(h);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spec.heading,
            style: const TextStyle(
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
                '${pct.toStringAsFixed(1)}% of total holdings',
                style: const TextStyle(
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
                    text: spec.blurbBold,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(text: spec.blurbRest),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          for (final type in order)
            if (grouped[type] != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_typeLabel[type] ?? type} (${grouped[type]!.length})',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    _typeValueHeader[type] ?? 'VALUE',
                    style: const TextStyle(
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
              for (int i = 0; i < grouped[type]!.length; i++)
                _buildHoldingRow(
                  grouped[type]![i],
                  isLast: i == grouped[type]!.length - 1,
                ),
              const SizedBox(height: 32),
            ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHoldingRow(HoldingBreakdownData h, {bool isLast = false}) {
    final initial = h.name.isEmpty ? '?' : h.name[0].toUpperCase();
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
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
                    h.name,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (h.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      h.subtitle,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              _formatInr(h.value),
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
        ],
      ],
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBar(width: 120, height: 10),
          const SizedBox(height: 8),
          const ShimmerBar(width: 180, height: 20),
          const SizedBox(height: 24),
          ShimmerBar(width: MediaQuery.of(context).size.width, height: 64),
          const SizedBox(height: 32),
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
