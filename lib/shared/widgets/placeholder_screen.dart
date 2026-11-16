import 'package:flutter/material.dart';

import '../../app/theme/app_design_tokens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions.dart';

/// Generic placeholder page for features under development.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.description,
  });

  final String title;
  final IconData icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                color: AppColors.electricBlue.withValues(
                  alpha: context.isDark ? 0.1 : 0.06,
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.electricBlue.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.comingSoon,
              style: context.textTheme.labelLarge?.copyWith(
                color: AppColors.electricBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description ?? AppStrings.featurePlaceholder,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
