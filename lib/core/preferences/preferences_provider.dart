import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported application languages.
enum AppLanguage {
  indonesian('id', 'Bahasa Indonesia'),
  english('en', 'English');

  const AppLanguage(this.code, this.label);
  final String code;
  final String label;
}

/// Preferences state model.
class AppPreferencesState {
  const AppPreferencesState({
    this.language = AppLanguage.indonesian,
    this.pushNotifications = true,
    this.dailyInsights = true,
  });

  final AppLanguage language;
  final bool pushNotifications;
  final bool dailyInsights;

  AppPreferencesState copyWith({
    AppLanguage? language,
    bool? pushNotifications,
    bool? dailyInsights,
  }) {
    return AppPreferencesState(
      language: language ?? this.language,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      dailyInsights: dailyInsights ?? this.dailyInsights,
    );
  }
}

/// Controller managing user preferences.
class AppPreferencesController extends StateNotifier<AppPreferencesState> {
  AppPreferencesController() : super(const AppPreferencesState());

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
  }

  void togglePushNotifications() {
    state = state.copyWith(pushNotifications: !state.pushNotifications);
  }

  void toggleDailyInsights() {
    state = state.copyWith(dailyInsights: !state.dailyInsights);
  }
}

final preferencesProvider =
    StateNotifierProvider<AppPreferencesController, AppPreferencesState>((ref) {
  return AppPreferencesController();
});
