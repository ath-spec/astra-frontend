import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/portfolio_analysis/data/portfolio_analysis_models.dart';

class PortfolioAnalysisRepository {
  final DioApiClient _client;

  const PortfolioAnalysisRepository(this._client);

  Future<AllocationData> getAllocation() async {
    try {
      final response = await _client.dio.get('/api/v1/portfolio-analysis/allocation');
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        AllocationData.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<DisciplineData> getDiscipline() async {
    try {
      final response = await _client.dio.get('/api/v1/portfolio-analysis/discipline');
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        DisciplineData.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<PerformanceData> getPerformance() async {
    try {
      final response = await _client.dio.get('/api/v1/portfolio-analysis/performance');
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        PerformanceData.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
