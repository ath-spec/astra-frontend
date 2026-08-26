// ============================================================
// FILE: lib/features/analytics/screens/analytics_screen.dart
// Root screen for the Analytics feature. Assembles each section
// as its own widget (see ../widgets/) so any one section can be
// reworked or re-ordered without touching the others.
// ============================================================

import 'package:flutter/material.dart';
import '../data/analytics_repository.dart';
import '../models/analytics_models.dart';
import '../widgets/ai_mood_insight_card.dart';
import '../widgets/focus_level_chart_card.dart';
import '../widgets/focus_cycle_sheet.dart';
import '../widgets/recent_spends_card.dart';
import '../widgets/category_allocation_card.dart';
import '../widgets/monthly_spending_level_card.dart';
import '../widgets/spend_trends_card.dart';
import '../widgets/actionable_insights_card.dart';
import 'category_spends_screen.dart';
import '../../transactions/screens/transactions_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _repo = AnalyticsRepository.instance;

  String _selectedCycle = 'This month';
  DateTime? _customFromDate;
  DateTime? _customToDate;

  AnalyticsSummary? _summary;
  AnalyticsInsights? _insights;
  bool _loadingSummary = true;
  bool _loadingInsights = true;

  @override
  void initState() {
    super.initState();
    // Instant paint from cache (if any), then refresh in the background —
    // same peek+fetch pattern used elsewhere in the app.
    _summary = _repo.peekSummary();
    _insights = _repo.peekInsights();
    _loadingSummary = _summary == null;
    _loadingInsights = _insights == null;
    _load();
  }

  Future<void> _openCycleSheet() async {
    final result = await showModalBottomSheet<FocusCycleResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FocusCycleSheet(
        currentCycle: _selectedCycle,
        currentFromDate: _customFromDate,
        currentToDate: _customToDate,
      ),
    );
    if (result == null) return;
    setState(() {
      _selectedCycle = result.cycle;
      _customFromDate = result.fromDate;
      _customToDate = result.toDate;
    });
  }

  Future<void> _load() async {
    final summary = await _repo.getSummary();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _loadingSummary = false;
    });

    final insights = await _repo.getInsights();
    if (!mounted) return;
    setState(() {
      _insights = insights;
      _loadingInsights = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            final s = await _repo.getSummary(forceRefresh: true);
            final i = await _repo.getInsights(forceRefresh: true);
            if (!mounted) return;
            setState(() {
              _summary = s;
              _insights = i;
            });
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
            children: [
              _AnalyticsHeader(
                selectedCycle: _selectedCycle,
                onCycleTap: _openCycleSheet,
              ),
              const SizedBox(height: 24),
              AiMoodInsightCard(
                mood: _insights?.aiInsight.mood ?? AiMood.neutral,
                text: _insights?.aiInsight.text ?? '',
                isLoading: _loadingInsights,
              ),
              const SizedBox(height: 28),
              if (summary != null) ...[
                FocusLevelChartCard(
                  selectedCycle: _selectedCycle,
                  customFromDate: _customFromDate,
                  customToDate: _customToDate,
                ),
                const SizedBox(height: 28),
                RecentSpendsCard(
                  spends: summary.recentSpends,
                  onSeeAll: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                  ),
                ),
                const SizedBox(height: 28),
                CategoryAllocationCard(
                  allocations: summary.categoryAllocations,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategorySpendsScreen()),
                  ),
                ),
                const SizedBox(height: 28),
                MonthlySpendingLevelCard(
                  categories: summary.spendingLevels,
                  onSeeAll: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategorySpendsScreen()),
                  ),
                ),
                const SizedBox(height: 28),
                SpendTrendsCard(trends: summary.spendTrends),
                const SizedBox(height: 28),
              ] else if (_loadingSummary) ...[
                const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
              ],
              if (_insights != null)
                ActionableInsightsCard(insights: _insights!.actionableInsights),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  final String selectedCycle;
  final VoidCallback onCycleTap;

  const _AnalyticsHeader({
    required this.selectedCycle,
    required this.onCycleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Analytics',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        GestureDetector(
          onTap: onCycleTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12.5, color: Color(0xFF0F172A)),
                const SizedBox(width: 6),
                Text(
                  selectedCycle,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
