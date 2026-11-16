import 'package:flutter/material.dart';

import '../../app/theme/app_design_tokens.dart';
import '../../core/utils/extensions.dart';

/// Section header with title and optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Text(title, style: context.textTheme.titleMedium),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
