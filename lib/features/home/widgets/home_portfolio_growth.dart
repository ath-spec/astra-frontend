import '../../../core/widgets/shimmer_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/dashboard/data/dashboard_providers.dart';
import 'package:astra_frontend/features/dashboard/data/dashboard_models.dart';
import 'portfolio_interactive_chart.dart';

class HomePortfolioGrowth extends ConsumerStatefulWidget {
  final bool mfConnected;
  final bool stocksConnected;

  const HomePortfolioGrowth({
    super.key,
    required this.mfConnected,
    required this.stocksConnected,
  });

  @override
  ConsumerState<HomePortfolioGrowth> createState() => _HomePortfolioGrowthState();
}

class _HomePortfolioGrowthState extends ConsumerState<HomePortfolioGrowth> {
  String _selectedPeriod = 'ALL';
  static const List<String> _timeframes = ['1M', '6M', '1Y', 'ALL'];

  String _formatDate(DateTime date) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${date.day} ${months[date.month - 1]} \'${date.year.toString().substring(2)}';
  }

  List<ChartDataPoint> _toChartData(List<DashboardGrowthPoint> points) {
    if (points.isEmpty) return const [];
    if (points.length == 1) {
      final p = points.first;
      return [
        ChartDataPoint(value: p.totalWealth, dateStr: _formatDate(p.date)),
        ChartDataPoint(value: p.totalWealth, dateStr: 'TODAY'),
      ];
    }
    return points
        .map((p) => ChartDataPoint(value: p.totalWealth, dateStr: _formatDate(p.date)))
        .toList();
  }

  List<DashboardGrowthPoint> _slicePointsForPeriod(List<DashboardGrowthPoint> allPoints, String period) {
    if (allPoints.isEmpty) return const [];
    int takeDays;
    switch (period) {
      case '1M':
        takeDays = 30;
        break;
      case '6M':
        takeDays = 182;
        break;
      case '1Y':
        takeDays = 365;
        break;
      case 'ALL':
      default:
        takeDays = allPoints.length;
        break;
    }

    if (allPoints.length <= takeDays) {
      return allPoints;
    }
    return allPoints.sublist(allPoints.length - takeDays);
  }

  String _getStartLabel(String period, List<DashboardGrowthPoint> currentPoints) {
    if (currentPoints.isNotEmpty) {
      return _formatDate(currentPoints.first.date).toUpperCase();
    }
    switch (period) {
      case '1M':
        return '1 MONTH AGO';
      case '6M':
        return '6 MONTHS AGO';
      case '1Y':
        return '1 YEAR AGO';
      case 'ALL':
      default:
        return 'START';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always request the full 365-day dataset so all timeframe buttons work instantly
    final growthAsync = ref.watch(dashboardGrowthProvider(365));

    return growthAsync.when(
      loading: () => _buildSkeletonLoading(),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: const Text(
          'Portfolio growth is unavailable right now.',
          style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF94A3B8)),
        ),
      ),
      data: (allPoints) => _buildContent(allPoints),
    );
  }

  Widget _buildContent(List<DashboardGrowthPoint> allPoints) {
    if (allPoints.isEmpty) {
      return _buildEmptyState();
    }

    final activePoints = _slicePointsForPeriod(allPoints, _selectedPeriod);
    final currentData = _toChartData(activePoints);
    final hasEnoughHistory = allPoints.length >= 2;

    final double displayValue = activePoints.isNotEmpty
        ? activePoints.last.totalWealth
        : 0.0;
    final bool isPositive =
        currentData.isEmpty || currentData.last.value >= currentData.first.value;
    final chartColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Portfolio Growth',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'PORTFOLIO VALUE',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '₹${displayValue.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              color: chartColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bar_chart_rounded, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasEnoughHistory
                      ? 'Portfolio growth does not include your bank balance'
                      : 'Not enough history yet — check back after a few days to see your growth trend',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 110), // Pushed down so tooltip doesn't overlap text

        // Chart
        if (currentData.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: PortfolioInteractiveChart(
                key: ValueKey(_selectedPeriod),
                data: currentData,
                lineColor: chartColor,
                height: 180,
                startDateLabel: _getStartLabel(_selectedPeriod, activePoints),
                endDateLabel: 'TODAY',
              ),
            ),
          ),

        const SizedBox(height: 32),

        // Timeline toggles — ALWAYS visible and selectable
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final label in _timeframes) _buildTimeframeToggle(label),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bottom divider matching the design
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(color: Color(0xFFE2E8F0), thickness: 1, height: 1),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Growth',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const ShimmerBar(width: 100, height: 10, borderRadius: 3),
          const SizedBox(height: 8),
          const ShimmerBar(width: 200, height: 36, borderRadius: 6),
          const SizedBox(height: 12),
          const ShimmerBar(width: 260, height: 12, borderRadius: 4),
          const SizedBox(height: 32),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: ShimmerBar(width: 180, height: 28, borderRadius: 4),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, height: 1),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Growth',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: const Center(
              child: Text(
                'Connect Mutual Funds or Stocks to track your growth trend',
                style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeToggle(String label) {
    final bool isSelected = _selectedPeriod == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
