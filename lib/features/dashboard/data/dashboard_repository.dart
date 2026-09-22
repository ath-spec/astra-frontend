import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/dashboard/data/dashboard_models.dart';

/// Wraps the `/api/v1/dashboard/*` endpoints.
class DashboardRepository {
  const DashboardRepository(this._client);

  final DioApiClient _client;

  Future<DashboardSummary> summary() async {
    try {
      final response = await _client.dio.get('/api/v1/dashboard/summary');
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        DashboardSummary.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Historical total-wealth series backing the Home screen's growth chart.
  /// Only has real history from whenever the user's dashboard was first
  /// read onward — there's no backfilled past data, so this can come back
  /// with 0 or 1 points for a brand-new user.
  Future<List<DashboardGrowthPoint>> growth({required int days}) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/dashboard/growth',
        queryParameters: {'days': days},
      );
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        DashboardGrowthPoint.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
