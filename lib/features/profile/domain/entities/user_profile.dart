/// Domain entity representing a user's full profile in LifePilot.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;

  /// Returns user's initials for the fallback avatar (e.g. "Alex Morgan" -> "AM").
  String get initials {
    final clean = displayName.trim();
    if (clean.isEmpty) {
      if (email.isNotEmpty) return email[0].toUpperCase();
      return 'U';
    }
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  /// Formatted date string for "Member since ...".
  String get memberSinceFormatted {
    if (createdAt == null) return 'Active Member';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return 'Member since ${months[createdAt!.month - 1]} ${createdAt!.year}';
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (bio != null) 'bio': bio,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {required String fallbackUid}) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      // Handles Firestore Timestamp if accessed dynamically
      try {
        final dynamic ts = val;
        return ts.toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    return UserProfile(
      uid: map['uid'] as String? ?? fallbackUid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      phone: map['phone'] as String?,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}
