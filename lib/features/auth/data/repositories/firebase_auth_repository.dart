import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] powered by Firebase Authentication.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  final fb.FirebaseAuth? _firebaseAuth;

  /// Safely resolves the FirebaseAuth instance, or null if Firebase is not initialized.
  fb.FirebaseAuth? get _auth {
    if (_firebaseAuth != null) return _firebaseAuth;
    if (Firebase.apps.isNotEmpty) {
      return fb.FirebaseAuth.instance;
    }
    return null;
  }

  @override
  bool get isFirebaseConfigured => Firebase.apps.isNotEmpty;

  @override
  Stream<UserEntity?> get authStateChanges {
    final auth = _auth;
    if (auth == null) {
      return Stream.value(null);
    }
    return auth.authStateChanges().map(_mapNullableFirebaseUser);
  }

  @override
  UserEntity? get currentUser {
    final user = _auth?.currentUser;
    return _mapNullableFirebaseUser(user);
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw AuthFailure.fromCode('firebase-not-initialized');
    }

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure(
          'Gagal mendapatkan profil pengguna setelah masuk.',
        );
      }

      return _mapFirebaseUser(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } on FirebaseException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw AuthFailure.fromCode('firebase-not-initialized');
    }

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Gagal membuat akun pengguna.');
      }

      // Update user display name in Firebase Auth
      final trimmedName = name.trim();
      if (trimmedName.isNotEmpty) {
        try {
          await user.updateDisplayName(trimmedName);
        } catch (_) {
          // Display name update failure should not cancel account creation
        }
      }

      return UserEntity(
        id: user.uid,
        email: user.email ?? email.trim(),
        displayName: trimmedName.isNotEmpty ? trimmedName : user.displayName,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } on FirebaseException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    final auth = _auth;
    if (auth == null) {
      throw AuthFailure.fromCode('firebase-not-initialized');
    }

    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } on FirebaseException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.signOut();
      } on fb.FirebaseAuthException catch (e) {
        throw AuthFailure.fromCode(e.code, e.message);
      }
    }
  }

  UserEntity? _mapNullableFirebaseUser(fb.User? user) {
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  UserEntity _mapFirebaseUser(fb.User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
