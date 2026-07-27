import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Production-ready Dio HTTP client configured with authentication interceptors,
/// timeouts, and token refresh retry logic following dart-flutter-patterns.
class DioClient {
  DioClient({
    required String baseUrl,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _setupInterceptors();
  }

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach Authorization Bearer token if stored
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('🌐 [HTTP REQUEST] => ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('✅ [HTTP RESPONSE] <= ${response.statusCode} ${response.requestOptions.uri}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            debugPrint('❌ [HTTP ERROR] <= ${error.response?.statusCode} ${error.requestOptions.uri}: ${error.message}');
          }

          // Guard against infinite retry loops: only attempt refresh once per request
          final isRetry = error.requestOptions.extra['_isRetry'] == true;
          if (!isRetry && error.response?.statusCode == 401) {
            final refreshed = await _attemptTokenRefresh();
            if (refreshed) {
              error.requestOptions.extra['_isRetry'] = true;
              try {
                // Retry the original request with new token
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Attempts to refresh the authentication token using stored refresh_token.
  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) return false;

      // Make a direct request without interceptors to avoid loops
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;
        if (newToken != null) {
          await _secureStorage.write(key: 'auth_token', value: newToken);
          if (newRefreshToken != null) {
            await _secureStorage.write(key: 'refresh_token', value: newRefreshToken);
          }
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to refresh token: $e');
      }
      // On refresh failure, clear tokens so user is forced to re-login
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'refresh_token');
    }
    return false;
  }
}
