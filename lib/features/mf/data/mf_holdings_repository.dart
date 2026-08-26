import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/mf/data/mf_holdings_models.dart';

/// Wraps the `/api/v1/mf/holdings` endpoint.
class MfHoldingsRepository {
  const MfHoldingsRepository(this._client);

  final DioApiClient _client;

  Future<MfHoldingsResponse> holdings() async {
    try {
      final response = await _client.dio.get('/api/v1/mf/holdings');
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        MfHoldingsResponse.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
