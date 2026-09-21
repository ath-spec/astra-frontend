import 'package:dio/dio.dart';
import 'package:astra_frontend/core/network/dio_client.dart';
import 'package:astra_frontend/core/network/api_exception.dart';

/// Thin wrapper owning the app-wide configured [Dio] instance.
///
/// Backed by [DioClient], which already installs the auth-token and
/// token-refresh interceptors. Existing call sites keep using the global
/// `dioApiClient` singleton; new code should read `dioApiClient.dio` to
/// issue requests, or use [unwrap]/[unwrapList] to decode the standard
/// `/api/v1` response envelope `{"error": bool, "message": string, "data": ...}`.
class DioApiClient {
  DioApiClient({String? baseUrl}) : _explicitBaseUrl = baseUrl;

  final String? _explicitBaseUrl;
  DioClient? _client;

  // Set at build/run time via `--dart-define=API_BASE_URL=...`. No fallback
  // is hardcoded here — an unset value fails fast instead of silently
  // pointing at a URL baked into source.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  DioClient get _effectiveClient {
    if (_client == null) {
      final url = _explicitBaseUrl ?? _envBaseUrl;
      if (url.isEmpty) {
        throw StateError(
          'API_BASE_URL is not set. Pass it via '
          '--dart-define=API_BASE_URL=<url> when running or building.',
        );
      }
      _client = DioClient(baseUrl: url);
    }
    return _client!;
  }

  Dio get dio => _effectiveClient.dio;

  /// Unwraps a single-object `/api/v1` envelope response, returning the
  /// decoded `data` payload via [fromJson]. Throws [ApiException] if the
  /// envelope reports an error, if `data` is missing, or if the request
  /// itself failed at the network layer.
  T unwrap<T>(
    Map<String, dynamic> envelope,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final bool isError = envelope['error'] == true;
    if (isError) {
      throw ApiException(
        envelope['message']?.toString() ?? 'Something went wrong',
      );
    }
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Malformed response from server');
    }
    return fromJson(data);
  }

  /// Same as [unwrap] but for endpoints whose `data` is a JSON array.
  List<T> unwrapList<T>(
    Map<String, dynamic> envelope,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final bool isError = envelope['error'] == true;
    if (isError) {
      throw ApiException(
        envelope['message']?.toString() ?? 'Something went wrong',
      );
    }
    final data = envelope['data'];
    if (data == null) return <T>[];
    if (data is! List) {
      throw const ApiException('Malformed response from server');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  /// Converts a thrown [DioException] (or anything else) into an
  /// [ApiException] carrying the best available human-readable message.
  ApiException toApiException(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        // /api/v1 envelope shape: {"error": bool, "message": "..."}
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) {
          return ApiException(msg, statusCode: error.response?.statusCode);
        }
        // /api/auth shape: {"error": "<message>", "code": ...}
        final err = data['error'];
        if (err is String && err.isNotEmpty) {
          return ApiException(err, statusCode: error.response?.statusCode);
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        return const ApiException('Could not reach the server. Please check your connection.');
      }
      return ApiException(
        error.message ?? 'Network request failed',
        statusCode: error.response?.statusCode,
      );
    }
    return ApiException(error.toString());
  }
}

final dioApiClient = DioApiClient();
