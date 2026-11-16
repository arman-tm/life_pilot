import 'package:flutter/material.dart';

import '../../app/theme/app_design_tokens.dart';
import '../../core/utils/extensions.dart';

/// Reusable icon container with a tinted background.
class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize = 22,
    this.color,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.electricBlue;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: accent.withValues(alpha: context.isDark ? 0.12 : 0.08),
      ),
      child: Icon(icon, size: iconSize, color: accent),
    );
  }
}
