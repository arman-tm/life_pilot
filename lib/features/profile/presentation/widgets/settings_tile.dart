import 'package:flutter/material.dart';

import '../../../../app/theme/app_design_tokens.dart';
import '../../../../core/utils/extensions.dart';

/// Reusable settings tile following the design system.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = isDestructive
        ? AppColors.error
        : (iconColor ?? AppColors.electricBlue);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppColors.error : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.softGray : AppColors.gray600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
            ] else if (onTap != null) ...[
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? AppColors.softGray : AppColors.gray400,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
