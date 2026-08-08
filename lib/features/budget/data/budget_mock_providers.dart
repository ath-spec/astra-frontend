import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/budget/data/models/budget_models.dart' hide BudgetLatestResponse;
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';

class BudgetState extends ChangeNotifier {
  final bool isLoadingDiagnosis;
  Diagnosis? currentDiagnosis;
  List<dynamic> suggestedCategories = [];
  String? currentSessionId = 'mock_session_id';
  bool editable = true;
  double sessionTotalSpent = 0.0;
  BudgetLatestResponse? latestDashboard;
  bool hasSetupRecurring = false;

  void setRecurringSetup(bool value) {
    hasSetupRecurring = value;
    notifyListeners();
  }

  BudgetState({
    this.isLoadingDiagnosis = false,
    this.currentDiagnosis,
  });

  Future<void> fetchDiagnosis({String? month, bool forceRefresh = false}) async {
    await Future.delayed(const Duration(seconds: 1));
  }
  
  void clearPendingRollover() {}

  

  Future<void> fetchLatestDashboard() async {
    await Future.delayed(const Duration(seconds: 1));
  }
  
  Future<void> createSession(double totalBudget, {String? month}) async {
    currentSessionId = 'mock_session_${DateTime.now().millisecondsSinceEpoch}';
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
    BudgetSettingsResponse budgetSettings = const BudgetSettingsResponse(
    spendingLimit: 0.0,
    linkedIncome: 300000.0,
    limitSource: 'user',
    incomeSource: 'user',
    billsTotal: 0.0,
    essentialCategoriesTotal: 0.0,
  );

  Future<BudgetSettingsResponse> fetchSettings({bool forceRefresh = false}) async {
    return budgetSettings;
  }
  
  Future<void> updateBudgetSettings({required double spendingLimit, required double linkedIncome}) async {
    budgetSettings = BudgetSettingsResponse(
        spendingLimit: spendingLimit,
        linkedIncome: linkedIncome,
        limitSource: budgetSettings.limitSource,
        incomeSource: budgetSettings.incomeSource,
        billsTotal: budgetSettings.billsTotal,
        essentialCategoriesTotal: budgetSettings.essentialCategoriesTotal,
        lastReset: budgetSettings.lastReset,
    );
  }

  
  Future<void> fetchCategorySuggestions(dynamic param) async {
    await Future.delayed(const Duration(seconds: 1));
    suggestedCategories = [
      CategorySuggestion(categoryId: 'utilities', categoryName: 'Utilities', suggestedAmount: 5000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 4000.0, maxRecommended: 6000.0)),
      CategorySuggestion(categoryId: 'groceries', categoryName: 'Groceries', suggestedAmount: 12000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 10000.0, maxRecommended: 14000.0)),
      CategorySuggestion(categoryId: 'dining', categoryName: 'Dining', suggestedAmount: 4000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 3000.0, maxRecommended: 5000.0)),
      CategorySuggestion(categoryId: 'shopping', categoryName: 'Shopping', suggestedAmount: 3000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 2000.0, maxRecommended: 4000.0)),
      CategorySuggestion(categoryId: 'entertainment', categoryName: 'Entertainment', suggestedAmount: 2000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 1000.0, maxRecommended: 3000.0)),
    ];
  }

  Future<void> analyzeSpends() async {
    await Future.delayed(const Duration(seconds: 2));
    currentDiagnosis = Diagnosis();
  }

  

  void setSessionBudget(double totalBudget, List<CategoryItem> categoryList) {}
  
  void setFromAverages(dynamic averages, {dynamic keep}) {}
  
    void _createMockDashboard(double totalBudget, List<dynamic> allocations, {List<dynamic>? categories}) {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final daysRemaining = nextMonth.difference(now).inDays;
    
    final budgets = <BudgetCategoryDetail>[];
    double totalSpent = 0.0;
    
    for (int i = 0; i < allocations.length; i++) {
        final alloc = allocations[i];
        final catId = alloc.categoryId;
        final amount = alloc.amount;
        
        String title = catId;
        String color = '#E0E0E0';
        
        try {
            if ((alloc as dynamic).categoryName != null) {
                title = (alloc as dynamic).categoryName;
            }
        } catch (_) {}

        try {
            if ((alloc as dynamic).categoryColor != null) {
                color = (alloc as dynamic).categoryColor;
            }
        } catch (_) {}
        
        if (categories != null) {
            for (var c in categories) {
                try {
                    if ((c as dynamic).categoryId == catId) {
                        if ((c as dynamic).title != null) title = (c as dynamic).title;
                        if ((c as dynamic).iconColor != null) {
                            Color colorObj = (c as dynamic).iconColor;
                            color = '#${colorObj.toARGB32().toRadixString(16).padLeft(8, '0')}';
                        }
                    }
                } catch (_) {}
            }
        }
        
        // Mocking spending as requested by user
        final spent = amount * 0.4;
        totalSpent += spent;
        
        budgets.add(BudgetCategoryDetail(
            id: 'mock_$i',
            categoryId: catId,
            categoryName: title,
            categoryIcon: 'assets/icons/mock.svg',
            categoryColor: color,
            categoryTextColor: '#000000',
            budgetedAmount: amount,
            spentAmount: spent,
            remainingAmount: amount - spent,
            percentageUsed: (spent / amount) * 100,
            status: 'positive',
            isHidden: false,
        ));
    }
    
    latestDashboard = BudgetLatestResponse(
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        daysRemainingInMonth: daysRemaining,
        projectedSpend: totalSpent * 1.5,
        incomeAmount: budgetSettings.linkedIncome,
        budgetPeriodStart: '${now.year}-${now.month.toString().padLeft(2, '0')}-01',
        budgetPeriodEnd: '${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-01',
        status: 'active',
        budgets: budgets,
    );
    notifyListeners();
  }

  bool isSubmitting = false;

  Future<void> submitBudgetSetup({
    required List<dynamic> allocations,
    required double totalBudget,
    List<dynamic>? categories,
  }) async {
    if (isSubmitting) return; // Prevent race conditions
    
    isSubmitting = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    
    _createMockDashboard(totalBudget, allocations, categories: categories);
    
    isSubmitting = false;
    notifyListeners();
  }

  Future<void> finalizeSession({required List<dynamic> allocations, required double totalBudget}) async {
    await Future.delayed(const Duration(seconds: 1));
    _createMockDashboard(totalBudget, allocations);
    notifyListeners();
  }

  Future<void> generateBudget({double? totalBudget, List<dynamic>? allocations, List<dynamic>? categoryList}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (totalBudget != null && allocations != null) {
      _createMockDashboard(totalBudget, allocations, categories: categoryList);
      notifyListeners();
    }
  }

  void resetBudget() {
    latestDashboard = null;
    currentSessionId = null;
    isSubmitting = false;
    hasSetupRecurring = false;
    notifyListeners();
  }
}

