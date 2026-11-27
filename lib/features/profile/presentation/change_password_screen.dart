import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:life_pilot/app/theme/app_design_tokens.dart';
import 'package:life_pilot/core/constants/app_strings.dart';
import 'package:life_pilot/core/utils/extensions.dart';
import 'package:life_pilot/core/utils/validators.dart';
import 'package:life_pilot/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:life_pilot/features/profile/presentation/controllers/profile_controller.dart';

/// Screen allowing authenticated users to change their password safely.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    ref.read(profileControllerProvider.notifier).clearMessages();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(profileControllerProvider.notifier)
        .changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.electricBlueDark,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final profileState = ref.watch(profileControllerProvider);
    final padding = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Kata Sandi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4],
            colors: isDark
                ? [AppColors.darkNavy, AppColors.deepBlack]
                : [AppColors.surfaceLight, AppColors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: AppSpacing.md,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Info Header ──
                      Text(
                        'Amankan Akun Anda',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Untuk menjaga keamanan akun, masukkan kata sandi Anda saat ini diikuti dengan kata sandi baru yang kuat.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Error Banner ──
                      if (profileState.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  profileState.errorMessage!,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // ── Current Password ──
                      CustomTextField(
                        controller: _currentPasswordController,
                        label: 'Kata Sandi Saat Ini',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: Validators.validatePassword,
                        textInputAction: TextInputAction.next,
                        enabled: !profileState.isSaving,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── New Password ──
                      CustomTextField(
                        controller: _newPasswordController,
                        label: 'Kata Sandi Baru',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_reset_rounded,
                        isPassword: true,
                        helperText: AppStrings.passwordRequirements,
                        validator: (val) => Validators.validatePassword(
                          val,
                          enforceSecurity: true,
                        ),
                        textInputAction: TextInputAction.next,
                        enabled: !profileState.isSaving,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Confirm New Password ──
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Konfirmasi Kata Sandi Baru',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_clock_outlined,
                        isPassword: true,
                        validator: (val) => Validators.validateConfirmPassword(
                          val,
                          _newPasswordController.text,
                        ),
                        textInputAction: TextInputAction.done,
                        enabled: !profileState.isSaving,
                        onFieldSubmitted: (_) => _handleChangePassword(),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Submit Button ──
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              profileState.isSaving ? null : _handleChangePassword,
                          child: profileState.isSaving
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          AppColors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Text('Memperbarui Kata Sandi...'),
                                  ],
                                )
                              : const Text('Simpan Kata Sandi Baru'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
