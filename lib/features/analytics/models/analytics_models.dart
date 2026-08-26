// ============================================================
// FILE: lib/features/analytics/models/analytics_models.dart
// Analytics feature models. Field names/json keys mirror the
// shape we expect from a future GET /v1/analytics/summary and
// GET /v1/analytics/insights endpoint pair, so wiring a real API
// later only means replacing AnalyticsRepository's bodies.
// ============================================================

/// Top-level payload for the Analytics screen.
class AnalyticsSummary {
  final List<FocusDataPoint> focusLevelData;
  final List<CategoryAllocation> categoryAllocations;
  final MonthlySpending monthlySpending;
  final List<SpendTrend> spendTrends;
  final List<SpendingLevelCategory> spendingLevels;
  final List<RecentSpend> recentSpends;

  const AnalyticsSummary({
    required this.focusLevelData,
    required this.categoryAllocations,
    required this.monthlySpending,
    required this.spendTrends,
    required this.spendingLevels,
    required this.recentSpends,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      focusLevelData: (json['focus_level_data'] as List<dynamic>? ?? [])
          .map((e) => FocusDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryAllocations: (json['category_allocations'] as List<dynamic>? ?? [])
          .map((e) => CategoryAllocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlySpending: MonthlySpending.fromJson(
        json['monthly_spending'] as Map<String, dynamic>? ?? const {},
      ),
      spendTrends: (json['spend_trends'] as List<dynamic>? ?? [])
          .map((e) => SpendTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
      spendingLevels: (json['spending_levels'] as List<dynamic>? ?? [])
          .map((e) => SpendingLevelCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentSpends: (json['recent_spends'] as List<dynamic>? ?? [])
          .map((e) => RecentSpend.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// One point on the "focus level" spend-over-time line chart.
class FocusDataPoint {
  final String label; // e.g. "Mon", "12 Aug"
  final double value;

  const FocusDataPoint({required this.label, required this.value});

  factory FocusDataPoint.fromJson(Map<String, dynamic> json) {
    return FocusDataPoint(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Spend allocated to a single category, used by the allocation
/// wedge chart and the monthly-spending-level carousel.
class CategoryAllocation {
  final String categoryId;
  final String categoryName;
  final String iconName;
  final double actualSpent;
  final double budgetedAmount;
  final double percentageUsed; // 0-100+
  final String colorHex;

  const CategoryAllocation({
    required this.categoryId,
    required this.categoryName,
    required this.iconName,
    required this.actualSpent,
    required this.budgetedAmount,
    required this.percentageUsed,
    required this.colorHex,
  });

  factory CategoryAllocation.fromJson(Map<String, dynamic> json) {
    return CategoryAllocation(
      categoryId: json['category_id'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'category',
      actualSpent: (json['actual_spent'] as num?)?.toDouble() ?? 0.0,
      budgetedAmount: (json['budgeted_amount'] as num?)?.toDouble() ?? 0.0,
      percentageUsed: (json['percentage_used'] as num?)?.toDouble() ?? 0.0,
      colorHex: json['color_hex'] as String? ?? '#5BA1F7',
    );
  }
}

/// This-month vs last-month total spend.
class MonthlySpending {
  final double currentTotal;
  final double previousTotal;
  final double percentageChange;

  const MonthlySpending({
    required this.currentTotal,
    required this.previousTotal,
    required this.percentageChange,
  });

  factory MonthlySpending.fromJson(Map<String, dynamic> json) {
    return MonthlySpending(
      currentTotal: (json['current_total'] as num?)?.toDouble() ?? 0.0,
      previousTotal: (json['previous_total'] as num?)?.toDouble() ?? 0.0,
      percentageChange: (json['percentage_change'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// One bar in the month-over-month spend trends chart.
class SpendTrend {
  final int year;
  final int month;
  final String monthLabel; // e.g. "Jan"
  final double totalSpent;

  const SpendTrend({
    required this.year,
    required this.month,
    required this.monthLabel,
    required this.totalSpent,
  });

  factory SpendTrend.fromJson(Map<String, dynamic> json) {
    return SpendTrend(
      year: json['year'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      monthLabel: json['month_label'] as String? ?? '',
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

enum SpendingStatus { normal, warning, over, under }

extension SpendingStatusX on SpendingStatus {
  static SpendingStatus fromString(String? value) {
    switch (value) {
      case 'warning':
        return SpendingStatus.warning;
      case 'over':
        return SpendingStatus.over;
      case 'under':
        return SpendingStatus.under;
      default:
        return SpendingStatus.normal;
    }
  }
}

/// One card in the horizontal "Monthly Spending Level" carousel.
class SpendingLevelCategory {
  final String categoryId;
  final String categoryName;
  final double amountSpent;
  final SpendingStatus status;
  final List<double> sparklineData;

  const SpendingLevelCategory({
    required this.categoryId,
    required this.categoryName,
    required this.amountSpent,
    required this.status,
    required this.sparklineData,
  });

  factory SpendingLevelCategory.fromJson(Map<String, dynamic> json) {
    return SpendingLevelCategory(
      categoryId: json['category_id'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      amountSpent: (json['amount_spent'] as num?)?.toDouble() ?? 0.0,
      status: SpendingStatusX.fromString(json['status'] as String?),
      sparklineData: (json['sparkline_data'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

/// A single row in the "Recent Spends" preview list on the
/// Analytics screen (a lighter shape than the full Transactions
/// feature's TransactionItem).
class RecentSpend {
  final String id;
  final String merchantName;
  final String category;
  final double amount;
  final DateTime time;
  final bool isDebit;

  const RecentSpend({
    required this.id,
    required this.merchantName,
    required this.category,
    required this.amount,
    required this.time,
    required this.isDebit,
  });

  factory RecentSpend.fromJson(Map<String, dynamic> json) {
    return RecentSpend(
      id: json['id'] as String? ?? '',
      merchantName: json['merchant_name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      isDebit: json['is_debit'] as bool? ?? true,
    );
  }
}

/// Mood conveyed by the AI insight avatar. Maps loosely from
/// whatever sentiment word a future backend sends back.
enum AiMood { happy, neutral, concerned }

extension AiMoodX on AiMood {
  static AiMood fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'sad':
      case 'worried':
      case 'concerned':
      case 'anxious':
        return AiMood.concerned;
      case 'neutral':
      case 'calm':
        return AiMood.neutral;
      default:
        return AiMood.happy;
    }
  }
}

/// The AI-generated narrative insight shown at the top of the
/// Analytics screen, paired with a mood for the avatar.
class AiInsight {
  final AiMood mood;
  final String text;

  const AiInsight({required this.mood, required this.text});

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      mood: AiMoodX.fromString(json['emotion'] as String?),
      text: json['text'] as String? ?? '',
    );
  }
}

/// A single actionable-insight card in the horizontal carousel
/// that appears after the user engages with the AI insight.
class ActionableInsight {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String colorHex;
  final String? tag;
  final String ctaText;
  final double? progress;

  const ActionableInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.colorHex,
    this.tag,
    required this.ctaText,
    this.progress,
  });

  factory ActionableInsight.fromJson(Map<String, dynamic> json) {
    return ActionableInsight(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'insights',
      colorHex: json['color_hex'] as String? ?? '#5BA1F7',
      tag: json['tag'] as String?,
      ctaText: json['cta_text'] as String? ?? 'Explore',
      progress: (json['progress'] as num?)?.toDouble(),
    );
  }
}

/// Response envelope for GET /v1/analytics/insights.
class AnalyticsInsights {
  final AiInsight aiInsight;
  final List<ActionableInsight> actionableInsights;

  const AnalyticsInsights({
    required this.aiInsight,
    required this.actionableInsights,
  });

  factory AnalyticsInsights.fromJson(Map<String, dynamic> json) {
    return AnalyticsInsights(
      aiInsight: AiInsight.fromJson(json['ai_insight'] as Map<String, dynamic>? ?? const {}),
      actionableInsights: (json['actionable_insights'] as List<dynamic>? ?? [])
          .map((e) => ActionableInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
