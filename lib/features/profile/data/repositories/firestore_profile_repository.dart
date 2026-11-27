import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Implementation of [ProfileRepository] using Cloud Firestore and Firebase Auth.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore,
        _auth = firebaseAuth;

  final FirebaseFirestore? _firestore;
  final fb.FirebaseAuth? _auth;

  bool get _isFirebaseActive => Firebase.apps.isNotEmpty;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    if (_isFirebaseActive) return FirebaseFirestore.instance;
    return null;
  }

  fb.FirebaseAuth? get _authInstance {
    if (_auth != null) return _auth;
    if (_isFirebaseActive) return fb.FirebaseAuth.instance;
    return null;
  }

  DocumentReference<Map<String, dynamic>>? _userDoc(String uid) {
    return _db?.collection('users').doc(uid);
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final authUser = _authInstance?.currentUser;

    try {
      final docRef = _userDoc(uid);
      if (docRef != null) {
        final snapshot = await docRef.get();
        if (snapshot.exists && snapshot.data() != null) {
          final profile = UserProfile.fromMap(
            snapshot.data()!,
            fallbackUid: uid,
          );
          return profile.copyWith(
            isEmailVerified: authUser?.emailVerified ?? false,
          );
        }
      }
    } catch (_) {
      // Fallback to Firebase Auth user metadata if Firestore query fails/offline
    }

    // Fallback: construct profile from authenticated Firebase user
    if (authUser != null && authUser.uid == uid) {
      return UserProfile(
        uid: authUser.uid,
        email: authUser.email ?? '',
        displayName: authUser.displayName ?? authUser.email?.split('@').first ?? 'User',
        photoUrl: authUser.photoURL,
        createdAt: authUser.metadata.creationTime,
        updatedAt: authUser.metadata.lastSignInTime,
        isEmailVerified: authUser.emailVerified,
      );
    }

    return null;
  }

  @override
  Stream<UserProfile?> streamProfile(String uid) {
    final docRef = _userDoc(uid);
    if (docRef == null) {
      // If Firestore is not ready, return single current auth state
      return Stream.fromFuture(getProfile(uid));
    }

    return docRef.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final profile = UserProfile.fromMap(snapshot.data()!, fallbackUid: uid);
        final authUser = _authInstance?.currentUser;
        return profile.copyWith(
          isEmailVerified: authUser?.emailVerified ?? false,
        );
      }
      return null;
    }).handleError((_) {
      return null;
    });
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      // 1. Update Firebase Auth display name if changed
      final authUser = _authInstance?.currentUser;
      if (authUser != null && authUser.displayName != profile.displayName) {
        await authUser.updateDisplayName(profile.displayName);
      }

      // 2. Persist to Cloud Firestore under users/{uid}
      final docRef = _userDoc(profile.uid);
      if (docRef != null) {
        await docRef.set(
          profile.toMap(),
          SetOptions(merge: true),
        );
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } catch (e) {
      throw AuthFailure('Gagal menyimpan profil: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDisplayName(String uid, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw const AuthFailure('Nama lengkap tidak boleh kosong.');
    }

    try {
      final authUser = _authInstance?.currentUser;
      if (authUser != null && authUser.uid == uid) {
        await authUser.updateDisplayName(trimmed);
      }

      final docRef = _userDoc(uid);
      if (docRef != null) {
        await docRef.set({
          'displayName': trimmed,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code, e.message);
    } catch (e) {
      throw AuthFailure('Gagal memperbarui nama: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _authInstance?.currentUser;
    if (user == null || user.email == null) {
      throw const AuthFailure('Pengguna belum masuk atau email tidak ditemukan.');
    }

    try {
      // Step 1: Re-authenticate with current credentials
      final credential = fb.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Step 2: Update password in Firebase Auth
      await user.updatePassword(newPassword);
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw const AuthFailure('Kata sandi saat ini yang Anda masukkan salah.');
        case 'weak-password':
          throw const AuthFailure('Kata sandi baru terlalu lemah. Minimal 8 karakter.');
        case 'requires-recent-login':
          throw const AuthFailure('Sesi kedaluwarsa. Silakan keluar dan masuk kembali sebelum mengganti kata sandi.');
        default:
          throw AuthFailure.fromCode(e.code, e.message);
      }
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure('Gagal mengganti kata sandi: ${e.toString()}');
    }
  }
}
