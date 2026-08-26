// ============================================================
// FILE: lib/features/analytics/data/analytics_repository.dart
// Mock data source for the Analytics feature. Every method has
// the async signature a real repository would have (Future,
// simulated network delay) so swapping the body for a Dio call
// against GET /v1/analytics/summary and /v1/analytics/insights
// later doesn't touch any call site.
// ============================================================

import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../models/analytics_models.dart';

class AnalyticsRepository {
  AnalyticsRepository._();
  static final AnalyticsRepository instance = AnalyticsRepository._();

  AnalyticsSummary? _cachedSummary;
  AnalyticsInsights? _cachedInsights;
  final Map<String, List<FocusDataPoint>> _focusCache = {};

  Future<AnalyticsSummary> getSummary({bool forceRefresh = false}) async {
    if (_cachedSummary != null && !forceRefresh) return _cachedSummary!;
    await Future.delayed(const Duration(milliseconds: 500));
    _cachedSummary = _buildMockSummary();
    return _cachedSummary!;
  }

  /// Instant synchronous peek at whatever's cached, for first-paint
  /// before the async fetch resolves. Mirrors the peek/cache pattern
  /// used elsewhere in the app for perceived-performance.
  AnalyticsSummary? peekSummary() => _cachedSummary;

  Future<AnalyticsInsights> getInsights({bool forceRefresh = false}) async {
    if (_cachedInsights != null && !forceRefresh) return _cachedInsights!;
    await Future.delayed(const Duration(milliseconds: 900));
    _cachedInsights = _buildMockInsights();
    return _cachedInsights!;
  }

  AnalyticsInsights? peekInsights() => _cachedInsights;

  /// Daily spend series for the focus-level chart, windowed to the
  /// requested cycle ('This week' / 'This month' / 'This year' / 'Custom').
  /// Cached per cycle+range key so switching back to a previously viewed
  /// cycle doesn't re-hit the (simulated) network.
  Future<List<FocusDataPoint>> getFocusLevelData({
    required String cycle,
    DateTime? fromDate,
    DateTime? toDate,
    bool forceRefresh = false,
  }) async {
    final key = _focusCacheKey(cycle, fromDate, toDate);
    if (_focusCache[key] != null && !forceRefresh) return _focusCache[key]!;
    await Future.delayed(const Duration(milliseconds: 350));
    final data = _buildMockFocusData(cycle: cycle, fromDate: fromDate, toDate: toDate);
    _focusCache[key] = data;
    return data;
  }

  List<FocusDataPoint>? peekFocusLevelData({
    required String cycle,
    DateTime? fromDate,
    DateTime? toDate,
  }) => _focusCache[_focusCacheKey(cycle, fromDate, toDate)];

  String _focusCacheKey(String cycle, DateTime? fromDate, DateTime? toDate) =>
      '${cycle.toLowerCase()}|${fromDate?.toIso8601String() ?? ''}|${toDate?.toIso8601String() ?? ''}';

  List<FocusDataPoint> _buildMockFocusData({
    required String cycle,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final now = DateTime.now();
    List<DateTime> dates;
    final isWeek = cycle.toLowerCase() == 'this week';

    switch (cycle.toLowerCase()) {
      case 'this week':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        dates = List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));
        break;
      case 'this year':
        final jan1 = DateTime(now.year, 1, 1);
        final daysInYear = DateTime(now.year, 12, 31).difference(jan1).inDays + 1;
        dates = List.generate(daysInYear, (i) => jan1.add(Duration(days: i)));
        break;
      case 'custom':
        if (fromDate != null && toDate != null) {
          final days = toDate.difference(fromDate).inDays + 1;
          dates = List.generate(days.clamp(1, 730), (i) => fromDate.add(Duration(days: i)));
        } else {
          dates = [now];
        }
        break;
      case 'this month':
      default:
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        dates = List.generate(daysInMonth, (i) => DateTime(now.year, now.month, i + 1));
    }

