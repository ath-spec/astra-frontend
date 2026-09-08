import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:astra_frontend/core/network/api.dart';
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

  factory BudgetSetupSession.fromJson(Map<String, dynamic> json) {
    final allocs = (json['category_allocations'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((e) => CategoryAllocation(
              categoryId: e['category_id']?.toString() ?? '',
              categoryName: e['category_name']?.toString(),
              categoryColor: e['category_color']?.toString(),
              amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
              isTracking: e['is_tracking'] as bool?,
              isHidden: (e['is_hidden'] as bool?) ?? false,
            ))
        .toList();
    return BudgetSetupSession(
      id: json['session_id']?.toString() ?? json['id']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
      categoryAllocations: allocs,
      data: json,
    );
  }
}

/// Session lifecycle calls for the budget setup wizard, backed by
/// astra-backend /api/v1/analytics/budgets/sessions/*.
class AnalyticsRepository {
  final DioApiClient _client;
  const AnalyticsRepository(this._client);

  static const _base = '/api/v1/analytics/budgets/sessions';

  Future<BudgetSetupSession?> getBudgetSetupSession(String sessionId) async {
    try {
      final res = await _client.dio.get('$_base/$sessionId');
      final body = res.data;
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'] as Map)
          : Map<String, dynamic>.from(body as Map);
      return BudgetSetupSession.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> finalizeBudgetSetupSession(String sessionId) async {
    try {
      await _client.dio.post(
        '$_base/$sessionId/finalize',
        data: const <String, dynamic>{},
        options: Options(headers: {'Idempotency-Key': 'finalize_$sessionId'}),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectBudgetSetupSession(String sessionId) async {
    try {
      await _client.dio.delete('$_base/$sessionId');
      return true;
    } catch (_) {
      return false;
    }
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(dioApiClient);
});
