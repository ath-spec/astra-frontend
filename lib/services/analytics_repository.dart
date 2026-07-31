import 'package:astra_frontend/core/network/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/budget/data/budget_mock_providers.dart';

class BudgetSetupSession {
  final String id;
  final String month;
  final double totalBudget;
  final List<CategoryAllocation> categoryAllocations;
  final Map<String, dynamic> data;

  BudgetSetupSession({
    this.id = 'mock_session',
    this.month = '2026-03',
    this.totalBudget = 0.0,
    this.categoryAllocations = const [],
    this.data = const {},
  });

  factory BudgetSetupSession.fromJson(Map<String, dynamic> json) => BudgetSetupSession(data: json);
}

class AnalyticsRepository {
  final DioApiClient _client;

  const AnalyticsRepository(this._client);

  Future<BudgetSetupSession?> getBudgetSetupSession(String sessionId) async {
    return BudgetSetupSession();
  }

  Future<bool> finalizeBudgetSetupSession(String sessionId) async {
    return true;
  }

  Future<bool> rejectBudgetSetupSession(String sessionId) async {
    return true;
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(dioApiClient);
});
