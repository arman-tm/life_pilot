import 'package:flutter/material.dart';

import '../../../app/theme/app_design_tokens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';

/// Data model for a single overview metric.
class OverviewMetric {
  const OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
}

/// 2×2 grid of today's overview metrics — uses dummy data.
class OverviewGrid extends StatelessWidget {
  const OverviewGrid({super.key});

  static const _metrics = [
    OverviewMetric(
      label: AppStrings.totalTasks,
      value: '8',
      icon: Icons.task_alt_rounded,
      color: AppColors.electricBlue,
    ),
    OverviewMetric(
      label: AppStrings.completed,
      value: '3',
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
    ),
    OverviewMetric(
      label: AppStrings.upcoming,
      value: '2',
      icon: Icons.event_rounded,
      color: AppColors.warning,
    ),
    OverviewMetric(
      label: AppStrings.pending,
      value: '4',
      icon: Icons.notifications_active_rounded,
      color: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: context.isCompact ? 2 : 4,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: context.isCompact ? 1.6 : 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _metrics.map((m) => _MetricTile(metric: m)).toList(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.sampleData,
          style: context.textTheme.labelSmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: context.isDark
                ? AppColors.softGray.withValues(alpha: 0.3)
                : AppColors.gray400,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});
  final OverviewMetric metric;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = metric.color ?? AppColors.electricBlue;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border.all(
          color: isDark ? AppColors.cardDarkBorder : AppColors.cardLightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(metric.icon, size: 20, color: accent),
          const Spacer(),
          Text(
            metric.value,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            style: context.textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
