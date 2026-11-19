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

/// Screen allowing new users to register (Phase 03A Demo).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _termsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    ref.read(authControllerProvider.notifier).clearError();

    final formValid = _formKey.currentState!.validate();
    setState(() {
      _termsError = !_agreedToTerms;
    });

    if (!formValid || !_agreedToTerms) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      // Show confirmation & navigate to dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully! Welcome, ${_nameController.text.trim()}.',
          ),
          backgroundColor: AppColors.electricBlueDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(RoutePaths.dashboard);
    }
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ──
                      const AuthHeader(
                        title: AppStrings.createAccount,
                        subtitle: AppStrings.registerSubtitle,
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
                          child: Text(
                            authState.errorMessage!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // ── Full Name Field ──
                      CustomTextField(
                        controller: _nameController,
                        label: AppStrings.fullNameLabel,
                        hint: AppStrings.fullNameHint,
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: Validators.validateName,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: AppSpacing.md),

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
                      const SizedBox(height: AppSpacing.md),

                      // ── Password Field ──
                      CustomTextField(
                        controller: _passwordController,
                        label: AppStrings.passwordLabel,
                        hint: AppStrings.passwordHint,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        helperText: AppStrings.passwordRequirements,
                        validator: (val) => Validators.validatePassword(
                          val,
                          enforceSecurity: true,
                        ),
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Confirm Password Field ──
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPasswordLabel,
                        hint: AppStrings.confirmPasswordHint,
                        prefixIcon: Icons.lock_clock_outlined,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: (val) => Validators.validateConfirmPassword(
                          val,
                          _passwordController.text,
                        ),
                        onFieldSubmitted: (_) => _handleRegister(),
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Terms & Conditions Checkbox ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: authState.isLoading
                                  ? null
                                  : (v) {
                                      setState(() {
                                        _agreedToTerms = v ?? false;
                                        if (_agreedToTerms) _termsError = false;
                                      });
                                    },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs + 2),
                          Expanded(
                            child: GestureDetector(
                              onTap: authState.isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _agreedToTerms = !_agreedToTerms;
                                        if (_agreedToTerms) _termsError = false;
                                      });
                                    },
                              child: Text(
                                AppStrings.agreeToTerms,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.softGray
                                      : AppColors.gray700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_termsError) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Text(
                            AppStrings.valTermsRequired,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),

                      // ── Submit Button ──
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : _handleRegister,
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
                                    Text(AppStrings.creatingAccount),
                                  ],
                                )
                              : const Text(AppStrings.createAccount),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Link to Sign In ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.alreadyHaveAccount,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.softGray
                                  : AppColors.gray600,
                            ),
                          ),
                          GestureDetector(
                            onTap: authState.isLoading
                                ? null
                                : () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go(RoutePaths.login);
                                    }
                                  },
                            child: Text(
                              AppStrings.signIn,
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
