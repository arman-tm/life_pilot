import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/activity_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/planner/planner_screen.dart';
import '../../features/profile/presentation/account_settings_screen.dart';
import '../../features/profile/presentation/change_password_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';

/// Named route paths.
abstract final class RoutePaths {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/dashboard';
  static const assistant = '/assistant';
  static const planner = '/planner';
  static const activity = '/activity';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const settings = '/profile/settings';
  static const changePassword = '/profile/change-password';
}

/// Listenable bridging Riverpod auth state changes to GoRouter's refreshListenable.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated ||
          previous?.status != next.status) {
        notifyListeners();
      }
    });
  }

  final Ref _ref;
}

final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  return RouterRefreshNotifier(ref);
});

/// GoRouter provider with route protection and session redirection.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final currentLoc = state.uri.path;

      final isSplash = currentLoc == RoutePaths.splash;
      final isOnboarding = currentLoc == RoutePaths.onboarding;
      final isAuthRoute =
          currentLoc == RoutePaths.login ||
          currentLoc == RoutePaths.register ||
          currentLoc == RoutePaths.forgotPassword;

      // Allow splash and onboarding to render without interference
      if (isSplash || isOnboarding) {
        return null;
      }

      // If user is authenticated, redirect away from auth screens to dashboard
      if (authState.isAuthenticated) {
        if (isAuthRoute) {
          return RoutePaths.dashboard;
        }
        return null;
      }

      // If user is not authenticated and tries to access protected areas, redirect to login
      if (!authState.isAuthenticated && !isAuthRoute) {
        return RoutePaths.login;
      }

      return null;
    },
    routes: [
      // ── Standalone routes (no shell) ──
      GoRoute(
        path: RoutePaths.splash,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: RoutePaths.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: RoutePaths.register,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: FadeTransition(opacity: animation, child: child),
              ),
        ),
      ),

      // ── Shell with bottom navigation ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                pageBuilder: (_, state) =>
                    const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.assistant,
                pageBuilder: (_, state) =>
                    const NoTransitionPage(child: AssistantScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.planner,
                pageBuilder: (_, state) =>
                    const NoTransitionPage(child: PlannerScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.activity,
                pageBuilder: (_, state) =>
                    const NoTransitionPage(child: ActivityScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                pageBuilder: (_, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),

      // ── Profile sub-pages (standalone, pushed above shell) ──
      GoRoute(
        path: RoutePaths.editProfile,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: RoutePaths.settings,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AccountSettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: RoutePaths.changePassword,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChangePasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: FadeTransition(opacity: animation, child: child),
              ),
        ),
      ),
    ],
  );
});
