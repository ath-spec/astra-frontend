import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/goals/data/goals_models.dart';

class GoalsRepository {
  final DioApiClient _client;

  const GoalsRepository(this._client);

  Future<List<GoalItem>> listGoals() async {
    try {
      final response = await _client.dio.get('/api/v1/goals');
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        GoalItem.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<GoalsSummary> getSummary() async {
    try {
      final response = await _client.dio.get('/api/v1/goals/summary');
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        GoalsSummary.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<GoalItem> createGoal({
    required String name,
    required double targetAmount,
    required double currentAmount,
    required String deadline,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/v1/goals',
        data: {
          'name': name,
          'target_amount': targetAmount,
          'current_amount': currentAmount,
          'deadline': deadline,
        },
      );
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        GoalItem.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
