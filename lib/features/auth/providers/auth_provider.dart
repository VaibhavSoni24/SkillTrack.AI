import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';
import 'auth_state.dart';

/// Auth state notifier managing the full authentication lifecycle.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthInitial());

  /// Check stored session on app startup.
  Future<void> checkSession() async {
    state = const AuthLoading();
    try {
      final hasSession = await _repository.hasValidSession();
      if (hasSession) {
        final user = await _repository.getCurrentUser();
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } on ApiException {
      state = const AuthUnauthenticated();
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  /// Email + password login.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final auth = await _repository.login(
        email: email,
        password: password,
      );
      await _repository.saveTokens(auth);
      state = AuthAuthenticated(auth.user);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Create new account.
  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final auth = await _repository.signup(
        username: username,
        email: email,
        password: password,
      );
      await _repository.saveTokens(auth);
      state = AuthAuthenticated(auth.user);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Handle OAuth callback.
  Future<void> oauthLogin({
    required String provider,
    required String code,
  }) async {
    state = const AuthLoading();
    try {
      final auth = await _repository.oauthLogin(
        provider: provider,
        code: code,
      );
      await _repository.saveTokens(auth);
      state = AuthAuthenticated(auth.user);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Sign out and clear tokens.
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  /// Update user in state.
  void updateUser(UserModel user) {
    state = AuthAuthenticated(user);
  }
}

// ── Providers ──

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Convenience provider for current user.
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});
