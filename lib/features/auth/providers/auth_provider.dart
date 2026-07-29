import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  String pendingPhone = '000000000';
  String pendingName = 'Investor';

  void setPendingPhone(String phone) {
    pendingPhone = phone;
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

  void logout() {
    state = const AuthInitial();
  }
}

/// Global provider for AuthNotifier and AuthState.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
