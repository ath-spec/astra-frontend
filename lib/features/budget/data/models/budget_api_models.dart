// ============================================================
// FILE: lib/features/budget/data/models/budget_api_models.dart
// Budget API models for updated backend (March 2026)
// ============================================================

import 'package:astra_frontend/features/budget/data/budget_mock_providers.dart';
/// Response from GET /v1/analytics/budgets/status
/// Call this on app start to determine if the user has an existing budget
/// without running the full setup wizard.
class BudgetStatusResponse {
  final bool hasActiveBudget;
  final String activeMonth; // "2026-03" or ""
  final double totalBudget;
  final int budgetCount;
  final int latestYear;
  final int latestMonth;

  const BudgetStatusResponse({
    required this.hasActiveBudget,
    this.activeMonth = '',
    this.totalBudget = 0,
    this.budgetCount = 0,
    this.latestYear = 0,
    this.latestMonth = 0,
  });

  factory BudgetStatusResponse.fromJson(Map<String, dynamic> json) {
    return BudgetStatusResponse(
      hasActiveBudget: json['has_active_budget'] as bool? ?? false,
      activeMonth: json['active_month'] as String? ?? '',
      totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
      budgetCount: json['budget_count'] as int? ?? 0,
      latestYear: json['latest_year'] as int? ?? 0,
      latestMonth: json['latest_month'] as int? ?? 0,
    );
  }
}

/// Single AI insight from POST /v1/analytics/budgets/diagnosis
/// or GET /v1/analytics/budgets/insights
class BudgetInsight {
  final String id;
  final String title;
  final String description;
  final String severity; // "positive" | "warning" | "critical"
  final String category;
  final double potentialSaving;
  final String actionType; // "reduce_spend" | "reallocate" | "save_more"

  const BudgetInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.potentialSaving,
    required this.actionType,
  });

  factory BudgetInsight.fromJson(Map<String, dynamic> json) {
    return BudgetInsight(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'positive',
      category: json['category'] as String? ?? '',
      potentialSaving: (json['potential_saving'] as num?)?.toDouble() ?? 0.0,
      actionType: json['action_type'] as String? ?? 'save_more',
    );
  }
}

/// Full response from GET /v1/analytics/budgets/insights
class BudgetInsightsResponse {
  final List<BudgetInsight> insights;
  final DateTime generatedAt;

  const BudgetInsightsResponse({
    required this.insights,
    required this.generatedAt,
  });

  factory BudgetInsightsResponse.fromJson(Map<String, dynamic> json) {
    return BudgetInsightsResponse(
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => BudgetInsight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ==========================================
// Settings API Models
// ==========================================

class BudgetSettingsResponse {
  final double spendingLimit;
  final String limitSource;
  final double linkedIncome;
  final String incomeSource;
  final double billsTotal;
  final double essentialCategoriesTotal;
  final DateTime? lastReset;

  const BudgetSettingsResponse({
    this.spendingLimit = 0.0,
    this.limitSource = '',
    this.linkedIncome = 0.0,
    this.incomeSource = '',
    this.billsTotal = 0.0,
    this.essentialCategoriesTotal = 0.0,
    this.lastReset,
  });

  factory BudgetSettingsResponse.fromJson(Map<String, dynamic> json) {
    return BudgetSettingsResponse(
      spendingLimit: (json['spending_limit']?['amount'] as num?)?.toDouble() ?? 0.0,
      limitSource: json['spending_limit']?['source'] as String? ?? '',
      linkedIncome: (json['linked_income']?['amount'] as num?)?.toDouble() ?? 0.0,
      incomeSource: json['linked_income']?['source'] as String? ?? '',
      billsTotal: (json['bills_total'] as num?)?.toDouble() ?? 0.0,
      essentialCategoriesTotal: (json['essential_categories_total'] as num?)?.toDouble() ?? 0.0,
      lastReset: json['last_reset'] != null ? DateTime.tryParse(json['last_reset']) : null,
    );
  }
}

// ==========================================
// Reallocation API Models (Smart Rebalance)
// ==========================================

class ReallocationProposal {
  final String fromCategory;
  final String toCategory;
  final double amount;
  final String reason;

  const ReallocationProposal({
    required this.fromCategory,
    required this.toCategory,
    required this.amount,
    required this.reason,
  });

  factory ReallocationProposal.fromJson(Map<String, dynamic> json) {
    return ReallocationProposal(
      fromCategory: json['from_category'] as String? ?? '',
      toCategory: json['to_category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'from_category': fromCategory,
    'to_category': toCategory,
    'amount': amount,
  };
}

class ReallocationRunResponse {
  final double overspentAmount;
  final double uncoveredOverspend;
  final List<ReallocationProposal> reallocations;
  final String message;

  const ReallocationRunResponse({
    this.overspentAmount = 0.0,
    this.uncoveredOverspend = 0.0,
    this.reallocations = const [],
    this.message = '',
  });

  factory ReallocationRunResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ReallocationRunResponse(
      overspentAmount: (data['overspent_amount'] as num?)?.toDouble() ?? 0.0,
      uncoveredOverspend: (data['uncovered_overspend'] as num?)?.toDouble() ?? 0.0,
      message: data['message'] as String? ?? '',
      reallocations: (data['reallocations'] as List<dynamic>?)
          ?.map((e) => ReallocationProposal.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
class BudgetConflictException implements Exception {
  final dynamic response;
  final String type;
  final double amount;
  final List<dynamic> conflicts;
  
  BudgetConflictException(
    this.response, {
    this.type = 'scalable_floor_exceeded',
    this.amount = 0.0,
    this.conflicts = const [],
  });
}

class BudgetDiagnosisResponse extends Diagnosis {
  final String month;
  BudgetDiagnosisResponse({
    required this.month,
    required super.historicalSpending,
    required super.averageIncome,
    required super.averageExpenses,
    required super.averageSavings,
    required super.suggestedTotalBudget,
    required super.diagnosisInsights,
  });
}
class BudgetLatestResponse {
  final double totalBudget;
  final double totalSpent;
  final int daysRemainingInMonth;
  final double projectedSpend;
  final double incomeAmount;
  final String? budgetPeriodStart;
  final String? budgetPeriodEnd;
  final String? status;
  final List<dynamic> budgets;

  BudgetLatestResponse({
    this.totalBudget = 0.0, 
    this.totalSpent = 0.0,
    this.daysRemainingInMonth = 0,
    this.projectedSpend = 0.0,
    this.incomeAmount = 0.0,
    this.budgetPeriodStart,
    this.budgetPeriodEnd,
    this.status,
    this.budgets = const [],
  });
}
