import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/firestore_profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// State representation for Profile editing and password management.
class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.profile,
  });

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final UserProfile? profile;

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    UserProfile? profile,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      profile: profile ?? this.profile,
    );
  }
}

/// Global provider for [ProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FirestoreProfileRepository();
});

/// Stream provider delivering live updates of the authenticated user's profile.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authUser = ref.watch(authControllerProvider).user;
  if (authUser == null) return Stream.value(null);

  final repository = ref.watch(profileRepositoryProvider);
  return repository.streamProfile(authUser.id);
});

/// Controller managing profile mutations and password changes.
class ProfileController extends StateNotifier<ProfileState> {
  ProfileController({
    required ProfileRepository profileRepository,
    required Ref ref,
  })  : _profileRepository = profileRepository,
        _ref = ref,
        super(const ProfileState()) {
    _init();
  }

  final ProfileRepository _profileRepository;
  final Ref _ref;

  void _init() {
    final authUser = _ref.read(authControllerProvider).user;
    if (authUser != null) {
      loadProfile(authUser.id);
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<void> loadProfile(String uid) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _profileRepository.getProfile(uid);
      state = state.copyWith(
        isLoading: false,
        profile: profile,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat profil: ${e.toString()}',
      );
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    String? bio,
    String? phone,
  }) async {
    final current = state.profile ??
        await _profileRepository.getProfile(
          _ref.read(authControllerProvider).user?.id ?? '',
        );

    if (current == null) {
      state = state.copyWith(
        errorMessage: 'Profil pengguna tidak ditemukan.',
      );
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    try {
      final updated = current.copyWith(
        displayName: displayName.trim(),
        bio: bio?.trim(),
        phone: phone?.trim(),
        updatedAt: DateTime.now(),
      );

      await _profileRepository.saveProfile(updated);

      state = state.copyWith(
        isSaving: false,
        profile: updated,
        successMessage: 'Profil berhasil diperbarui.',
      );
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan perubahan: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    try {
      await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Kata sandi berhasil diubah.',
      );
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal mengubah kata sandi: ${e.toString()}',
      );
      return false;
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileController(profileRepository: repository, ref: ref);
});
