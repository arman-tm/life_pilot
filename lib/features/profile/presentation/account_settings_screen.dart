import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:life_pilot/app/router/app_router.dart';
import 'package:life_pilot/app/theme/app_design_tokens.dart';
import 'package:life_pilot/app/theme/theme_provider.dart';
import 'package:life_pilot/core/constants/app_strings.dart';
import 'package:life_pilot/core/preferences/preferences_provider.dart';
import 'package:life_pilot/core/utils/extensions.dart';
import 'package:life_pilot/features/auth/presentation/controllers/auth_controller.dart';
import 'package:life_pilot/features/profile/presentation/controllers/profile_controller.dart';
import 'package:life_pilot/features/profile/presentation/widgets/settings_tile.dart';

/// Screen managing all account settings, appearance, preferences, and privacy.
class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Sesi login Anda akan diakhiri dan Anda akan diarahkan kembali ke halaman masuk.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go(RoutePaths.login);
              }
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.electricBlue,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Privasi & Keamanan Data',
                  style: sheetContext.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Di LifePilot AI, privasi Anda adalah prioritas utama kami:\n\n'
              '• Data profil Anda dienkripsi dan diisolasi khusus berdasarkan UID unik Anda di Cloud Firestore.\n'
              '• Tidak ada pengguna lain yang dapat membaca atau memodifikasi data akun Anda.\n'
              '• Kata sandi Anda dikelola secara aman oleh Firebase Authentication dan tidak pernah disimpan secara terbuka.\n'
              '• Anda memiliki kontrol penuh untuk memperbarui atau mengakhiri sesi kapan saja.',
              style: sheetContext.textTheme.bodyMedium?.copyWith(height: 1.55),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Saya Mengerti'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final padding = context.pagePadding;

    final themeMode = ref.watch(themeModeProvider);
    final preferences = ref.watch(preferencesProvider);
    final profile = ref.watch(profileControllerProvider).profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4],
            colors: isDark
                ? [AppColors.darkNavy, AppColors.deepBlack]
                : [AppColors.surfaceLight, AppColors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: AppSpacing.md,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ──────────────── Section A: Akun ────────────────
                    _buildSectionHeader(context, 'AKUN PENGGUNA'),
                    SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Profil Pengguna',
                      subtitle: profile?.displayName ?? 'Edit nama & bio',
                      onTap: () => context.push(RoutePaths.editProfile),
                    ),
                    SettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Alamat Email',
                      subtitle: profile?.email ?? 'Memuat...',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          profile?.isEmailVerified == true ? 'Terverifikasi' : 'Aktif',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Ganti Kata Sandi',
                      subtitle: 'Perbarui kata sandi akun Anda',
                      onTap: () => context.push(RoutePaths.changePassword),
                    ),
                    SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Keluar (Sign Out)',
                      subtitle: 'Akhiri sesi aktif di perangkat ini',
                      iconColor: AppColors.error,
                      isDestructive: true,
                      onTap: () => _showSignOutDialog(context, ref),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ──────────────── Section B: Tampilan ────────────────
                    _buildSectionHeader(context, 'TAMPILAN & TEMA'),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isDark
                              ? AppColors.cardDarkBorder
                              : AppColors.cardLightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilihan Tema Aplikasi',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              _ThemeOption(
                                label: 'Dark',
                                icon: Icons.dark_mode_rounded,
                                isSelected: themeMode == ThemeMode.dark,
                                onTap: () => ref
                                    .read(themeModeProvider.notifier)
                                    .state = ThemeMode.dark,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _ThemeOption(
                                label: 'Light',
                                icon: Icons.light_mode_rounded,
                                isSelected: themeMode == ThemeMode.light,
                                onTap: () => ref
                                    .read(themeModeProvider.notifier)
                                    .state = ThemeMode.light,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _ThemeOption(
                                label: 'Sistem',
                                icon: Icons.brightness_auto_rounded,
                                isSelected: themeMode == ThemeMode.system,
                                onTap: () => ref
                                    .read(themeModeProvider.notifier)
                                    .state = ThemeMode.system,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ──────────────── Section C: Preferensi ────────────────
                    _buildSectionHeader(context, 'PREFERENSI'),
                    SettingsTile(
                      icon: Icons.language_rounded,
                      title: 'Bahasa Aplikasi',
                      subtitle: preferences.language.label,
                      trailing: DropdownButton<AppLanguage>(
                        value: preferences.language,
                        underline: const SizedBox(),
                        dropdownColor:
                            isDark ? AppColors.cardDark : AppColors.cardLight,
                        items: AppLanguage.values.map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(
                              lang.label,
                              style: context.textTheme.bodySmall,
                            ),
                          );
                        }).toList(),
                        onChanged: (newLang) {
                          if (newLang != null) {
                            ref
                                .read(preferencesProvider.notifier)
                                .setLanguage(newLang);
                          }
                        },
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi Aplikasi',
                      subtitle: preferences.pushNotifications
                          ? 'Aktif'
                          : 'Dinonaktifkan',
                      trailing: Switch.adaptive(
                        value: preferences.pushNotifications,
                        activeTrackColor: AppColors.electricBlue,
                        onChanged: (_) => ref
                            .read(preferencesProvider.notifier)
                            .togglePushNotifications(),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'Rekomendasi Daily Insight',
                      subtitle: preferences.dailyInsights
                          ? 'Menampilkan insight produktivitas di dashboard'
                          : 'Dinonaktifkan',
                      trailing: Switch.adaptive(
                        value: preferences.dailyInsights,
                        activeTrackColor: AppColors.electricBlue,
                        onChanged: (_) => ref
                            .read(preferencesProvider.notifier)
                            .toggleDailyInsights(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ──────────────── Section D: Privasi & Keamanan ────────────────
                    _buildSectionHeader(context, 'PRIVASI & KEAMANAN'),
                    SettingsTile(
                      icon: Icons.security_rounded,
                      title: 'Informasi Keamanan & Data',
                      subtitle: 'Pelajari bagaimana LifePilot melindungi data Anda',
                      onTap: () => _showPrivacyInfoSheet(context),
                    ),
                    SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi',
                      subtitle: '${AppStrings.appName} v0.1.0 (Phase 03C)',
                      trailing: const Text(
                        'Stable',
                        style: TextStyle(
                          color: AppColors.softGray,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.electricBlue,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            color: isSelected
                ? AppColors.electricBlue.withValues(alpha: isDark ? 0.2 : 0.12)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? AppColors.electricBlue
                  : (isDark
                      ? AppColors.cardDarkBorder
                      : AppColors.cardLightBorder),
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.electricBlue : AppColors.softGray,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.electricBlue : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
