import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_design_tokens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions.dart';

/// Scaffold shell with bottom navigation and sidebar for wide screens.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: AppStrings.home,
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome_rounded),
      label: AppStrings.assistant,
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month_rounded),
      label: AppStrings.planner,
    ),
    NavigationDestination(
      icon: Icon(Icons.timeline_outlined),
      selectedIcon: Icon(Icons.timeline_rounded),
      label: AppStrings.activity,
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: AppStrings.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Wide screens: use NavigationRail in a Row.
    if (context.isExpanded) {
      return Scaffold(
        body: Row(
          children: [
            _buildSideRail(context),
            const VerticalDivider(width: 0.5, thickness: 0.5),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    // Compact & medium: bottom navigation.
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.cardDarkBorder
                : AppColors.cardLightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: _destinations,
      ),
    );
  }

  Widget _buildSideRail(BuildContext context) {
    final isDark = context.isDark;

    return NavigationRail(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: _onTap,
      labelType: NavigationRailLabelType.all,
      backgroundColor: isDark
          ? AppColors.surfaceDark
          : AppColors.surfaceLightElevated,
      indicatorColor: AppColors.electricBlue.withValues(
        alpha: isDark ? 0.15 : 0.1,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.lg,
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
            ),
          ),
          child: const Center(
            child: Text(
              'LP',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text(AppStrings.home),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome_rounded),
          label: Text(AppStrings.assistant),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: Text(AppStrings.planner),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.timeline_outlined),
          selectedIcon: Icon(Icons.timeline_rounded),
          label: Text(AppStrings.activity),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text(AppStrings.profile),
        ),
      ],
    );
  }
}
