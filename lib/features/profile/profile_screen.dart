import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/app_design_tokens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions.dart';
import '../auth/presentation/controllers/auth_controller.dart';

/// Profile screen with user information and simulated sign-out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final displayName = authState.userName?.isNotEmpty == true
        ? authState.userName!
        : 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Avatar ──
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.electricBlue.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.electricBlue.withValues(alpha: 0.25),
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(displayName, style: context.textTheme.headlineMedium),
            if (authState.userEmail != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                authState.userEmail!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.softGray,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(AppStrings.tagline, style: context.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.comingSoon,
              style: context.textTheme.labelLarge?.copyWith(
                color: AppColors.electricBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Profile settings, preferences, and account management '
              'will be available here.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Sign Out Button ──
            OutlinedButton.icon(
              onPressed: () {
                ref.read(authControllerProvider.notifier).signOut();
                context.go(RoutePaths.login);
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(AppStrings.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
