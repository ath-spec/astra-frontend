// ============================================================
// FILE: lib/features/analytics/data/analytics_repository.dart
// Live data source for the Analytics feature, backed by the spend
// analytics engine (GET /api/v1/analytics/spend/*) and the budget
// feature (GET /api/v1/analytics/budgets/*) — the same backend
// endpoints the Transactions screen and RM Spend Intelligence read
// from. No fabricated numbers: every field here is either a direct
// mapping of a real API field, or (for the AI insight text and the
// decorative sparkline points, which the backend doesn't compute)
// a deterministic derivation from the real numbers already fetched.
// ============================================================

import 'package:intl/intl.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/core/network/api_exception.dart';
import '../models/analytics_models.dart';

class AnalyticsRepository {
  AnalyticsRepository._();
  static final AnalyticsRepository instance = AnalyticsRepository._();

  final DioApiClient _client = dioApiClient;

  AnalyticsSummary? _cachedSummary;
  AnalyticsInsights? _cachedInsights;
  final Map<String, List<FocusDataPoint>> _focusCache = {};
  List<_DailyPoint>? _dailyTrendCache;

  Future<AnalyticsSummary> getSummary({bool forceRefresh = false}) async {
    if (_cachedSummary != null && !forceRefresh) return _cachedSummary!;
    _cachedSummary = await _buildSummary();
    return _cachedSummary!;
  }

  /// Instant synchronous peek at whatever's cached, for first-paint
  /// before the async fetch resolves.
  AnalyticsSummary? peekSummary() => _cachedSummary;

  Future<AnalyticsInsights> getInsights({bool forceRefresh = false}) async {
    if (_cachedInsights != null && !forceRefresh) return _cachedInsights!;
    final summary = await getSummary(forceRefresh: forceRefresh);
    _cachedInsights = await _buildInsights(summary);
    return _cachedInsights!;
  }

  AnalyticsInsights? peekInsights() => _cachedInsights;

