import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_design_tokens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/daily_insight_card.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/greeting_section.dart';
import 'widgets/overview_grid.dart';
import 'widgets/quick_actions_row.dart';

/// Main dashboard — the home tab of the application.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final padding = context.pagePadding;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35],
            colors: isDark
                ? [AppColors.darkNavy, AppColors.deepBlack]
                : [AppColors.surfaceLight, AppColors.white],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding, AppSpacing.md, padding, 0),
                sliver: const SliverToBoxAdapter(child: DashboardHeader()),
              ),

              // ── Greeting / Hero ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  padding, AppSpacing.lg, padding, 0,
                ),
                sliver: const SliverToBoxAdapter(child: GreetingSection()),
              ),

              // ── AI Assistant Card ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  padding, AppSpacing.lg, padding, 0,
                ),
                sliver: SliverToBoxAdapter(
                  child: AIAssistantCard(
                    onTap: () => _showPlaceholder(context, AppStrings.assistant),
                  ),
                ),
              ),

              // ── Quick Actions ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  padding, AppSpacing.lg, padding, 0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Quick Actions'),
                      QuickActionsRow(
                        actions: const [
                          QuickActionData(
                            label: AppStrings.myTasks,
                            icon: Icons.task_alt_rounded,
                            color: AppColors.electricBlue,
                          ),
                          QuickActionData(
                            label: AppStrings.calendar,
                            icon: Icons.calendar_month_rounded,
                            color: AppColors.success,
                          ),
                          QuickActionData(
                            label: AppStrings.reminders,
                            icon: Icons.notifications_active_rounded,
                            color: AppColors.warning,
                          ),
                          QuickActionData(
                            label: AppStrings.aiPlanner,
                            icon: Icons.auto_awesome_rounded,
                            color: AppColors.info,
                          ),
                        ],
                        onTap: (i) {
                          const labels = [
                            AppStrings.myTasks,
                            AppStrings.calendar,
                            AppStrings.reminders,
                            AppStrings.aiPlanner,
                          ];
                          _showPlaceholder(context, labels[i]);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Today's Overview ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  padding, AppSpacing.lg, padding, 0,
                ),
                sliver: const SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: AppStrings.todaysOverview),
                      OverviewGrid(),
                    ],
                  ),
                ),
              ),

              // ── Daily Insight ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  padding, AppSpacing.lg, padding, AppSpacing.xxl,
                ),
                sliver: const SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: AppStrings.dailyInsight),
                      DailyInsightCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature — ${AppStrings.comingSoon}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
