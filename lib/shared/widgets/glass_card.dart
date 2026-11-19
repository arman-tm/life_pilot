import 'package:flutter/material.dart';

import '../../app/theme/app_design_tokens.dart';
import '../../core/utils/extensions.dart';

/// Glass-morphic style card used across the dashboard.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      color: gradient == null
          ? (isDark ? AppColors.cardDark : AppColors.cardLight)
          : null,
      gradient: gradient,
      border: Border.all(
        color: isDark ? AppColors.cardDarkBorder : AppColors.cardLightBorder,
        width: 0.5,
      ),
    );

    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return content;

    return GestureDetector(onTap: onTap, child: content);
  }
}