class Diagnosis {
  final double averageIncome;
  final double averageSavings;
  final double averageExpenses;
  final List<DiagnosisInsight> diagnosisInsights;
  final double suggestedTotalBudget;
  final List<dynamic> historicalSpending;

  Diagnosis({
    this.averageIncome = 150000.0,
    this.averageSavings = 45000.0,
    this.averageExpenses = 105000.0,
    this.suggestedTotalBudget = 100000.0,
    this.historicalSpending = const [1],
    this.diagnosisInsights = const [],
  });
}

class DiagnosisInsight {
  final String title;
  final String description;
  const DiagnosisInsight({required this.title, required this.description});
}

class CategoryAllocation {
  final String categoryId;
  final String? categoryName;
  final String? categoryColor;
  final double amount;
  final bool? isTracking;
  final bool isHidden;
  CategoryAllocation({required this.categoryId, this.categoryName, this.categoryColor, required this.amount, this.isTracking, this.isHidden = false});
}

final budgetStateProvider = ChangeNotifierProvider<BudgetState>((ref) {
  return BudgetState(
    isLoadingDiagnosis: false,
    currentDiagnosis: Diagnosis(
      averageIncome: 300000.0,
      averageSavings: 111000.0,
      averageExpenses: 190103.0,
      suggestedTotalBudget: 185672.0,
      historicalSpending: const [
        {
          'month': 2,
          'year': 2026,
          'income': 300000.0,
          'expenses': 185000.0,
          'savings': 115000.0,
        },
        {
          'month': 3,
          'year': 2026,
          'income': 300000.0,
          'expenses': 182500.0,
          'savings': 117500.0,
        },
        {
          'month': 4,
          'year': 2026,
          'income': 300000.0,
          'expenses': 188000.0,
          'savings': 112000.0,
        },
        {
          'month': 5,
          'year': 2026,
          'income': 300000.0,
          'expenses': 192000.0,
          'savings': 108000.0,
        },
        {
          'month': 6,
          'year': 2026,
          'income': 300000.0,
          'expenses': 190103.0,
          'savings': 111000.0,
        },
        {
          'month': 7,
          'year': 2026,
          'income': 300000.0,
          'expenses': 188500.0,
          'savings': 111500.0,
        },
      ],
      diagnosisInsights: const [
        DiagnosisInsight(
          title: 'Strong savings',
          description: 'You\'re saving 36.6% of your income. Excellent financial discipline!',
        ),
      ],
    ),
  );
});

