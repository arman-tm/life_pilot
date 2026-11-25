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

/// Screen allowing users to request a password reset via Firebase.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    ref.read(authControllerProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(email: _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final authState = ref.watch(authControllerProvider);
    final padding = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            ref.read(authControllerProvider.notifier).clearResetStatus();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RoutePaths.login);
            }
          },
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
                constraints: const BoxConstraints(maxWidth: 460),
                child: AnimatedSwitcher(
                  duration: AppDurations.medium,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: authState.resetLinkSent
                      ? _buildConfirmationView(
                          context,
                          isDark,
                          authState.resetEmail ?? _emailController.text,
                        )
                      : _buildFormView(context, isDark, authState),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(
    BuildContext context,
    bool isDark,
    AuthState authState,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('forgot_password_form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          const AuthHeader(
            title: AppStrings.resetPassword,
            subtitle: AppStrings.resetSubtitle,
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
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: Validators.validateEmail,
            onFieldSubmitted: (_) => _handleReset(),
            enabled: !authState.isLoading,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Submit Button ──
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleReset,
              child: authState.isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Text(AppStrings.sendingResetLink),
                      ],
                    )
                  : const Text(AppStrings.sendResetLink),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Back to Sign In Link ──
          Center(
            child: TextButton.icon(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RoutePaths.login);
                      }
                    },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text(AppStrings.backToSignIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationView(
    BuildContext context,
    bool isDark,
    String email,
  ) {
    return Column(
      key: const ValueKey('forgot_password_confirmation'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Success Icon Container ──
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.success,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Title & Message ──
        Text(
          AppStrings.resetLinkSent,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${AppStrings.resetLinkSentDesc}\n$email',
          style: context.textTheme.bodyMedium?.copyWith(height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Feedback Pill ──
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDarkElevated : AppColors.gray100,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark
                  ? AppColors.cardDarkBorder
                  : AppColors.cardLightBorder,
            ),
          ),
          child: Text(
            AppStrings.checkInbox,
            style: context.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.softGray : AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Back to Sign In Button ──
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).clearResetStatus();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.login);
              }
            },
            child: const Text(AppStrings.backToSignIn),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Resend Option ──
        Center(
          child: TextButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).clearResetStatus();
            },
            child: const Text(AppStrings.resendLink),
          ),
        ),
      ],
    );
  }
}
