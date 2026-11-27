import '../entities/user_profile.dart';

/// Contract for profile and account settings management.
abstract class ProfileRepository {
  /// Fetches profile data from Firestore or Firebase Auth.
  Future<UserProfile?> getProfile(String uid);

  /// Streams real-time updates for user profile from `users/{uid}`.
  Stream<UserProfile?> streamProfile(String uid);

  /// Saves or updates the user's profile under `users/{uid}`.
  Future<void> saveProfile(UserProfile profile);

  /// Updates the user's display name across Firebase Auth and Firestore.
  Future<void> updateDisplayName(String uid, String newName);

  /// Reauthenticates and updates the user's password in Firebase Auth.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
