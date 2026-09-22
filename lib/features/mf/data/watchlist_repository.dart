import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/mf/data/watchlist_models.dart';

/// Wraps the `/api/v1/watchlist` endpoints.
class WatchlistRepository {
  const WatchlistRepository(this._client);

  final DioApiClient _client;

  Future<List<WatchlistItem>> list() async {
    try {
      final response = await _client.dio.get('/api/v1/watchlist');
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        WatchlistItem.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Adds [schemeCode] to the watchlist. Idempotent. Returns the resulting
  /// watched state (expected `true`).
  Future<bool> add(String schemeCode) async {
    try {
      final response = await _client.dio.put('/api/v1/watchlist/$schemeCode');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      if (data is Map<String, dynamic>) {
        return data['watched'] == true;
      }
      return true;
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Removes [schemeCode] from the watchlist. Idempotent. Returns the
  /// resulting watched state (expected `false`).
  Future<bool> remove(String schemeCode) async {
    try {
      final response =
          await _client.dio.delete('/api/v1/watchlist/$schemeCode');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      if (data is Map<String, dynamic>) {
        return data['watched'] == true;
      }
      return false;
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
