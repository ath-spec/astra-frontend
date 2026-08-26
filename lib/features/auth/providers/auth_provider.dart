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
  AuthNotifier() : super(const AuthInitial());

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

  void setPendingPhone(String phone) {
    pendingPhone = phone;
  }

  void setPendingPan(String pan) {
    pendingPan = pan;
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
    state = const AuthInitial();
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

  /// App-launch session restore: if a token is stored, validates it against
  /// `GET /api/auth/me` and authenticates on success. Clears the stored
  /// token and leaves state as [AuthInitial] on failure (invalid/expired
  /// token, or no network). Returns `true` if the session was restored.
  Future<bool> restoreSession() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null || token.isEmpty) return false;

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
      if (name != null && name.isNotEmpty) pendingName = name;

      state = AuthAuthenticated(
        User(
          id: userId,
          name: name != null && name.isNotEmpty ? name : pendingName,
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
