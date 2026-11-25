import 'failures.dart';

/// Domain failure representing authentication-specific errors.
class AuthFailure extends Failure {
  const AuthFailure(super.message, {this.code});

  final String? code;

  /// Translates FirebaseAuthException codes and general auth errors
  /// into user-friendly Indonesian messages.
  factory AuthFailure.fromCode(String code, [String? customMessage]) {
    switch (code) {
      case 'invalid-email':
        return const AuthFailure(
          'Format alamat email tidak valid.',
          code: 'invalid-email',
        );
      case 'user-not-found':
        return const AuthFailure(
          'Akun dengan email ini tidak ditemukan.',
          code: 'user-not-found',
        );
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(
          'Email atau kata sandi salah. Silakan periksa kembali.',
          code: 'invalid-credential',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          'Email ini sudah terdaftar. Silakan gunakan email lain atau masuk.',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthFailure(
          'Kata sandi terlalu lemah. Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.',
          code: 'weak-password',
        );
      case 'network-request-failed':
        return const AuthFailure(
          'Koneksi internet bermasalah. Periksa jaringan Anda dan coba lagi.',
          code: 'network-request-failed',
        );
      case 'too-many-requests':
        return const AuthFailure(
          'Terlalu banyak percobaan gagal. Harap tunggu beberapa saat sebelum mencoba lagi.',
          code: 'too-many-requests',
        );
      case 'user-disabled':
        return const AuthFailure(
          'Akun ini telah dinonaktifkan. Hubungi dukungan jika ini adalah kesalahan.',
          code: 'user-disabled',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          'Metode masuk Email/Password belum diaktifkan di Firebase Console.',
          code: 'operation-not-allowed',
        );
      case 'firebase-not-initialized':
        return const AuthFailure(
          'Firebase belum dikonfigurasi pada aplikasi. Silakan hubungkan proyek Firebase Anda.',
          code: 'firebase-not-initialized',
        );
      default:
        return AuthFailure(
          customMessage ?? 'Terjadi kesalahan autentikasi. Silakan coba lagi.',
          code: code,
        );
    }
  }
}
