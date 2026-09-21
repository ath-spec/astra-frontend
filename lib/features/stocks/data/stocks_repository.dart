import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/stocks/data/stocks_models.dart';

class StocksRepository {
  final DioApiClient _client;

  const StocksRepository(this._client);

  Future<List<StockHoldingItem>> getHoldings() async {
    try {
      final response = await _client.dio.get('/api/v1/stocks/holdings');
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        StockHoldingItem.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Lists stock orders, optionally narrowed to one [statusFilter]
  /// (`OPEN`, `COMPLETE`, `CANCELLED`, `REJECTED`). Omit to fetch all.
  Future<List<StockOrderRecord>> listOrders({String? statusFilter}) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/stocks/orders',
        queryParameters: statusFilter != null && statusFilter.isNotEmpty
            ? {'status_filter': statusFilter}
            : null,
      );
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        StockOrderRecord.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Back-compat alias for [listOrders] with no filter.
  Future<List<StockOrderRecord>> getOrders() => listOrders();

  Future<StockProfileDetail> getProfile(String tradingSymbol) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/stocks/profile',
        queryParameters: {'trading_symbol': tradingSymbol},
      );
      return _client.unwrap(
        response.data as Map<String, dynamic>,
        StockProfileDetail.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
