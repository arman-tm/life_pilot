import '../constants/app_strings.dart';

/// Form field validation helpers.
abstract final class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Validates full name input.
  static String? validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return AppStrings.valNameRequired;
    }
    if (trimmed.length < 2) {
      return AppStrings.valNameTooShort;
    }
    return null;
  }

  /// Validates email format.
  static String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return AppStrings.valEmailRequired;
    }
    if (!_emailRegExp.hasMatch(trimmed)) {
      return AppStrings.valEmailInvalid;
    }
    return null;
  }

  /// Validates password presence and security.
  static String? validatePassword(
    String? value, {
    bool enforceSecurity = false,
  }) {
    if (value == null || value.isEmpty) {
      return AppStrings.valPasswordRequired;
    }
    if (value.length < 8) {
      return AppStrings.valPasswordLength;
    }
    if (enforceSecurity) {
      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
      final hasDigit = RegExp(r'[0-9]').hasMatch(value);
      if (!hasLetter || !hasDigit) {
        return AppStrings.valPasswordSecurity;
      }
    }
    return null;
  }

  /// Validates password confirmation matching.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.valConfirmRequired;
    }
    if (value != password) {
      return AppStrings.valPasswordMismatch;
    }
    return null;
  }
}
