import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:life_pilot/app/app.dart';
import 'package:life_pilot/core/constants/app_strings.dart';

void main() {
  Widget buildApp() => const ProviderScope(child: LifePilotApp());

  testWidgets('Splash screen shows app name and tagline', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
  });

  testWidgets('Splash navigates to Login screen after delay', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Should now be on the Login screen
    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
    expect(find.text(AppStrings.emailLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
    expect(find.text(AppStrings.rememberMe), findsOneWidget);
    expect(find.text(AppStrings.forgotPassword), findsOneWidget);
    expect(find.text(AppStrings.signIn), findsOneWidget);
    expect(find.text(AppStrings.signUp), findsOneWidget);
  });

  testWidgets('Login password visibility toggle works', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Locate the toggle icon button
    final toggleFinder = find.byTooltip('Show password');
    expect(toggleFinder, findsOneWidget);

    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('Login validation shows errors on invalid inputs', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Clear email & password fields
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.first, '');
    await tester.enterText(textFields.last, '');

    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.valEmailRequired), findsOneWidget);
    expect(find.text(AppStrings.valPasswordRequired), findsOneWidget);
  });

  testWidgets('Sign in navigates to Dashboard and tabs are functional', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Use default demo credentials and tap Sign In
    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Should now be on Dashboard
    expect(find.textContaining('👋'), findsOneWidget);
    expect(find.text(AppStrings.home), findsOneWidget);
    expect(find.text(AppStrings.askLifePilot), findsOneWidget);
    expect(find.text(AppStrings.heroTitle), findsOneWidget);

    // Switch to Profile tab
    await tester.tap(find.text(AppStrings.profile));
    await tester.pumpAndSettle();

    // Verify Sign Out button is present and tap it
    final signOutBtn = find.text(AppStrings.signOut);
    expect(signOutBtn, findsOneWidget);

    await tester.tap(signOutBtn);
    await tester.pumpAndSettle();

    // Should return to Login screen
    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
  });

  testWidgets('Navigation to Register screen and form validation', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Tap "Sign Up" from Login screen
    await tester.tap(find.text(AppStrings.signUp));
    await tester.pumpAndSettle();

    // Verify Register screen UI
    expect(find.text(AppStrings.createAccount), findsWidgets);
    expect(find.text(AppStrings.fullNameLabel), findsOneWidget);
    expect(find.text(AppStrings.confirmPasswordLabel), findsOneWidget);
    expect(find.text(AppStrings.agreeToTerms), findsOneWidget);

    // Attempt submitting without filling form
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

    // Test password mismatch
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alex Morgan');
    await tester.enterText(fields.at(1), 'alex@example.com');
    await tester.enterText(fields.at(2), 'Pass12345');
    await tester.enterText(fields.at(3), 'DifferentPass');

    // Check terms checkbox
    final checkboxFinder = find.byType(Checkbox);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.valPasswordMismatch), findsOneWidget);
  });

  testWidgets('Navigation to Forgot Password screen and reset simulation', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Tap "Forgot Password?"
    await tester.tap(find.text(AppStrings.forgotPassword));
    await tester.pumpAndSettle();

    // Verify Forgot Password screen UI
    expect(find.text(AppStrings.resetPassword), findsOneWidget);
    expect(find.text(AppStrings.sendResetLink), findsOneWidget);

    // Test empty email validation
    final sendButton = find.widgetWithText(
      ElevatedButton,
      AppStrings.sendResetLink,
    );
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.valEmailRequired), findsOneWidget);

    // Enter valid email and submit
    final emailField = find.byType(TextFormField);
    await tester.enterText(emailField, 'user@example.com');

    await tester.tap(sendButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify confirmation view
    expect(find.text(AppStrings.resetLinkSent), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsOneWidget);
    expect(find.text('DEMO SIMULATION'), findsOneWidget);
    expect(find.text(AppStrings.backToSignIn), findsOneWidget);

    // Tap Back to Sign In
    await tester.tap(
      find.widgetWithText(ElevatedButton, AppStrings.backToSignIn),
    );
    await tester.pumpAndSettle();

    // Returns to Login screen
    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
  });
}
