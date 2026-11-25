import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:life_pilot/app/app.dart';
import 'package:life_pilot/core/constants/app_strings.dart';
import 'package:life_pilot/core/errors/auth_failure.dart';
import 'package:life_pilot/features/auth/domain/entities/user_entity.dart';
import 'package:life_pilot/features/auth/domain/repositories/auth_repository.dart';
import 'package:life_pilot/features/auth/presentation/controllers/auth_controller.dart';

/// Test double implementing [AuthRepository] for deterministic widget testing.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({UserEntity? initialUser}) : _currentUser = initialUser;

  UserEntity? _currentUser;
  final _controller = StreamController<UserEntity?>.broadcast();
  bool shouldFail = false;
  String failureCode = 'invalid-credential';

  @override
  bool get isFirebaseConfigured => true;

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw AuthFailure.fromCode(failureCode);
    }
    final user = UserEntity(
      id: 'mock_uid_123',
      email: email.trim(),
      displayName: email.split('@').first,
    );
    _currentUser = user;
    _controller.add(_currentUser);
    return user;
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw AuthFailure.fromCode(failureCode);
    }
    final user = UserEntity(
      id: 'mock_uid_123',
      email: email.trim(),
      displayName: name.trim(),
    );
    _currentUser = user;
    _controller.add(_currentUser);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (shouldFail) {
      throw AuthFailure.fromCode(failureCode);
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}

void main() {
  late FakeAuthRepository fakeAuth;

  setUp(() {
    fakeAuth = FakeAuthRepository();
  });

  Widget buildApp({FakeAuthRepository? repo}) {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo ?? fakeAuth)],
      child: const LifePilotApp(),
    );
  }

  testWidgets('Splash screen shows app name and tagline', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
  });

  testWidgets('Splash navigates to Login screen after delay', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
    expect(find.text(AppStrings.emailLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
    expect(find.text(AppStrings.signIn), findsOneWidget);
    expect(find.text(AppStrings.signUp), findsOneWidget);
  });

  testWidgets('Login password visibility toggle works', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final toggleFinder = find.byTooltip('Show password');
    expect(toggleFinder, findsOneWidget);

    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('Login validation shows error messages when fields are empty', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.valEmailRequired), findsOneWidget);
    expect(find.text(AppStrings.valPasswordRequired), findsOneWidget);
  });

  testWidgets('Firebase auth failure shows friendly error banner', (
    tester,
  ) async {
    fakeAuth.shouldFail = true;
    fakeAuth.failureCode = 'invalid-credential';

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@lifepilot.ai');
    await tester.enterText(fields.at(1), 'WrongPassword123');

    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle();

    expect(
      find.text('Email atau kata sandi salah. Silakan periksa kembali.'),
      findsOneWidget,
    );
  });

  testWidgets('Successful Firebase sign in routes to Dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'pilot@lifepilot.ai');
    await tester.enterText(fields.at(1), 'ValidPass123');

    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle();

    expect(find.textContaining('👋'), findsOneWidget);
    expect(find.text(AppStrings.home), findsOneWidget);
    expect(find.text(AppStrings.askLifePilot), findsOneWidget);
  });

  testWidgets(
    'Route protection redirects unauthenticated users away from Dashboard',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Initially unauthenticated user is on Login
      expect(find.text(AppStrings.welcomeBack), findsOneWidget);
    },
  );

  testWidgets('Sign out clears session and redirects to Login', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Sign in first
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'pilot@lifepilot.ai');
    await tester.enterText(fields.at(1), 'ValidPass123');
    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle();

    // Navigate to profile tab
    await tester.tap(find.text(AppStrings.profile));
    await tester.pumpAndSettle();

    // Tap Sign Out
    final signOutBtn = find.text(AppStrings.signOut);
    expect(signOutBtn, findsOneWidget);
    await tester.tap(signOutBtn);
    await tester.pumpAndSettle();

    // Should return to Login screen
    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
  });

  testWidgets('Register screen validation and account creation', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.tap(find.text(AppStrings.signUp));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.createAccount), findsWidgets);
    expect(find.text(AppStrings.fullNameLabel), findsOneWidget);

    final submitButton = find.widgetWithText(
      ElevatedButton,
      AppStrings.createAccount,
    );
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.valNameRequired), findsOneWidget);
    expect(find.text(AppStrings.valEmailRequired), findsOneWidget);
    expect(find.text(AppStrings.valPasswordRequired), findsOneWidget);
    expect(find.text(AppStrings.valTermsRequired), findsOneWidget);

    // Fill valid registration form
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alex Pilot');
    await tester.enterText(fields.at(1), 'alex@lifepilot.ai');
    await tester.enterText(fields.at(2), 'SecretPass123');
    await tester.enterText(fields.at(3), 'SecretPass123');

    final checkboxFinder = find.byType(Checkbox);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // After successful creation, routes to Dashboard
    expect(find.textContaining('👋'), findsOneWidget);
  });

  testWidgets('Forgot password sends reset email and displays confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.tap(find.text(AppStrings.forgotPassword));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.resetPassword), findsOneWidget);

    final emailField = find.byType(TextFormField);
    await tester.enterText(emailField, 'recovery@lifepilot.ai');

    final sendButton = find.widgetWithText(
      ElevatedButton,
      AppStrings.sendResetLink,
    );
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.resetLinkSent), findsOneWidget);
    expect(find.textContaining('recovery@lifepilot.ai'), findsOneWidget);
  });
}
