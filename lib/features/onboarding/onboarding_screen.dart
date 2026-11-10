import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/app_design_tokens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/extensions.dart';

/// Onboarding data model.
class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.icon,
  });
  final String title;
  final String body;
  final IconData icon;
}

const _pages = [
  _OnboardingPage(
    title: AppStrings.onboardingTitle1,
    body: AppStrings.onboardingBody1,
    icon: Icons.rocket_launch_rounded,
  ),
  _OnboardingPage(
    title: AppStrings.onboardingTitle2,
    body: AppStrings.onboardingBody2,
    icon: Icons.psychology_rounded,
  ),
  _OnboardingPage(
    title: AppStrings.onboardingTitle3,
    body: AppStrings.onboardingBody3,
    icon: Icons.flight_takeoff_rounded,
  ),
];

/// Onboarding screen with page-view swipe navigation.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() => context.go(RoutePaths.dashboard);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkNavy, AppColors.deepBlack]
                : [AppColors.surfaceLight, AppColors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip button ──
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    right: AppSpacing.md,
                  ),
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text(AppStrings.skip),
                  ),
                ),
              ),

              // ── Pages ──
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _PageContent(page: _pages[i]),
                ),
              ),

              // ── Indicators + Action ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    _PageIndicators(
                      count: _pages.length,
                      current: _currentPage,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _next,
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? AppStrings.getStarted
                              : AppStrings.next,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single onboarding page content.
class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Icon container ──
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.electricBlue.withValues(alpha: 0.15),
                  AppColors.electricBlueDark.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: AppColors.electricBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              page.icon,
              size: 52,
              color: AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            page.body,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dot indicators for page position.
class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.electricBlue
                : AppColors.electricBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      }),
    );
  }
}
