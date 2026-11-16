import 'package:flutter/material.dart';

import '../../../app/theme/app_design_tokens.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/icon_container.dart';

/// Single quick action item.
class QuickActionData {
  const QuickActionData({
    required this.label,
    required this.icon,
    this.color,
  });
  final String label;
  final IconData icon;
  final Color? color;
}

/// Horizontal scrollable quick-action row.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.actions,
    this.onTap,
  });

  final List<QuickActionData> actions;
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) => _QuickActionItem(
          data: actions[i],
          onTap: onTap != null ? () => onTap!(i) : null,
        ),
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.data, this.onTap});
  final QuickActionData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          border: Border.all(
            color: isDark ? AppColors.cardDarkBorder : AppColors.cardLightBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconContainer(
              icon: data.icon,
              color: data.color,
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              data.label,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
