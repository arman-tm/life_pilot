import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Authentication status enumeration for route protection and state checks.
enum AuthStatus {
  /// App is determining if a persisted session exists.
  initial,

  /// User is signed in with a valid session.
  authenticated,

  /// User is not signed in.
  unauthenticated,
}

/// State representation for authentication and auth forms.
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.rememberMe = true,
    this.resetLinkSent = false,
    this.resetEmail,
  });

  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;
  final UserEntity? user;
  final bool rememberMe;
  final bool resetLinkSent;
  final String? resetEmail;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  String? get userName => user?.displayName;
  String? get userEmail => user?.email;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    UserEntity? user,
    bool? rememberMe,
    bool? resetLinkSent,
    String? resetEmail,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: clearUser ? null : (user ?? this.user),
      rememberMe: rememberMe ?? this.rememberMe,
      resetLinkSent: resetLinkSent ?? this.resetLinkSent,
      resetEmail: resetEmail ?? this.resetEmail,
    );
  }
}

/// Global provider for [AuthRepository]. Can be overridden in widget/unit tests.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Stream provider for raw auth state changes from the repository.
final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Controller managing Firebase authentication state with session persistence.
class AuthController extends StateNotifier<AuthState> {
  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    _initAuthListener();
  }

  final AuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  void _initAuthListener() {
    // Check initial cached user if any
    final initialUser = _authRepository.currentUser;
    if (initialUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: initialUser,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    // Listen to persistent session changes (token refresh, login, logout)
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        );
      }
    });
  }

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

  /// Sign in with Firebase email and password.
  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      );
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan tidak terduga: ${e.toString()}',
      );
      return false;
    }
  }

  /// Register a new account with Firebase Authentication.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authRepository.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      );
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal membuat akun: ${e.toString()}',
      );
      return false;
    }
  }

  /// Send password recovery link using Firebase.
  Future<bool> sendPasswordReset({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.sendPasswordResetEmail(email: email);

      state = state.copyWith(
        isLoading: false,
        resetLinkSent: true,
        resetEmail: email.trim(),
        clearError: true,
      );
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengirim email reset: ${e.toString()}',
      );
      return false;
    }
  }

  /// Sign out from Firebase and clear active session.
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } finally {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Global provider for [AuthController].
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repository = ref.watch(authRepositoryProvider);
    return AuthController(authRepository: repository);
  },
);
