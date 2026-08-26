import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/fd/data/fd_models.dart';

class FDRepository {
  final DioApiClient _client;

  const FDRepository(this._client);

  Future<List<FDAccountItem>> listFDs() async {
    try {
      final response = await _client.dio.get('/api/v1/fd');
      return _client.unwrapList(
        response.data as Map<String, dynamic>,
        FDAccountItem.fromJson,
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
