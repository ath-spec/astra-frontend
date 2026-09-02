// lib/services/finance_repository.dart
//
// Budget data layer. Talks to astra-backend at /api/v1/analytics/budgets —
// the same resource paths and JSON shapes as the reference budget API, so
// the ported models parse unchanged. Signatures are kept identical to the
// previous stub so existing callers compile untouched.
//
// The wizard screens still read `budgetStateProvider` from
// features/budget/data/budget_mock_providers.dart (a pure mock). Point that
// provider — or the real BudgetState in features/budget/data/state — at this
// repository to take the flow live end to end.

import 'package:dio/dio.dart';

import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/budget/data/models/budget_models.dart' as m;
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';

class _R {
  static const base = '/api/v1/analytics/budgets';
  static const diagnosis = '$base/diagnosis';
  static const suggest = '$base/suggest/categories';
  static const sessions = '$base/sessions';
  static String session(String id) => '$base/sessions/$id';
  static String finalize(String id) => '$base/sessions/$id/finalize';
  static const latest = '$base/latest';
  static const latestCategories = '$base/latest/categories';
  static const status = '$base/status';
  static const insights = '$base/insights';
  static const settings = '$base/settings';
  static const active = '$base/active';
}

class FinanceRepository {
  final Dio _dio;
  FinanceRepository([dynamic client])
      : _dio = (client is DioApiClient ? client : dioApiClient).dio;

  String _month([String? month]) {
    if (month != null && month.isNotEmpty) return month;
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _obj(dynamic body) {
    if (body is Map<String, dynamic>) {
      final d = body['data'];
      return d is Map<String, dynamic> ? d : body;
    }
    return <String, dynamic>{};
  }

  // ── Diagnosis ──────────────────────────────────────────────────────
  /// Returns the raw diagnosis JSON (POST /budgets/diagnosis body); callers
  /// parse into their own model.
  Future<Map<String, dynamic>> getBudgetDiagnosis({String? month, bool forceRefresh = false}) async {
    final res = await _dio.post(_R.diagnosis, data: {
      'month': _month(month),
      'force_refresh': forceRefresh,
    });
    return _obj(res.data);
  }

  // ── Suggest categories ────────────────────────────────────────────
  Future<List<m.CategorySuggestion>> getCategorySuggestions({
    double? limit,
    double? totalBudget,
    String? month,
    Map<String, double>? userCategoryOverrides,
  }) async {
    try {
      final res = await _dio.post(_R.suggest, data: {
        'total_budget': totalBudget ?? limit ?? 0,
        'month': _month(month),
        if (userCategoryOverrides != null) 'user_category_overrides': userCategoryOverrides,
      });
      final data = _obj(res.data);
      final list = (data['suggestions'] as List?) ?? const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(m.CategorySuggestion.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final body = e.response?.data;
        final cd = (body is Map)
            ? (body['data']?['conflict_details'] ?? body['conflict_details'])
            : null;
        if (cd is Map) {
          throw BudgetConflictException(
            cd,
            type: cd['type']?.toString() ?? 'scalable_floor_exceeded',
            amount: (cd['overage_amount'] as num?)?.toDouble() ?? 0.0,
            conflicts: (cd['conflicts'] as List?) ?? const [],
          );
        }
      }
      rethrow;
    }
  }

  // ── Setup sessions ────────────────────────────────────────────────
  Future<dynamic> createBudgetSession({String? month, double? totalBudget}) async {
    final res = await _dio.post(_R.sessions, data: {'month': _month(month)});
    return m.BudgetSession.fromJson(_obj(res.data));
  }

  Future<void> updateBudgetSession({
    String? sessionId,
    double? totalBudget,
    dynamic categoryAllocations,
  }) async {
    if (sessionId == null || sessionId.isEmpty) return;
    await _dio.patch(_R.session(sessionId), data: {
      if (totalBudget != null) 'total_budget': totalBudget,
      if (categoryAllocations != null)
        'category_allocations': _allocList(categoryAllocations),
    });
  }

  Future<dynamic> finalizeBudgetSession({
    String? sessionId,
    dynamic categoryAllocations,
    double? totalBudget,
  }) async {
    if (sessionId == null || sessionId.isEmpty) return null;
    if (categoryAllocations != null || totalBudget != null) {
      await updateBudgetSession(
        sessionId: sessionId,
        totalBudget: totalBudget,
        categoryAllocations: categoryAllocations,
      );
    }
    final res = await _dio.post(
      _R.finalize(sessionId),
      data: const <String, dynamic>{},
      options: Options(headers: {'Idempotency-Key': 'finalize_$sessionId'}),
    );
    return res.data;
  }

  List<Map<String, dynamic>> _allocList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map<Map<String, dynamic>>((e) {
      if (e is Map<String, dynamic>) return e;
      try {
        return (e as dynamic).toJson() as Map<String, dynamic>;
      } catch (_) {
        return {
          'category_id': (e as dynamic).categoryId?.toString() ?? '',
          'amount': ((e as dynamic).amount as num?)?.toDouble() ?? 0.0,
          'is_tracking': ((e as dynamic).isTracking as bool?) ?? true,
          'is_hidden': ((e as dynamic).isHidden as bool?) ?? false,
        };
      }
    }).toList();
  }

