import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/budget/data/models/budget_models.dart' hide BudgetLatestResponse;
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';

class BudgetState {
  final bool isLoadingDiagnosis;
  Diagnosis? currentDiagnosis;
  List<dynamic> suggestedCategories = [];
  String? currentSessionId = 'mock_session_id';
  bool editable = true;
  double sessionTotalSpent = 0.0;
  BudgetLatestResponse? latestDashboard;

  BudgetState({
    this.isLoadingDiagnosis = false,
    this.currentDiagnosis,
  });

  Future<void> fetchDiagnosis({String? month, bool forceRefresh = false}) async {
    await Future.delayed(const Duration(seconds: 1));
  }
  
  void clearPendingRollover() {}

  Future<void> finalizeSession({required List<dynamic> allocations, required double totalBudget}) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> fetchLatestDashboard() async {
    await Future.delayed(const Duration(seconds: 1));
  }
  
  Future<void> createSession(double totalBudget, {String? month}) async {
    currentSessionId = 'mock_session_${DateTime.now().millisecondsSinceEpoch}';
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  Future<BudgetSettingsResponse> fetchSettings({bool forceRefresh = false}) async {
    return const BudgetSettingsResponse();
  }
  
  Future<void> fetchCategorySuggestions(dynamic param) async {
    await Future.delayed(const Duration(seconds: 1));
    suggestedCategories = [
      CategorySuggestion(categoryId: 'cat_util', categoryName: 'Utilities', suggestedAmount: 5000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 4000.0, maxRecommended: 6000.0)),
      CategorySuggestion(categoryId: 'cat_groc', categoryName: 'Groceries', suggestedAmount: 12000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 10000.0, maxRecommended: 14000.0)),
      CategorySuggestion(categoryId: 'cat_dine', categoryName: 'Dining', suggestedAmount: 4000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 3000.0, maxRecommended: 5000.0)),
      CategorySuggestion(categoryId: 'cat_shop', categoryName: 'Shopping', suggestedAmount: 3000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 2000.0, maxRecommended: 4000.0)),
      CategorySuggestion(categoryId: 'cat_ent', categoryName: 'Entertainment', suggestedAmount: 2000.0, confidenceScore: 0.9, adjustmentBounds: AdjustmentBounds(minRecommended: 1000.0, maxRecommended: 3000.0)),
    ];
  }

  Future<void> analyzeSpends() async {
    await Future.delayed(const Duration(seconds: 2));
    currentDiagnosis = Diagnosis();
  }

  Future<void> generateBudget() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  void setSessionBudget(double totalBudget, List<CategoryItem> categoryList) {}
  
  void setFromAverages(dynamic averages, {dynamic keep}) {}
  
  void resetBudget() {
    latestDashboard = null;
    currentSessionId = null;
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

final budgetStateProvider = Provider<BudgetState>((ref) {
  return BudgetState(
    isLoadingDiagnosis: false,
    currentDiagnosis: Diagnosis(
      averageIncome: 300000.0,
      averageSavings: 111000.0,
      averageExpenses: 190103.0,
      suggestedTotalBudget: 185672.0,
      historicalSpending: const [1],
      diagnosisInsights: const [
        DiagnosisInsight(
          title: 'Strong savings',
          description: 'You\'re saving 36.6% of your income. Excellent financial discipline!',
        ),
      ],
    ),
  );
});
