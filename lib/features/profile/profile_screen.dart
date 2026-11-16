import 'package:flutter/material.dart';

import '../../app/theme/app_design_tokens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions.dart';

/// Profile placeholder with app identity.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: const Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('User', style: context.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.tagline,
              style: context.textTheme.bodyMedium,
            ),
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
          ],
        ),
      ),
    );
  }
}
