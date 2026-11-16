import 'package:flutter/material.dart';

import '../../../app/theme/app_design_tokens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';

/// Hero greeting section with dynamic time-based salutation.
class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${now.greetingPrefix}, User 👋',
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.heroTitle,
          style: context.textTheme.titleMedium?.copyWith(
            color: AppColors.electricBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.heroSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
      ],
    );
  }
}
