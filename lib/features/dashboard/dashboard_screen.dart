import 'package:flutter/material.dart';

import '../../app/theme/app_design_tokens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions.dart';

/// Dashboard placeholder — the main hub after onboarding.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final now = DateTime.now();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3],
            colors: isDark
                ? [AppColors.darkNavy, AppColors.deepBlack]
                : [AppColors.surfaceLight, AppColors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(context, isDark),
                      const SizedBox(height: AppSpacing.lg),
                      _buildGreeting(context, now),
                    ],
                  ),
                ),
              ),

              // ── Feature Placeholders ──
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverGrid.count(
                  crossAxisCount: context.isWide ? 3 : 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.1,
                  children: const [
                    _FeatureCard(
                      icon: Icons.chat_rounded,
                      label: 'AI Chat',
                    ),
                    _FeatureCard(
                      icon: Icons.calendar_month_rounded,
                      label: 'Calendar',
                    ),
                    _FeatureCard(
                      icon: Icons.task_alt_rounded,
                      label: 'Tasks',
                    ),
                    _FeatureCard(
                      icon: Icons.notifications_active_rounded,
                      label: 'Reminders',
                    ),
                    _FeatureCard(
                      icon: Icons.mic_rounded,
                      label: 'Voice',
                    ),
                    _FeatureCard(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Memory',
                    ),
                  ],
                ),
              ),

              // ── Bottom padding ──
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Mini logo
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.electricBlue,
                AppColors.electricBlueDark,
              ],
            ),
          ),
          child: const Center(
            child: Text(
              'LP',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          AppStrings.appName,
          style: context.textTheme.titleLarge,
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? AppColors.softGray : AppColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context, DateTime now) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${now.greetingPrefix}! 👋',
          style: context.textTheme.displayMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.dashboardSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}

/// Placeholder card for future features — non-interactive.
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: isDark
            ? Border.all(
                color: AppColors.surfaceDarkElevated,
              )
            : Border.all(color: AppColors.gray200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: AppColors.electricBlue.withValues(alpha: isDark ? 0.12 : 0.08),
            ),
            child: Icon(
              icon,
              color: AppColors.electricBlue.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: isDark
                  ? AppColors.softGray.withValues(alpha: 0.7)
                  : AppColors.gray500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppStrings.comingSoon,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: isDark
                  ? AppColors.softGray.withValues(alpha: 0.4)
                  : AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
