import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/mf/data/mf_holdings_models.dart';
import 'package:astra_frontend/features/mf/data/mf_transactions_models.dart';

/// Wraps the `/api/v1/mf/holdings` and `/api/v1/mf/transactions` endpoints.
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

  /// Lists MF transactions, optionally narrowed to one [schemeCode].
  /// Omit to fetch transactions across all schemes.
  Future<List<MfTransaction>> getTransactions({String? schemeCode}) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/mf/transactions',
        queryParameters: schemeCode != null && schemeCode.isNotEmpty
            ? {'scheme_code': schemeCode}
            : null,
      );
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        MfTransaction.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
