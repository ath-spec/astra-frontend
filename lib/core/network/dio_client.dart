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

  /// Fired when a refresh token genuinely fails (expired past its 30-day
  /// TTL, or revoked) — as opposed to a transient network error. The app
  /// wires this at startup to force the auth state to logged-out, so a
  /// session that's actually over shows the login screen immediately
  /// instead of leaving the user stranded on screens whose API calls now
  /// silently 401 until they happen to restart the app.
  void Function()? onSessionExpired;

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

  // Concurrent requests that all expire at once (e.g. home screen firing
  // several calls together) must not each fire their own refresh: the
  // backend rotates the refresh token on every use, so a second caller
  // racing with the same old token gets rejected and — before this guard —
  // would wipe out the valid tokens the first caller had just written.
  // Every concurrent 401 now shares this single in-flight refresh instead.
  Future<bool>? _refreshFuture;

  Future<bool> _attemptTokenRefresh() {
    return _refreshFuture ??= _doRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<bool> _doRefresh() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) return false;

      // Make a direct request without interceptors to avoid loops. Explicit
      // timeouts matter here specifically — this Dio instance is bare (no
      // BaseOptions inherited from the main client), so without these it
      // would hang indefinitely on a stalled connection instead of failing
      // fast into the transient-error branch below.
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ));
      final response = await refreshDio.post(
        '/api/auth/refresh',
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
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to refresh token: $e');
      }
      // A definitive rejection from the server (401/400 — the refresh token
      // really is invalid, expired, or already consumed) means the session
      // is genuinely over: clear it and force the login redirect. Anything
      // else — no response at all (timeout, dropped wifi, DNS hiccup,
      // connection reset) — is transient and tells us nothing about whether
      // the refresh token is still valid. Wiping a real, valid refresh token
      // just because the phone briefly lost signal would log the user out
      // for no reason; better to leave it alone and let the next request
      // retry once connectivity is back.
      if (e.response != null) {
        await _secureStorage.delete(key: 'auth_token');
        await _secureStorage.delete(key: 'refresh_token');
        onSessionExpired?.call();
      }
    } catch (e) {
      // Anything not a DioException (e.g. a secure-storage read/write
      // failure) is also not evidence the refresh token itself is invalid —
      // same reasoning as above, leave the stored tokens alone.
      if (kDebugMode) {
        debugPrint('Failed to refresh token: $e');
      }
    }
    return false;
  }
}