  // ── Active dashboard ─────────────────────────────────────────────
  /// Returns the raw latest-budget JSON; callers parse into their own model.
  Future<Map<String, dynamic>> getLatestBudget() async {
    final res = await _dio.get(_R.latest);
    return _obj(res.data);
  }

  Future<void> patchCategoryBudget(String categoryId, double amount) async {
    await _dio.patch(_R.latestCategories, data: {'category_id': categoryId, 'amount': amount});
  }

  Future<BudgetStatusResponse> getBudgetStatus() async {
    try {
      final res = await _dio.get(_R.status);
      return BudgetStatusResponse.fromJson(_obj(res.data));
    } catch (_) {
      return const BudgetStatusResponse(hasActiveBudget: false);
    }
  }

  Future<BudgetInsightsResponse> getBudgetInsights() async {
    try {
      final res = await _dio.get(_R.insights);
      return BudgetInsightsResponse.fromJson(_obj(res.data));
    } catch (_) {
      return BudgetInsightsResponse(insights: const [], generatedAt: DateTime.now());
    }
  }

  Future<void> resetActiveBudget() async {
    await _dio.delete(_R.active);
  }

  // ── Settings ─────────────────────────────────────────────────────
  Future<BudgetSettingsResponse> getBudgetSettings() async {
    final res = await _dio.get(_R.settings);
    final body = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{};
    return BudgetSettingsResponse.fromJson(body);
  }

  Future<void> updateBudgetSettings({double? spendingLimit, double? linkedIncome}) async {
    await _dio.patch(_R.settings, data: {
      if (spendingLimit != null) 'spending_limit': spendingLimit,
      if (linkedIncome != null) 'linked_income': linkedIncome,
    });
  }

  // ── Smart Rebalance (reallocation) ───────────────────────────────
  static const _reallocRun = '${_R.base}/reallocation/run';
  static const _reallocApply = '${_R.base}/reallocation/apply';

  Future<ReallocationRunResponse> runReallocation({
    required String targetCategory,
    double minRemainingRatio = 0.6,
  }) async {
    final res = await _dio.post(_reallocRun, data: {
      'target_category': targetCategory,
      'min_remaining_ratio': minRemainingRatio,
    });
    final body = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{};
    return ReallocationRunResponse.fromJson(body);
  }

  Future<void> applyReallocation({
    required String sessionId,
    String? month,
    required List<ReallocationProposal> proposals,
  }) async {
    await _dio.post(_reallocApply, data: {
      'session_id': sessionId,
      if (month != null) 'month': month,
      'reallocations': proposals.map((p) => p.toJson()).toList(),
    });
  }

  // ── ML feedback loop ────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listBudgetSuggestions() async {
    try {
      final res = await _dio.get('${_R.base}/ml/suggestions');
      final list = (res.data is Map ? res.data['suggestions'] : null) as List?;
      return (list ?? const []).whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> respondToSuggestion(String id, String action, {String? reason}) async {
    await _dio.post('${_R.base}/ml/suggestions/$id/respond', data: {
      'action': action,
      if (reason != null) 'reason': reason,
    });
  }

  Future<List<Map<String, dynamic>>> listBudgetCooldowns() async {
    try {
      final res = await _dio.get('${_R.base}/ml/cooldowns');
      final list = (res.data is Map ? res.data['cooldowns'] : null) as List?;
      return (list ?? const []).whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return const [];
    }
  }

  // ── Month rollover ─────────────────────────────────────────────
  Future<String?> triggerRollover() async {
    try {
      final res = await _dio.post('${_R.base}/admin/trigger-rollover');
      final body = res.data;
      if (body is Map) return body['pending_rollover_draft_id'] as String?;
      return null;
    } catch (_) {
      return null;
    }
  }

  // Retained for source compatibility; not used by the current flow.
  Future<dynamic> initialAverages(String month) async => null;
}

class MockSession {
  String get sessionId => 'mock_session';
}
