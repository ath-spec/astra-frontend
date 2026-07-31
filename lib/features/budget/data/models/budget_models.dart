// lib/models/budget_models.dart

class BudgetDiagnosisResponse {
  final String month;                           // "2026-03"
  final List<HistoricalSpending> historicalSpending;
  final double averageIncome;
  final double averageExpenses;
  final double averageSavings;
  final double suggestedTotalBudget;            // KEY FIELD — 0.85 × avg_expenses
  final List<CategorySuggestion> suggestedCategories; // Pre-calculated ML categories
  final List<DiagnosisInsight> diagnosisInsights;
  final List<String> suggestedBudgetReasoning;
  final DateTime generatedAt;

  BudgetDiagnosisResponse({
    this.month = '',
    required this.historicalSpending,
    required this.averageIncome,
    required this.averageExpenses,
    required this.averageSavings,
    this.suggestedTotalBudget = 5000.0,
    this.suggestedCategories = const [],
    required this.diagnosisInsights,
    this.suggestedBudgetReasoning = const [],
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  factory BudgetDiagnosisResponse.fromJson(Map<String, dynamic> json) {
    // 1. Extract history first
    final List<HistoricalSpending> history = (json['historical_spending'] as List? ?? [])
        .map((e) => HistoricalSpending.fromJson(e as Map<String, dynamic>))
        .toList();

    // 2. Extract Income with multiple key variants
    double avgIncome = (json['average_income'] as num?)?.toDouble() ?? 
                       (json['avg_income'] as num?)?.toDouble() ??
                       (json['total_income'] as num?)?.toDouble() ?? 
                       (json['income'] as num?)?.toDouble() ?? 0.0;

    // 3. Extract Expenses with multiple key variants
    double avgExpenses = (json['average_expenses'] as num?)?.toDouble() ?? 
                         (json['avg_expenses'] as num?)?.toDouble() ??
                         (json['total_expenses'] as num?)?.toDouble() ?? 
                         (json['expenses'] as num?)?.toDouble() ?? 0.0;

    // 4. Extract Savings with multiple key variants
    double avgSavings = (json['average_savings'] as num?)?.toDouble() ?? 
                        (json['avg_savings'] as num?)?.toDouble() ??
                        (json['total_savings'] as num?)?.toDouble() ?? 
                        (json['savings'] as num?)?.toDouble() ?? 0.0;

    // RECOVERY LOGIC: If top-level aggregates are zero but we have history, 
    // compute the averages ourselves from the history list.
    if (history.isNotEmpty) {
      if (avgIncome == 0) {
        avgIncome = history.map((e) => e.income).reduce((a, b) => a + b) / history.length;
      }
      if (avgExpenses == 0) {
        avgExpenses = history.map((e) => e.expenses).reduce((a, b) => a + b) / history.length;
      }
      if (avgSavings == 0) {
        avgSavings = history.map((e) => e.savings).reduce((a, b) => a + b) / history.length;
      }
    }

    // 5. Find suggested budget from multiple possible keys
    double? suggested;
    final possibleKeys = [
      'suggested_total_budget', 'suggested_budget', 'recommended_budget',
      'suggested_amount', 'target_budget', 'diagnostic_budget', 'total_budget_suggestion'
    ];
    for (final key in possibleKeys) {
      if (json[key] != null) {
        suggested = (json[key] as num?)?.toDouble();
        if (suggested != null && suggested > 0) break;
      }
    }

    // FINAL FALLBACK: 85% of real (or recovered) average expenses
    final fallback = avgExpenses > 0 ? (avgExpenses * 0.85) : 5000.0;
    final finalSuggested = (suggested != null && suggested > 0) ? suggested : fallback;

    return BudgetDiagnosisResponse(
      month: json['month'] as String? ?? '',
      historicalSpending: history,
      averageIncome: avgIncome,
      averageExpenses: avgExpenses,
      averageSavings: avgSavings,
      suggestedTotalBudget: finalSuggested,
      suggestedCategories: (json['suggested_categories'] as List? ?? [])
          .map((e) => CategorySuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestedBudgetReasoning: (json['suggested_budget_reasoning'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      diagnosisInsights: (json['diagnosis_insights'] as List? ?? [])
          .map((e) => DiagnosisInsight.fromJson(e))
          .toList(),
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'] as String)
          : null,
    );
  }
}

class HistoricalSpending {
  final int month;
  final int year;
  final double income;
  final double expenses;
  final double savings; // NEW — now included in API response

  HistoricalSpending({
    required this.month,
    required this.year,
    required this.income,
    required this.expenses,
    this.savings = 0.0,
  });

  /// Short label like "Mar 2026" for chart axes
  String get monthLabel {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    if (month < 1 || month > 12) return '';
    return '${months[month - 1]} $year';
  }

  factory HistoricalSpending.fromJson(Map<String, dynamic> json) {
    return HistoricalSpending(
      month: json['month'] as int? ?? 0,
      year: json['year'] as int? ?? 0,
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0.0,
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DiagnosisInsight {
  final String title;
  final String description;
  final String severity; // "positive", "warning", "critical"

  DiagnosisInsight({
    required this.title,
    required this.description,
    required this.severity,
  });

  factory DiagnosisInsight.fromJson(Map<String, dynamic> json) {
    return DiagnosisInsight(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'positive',
    );
  }
}

class CategorySuggestion {
  final String categoryId;
  final String categoryName;
  final double suggestedAmount;
  final double confidenceScore;
  final AdjustmentBounds adjustmentBounds;

  CategorySuggestion({
    required this.categoryId,
    required this.categoryName,
    required this.suggestedAmount,
    required this.confidenceScore,
    required this.adjustmentBounds,
  });

  factory CategorySuggestion.fromJson(Map<String, dynamic> json) {
    // Robustly find a name from any possible key
    String foundName = '';
    
    // Check possible keys in priority order
    final possibleKeys = [
      'category_name', 'categoryName', 'category', 'name', 'label', 'title', 
      'display_name', 'displayName', 'description', 'category_id', 'id'
    ];
    
    for (final key in possibleKeys) {
      final val = json[key];
      if (val != null) {
        if (val is String && val.isNotEmpty) {
          foundName = val;
          break;
        } else if (val is Map) {
          // Check nested name in priority order
          final nestedName = val['name'] ?? val['category_name'] ?? val['display_name'] ?? val['label'];
          if (nestedName != null && nestedName.toString().isNotEmpty) {
            foundName = nestedName.toString();
            break;
          }
        }
      }
    }

    return CategorySuggestion(
      categoryId: json['category_id']?.toString() ?? json['id']?.toString() ?? '',
      categoryName: foundName,
      suggestedAmount: (json['suggested_amount'] as num?)?.toDouble() ?? 0.0,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      adjustmentBounds: AdjustmentBounds.fromJson(json['adjustment_bounds'] ?? {}),
    );
  }
}

class AdjustmentBounds {
  final double minRecommended;
  final double maxRecommended;

  AdjustmentBounds({
    required this.minRecommended,
    required this.maxRecommended,
  });

  factory AdjustmentBounds.fromJson(dynamic raw) {
    // API may return a List [min, max] or a Map {min_recommended, max_recommended}
    if (raw is List) {
      return AdjustmentBounds(
        minRecommended: (raw.isNotEmpty ? raw[0] as num? : null)?.toDouble() ?? 0.0,
        maxRecommended: (raw.length > 1 ? raw[1] as num? : null)?.toDouble() ?? 0.0,
      );
    }
    final json = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    return AdjustmentBounds(
      minRecommended: (json['min_recommended'] as num?)?.toDouble() ?? 0.0,
      maxRecommended: (json['max_recommended'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BudgetSession {
  final String sessionId;
  final String status; // "active", "finalized"

  BudgetSession({required this.sessionId, required this.status});

  factory BudgetSession.fromJson(Map<String, dynamic> json) {
    return BudgetSession(
      sessionId: json['session_id'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
    );
  }
}

class BudgetLatestResponse {
  final List<BudgetCategoryDetail> budgets;
  final double totalBudget;
  final double totalSpent;
  final int daysRemainingInMonth;
  final double projectedSpend;
  final String status; // "positive", "warning", "critical"
  final double healthScore;
  final double? percentage; // New field from API
  // NEW fields from updated backend (March 2026)
  final double incomeAmount;       // was hardcoded 0.0 in BudgetOverviewCard
  final String budgetPeriodStart;  // "2026-03-01" — replaces hardcoded date string
  final String budgetPeriodEnd;    // "2026-03-31"

  BudgetLatestResponse({
    required this.budgets,
    required this.totalBudget,
    required this.totalSpent,
    required this.daysRemainingInMonth,
    required this.projectedSpend,
    required this.status,
    required this.healthScore,
    this.incomeAmount = 0.0,
    this.budgetPeriodStart = '',
    this.budgetPeriodEnd = '',
    this.percentage,
  });

  factory BudgetLatestResponse.fromJson(Map<String, dynamic> json) {
    final budgetsList = (json['budgets'] as List? ?? [])
        .map((e) => BudgetCategoryDetail.fromJson(e))
        .toList();
        
    double tb = (json['total_budget'] as num?)?.toDouble() ?? 0.0;

    return BudgetLatestResponse(
      budgets: budgetsList,
      totalBudget: tb,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      daysRemainingInMonth: json['days_remaining_in_month'] as int? ?? 0,
      projectedSpend: (json['projected_spend'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'positive',
      healthScore: (json['health_score'] as num?)?.toDouble() ?? 0.0,
      incomeAmount: (json['income_amount'] as num?)?.toDouble() ?? 0.0,
      budgetPeriodStart: json['budget_period_start'] as String? ?? '',
      budgetPeriodEnd: json['budget_period_end'] as String? ?? '',
      percentage: json['percentage'] != null ? (json['percentage'] as num).toDouble() / 100.0 : null,
    );
  }
}

class BudgetCategoryDetail {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final String categoryTextColor;
  final double budgetedAmount;
  final double spentAmount;
  final double remainingAmount;
  final double percentageUsed;
  final String status; // "positive", "warning", "critical"
  final bool isHidden;

  BudgetCategoryDetail({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryTextColor,
    required this.budgetedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentageUsed,
    required this.status,
    this.isHidden = false,
  });

  factory BudgetCategoryDetail.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryDetail(
      id: json['id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      categoryName: (json['display_name'] ?? json['category_name']) as String? ?? '',
      categoryIcon: json['icon'] as String? ?? json['category_icon'] as String? ?? '',
      categoryColor: json['color'] as String? ?? json['category_color'] as String? ?? '',
      categoryTextColor: json['text_color'] as String? ?? json['category_text_color'] as String? ?? '',
      budgetedAmount: (json['amount'] as num? ?? json['budgeted_amount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spent_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      percentageUsed: (json['percentage_used'] != null 
                       ? (json['percentage_used'] as num).toDouble() / 100.0 
                       : (json['percentage'] != null ? (json['percentage'] as num).toDouble() / 100.0 : 0.0)),
      status: json['status'] as String? ?? 'positive',
      isHidden: json['is_hidden'] as bool? ?? false,
    );
  }
}

class CategoryAllocation {
  final String categoryId;
  final double amount;
  final bool? isTracking;
  final bool isHidden;

  CategoryAllocation({
    required this.categoryId,
    required this.amount,
    this.isTracking,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'amount': amount,
        'is_tracking': isTracking,
        'is_hidden': isHidden,
      };
}
