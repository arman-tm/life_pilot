import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/placeholder_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: AppStrings.activity,
      icon: Icons.timeline_rounded,
      description: 'Track your productivity, view history, and see insights '
          'about your daily activities.',
    );
  }
}
