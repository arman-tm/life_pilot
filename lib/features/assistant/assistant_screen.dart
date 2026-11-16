import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/placeholder_screen.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: AppStrings.assistant,
      icon: Icons.auto_awesome_rounded,
      description: 'Your AI-powered personal assistant will be available here. '
          'Chat, ask questions, and get intelligent recommendations.',
    );
  }
}
