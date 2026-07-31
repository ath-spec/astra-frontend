import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';

class FinanceRepository {
  FinanceRepository([dynamic client]);
  Future<void> updateBudgetSettings({double? spendingLimit, double? linkedIncome}) async {}
  Future<void> updateBudgetSession({String? sessionId, double? totalBudget, dynamic categoryAllocations}) async {}
  Future<dynamic> initialAverages(String month) async => null;
  Future<BudgetStatusResponse> getBudgetStatus() async => const BudgetStatusResponse(hasActiveBudget: false);
  Future<dynamic> createBudgetSession({String? month, double? totalBudget}) async => MockSession();
  Future<dynamic> getCategorySuggestions({double? limit, double? totalBudget, String? month}) async => [];
  Future<dynamic> finalizeBudgetSession({String? sessionId, dynamic categoryAllocations, double? totalBudget}) async => null;
  Future<BudgetSettingsResponse> getBudgetSettings() async => const BudgetSettingsResponse();
  Future<dynamic> getLatestBudget() async => null;
  Future<dynamic> getBudgetDiagnosis({String? month, bool forceRefresh = false}) async => null;
}

class MockSession {
  String get sessionId => 'mock_session';
}
