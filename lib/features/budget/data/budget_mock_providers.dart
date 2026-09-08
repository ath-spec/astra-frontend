import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/services/finance_repository.dart';
import 'package:astra_frontend/features/budget/data/models/budget_models.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart'
    hide BudgetLatestResponse, BudgetDiagnosisResponse;
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';

/// Budget wizard + dashboard state. Every method drives [FinanceRepository]
/// against /api/v1/analytics/budgets. The extra members (`generateBudget`,
/// `submitBudgetSetup`, `analyzeSpends`, `hasSetupRecurring`, …) are thin
/// wrappers over the same real calls so the ported screens compile unchanged.
class BudgetState extends ChangeNotifier {
  final FinanceRepository _repo = FinanceRepository(dioApiClient);

  // 1. Diagnosis phase
  Diagnosis? currentDiagnosis;
  bool isLoadingDiagnosis = false;

  // 2. Setup phase (session)
  String? currentSessionId;
  List<dynamic> suggestedCategories = [];
  bool isLoadingSuggestions = false;

  // 3. Active phase (dashboard)
  BudgetLatestResponse? latestDashboard;
  bool isLoadingDashboard = false;

  // 4. Settings
  BudgetSettingsResponse? cachedSettings;
  BudgetSettingsResponse budgetSettings = const BudgetSettingsResponse();

  // Session-restore / misc state used across screens
  bool isBudgetCreated = false;
  double sessionTotalBudget = 0.0;
  double sessionTotalSpent = 0.0;
  bool isSubmitting = false;
  bool hasSetupRecurring = false;
  String? pendingRolloverDraftId;
  bool pendingRolloverIsFallback = false;

  // ── small setters used by screens ──────────────────────────────────

  void setRecurringSetup(bool value) {
    hasSetupRecurring = value;
    notifyListeners();
  }

  void clearPendingRollover() {
    pendingRolloverDraftId = null;
    pendingRolloverIsFallback = false;
    notifyListeners();
  }

  void setSessionBudget(double totalBudget, List<CategoryItem> categoryList) {
    sessionTotalBudget = totalBudget;
    isBudgetCreated = true;
    notifyListeners();
  }

  void setFromAverages(dynamic averages, {dynamic keep}) {}

  void updateCachedSettings(BudgetSettingsResponse newSettings) {
    cachedSettings = newSettings;
    budgetSettings = newSettings;
    notifyListeners();
  }

  // ── App-start restore ─────────────────────────────────────────────
  // GET /budgets/status — restores isBudgetCreated without the wizard.

