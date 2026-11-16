import 'package:flutter/material.dart';

/// Date/time formatting helpers.
extension DateTimeX on DateTime {
  String get greetingPrefix {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${days[weekday - 1]}, ${months[month - 1]} $day';
  }
}

/// Responsive sizing helpers.
extension ContextX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Compact phone (<600).
  bool get isCompact => screenWidth < 600;

  /// Medium tablet (600–900).
  bool get isMedium => screenWidth >= 600 && screenWidth < 900;

  /// Expanded desktop (>=900).
  bool get isExpanded => screenWidth >= 900;

  /// Legacy alias.
  bool get isWide => screenWidth > 600;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;

  /// Horizontal page padding that scales with screen width.
  double get pagePadding => isCompact ? 20 : (isMedium ? 32 : 48);
}