    const weekdayAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dates.map((d) {
      final seed = d.year * 10000 + d.month * 100 + d.day;
      final rng = math.Random(seed);
      final weekendBoost = (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) ? 1.4 : 1.0;
      final value = ((400 + rng.nextDouble() * 2600) * weekendBoost).roundToDouble();
      final label = isWeek ? weekdayAbbr[d.weekday - 1] : DateFormat('d MMM').format(d);
      return FocusDataPoint(label: label, value: value);
    }).toList();
  }

  // ---------------------------------------------------------------
  // Dummy data below. Shapes mirror analytics_models.dart 1:1 so a
  // future `AnalyticsSummary.fromJson(response.data)` drops in clean.
  // ---------------------------------------------------------------

  AnalyticsSummary _buildMockSummary() {
    return AnalyticsSummary(
      focusLevelData: const [
        FocusDataPoint(label: 'Mon', value: 1240),
        FocusDataPoint(label: 'Tue', value: 890),
        FocusDataPoint(label: 'Wed', value: 2100),
        FocusDataPoint(label: 'Thu', value: 1560),
        FocusDataPoint(label: 'Fri', value: 3200),
        FocusDataPoint(label: 'Sat', value: 2760),
        FocusDataPoint(label: 'Sun', value: 940),
      ],
      categoryAllocations: const [
        CategoryAllocation(
          categoryId: 'food_dining',
          categoryName: 'Food & Dining',
          iconName: 'restaurant',
          actualSpent: 8450,
          budgetedAmount: 10000,
          percentageUsed: 84.5,
          colorHex: '#F97316',
        ),
        CategoryAllocation(
          categoryId: 'shopping',
          categoryName: 'Shopping',
          iconName: 'shopping_bag',
          actualSpent: 6120,
          budgetedAmount: 8000,
          percentageUsed: 76.5,
          colorHex: '#5BA1F7',
        ),
        CategoryAllocation(
          categoryId: 'transport',
          categoryName: 'Transport',
          iconName: 'directions_car',
          actualSpent: 3220,
          budgetedAmount: 4000,
          percentageUsed: 80.5,
          colorHex: '#22C55E',
        ),
        CategoryAllocation(
          categoryId: 'entertainment',
          categoryName: 'Entertainment',
          iconName: 'movie',
          actualSpent: 2140,
          budgetedAmount: 3000,
          percentageUsed: 71.3,
          colorHex: '#A855F7',
        ),
        CategoryAllocation(
          categoryId: 'bills_utilities',
          categoryName: 'Bills & Utilities',
          iconName: 'receipt_long',
          actualSpent: 4890,
          budgetedAmount: 5000,
          percentageUsed: 97.8,
          colorHex: '#F43F5E',
        ),
      ],
      monthlySpending: const MonthlySpending(
        currentTotal: 24820,
        previousTotal: 27960,
        percentageChange: -11.2,
      ),
      spendTrends: const [
        SpendTrend(year: 2026, month: 3, monthLabel: 'Mar', totalSpent: 21400),
        SpendTrend(year: 2026, month: 4, monthLabel: 'Apr', totalSpent: 23890),
        SpendTrend(year: 2026, month: 5, monthLabel: 'May', totalSpent: 19230),
        SpendTrend(year: 2026, month: 6, monthLabel: 'Jun', totalSpent: 26510),
        SpendTrend(year: 2026, month: 7, monthLabel: 'Jul', totalSpent: 27960),
        SpendTrend(year: 2026, month: 8, monthLabel: 'Aug', totalSpent: 24820),
      ],
      spendingLevels: const [
        SpendingLevelCategory(
          categoryId: 'food_dining',
          categoryName: 'Food & Dining',
          amountSpent: 8450,
          status: SpendingStatus.warning,
          sparklineData: [4, 6, 5, 8, 7, 9, 8.4],
        ),
        SpendingLevelCategory(
          categoryId: 'shopping',
          categoryName: 'Shopping',
          amountSpent: 6120,
          status: SpendingStatus.normal,
          sparklineData: [3, 4, 5, 4.5, 6, 5.8, 6.1],
        ),
        SpendingLevelCategory(
          categoryId: 'transport',
          categoryName: 'Transport',
          amountSpent: 3220,
          status: SpendingStatus.under,
          sparklineData: [4, 3.6, 3.2, 3, 3.3, 3.1, 3.2],
        ),
        SpendingLevelCategory(
          categoryId: 'entertainment',
          categoryName: 'Entertainment',
          amountSpent: 2140,
          status: SpendingStatus.normal,
          sparklineData: [1, 1.5, 2, 1.8, 2.2, 2.0, 2.1],
        ),
        SpendingLevelCategory(
          categoryId: 'bills_utilities',
          categoryName: 'Bills & Utilities',
          amountSpent: 4890,
          status: SpendingStatus.over,
          sparklineData: [4.2, 4.4, 4.6, 4.7, 4.8, 4.85, 4.89],
        ),
      ],
      recentSpends: [
        RecentSpend(
          id: 'txn_1',
          merchantName: 'Zomato',
          category: 'Food & Dining',
          amount: 486,
          time: DateTime.now().subtract(const Duration(hours: 2)),
          isDebit: true,
        ),
        RecentSpend(
          id: 'txn_2',
          merchantName: 'Amazon',
          category: 'Shopping',
          amount: 2340,
          time: DateTime.now().subtract(const Duration(hours: 6)),
          isDebit: true,
        ),
        RecentSpend(
          id: 'txn_3',
          merchantName: 'Uber',
          category: 'Transport',
          amount: 218,
          time: DateTime.now().subtract(const Duration(hours: 9)),
          isDebit: true,
        ),
        RecentSpend(
          id: 'txn_4',
          merchantName: 'Salary Credit',
          category: 'Income',
          amount: 85000,
          time: DateTime.now().subtract(const Duration(days: 1)),
          isDebit: false,
        ),
        RecentSpend(
          id: 'txn_5',
          merchantName: 'Netflix',
          category: 'Entertainment',
          amount: 649,
          time: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
          isDebit: true,
        ),
      ],
    );
  }

  AnalyticsInsights _buildMockInsights() {
    return const AnalyticsInsights(
      aiInsight: AiInsight(
        mood: AiMood.neutral,
        text: 'Your spending dropped 11% this month, mostly thanks to lighter dining-out. '
            'Food & Dining is still your biggest bucket at 84% of budget though, '
            'so a few more home-cooked evenings would put you comfortably under.',
      ),
      actionableInsights: [
        ActionableInsight(
          id: 'insight_1',
          title: 'Dining spend is close to its limit',
          description: 'You have ₹1,550 left in Food & Dining for the next 9 days.',
          iconName: 'restaurant',
          colorHex: '#F97316',
          tag: 'Budget',
          ctaText: 'Review category',
          progress: 0.845,
        ),
        ActionableInsight(
          id: 'insight_2',
          title: 'Bills & Utilities is nearly maxed',
          description: 'Only ₹110 of headroom left this cycle — watch for surprise auto-debits.',
          iconName: 'receipt_long',
          colorHex: '#F43F5E',
          tag: 'Alert',
          ctaText: 'See bills',
          progress: 0.978,
        ),
        ActionableInsight(
          id: 'insight_3',
          title: 'You saved ₹3,140 vs last month',
          description: 'Keep this pace and you will close the month 11% under budget.',
          iconName: 'savings',
          colorHex: '#22C55E',
          tag: 'Trend',
          ctaText: 'View trend',
        ),
      ],
    );
  }
}