  Future<void> checkBudgetStatus() async {
    try {
      final status = await _repo.getBudgetStatus();
      pendingRolloverDraftId = status.pendingRolloverDraftId;
      if (status.hasActiveBudget) {
        isBudgetCreated = true;
        sessionTotalBudget = status.totalBudget;
        notifyListeners();
        await fetchLatestDashboard();
      } else {
        isBudgetCreated = false;
        sessionTotalBudget = 0.0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('checkBudgetStatus (non-fatal): $e');
    }
  }

  // ── Phase 1: diagnosis ───────────────────────────────────────────
  // POST /budgets/diagnosis

  Future<void> fetchDiagnosis({String? month, bool forceRefresh = false}) async {
    isLoadingDiagnosis = true;
    notifyListeners();
    try {
      final raw = await _repo.getBudgetDiagnosis(month: month, forceRefresh: forceRefresh);
      currentDiagnosis = Diagnosis.fromJson(raw);
    } catch (e) {
      debugPrint('fetchDiagnosis error: $e');
    } finally {
      isLoadingDiagnosis = false;
      notifyListeners();
    }
  }

  /// Alias kept for screens that called the old mock name.
  Future<void> analyzeSpends() => fetchDiagnosis();

  // ── Phase 2: setup session ───────────────────────────────────────
  // POST /budgets/sessions  →  POST /budgets/suggest/categories

  Future<void> createSession(double totalBudget, {String? month}) async {
    try {
      final session = await _repo.createBudgetSession(month: month);
      currentSessionId = (session as dynamic).sessionId as String?;
    } catch (e) {
      debugPrint('createSession error: $e');
    }
    notifyListeners();
  }

  Future<void> fetchCategorySuggestions(double totalBudget, {String? month}) async {
    isLoadingSuggestions = true;
    notifyListeners();
    try {
      suggestedCategories = await _repo.getCategorySuggestions(
        totalBudget: totalBudget,
        month: month,
      );
    } finally {
      isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  // ── Phase 2→3: finalize ──────────────────────────────────────────
  // PATCH /budgets/sessions/:id  →  POST /budgets/sessions/:id/finalize

  Future<void> finalizeSession({List<dynamic>? allocations, double? totalBudget}) async {
    if (currentSessionId == null || currentSessionId!.isEmpty) return;
    await _repo.finalizeBudgetSession(
      sessionId: currentSessionId,
      categoryAllocations: allocations,
      totalBudget: totalBudget,
    );
    currentSessionId = null;
    if (totalBudget != null) {
      sessionTotalBudget = totalBudget;
      isBudgetCreated = true;
    }
    pendingRolloverDraftId = null;
    pendingRolloverIsFallback = false;
    notifyListeners();
  }

  /// Same commit path as [finalizeSession], then refreshes the dashboard —
  /// same as the generate screen path (finalizeSession + fetchLatestDashboard).
  Future<void> generateBudget({
    double? totalBudget,
    List<dynamic>? allocations,
    List<dynamic>? categoryList,
  }) async {
    await finalizeSession(allocations: allocations, totalBudget: totalBudget);
    await fetchLatestDashboard();
  }

  Future<void> submitBudgetSetup({
    required List<dynamic> allocations,
    required double totalBudget,
    List<dynamic>? categories,
  }) async {
    if (isSubmitting) return;
    isSubmitting = true;
    notifyListeners();
    try {
      await finalizeSession(allocations: allocations, totalBudget: totalBudget);
      await fetchLatestDashboard();
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Phase 3: active dashboard ────────────────────────────────────
  // GET /budgets/latest

  Future<void> fetchLatestDashboard() async {
    isLoadingDashboard = true;
    notifyListeners();
    try {
      final raw = await _repo.getLatestBudget();
      latestDashboard = BudgetLatestResponse.fromJson(raw);
      sessionTotalSpent = latestDashboard?.totalSpent ?? sessionTotalSpent;
      if ((latestDashboard?.totalBudget ?? 0) > 0) {
        sessionTotalBudget = latestDashboard!.totalBudget;
        isBudgetCreated = true;
      }
    } catch (e) {
      debugPrint('fetchLatestDashboard error: $e');
    } finally {
      isLoadingDashboard = false;
      notifyListeners();
    }
  }

  // ── Settings ────────────────────────────────────────────────────
  // GET/PATCH /budgets/settings

  Future<BudgetSettingsResponse> fetchSettings({bool forceRefresh = false}) async {
    if (!forceRefresh && cachedSettings != null) return cachedSettings!;
    try {
      cachedSettings = await _repo.getBudgetSettings();
      budgetSettings = cachedSettings!;
    } catch (e) {
      debugPrint('fetchSettings error: $e');
    }
    notifyListeners();
    return cachedSettings ?? budgetSettings;
  }

  Future<void> updateBudgetSettings({
    required double spendingLimit,
    required double linkedIncome,
  }) async {
    await _repo.updateBudgetSettings(
      spendingLimit: spendingLimit,
      linkedIncome: linkedIncome,
    );
    await fetchSettings(forceRefresh: true);
  }

  // ── Reset ──────────────────────────────────────────────────────
  // DELETE /budgets/active

  Future<void> resetBudget() async {
    try {
      await _repo.resetActiveBudget();
    } catch (e) {
      debugPrint('resetBudget error: $e');
    }
    latestDashboard = null;
    currentSessionId = null;
    currentDiagnosis = null;
    suggestedCategories = [];
    cachedSettings = null;
    isBudgetCreated = false;
    isSubmitting = false;
    hasSetupRecurring = false;
    sessionTotalBudget = 0.0;
    sessionTotalSpent = 0.0;
    pendingRolloverDraftId = null;
    pendingRolloverIsFallback = false;
    notifyListeners();
  }
}

/// Lightweight diagnosis view model. Parses the raw POST /budgets/diagnosis
/// body (snake_case).
class Diagnosis {
  final double averageIncome;
  final double averageSavings;
  final double averageExpenses;
  final List<DiagnosisInsight> diagnosisInsights;
  final double suggestedTotalBudget;
  final List<dynamic> historicalSpending;

  Diagnosis({
    this.averageIncome = 0.0,
    this.averageSavings = 0.0,
    this.averageExpenses = 0.0,
    this.suggestedTotalBudget = 0.0,
    this.historicalSpending = const [],
    this.diagnosisInsights = const [],
  });

  factory Diagnosis.fromJson(Map<String, dynamic> j) {
    double n(String k) => (j[k] as num?)?.toDouble() ?? 0.0;
    final expenses = n('average_expenses');
    return Diagnosis(
      averageIncome: n('average_income'),
      averageExpenses: expenses,
      averageSavings: n('average_savings'),
      suggestedTotalBudget: (j['suggested_total_budget'] as num?)?.toDouble() ??
          (expenses > 0 ? expenses * 0.85 : 5000.0),
      historicalSpending: (j['historical_spending'] as List?) ?? const [],
      diagnosisInsights: ((j['diagnosis_insights'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => DiagnosisInsight(
                title: e['title']?.toString() ?? '',
                description: e['description']?.toString() ?? '',
              ))
          .toList(),
    );
  }
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

  CategoryAllocation({
    required this.categoryId,
    this.categoryName,
    this.categoryColor,
    required this.amount,
    this.isTracking,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        if (categoryName != null) 'category_name': categoryName,
        if (categoryColor != null) 'category_color': categoryColor,
        'amount': amount,
        'is_tracking': isTracking ?? true,
        'is_hidden': isHidden,
      };
}

final budgetStateProvider = ChangeNotifierProvider<BudgetState>((ref) {
  return BudgetState();
});
