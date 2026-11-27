import 'package:flutter/material.dart';

import '../../../../app/theme/app_design_tokens.dart';
import '../../../../core/utils/extensions.dart';

/// Reusable premium avatar displaying user photo or fallback initials.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initials,
    this.photoUrl,
    this.size = 88,
    this.fontSize = 32,
    this.onTap,
  });

  final String initials;
  final String? photoUrl;
  final double size;
  final double fontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.electricBlue.withValues(alpha: context.isDark ? 0.2 : 0.12),
            AppColors.electricBlueDark.withValues(alpha: context.isDark ? 0.1 : 0.05),
          ],
        ),
        border: Border.all(
          color: AppColors.electricBlue.withValues(alpha: 0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasPhoto
          ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.electricBlue,
                  letterSpacing: -0.5,
                ),
              ),
            )
          : null,
    );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          avatar,
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.electricBlue,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 16,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
