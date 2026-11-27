import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/app_design_tokens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions.dart';
import '../auth/presentation/controllers/auth_controller.dart';
import 'presentation/controllers/profile_controller.dart';
import 'presentation/widgets/profile_avatar.dart';

/// Premium Profile Screen displaying real user account details and quick actions.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final padding = context.pagePadding;

    final authUser = ref.watch(authControllerProvider).user;
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value ?? ref.watch(profileControllerProvider).profile;

    final displayName = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : (authUser?.displayName?.isNotEmpty == true
            ? authUser!.displayName!
            : 'Pengguna LifePilot');
    final email = profile?.email.isNotEmpty == true
        ? profile!.email
        : (authUser?.email ?? '');
    final initials = profile?.initials ?? 'LP';
    final memberSince = profile?.memberSinceFormatted ?? 'Active Member';
    final isEmailVerified = profile?.isEmailVerified ?? false;

    return Scaffold(
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  children: [
                    // ── Header Bar ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profil Pengguna',
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          tooltip: 'Pengaturan Akun',
                          onPressed: () => context.push(RoutePaths.settings),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Avatar ──
                    ProfileAvatar(
                      initials: initials,
                      photoUrl: profile?.photoUrl,
                      size: 100,
                      fontSize: 36,
                      onTap: () => context.push(RoutePaths.editProfile),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Name & Email ──
                    Text(
                      displayName,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      email,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.softGray : AppColors.gray600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Status Pill ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.electricBlue.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEmailVerified
                                ? Icons.verified_rounded
                                : Icons.account_circle_outlined,
                            size: 14,
                            color: AppColors.electricBlue,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            isEmailVerified
                                ? 'Akun Terverifikasi'
                                : 'Akun Aktif',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Bio (if provided) ──
                    if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Text(
                          '"${profile.bio!}"',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? AppColors.softGray
                                : AppColors.gray700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // ── Edit Profile & Settings Action Buttons ──
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push(RoutePaths.editProfile),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit Profil'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push(RoutePaths.settings),
                            icon: const Icon(Icons.tune_rounded, size: 18),
                            label: const Text('Pengaturan'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Account Info Cards ──
                    _buildInfoCard(
                      context,
                      isDark: isDark,
                      icon: Icons.calendar_today_rounded,
                      title: 'Bergabung',
                      value: memberSince,
                    ),
                    _buildInfoCard(
                      context,
                      isDark: isDark,
                      icon: Icons.shield_outlined,
                      title: 'Sistem Keamanan',
                      value: 'Firebase Authentication & Firestore',
                    ),
                    if (profile?.phone != null && profile!.phone!.isNotEmpty)
                      _buildInfoCard(
                        context,
                        isDark: isDark,
                        icon: Icons.phone_outlined,
                        title: 'Nomor Telepon',
                        value: profile.phone!,
                      ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Sign Out Button ──
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                        onPressed: () => _showSignOutDialog(context, ref),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text(AppStrings.signOut),
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

  Widget _buildInfoCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.cardDarkBorder : AppColors.cardLightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(
                alpha: isDark ? 0.12 : 0.08,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.electricBlue, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.softGray : AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
