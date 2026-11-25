import '../entities/user_entity.dart';

/// Contract for authentication operations in LifePilot.
abstract class AuthRepository {
  /// Stream emitting the currently authenticated user or null on logout.
  Stream<UserEntity?> get authStateChanges;

  /// Returns the currently cached user entity, if any.
  UserEntity? get currentUser;

  /// Authenticate using email and password.
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create a new account with email, password, and display name.
  Future<UserEntity> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  /// Send password reset link to user's registered email.
  Future<void> sendPasswordResetEmail({required String email});

  /// Terminate the active session.
  Future<void> signOut();

  /// Whether a real Firebase instance is initialized and operational.
  bool get isFirebaseConfigured;
}
