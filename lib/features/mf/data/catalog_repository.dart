import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/mf/data/catalog_models.dart';

class CatalogRepository {
  final DioApiClient _client;

  const CatalogRepository(this._client);

  Future<List<CatalogFund>> searchFunds({
    String? category,
    String? riskLevel,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (riskLevel != null && riskLevel.isNotEmpty) {
        queryParams['risk_level'] = riskLevel;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _client.dio.get(
        '/api/v1/catalog/funds',
        queryParameters: queryParams,
      );
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        CatalogFund.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<FundProfileDetail> getFundProfile(String schemeCode) async {
    try {
      final response = await _client.dio.get('/api/v1/catalog/funds//profile');
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        FundProfileDetail.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  Future<List<NfoItem>> listNfos() async {
    try {
      final response = await _client.dio.get('/api/v1/catalog/nfos');
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        NfoItem.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
