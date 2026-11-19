import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_design_tokens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';
import 'controllers/auth_controller.dart';
import 'widgets/auth_header.dart';
import 'widgets/custom_text_field.dart';

/// Screen allowing users to sign in with simulated credentials (Phase 03A Demo).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@lifepilot.ai');
  final _passwordController = TextEditingController(text: 'PilotPass123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    // Clear any previous error
    ref.read(authControllerProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go(RoutePaths.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final authState = ref.watch(authControllerProvider);
    final padding = context.pagePadding;

    return Scaffold(
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
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ──
                      const AuthHeader(
                        title: AppStrings.welcomeBack,
                        subtitle: AppStrings.loginSubtitle,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Error Banner (if any) ──
                      if (authState.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                              width: 1,
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
                                  authState.errorMessage!,
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

                      // ── Email Field ──
                      CustomTextField(
                        controller: _emailController,
                        label: AppStrings.emailLabel,
                        hint: AppStrings.emailHint,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.validateEmail,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Password Field ──
                      CustomTextField(
                        controller: _passwordController,
                        label: AppStrings.passwordLabel,
                        hint: AppStrings.passwordHint,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: Validators.validatePassword,
                        onFieldSubmitted: (_) => _handleSignIn(),
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── Remember Me & Forgot Password ──
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: authState.rememberMe,
                              onChanged: authState.isLoading
                                  ? null
                                  : (_) {
                                      ref
                                          .read(authControllerProvider.notifier)
                                          .toggleRememberMe();
                                    },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs + 2),
                          GestureDetector(
                            onTap: authState.isLoading
                                ? null
                                : () {
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .toggleRememberMe();
                                  },
                            child: Text(
                              AppStrings.rememberMe,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.softGray
                                    : AppColors.gray700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: authState.isLoading
                                ? null
                                : () => context.push(RoutePaths.forgotPassword),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppStrings.forgotPassword,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.electricBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Sign In Button ──
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleSignIn,
                          child: authState.isLoading
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
                                    Text(AppStrings.signingIn),
                                  ],
                                )
                              : const Text(AppStrings.signIn),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Demo Notice Pill ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDarkElevated
                              : AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: isDark
                                ? AppColors.cardDarkBorder
                                : AppColors.cardLightBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          AppStrings.demoNotice,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.softGray.withValues(alpha: 0.7)
                                : AppColors.gray600,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Link to Register ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAccount,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.softGray
                                  : AppColors.gray600,
                            ),
                          ),
                          GestureDetector(
                            onTap: authState.isLoading
                                ? null
                                : () => context.push(RoutePaths.register),
                            child: Text(
                              AppStrings.signUp,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.electricBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
