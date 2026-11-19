import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State representation for authentication and auth forms.
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.userName,
    this.userEmail,
    this.rememberMe = true,
    this.resetLinkSent = false,
    this.resetEmail,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final String? userName;
  final String? userEmail;
  final bool rememberMe;
  final bool resetLinkSent;
  final String? resetEmail;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    String? userName,
    String? userEmail,
    bool? rememberMe,
    bool? resetLinkSent,
    String? resetEmail,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      rememberMe: rememberMe ?? this.rememberMe,
      resetLinkSent: resetLinkSent ?? this.resetLinkSent,
      resetEmail: resetEmail ?? this.resetEmail,
    );
  }
}

/// Controller managing simulated authentication state (Demo Mode).
class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  void clearResetStatus() {
    state = state.copyWith(resetLinkSent: false, resetEmail: null);
  }

  /// Simulated sign-in.
  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // Simulated network latency
    await Future.delayed(const Duration(milliseconds: 600));

    // Demo credentials or general success check
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Email and password are required.',
      );
      return false;
    }

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      userEmail: cleanEmail,
      userName: cleanEmail.split('@').first,
      clearError: true,
    );
    return true;
  }

  /// Simulated account creation.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(milliseconds: 700));

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      userName: name.trim(),
      userEmail: email.trim(),
      clearError: true,
    );
    return true;
  }

  /// Simulated password recovery link dispatch.
  Future<bool> sendPasswordReset({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(
      isLoading: false,
      resetLinkSent: true,
      resetEmail: email.trim(),
      clearError: true,
    );
    return true;
  }

  /// Simulated sign-out.
  void signOut() {
    state = const AuthState();
  }
}

/// Global provider for AuthController.
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController();
  },
);
