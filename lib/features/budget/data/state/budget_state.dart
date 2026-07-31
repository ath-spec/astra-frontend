import 'package:flutter/foundation.dart';

import 'package:astra_frontend/features/budget/data/models/budget.dart';
import 'package:astra_frontend/features/budget/data/models/category_avg.dart';
import 'package:astra_frontend/features/budget/data/models/budget_models.dart' hide BudgetDiagnosisResponse, BudgetLatestResponse;
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:astra_frontend/services/finance_repository.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';
import 'package:astra_frontend/services/analytics_repository.dart' hide debugPrint;

class BudgetState extends ChangeNotifier {
  final FinanceRepository _repo = FinanceRepository(dioApiClient);

  BudgetState() {
    loadCache();
  }

  // Cache keys
  static const String _kIsBudgetCreated = 'budget_is_created';
  static const String _kSessionTotalBudget = 'budget_session_total';
  static const String _kPendingRolloverDraftId = 'budget_pending_rollover_id';
  static const String _kPendingRolloverIsFallback = 'budget_pending_rollover_fallback';

  // 1. Diagnosis Phase
  BudgetDiagnosisResponse? currentDiagnosis;
  bool isLoadingDiagnosis = false;

  // 2. Setup Phase (Session)
  String? currentSessionId;
  List<CategorySuggestion> suggestedCategories = [];
  bool isLoadingSuggestions = false;

  // 3. Active Phase (Dashboard)
  BudgetLatestResponse? latestDashboard;
  bool isLoadingDashboard = false;

  // 4. Settings Cache
  BudgetSettingsResponse? cachedSettings;

  // Helpers
  List<Budget> editable = [];

  // Dummy session state (restored)
  bool isBudgetCreated = false;
  double sessionTotalBudget = 0.0;
  double sessionTotalSpent = 0.0;
  List<CategoryItem>? sessionCategoryList;

  // Pending Rollover Draft
  String? pendingRolloverDraftId;
  bool pendingRolloverIsFallback = false;

  void reset() {
    currentDiagnosis = null;
    isLoadingDiagnosis = false;
    currentSessionId = null;
    suggestedCategories = [];
    isLoadingSuggestions = false;
    latestDashboard = null;
    isLoadingDashboard = false;
    editable = [];
    isBudgetCreated = false;
    sessionTotalBudget = 0.0;
    sessionTotalSpent = 0.0;
    sessionCategoryList = null;
    pendingRolloverDraftId = null;
    pendingRolloverIsFallback = false;
    cachedSettings = null;
    notifyListeners();
  }

  Future<void> loadCache() async {
    // SharedPreferences not available, stubbing out
  }

  Future<void> _saveCache() async {
    // SharedPreferences not available, stubbing out
  }

