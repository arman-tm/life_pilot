import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:life_pilot/app/theme/app_design_tokens.dart';
import 'package:life_pilot/core/utils/extensions.dart';
import 'package:life_pilot/core/utils/validators.dart';
import 'package:life_pilot/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:life_pilot/features/profile/presentation/controllers/profile_controller.dart';
import 'package:life_pilot/features/profile/presentation/widgets/profile_avatar.dart';

/// Screen allowing users to update their profile details (display name, bio, phone).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _syncFromProfile() {
    if (_initialized) return;
    final profile = ref.read(profileControllerProvider).profile;
    if (profile != null) {
      _nameController.text = profile.displayName;
      _bioController.text = profile.bio ?? '';
      _phoneController.text = profile.phone ?? '';
      _initialized = true;
    }
  }

  Future<void> _handleSave() async {
    ref.read(profileControllerProvider.notifier).clearMessages();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          displayName: _nameController.text,
          bio: _bioController.text,
          phone: _phoneController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.electricBlueDark,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncFromProfile();

    final isDark = context.isDark;
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;
    final padding = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                      // ── Avatar Preview ──
                      Center(
                        child: ProfileAvatar(
                          initials: profile?.initials ?? 'U',
                          photoUrl: profile?.photoUrl,
                          size: 96,
                          fontSize: 34,
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

                      // ── Read-only Email ──
                      CustomTextField(
                        label: 'Email (Terkait Akun)',
                        controller: TextEditingController(
                          text: profile?.email ?? '',
                        ),
                        enabled: false,
                        prefixIcon: Icons.email_outlined,
                        helperText: 'Email akun tidak dapat diubah dari formulir ini.',
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Full Name Input ──
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: Validators.validateName,
                        textInputAction: TextInputAction.next,
                        enabled: !profileState.isSaving,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Phone Input ──
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Nomor Telepon (Opsional)',
                        hint: '+62 812 3456 7890',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        enabled: !profileState.isSaving,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Bio Input ──
                      CustomTextField(
                        controller: _bioController,
                        label: 'Bio Singkat',
                        hint: 'Ceritakan sedikit tentang Anda...',
                        prefixIcon: Icons.edit_note_rounded,
                        textInputAction: TextInputAction.done,
                        enabled: !profileState.isSaving,
                        onFieldSubmitted: (_) => _handleSave(),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Save Button ──
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: profileState.isSaving ? null : _handleSave,
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
                                    Text('Menyimpan Perubahan...'),
                                  ],
                                )
                              : const Text('Simpan Perubahan'),
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
