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

/// Lookback window (in days) requested from `/api/v1/dashboard/growth` for
/// each timeframe toggle. The backend only has real history from whenever
/// the user's dashboard was first read onward (no backfilled past data), so
/// these are just upper bounds — a new user's series will simply come back
/// shorter than the requested window.
const Map<String, int> _periodDays = {
  '1M': 30,
  '6M': 182,
  '1Y': 365,
  'ALL': 3650,
};

class _HomePortfolioGrowthState extends ConsumerState<HomePortfolioGrowth> {
  String _selectedPeriod = 'ALL';

  String _formatDate(DateTime date) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${date.day} ${months[date.month - 1]} \'${date.year.toString().substring(2)}';
  }

  /// Converts the raw growth series into chart points. When the backend has
  /// fewer than 2 points of real history (a brand-new account), duplicates
  /// the single point into a flat 2-point line so the chart can render
  /// without dividing by zero — it does not fabricate any value, both
  /// points share the same real total-wealth figure.
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

  String _getStartLabel(String period, List<DashboardGrowthPoint> points) {
    if (points.isNotEmpty) return _formatDate(points.first.date).toUpperCase();
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
    final days = _periodDays[_selectedPeriod] ?? 3650;
    final growthAsync = ref.watch(dashboardGrowthProvider(days));

    return growthAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Text(
          'Portfolio growth is unavailable right now.',
          style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF94A3B8)),
        ),
      ),
      data: (points) => _buildContent(points),
    );
  }

  /// Which timeframe toggles are worth showing, given how much real history
  /// actually exists. A toggle only appears once the account has at least
  /// half of that window's worth of real data — otherwise every longer
  /// toggle would just render the same short, flat line as 1M, which isn't
  /// a meaningful choice to offer.
  List<String> _availableTimeframes(List<DashboardGrowthPoint> points) {
    if (points.isEmpty) return const [];
    final spanDays = DateTime.now().difference(points.first.date).inDays;
    final available = <String>['1M'];
    if (spanDays >= 91) available.add('6M');
    if (spanDays >= 182) available.add('1Y');
    if (spanDays >= 45) available.add('ALL');
    return available;
  }

  Widget _buildContent(List<DashboardGrowthPoint> points) {
    if (points.isEmpty) {
      return _buildEmptyState();
    }

    final availableTimeframes = _availableTimeframes(points);
    if (!availableTimeframes.contains(_selectedPeriod)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedPeriod = availableTimeframes.last);
      });
    }

    final currentData = _toChartData(points);
    final hasEnoughHistory = points.length >= 2;

    final double displayValue = points.isNotEmpty
        ? points.last.totalWealth
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
                startDateLabel: _getStartLabel(_selectedPeriod, points),
                endDateLabel: 'TODAY',
              ),
            ),
          ),

        const SizedBox(height: 32),

        // Timeline toggles — only ones with enough real history to be
        // meaningful are shown (see _availableTimeframes).
        if (availableTimeframes.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final label in availableTimeframes) _buildTimeframeToggle(label),
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

  /// Shown when there is genuinely zero recorded history yet (should be
  /// rare — the first dashboard read already writes today's snapshot — but
  /// covers a brand-new account's very first render before that completes).
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.show_chart_rounded, size: 28, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                const Text(
                  'Your growth chart starts today',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Come back tomorrow to see your first trend line',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, height: 1),
        ],
      ),
    );
  }

  Widget _buildTimeframeToggle(String label) {
    final isSelected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedPeriod = label;
          });
        }
      },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
          label,
            style: TextStyle(
              fontFamily: 'DMMono',
              fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
