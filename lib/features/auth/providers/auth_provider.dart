import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/core/network/api_exception.dart';
import '../models/user_model.dart';

/// Sealed class hierarchy for authentication state.
/// Ensures exhaustive pattern matching across UI components.
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Transient state held from app launch until [AuthNotifier.restoreSession]
/// resolves. The router's `redirect` treats this the same as an onboarding
/// route (never force-navigates away) so a slow/in-flight session restore
/// can never be mistaken for "definitely logged out" and bounce the user to
/// `/intro` before the stored token has had a chance to be checked.
final class AuthChecking extends AuthState {
  const AuthChecking();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

/// StateNotifier managing user authentication lifecycle.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthChecking());

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    
    // Simulate network authentication delay
    await Future.delayed(const Duration(milliseconds: 900));
    
    if (password == 'wrong' || password == 'error') {
      state = const AuthError('Invalid credentials. Try any valid password.');
    } else {
      final displayName = email.contains('@') 
          ? email.split('@').first.replaceAll('.', ' ').toUpperCase()
          : email;
      state = AuthAuthenticated(
        User(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: displayName,
          email: email,
          isAdmin: email.toLowerCase().contains('admin'),
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=faces',
        ),
      );
    }
  }

  String pendingPhone = '';
  String pendingName = 'Investor';
  String pendingPan = '';

  /// Advisory opt-in from the login form. Sent as `wants_rm` on OTP verify;
  /// the backend assigns a Relationship Manager only when this is true.
  bool pendingWantsRm = false;

  void setPendingPhone(String phone) {
    pendingPhone = phone;
  }

  void setPendingWantsRm(bool value) {
    pendingWantsRm = value;
  }

  void setPendingPan(String pan) {
    pendingPan = pan;
    // Cache locally the same way updateName() caches the display name —
    // the backend only persists a PAN once POST /api/v1/kyc/pan/verify
    // actually runs, so this covers the gap between "user typed it on the
    // onboarding screen" and "server has it on file" (or if that
    // verification step never completes / isn't configured for this build).
    unawaited(_secureStorage.write(key: 'cached_pan', value: pan).catchError((_) {}));
  }

  void setPendingName(String name) {
    pendingName = name;
  }

  void skipLogin() {
    state = const AuthAuthenticated(
      User(
        id: 'usr_hardcoded_skip',
        name: 'Guest Investor',
        email: 'guest@example.com',
        isAdmin: false,
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=faces',
      ),
    );
  }

  Future<void> loginWithPhone(String phone) async {
    state = const AuthLoading();
    await Future.delayed(const Duration(milliseconds: 600));
    state = AuthAuthenticated(
      User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: pendingName,
        email: '$phone@astra.dev',
        isAdmin: false,
        avatarUrl: null,
      ),
    );
  }

  Future<void> verifyPan(String pan, {String? phone}) async {
    state = const AuthLoading();
    await Future.delayed(const Duration(milliseconds: 600));
    final displayPhone = phone ?? pendingPhone;
    state = AuthAuthenticated(
      User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: pendingName,
        email: '$displayPhone@astra.dev',
        isAdmin: false,
        avatarUrl: null,
      ),
    );
  }

  Future<void> verifyAccountAggregator({String? phone}) async {
    state = const AuthLoading();
    await Future.delayed(const Duration(milliseconds: 600));
    final displayPhone = phone ?? pendingPhone;
    state = AuthAuthenticated(
      User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: pendingName,
        email: '$displayPhone@astra.dev',
        isAdmin: false,
        avatarUrl: null,
      ),
    );
  }

  /// Logs the user out. Best-effort revokes the refresh token server-side
  /// (never blocks logout on that call failing), then clears both stored
  /// tokens and resets state.
  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await dioApiClient.dio.post(
          '/api/auth/logout',
          data: {'refresh_token': refreshToken},
        );
      }
    } catch (_) {
      // Best-effort — proceed to clear local session regardless.
    }
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'cached_display_name');
    await _secureStorage.delete(key: 'cached_pan');
    state = const AuthInitial();
  }

  /// Reacts to the refresh token genuinely failing (expired past its 30-day
  /// TTL, or revoked) mid-session — see [DioClient.onSessionExpired]. Unlike
  /// [logout], the tokens are already gone by the time this fires (DioClient
  /// cleared them before calling this), so there's nothing left to revoke
  /// server-side; this just makes the app's own state catch up so the
  /// router's auth redirect sends the user to login immediately instead of
  /// leaving them on a screen whose API calls now silently keep failing.
  void forceSignOut() {
    if (state is AuthAuthenticated) {
      state = const AuthInitial();
    }
  }

  static const _secureStorage = FlutterSecureStorage();

  /// Sends a (mock) OTP to [phone] via the backend. Does not authenticate —
  /// callers should check state is not [AuthError] before proceeding to the
  /// OTP-entry screen.
  Future<void> sendOtp(String phone) async {
    state = const AuthLoading();
    try {
      await dioApiClient.dio.post(
        '/api/auth/otp/send',
        data: {'phone_number': phone},
      );
      pendingPhone = phone;
      state = const AuthInitial();
    } catch (e) {
      state = AuthError(dioApiClient.toApiException(e).message);
    }
  }

  /// Verifies [otp] for [phone], saves the returned auth token, and
  /// authenticates the user on success. Returns whether this is a new user
  /// (per the backend's `is_new_user` flag) so the caller can decide whether
  /// to continue into onboarding or go straight to home; returns `null` if
  /// verification failed (check `state` for the [AuthError] in that case).
  Future<bool?> verifyOtp(String phone, String otp) async {
    state = const AuthLoading();
    try {
      final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
      final response = await dioApiClient.dio.post(
        '/api/auth/otp/verify',
        data: {
          'astra_user_id': 'astra_$phoneDigits',
          'phone_number': phoneDigits,
          'otp': otp,
          'name': pendingName,
          'wants_rm': pendingWantsRm,
          'banks': <String>[],
        },
      );

      final data = response.data;
      final token = data is Map<String, dynamic> ? data['token'] as String? : null;
      if (token == null || token.isEmpty) {
        throw const ApiException('Login failed. Please try again.');
      }
      final isNewUser = data is Map<String, dynamic> ? data['is_new_user'] as bool? ?? true : true;
      final refreshToken = data is Map<String, dynamic> ? data['refresh_token'] as String? : null;
      await _secureStorage.write(key: 'auth_token', value: token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      }

      state = AuthAuthenticated(
        User(
          id: 'astra_$phoneDigits',
          name: pendingName,
          email: '$phoneDigits@astra.dev',
          isAdmin: false,
          avatarUrl: null,
        ),
      );
      return isNewUser;
    } catch (e) {
      state = AuthError(dioApiClient.toApiException(e).message);
      return null;
    }
  }

  /// Persists the display name collected on the onboarding name step.
  /// The account row is created on OTP verify (before the name is known),
  /// so this PATCH is what actually gets the real name onto the profile —
  /// and into the RM dashboard.
  ///
  /// Written to secure storage FIRST, unconditionally — not just held in the
  /// in-memory [pendingName] field. [pendingName] resets to its 'Investor'
  /// class default on every cold start (a fresh AuthNotifier is constructed),
  /// so if the PATCH below silently failed (a network blip mid-onboarding)
  /// there was previously nothing else backing the name up: the next
  /// [restoreSession] would see an empty `name` from the server, fall back to
  /// the freshly-reset 'Investor' default, and the user's real name would
  /// appear to vanish after the app was killed and reopened. The local cache
  /// makes that recoverable, and restoreSession below retries the PATCH so
  /// the backend eventually catches up too.
  Future<void> updateName(String name) async {
    final trimmed = name.trim();
    pendingName = trimmed;
    try {
      await _secureStorage.write(key: 'cached_display_name', value: trimmed);
    } catch (_) {
      // Best-effort cache write — the in-memory pendingName still covers the
      // rest of this session even if this fails.
    }
    final current = state;
    if (current is AuthAuthenticated) {
      state = AuthAuthenticated(
        User(
          id: current.user.id,
          name: trimmed,
          email: current.user.email,
          isAdmin: current.user.isAdmin,
          avatarUrl: current.user.avatarUrl,
        ),
      );
    }
    try {
      await dioApiClient.dio.patch(
        '/api/auth/me',
        data: {'name': trimmed},
      );
    } catch (_) {
      // Non-fatal — onboarding continues. The locally cached name above
      // covers this device regardless; restoreSession retries the sync.
    }
  }

  /// App-launch session restore: if a token is stored, validates it against
  /// `GET /api/auth/me` and authenticates on success. Clears the stored
  /// token and leaves state as [AuthInitial] on failure (invalid/expired
  /// token, or no network). Returns `true` if the session was restored.
  Future<bool> restoreSession() async {
    String? token;
    try {
      token = await _secureStorage.read(key: 'auth_token');
    } catch (_) {
      // Secure storage can throw (e.g. an invalidated Android keystore key)
      // — treat that the same as "no stored session" rather than leaving
      // state stuck on AuthChecking and letting the exception propagate
      // unhandled out of the fire-and-forget call in SplashScreen.
      token = null;
    }
    if (token == null || token.isEmpty) {
      state = const AuthInitial();
      return false;
    }

    try {
      final response = await dioApiClient.dio.get('/api/auth/me');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException('Session is no longer valid');
      }
      final name = data['name']?.toString();
      final phone = data['phone_number']?.toString() ?? '';
      final userId = data['astra_user_id']?.toString() ?? data['user_id']?.toString() ?? '';
      pendingPhone = phone;

      final pan = data['pan']?.toString();
      if (pan != null && pan.isNotEmpty) {
        pendingPan = pan;
        try {
          await _secureStorage.write(key: 'cached_pan', value: pan);
        } catch (_) {}
      } else {
        // No verified PAN on file server-side — fall back to whatever this
        // device has cached locally (e.g. entered during onboarding before
        // PAN verification was ever wired to persist anywhere server-side).
        String? cachedPan;
        try {
          cachedPan = await _secureStorage.read(key: 'cached_pan');
        } catch (_) {
          cachedPan = null;
        }
        if (cachedPan != null && cachedPan.isNotEmpty) {
          pendingPan = cachedPan;
        }
      }

      if (name != null && name.isNotEmpty) {
        pendingName = name;
      } else {
        // The server has no name on file — likely a prior updateName() PATCH
        // that silently failed. Fall back to this device's locally cached
        // name (survives app restarts, unlike the in-memory default) and
        // retry syncing it to the backend now that we have connectivity.
        String? cached;
        try {
          cached = await _secureStorage.read(key: 'cached_display_name');
        } catch (_) {
          cached = null;
        }
        if (cached != null && cached.isNotEmpty) {
          pendingName = cached;
          unawaited(
            dioApiClient.dio
                .patch('/api/auth/me', data: {'name': cached})
                .catchError((_) {}),
          );
        }
      }
      pendingWantsRm = data['wants_rm'] == true;

      state = AuthAuthenticated(
        User(
          id: userId,
          name: pendingName,
          email: '$phone@astra.dev',
          isAdmin: false,
          avatarUrl: null,
        ),
      );
      return true;
    } catch (_) {
      await _secureStorage.delete(key: 'auth_token');
      state = const AuthInitial();
      return false;
    }
  }
}

/// Global provider for AuthNotifier and AuthState.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
