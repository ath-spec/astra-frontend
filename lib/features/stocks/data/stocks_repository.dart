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

  Future<List<StockOrderRecord>> getOrders() async {
    try {
      final response = await _client.dio.get('/api/v1/stocks/orders');
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        StockOrderRecord.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