  /// Daily spend series for the focus-level chart, windowed to the
  /// requested cycle ('This week' / 'This month' / 'This year' / 'Custom').
  /// Backed by GET /trends?period=daily, which only covers the last 180
  /// days of real transaction history — a cycle reaching further back than
  /// that will simply have fewer points, which is honest rather than
  /// fabricated.
  Future<List<FocusDataPoint>> getFocusLevelData({
    required String cycle,
    DateTime? fromDate,
    DateTime? toDate,
    bool forceRefresh = false,
  }) async {
    final key = _focusCacheKey(cycle, fromDate, toDate);
    if (_focusCache[key] != null && !forceRefresh) return _focusCache[key]!;
    final daily = await _fetchDailyTrend(forceRefresh: forceRefresh);
    final data = _buildFocusData(daily, cycle: cycle, fromDate: fromDate, toDate: toDate);
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

  // ---------------------------------------------------------------
  // Backend calls
  // ---------------------------------------------------------------

  /// GETs an `/api/v1` envelope endpoint whose `data` is a JSON object,
  /// returning that object. Throws [ApiException] on a reported error or a
  /// network failure.
  Future<Map<String, dynamic>> _getObject(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _client.dio.get(path, queryParameters: query);
      final envelope = response.data as Map<String, dynamic>;
      if (envelope['error'] == true) {
        throw ApiException(envelope['message']?.toString() ?? 'Something went wrong');
      }
      return envelope['data'] as Map<String, dynamic>? ?? const {};
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<List<_DailyPoint>> _fetchDailyTrend({bool forceRefresh = false}) async {
    if (_dailyTrendCache != null && !forceRefresh) return _dailyTrendCache!;
    final data = await _getObject('/api/v1/analytics/spend/trends', query: {'period': 'daily'});
    final points = (data['points'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_DailyPoint.fromJson)
        .toList();
    _dailyTrendCache = points;
    return points;
  }

  /// The most recent [limit] raw transactions, newest first. Mirrors the
  /// page-unwrapping fix in TransactionsRepository — GET /transactions
  /// returns a {items, total, limit, offset} object, not a bare array.
  Future<List<_RawTxn>> _fetchRecentTransactions({int limit = 5}) async {
    final page = await _getObject('/api/v1/analytics/spend/transactions', query: {'limit': limit});
    final items = page['items'] as List<dynamic>? ?? const [];
    return items.whereType<Map<String, dynamic>>().map(_RawTxn.fromJson).toList();
  }

  // ---------------------------------------------------------------
  // Assembly
  // ---------------------------------------------------------------

  Future<AnalyticsSummary> _buildSummary() async {
    final monthly = await _getObject('/api/v1/analytics/spend/trends', query: {'period': 'monthly'});
    final monthlyPoints = (monthly['points'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_DailyPoint.fromJson)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final spendTrends = monthlyPoints
        .skip((monthlyPoints.length - 6).clamp(0, monthlyPoints.length))
        .map((p) => SpendTrend(
              year: p.date.year,
              month: p.date.month,
              monthLabel: DateFormat('MMM').format(p.date),
              totalSpent: p.total,
            ))
        .toList();

    final current = monthlyPoints.isNotEmpty ? monthlyPoints.last.total : 0.0;
    final previous = monthlyPoints.length > 1 ? monthlyPoints[monthlyPoints.length - 2].total : 0.0;
    final pctChange = previous == 0
        ? (current == 0 ? 0.0 : 100.0)
        : ((current - previous) / previous * 100);
    final monthlySpending = MonthlySpending(
      currentTotal: current,
      previousTotal: previous,
      percentageChange: pctChange,
    );

    final budgetData = await _getObject('/api/v1/analytics/budgets/latest');
    final budgetRows = (budgetData['budgets'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    List<CategoryAllocation> categoryAllocations;
    List<SpendingLevelCategory> spendingLevels;

    if (budgetRows.isNotEmpty) {
      categoryAllocations = budgetRows.map((b) {
        final actual = (b['spent_amount'] as num?)?.toDouble() ?? 0.0;
        final budgeted = (b['budgeted_amount'] as num?)?.toDouble() ?? 0.0;
        return CategoryAllocation(
          categoryId: b['category_id'] as String? ?? '',
          categoryName: b['category_name'] as String? ?? '',
          iconName: (b['category_icon'] as String?)?.isNotEmpty == true
              ? b['category_icon'] as String
              : _categoryVisual(b['category_name'] as String? ?? '').icon,
          actualSpent: actual,
          budgetedAmount: budgeted,
          percentageUsed: (b['percentage_used'] as num?)?.toDouble() ?? 0.0,
          colorHex: (b['category_color'] as String?)?.isNotEmpty == true
              ? b['category_color'] as String
              : _categoryVisual(b['category_name'] as String? ?? '').color,
        );
      }).toList();

      spendingLevels = budgetRows.map((b) {
        final spent = (b['spent_amount'] as num?)?.toDouble() ?? 0.0;
        final pct = (b['percentage_used'] as num?)?.toDouble() ?? 0.0;
        return SpendingLevelCategory(
          categoryId: b['category_id'] as String? ?? '',
          categoryName: b['category_name'] as String? ?? '',
          amountSpent: spent,
          status: _statusFromBudget(b['status'] as String?, pct),
          sparklineData: _syntheticSparkline(spent),
        );
      }).toList();
    } else {
      // No budget set up yet — fall back to raw category spend (no
      // budgeted-amount context, so those fields are honestly 0/unused).
      final categories = await _getObject('/api/v1/analytics/spend/categories');
      final catRows = (categories['categories'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      categoryAllocations = catRows.map((c) {
        final name = c['category'] as String? ?? '';
        final visual = _categoryVisual(name);
        return CategoryAllocation(
          categoryId: name,
          categoryName: name,
          iconName: visual.icon,
          actualSpent: (c['current_total'] as num?)?.toDouble() ?? 0.0,
          budgetedAmount: 0,
          percentageUsed: (c['share_pct'] as num?)?.toDouble() ?? 0.0,
          colorHex: visual.color,
        );
      }).toList();

      spendingLevels = catRows.map((c) {
        final spent = (c['current_total'] as num?)?.toDouble() ?? 0.0;
        final direction = c['direction'] as String? ?? 'FLAT';
        return SpendingLevelCategory(
          categoryId: c['category'] as String? ?? '',
          categoryName: c['category'] as String? ?? '',
          amountSpent: spent,
          status: direction == 'UP'
              ? SpendingStatus.warning
              : (direction == 'DOWN' ? SpendingStatus.under : SpendingStatus.normal),
          sparklineData: _syntheticSparkline(spent),
        );
      }).toList();
    }

    final recent = await _fetchRecentTransactions(limit: 5);
    final recentSpends = recent
        .map((t) => RecentSpend(
              id: t.id,
              merchantName: t.merchant,
              category: t.category,
              amount: t.amount,
              time: t.occurredAt,
              isDebit: t.isDebit,
            ))
        .toList();

    return AnalyticsSummary(
      // The focus-level chart fetches its own data directly via
      // getFocusLevelData (cycle-aware); this field isn't read by any
      // widget, so it's left empty rather than issuing a redundant call.
      focusLevelData: const [],
      categoryAllocations: categoryAllocations,
      monthlySpending: monthlySpending,
      spendTrends: spendTrends,
      spendingLevels: spendingLevels,
      recentSpends: recentSpends,
    );
  }

  /// Tries the ML-backed budget insights endpoint first; falls back to a
  /// deterministic template built from the real numbers already in
  /// [summary] when that service is unavailable or has nothing to say
  /// (e.g. no ML backend configured, or no budget set up yet).
  Future<AnalyticsInsights> _buildInsights(AnalyticsSummary summary) async {
    try {
      final data = await _getObject('/api/v1/analytics/budgets/insights');
      final rows = (data['insights'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      if (rows.isNotEmpty) {
        final actionable = rows.map((r) {
          final actionType = r['action_type'] as String? ?? 'save_more';
          return ActionableInsight(
            id: r['id'] as String? ?? '',
            title: r['title'] as String? ?? 'Insight',
            description: r['description'] as String? ?? '',
            iconName: _actionIcon(actionType),
            colorHex: _severityColor(r['severity'] as String?),
            tag: r['severity'] as String?,
            ctaText: _actionCta(actionType),
          );
        }).toList();
        return AnalyticsInsights(
          aiInsight: _deriveAiInsight(summary),
          actionableInsights: actionable,
        );
      }
    } catch (_) {
      // ML insights unavailable — fall through to the deterministic
      // fallback below rather than surfacing an error for a non-critical
      // supplementary feature.
    }
    return AnalyticsInsights(
      aiInsight: _deriveAiInsight(summary),
      actionableInsights: _deriveFallbackInsights(summary),
    );
  }

  AiInsight _deriveAiInsight(AnalyticsSummary summary) {
    final change = summary.monthlySpending.percentageChange;
    final overBudget = summary.categoryAllocations.where((c) => c.percentageUsed >= 100).toList();
    final top = [...summary.categoryAllocations]
      ..sort((a, b) => b.actualSpent.compareTo(a.actualSpent));

    final mood = overBudget.isNotEmpty || change > 15
        ? AiMood.concerned
        : (change < -10 ? AiMood.happy : AiMood.neutral);

    if (top.isEmpty) {
      return const AiInsight(
        mood: AiMood.neutral,
        text: 'No spending recorded yet for this period — connect a bank account '
            'or make a few transactions to see insights here.',
      );
    }

    final topCat = top.first;
    final changeText = change == 0
        ? 'about the same as last month'
        : (change > 0
            ? 'up ${change.abs().toStringAsFixed(0)}% from last month'
            : 'down ${change.abs().toStringAsFixed(0)}% from last month');

    final budgetNote = topCat.budgetedAmount > 0
        ? ' at ${topCat.percentageUsed.toStringAsFixed(0)}% of its budget'
        : '';

    return AiInsight(
      mood: mood,
      text: 'Your spending is $changeText. ${topCat.categoryName} is your biggest '
          'category so far, totaling ₹${topCat.actualSpent.toStringAsFixed(0)}$budgetNote.',
    );
  }

  List<ActionableInsight> _deriveFallbackInsights(AnalyticsSummary summary) {
    final withBudget = summary.categoryAllocations.where((c) => c.budgetedAmount > 0).toList()
      ..sort((a, b) => b.percentageUsed.compareTo(a.percentageUsed));

    if (withBudget.isNotEmpty) {
      return withBudget.take(3).map((c) {
        final remaining = (c.budgetedAmount - c.actualSpent).clamp(0, double.infinity);
        final over = c.percentageUsed >= 100;
        return ActionableInsight(
          id: 'cat_${c.categoryId}',
          title: over ? '${c.categoryName} is over budget' : '${c.categoryName} is close to its limit',
          description: over
              ? 'You have spent ₹${c.actualSpent.toStringAsFixed(0)} against a '
                  '₹${c.budgetedAmount.toStringAsFixed(0)} budget.'
              : 'You have ₹${remaining.toStringAsFixed(0)} left in ${c.categoryName} this period.',
          iconName: c.iconName,
          colorHex: c.colorHex,
          tag: over ? 'Alert' : 'Budget',
          ctaText: 'Review category',
          progress: (c.percentageUsed / 100).clamp(0, 1.5),
        );
      }).toList();
    }

    final byAmount = [...summary.categoryAllocations]
      ..sort((a, b) => b.actualSpent.compareTo(a.actualSpent));
    if (byAmount.isEmpty) return const [];
    final top = byAmount.first;
    return [
      ActionableInsight(
        id: 'top_${top.categoryId}',
        title: '${top.categoryName} is your top category',
        description: 'You have spent ₹${top.actualSpent.toStringAsFixed(0)} on '
            '${top.categoryName} this period.',
        iconName: top.iconName,
        colorHex: top.colorHex,
        tag: 'Trend',
        ctaText: 'View trend',
      ),
    ];
  }

  List<FocusDataPoint> _buildFocusData(
    List<_DailyPoint> daily, {
    required String cycle,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final byDate = {for (final p in daily) _dateKey(p.date): p.total};
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
      final value = byDate[_dateKey(d)] ?? 0.0;
      final label = isWeek ? weekdayAbbr[d.weekday - 1] : DateFormat('d MMM').format(d);
      return FocusDataPoint(label: label, value: value);
    }).toList();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  List<double> _syntheticSparkline(double amountSpent) {
    // The backend has no per-category daily time series (a real one would
    // need a dedicated endpoint), so this renders a short, monotonically
    // rising line ending at the real current spend — an honest shape
    // (spend accumulates over the period) rather than random noise.
    if (amountSpent <= 0) return const [0, 0, 0, 0, 0, 0, 0];
    const fractions = [0.45, 0.55, 0.65, 0.75, 0.85, 0.93, 1.0];
    return fractions.map((f) => (amountSpent * f)).toList();
  }

  SpendingStatus _statusFromBudget(String? status, double pct) {
    switch (status) {
      case 'critical':
        return SpendingStatus.over;
      case 'warning':
        return SpendingStatus.warning;
      default:
        return pct < 30 ? SpendingStatus.under : SpendingStatus.normal;
    }
  }

  String _actionIcon(String actionType) {
    switch (actionType) {
      case 'reduce_spend':
        return 'trending_down';
      case 'reallocate':
        return 'swap_horiz';
      default:
        return 'savings';
    }
  }

  String _actionCta(String actionType) {
    switch (actionType) {
      case 'reduce_spend':
        return 'Review category';
      case 'reallocate':
        return 'Reallocate';
      default:
        return 'View trend';
    }
  }

  String _severityColor(String? severity) {
    switch (severity) {
      case 'critical':
        return '#F43F5E';
      case 'warning':
        return '#F97316';
      default:
        return '#22C55E';
    }
  }

  ({String icon, String color}) _categoryVisual(String categoryName) {
    return _categoryVisuals[categoryName] ?? (icon: 'category', color: '#5BA1F7');
  }

  static const Map<String, ({String icon, String color})> _categoryVisuals = {
    'Food & Dining': (icon: 'restaurant', color: '#F97316'),
    'Groceries': (icon: 'local_grocery_store', color: '#F59E0B'),
    'Shopping': (icon: 'shopping_bag', color: '#5BA1F7'),
    'Transport': (icon: 'directions_car', color: '#22C55E'),
    'Entertainment': (icon: 'movie', color: '#A855F7'),
    'Bills & Utilities': (icon: 'receipt_long', color: '#F43F5E'),
    'Rent & Housing': (icon: 'home', color: '#0EA5E9'),
    'Rent': (icon: 'home', color: '#0EA5E9'),
    'Health': (icon: 'local_hospital', color: '#10B981'),
    'Investments': (icon: 'trending_up', color: '#6366F1'),
    'Income': (icon: 'savings', color: '#22C55E'),
    'Cash': (icon: 'payments', color: '#64748B'),
    'Transfers': (icon: 'swap_horiz', color: '#64748B'),
    'Other': (icon: 'category', color: '#94A3B8'),
  };
}

class _DailyPoint {
  final DateTime date;
  final double total;

  const _DailyPoint({required this.date, required this.total});

  factory _DailyPoint.fromJson(Map<String, dynamic> json) {
    final epochSeconds = (json['period_start'] as num?)?.toInt() ?? 0;
    return _DailyPoint(
      date: DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class _RawTxn {
  final String id;
  final double amount;
  final bool isDebit;
  final String category;
  final String merchant;
  final DateTime occurredAt;

  const _RawTxn({
    required this.id,
    required this.amount,
    required this.isDebit,
    required this.category,
    required this.merchant,
    required this.occurredAt,
  });

  factory _RawTxn.fromJson(Map<String, dynamic> json) {
    final epochSeconds = (json['occurred_at'] as num?)?.toInt() ?? 0;
    return _RawTxn(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isDebit: (json['type'] as String? ?? 'DEBIT').toUpperCase() != 'CREDIT',
      category: json['category'] as String? ?? '',
      merchant: json['merchant'] as String? ?? '',
      occurredAt: DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000),
    );
  }
}