  Future<void> checkBudgetStatus() async {
    try {
      final status = await _repo.getBudgetStatus();
      debugPrint('📊 [checkBudgetStatus] hasActiveBudget: ${status.hasActiveBudget}, total: ${status.totalBudget}');
      if (status.hasActiveBudget) {
        isBudgetCreated = true;
        sessionTotalBudget = status.totalBudget;
        _saveCache();
        notifyListeners();
        // Also fetch latest dashboard data to ensure home screen is ready
        fetchLatestDashboard();
      } else {
        isBudgetCreated = false;
        
        // Preserve or fetch rollover total budget to avoid flashing 0
        if (pendingRolloverDraftId != null) {
          // If we already have a non-zero cache, keep it. 
          // Otherwise, we could fetch it, but usually the dashboard call or RolloverDraftScreen will fetch it.
          // Just don't aggressively zero it out.
          if (sessionTotalBudget <= 0) {
            try {
              final repo = AnalyticsRepository(dioApiClient);
              final session = await repo.getBudgetSetupSession(pendingRolloverDraftId!);
              if (session != null) {
                sessionTotalBudget = session.totalBudget;
              }
            } catch (_) {}
          }
        } else {
          sessionTotalBudget = 0.0;
        }
        
        _saveCache();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('checkBudgetStatus error (non-fatal): $e');
    }
  }

  Future<void> fetchDiagnosis({String? month, bool forceRefresh = false}) async {
    isLoadingDiagnosis = true;
    notifyListeners();
    try {
      currentDiagnosis = await _repo.getBudgetDiagnosis(month: month, forceRefresh: forceRefresh);
    } finally {
      isLoadingDiagnosis = false;
      notifyListeners();
    }
  }

  Future<void> createSession(double totalBudget, {String? month}) async {
    final session = await _repo.createBudgetSession(month: month);
    currentSessionId = session.sessionId;
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

  Future<void> finalizeSession({List<CategoryAllocation>? allocations, double? totalBudget}) async {
    if (currentSessionId == null) return;
    
    // 1. Sync the final category choices and total budget back to the session before finalizing
    if (allocations != null || totalBudget != null) {
      await _repo.updateBudgetSession(
        sessionId: currentSessionId!,
        totalBudget: totalBudget,
        categoryAllocations: allocations,
      );
    }
    
    // 2. Commit the session
    await _repo.finalizeBudgetSession(sessionId: currentSessionId!);
    
    // Clear the session ID so subsequent budget edits create a new session
    currentSessionId = null;
    
    if (totalBudget != null) {
      sessionTotalBudget = totalBudget;
      isBudgetCreated = true;
    }
    
    // Clear any pending rollover state since we just finalized a budget
    pendingRolloverDraftId = null;
    pendingRolloverIsFallback = false;
    
    _saveCache();
    notifyListeners();
  }

  Future<void> fetchLatestDashboard() async {
    isLoadingDashboard = true;
    notifyListeners();
    try {
      latestDashboard = await _repo.getLatestBudget();
    } catch (e) {
      debugPrint('fetchLatestDashboard error: $e');
    } finally {
      isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<BudgetSettingsResponse> fetchSettings({bool forceRefresh = false}) async {
    if (!forceRefresh && cachedSettings != null) {
      return cachedSettings!;
    }
    cachedSettings = await _repo.getBudgetSettings();
    notifyListeners();
    return cachedSettings!;
  }

  void updateCachedSettings(BudgetSettingsResponse newSettings) {
    cachedSettings = newSettings;
    notifyListeners();
  }

  void setFromAverages(List<CategoryAvg> avgs) {
    editable = avgs.map((a) => Budget(name: a.name, amount: a.avg)).toList();
    notifyListeners();
  }

  void updateAmount(String category, double newAmount) {
    final i = editable.indexWhere((e) => e.name == category);
    if (i != -1) {
      final old = editable[i];
      editable[i] = Budget(name: old.name, amount: newAmount);
      notifyListeners();
    }
  }

  void setSessionBudget(double total, List<CategoryItem>? categories) {
    isBudgetCreated = true;
    sessionTotalBudget = total;
    sessionCategoryList = categories;
    _saveCache();
    notifyListeners();
  }

  void updateSessionStats({double? totalBudget, double? totalSpent, String? pendingRolloverDraftId, bool? pendingRolloverIsFallback}) {
    if (totalBudget != null) {
      // Don't overwrite a cached rollover total budget with 0 from the dashboard
      if (totalBudget > 0 || (pendingRolloverDraftId == null && this.pendingRolloverDraftId == null)) {
        sessionTotalBudget = totalBudget;
      }
      isBudgetCreated = totalBudget > 0;
    }
    if (totalSpent != null) sessionTotalSpent = totalSpent;
    if (pendingRolloverDraftId != null) this.pendingRolloverDraftId = pendingRolloverDraftId;
    if (pendingRolloverIsFallback != null) this.pendingRolloverIsFallback = pendingRolloverIsFallback;
    if (totalBudget != null || totalSpent != null || pendingRolloverDraftId != null || pendingRolloverIsFallback != null) {
      _saveCache();
      notifyListeners();
    }
  }

  void clearPendingRollover() {
    pendingRolloverDraftId = null;
    pendingRolloverIsFallback = false;
    _saveCache();
    notifyListeners();
  }

  void markBudgetCreated({required double totalBudget}) {
    isBudgetCreated = true;
    sessionTotalBudget = totalBudget;
    currentSessionId = null; // session consumed, clear it
    _saveCache();
    notifyListeners();
  }

  void resetBudget() {
    isBudgetCreated = false;
    sessionTotalBudget = 0.0;
    sessionTotalSpent = 0.0;
    sessionCategoryList = null;
    latestDashboard = null;
    currentDiagnosis = null;
    currentSessionId = null;
    pendingRolloverDraftId = null;
    pendingRolloverIsFallback = false;
    suggestedCategories = [];
    _saveCache();
    notifyListeners();
  }
}
