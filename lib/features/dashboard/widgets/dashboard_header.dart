import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_design_tokens.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';

/// Dashboard header — logo, greeting, date, avatar, settings.
class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    return Row(
      children: [
        // ── Logo ──
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'LP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // ── Title + date ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(now.formattedDate, style: context.textTheme.bodySmall),
            ],
          ),
        ),

        // ── Theme toggle ──
        _CircleAction(
          icon: context.isDark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          onTap: () {
            final current = ref.read(themeModeProvider);
            ref.read(themeModeProvider.notifier).state =
                current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          },
        ),
        const SizedBox(width: AppSpacing.sm),

        // ── Avatar ──
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.electricBlue.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.electricBlue.withValues(alpha: 0.3),
            ),
          ),
          child: const Center(
            child: Text(
              'U',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.electricBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.isDark
              ? AppColors.surfaceDarkElevated
              : AppColors.gray100,
        ),
        child: Icon(
          icon,
          size: 18,
          color: context.isDark ? AppColors.softGray : AppColors.gray600,
        ),
      ),
    );
  }
}
