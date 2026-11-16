import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/placeholder_screen.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: AppStrings.planner,
      icon: Icons.calendar_month_rounded,
      description: 'AI-assisted planning, calendar, and task management '
          'will be available here.',
    );
  }
}
