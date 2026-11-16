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

  testWidgets('Splash navigates to onboarding after delay', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text(AppStrings.skip), findsOneWidget);
    expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);
  });

  testWidgets('Onboarding skip navigates to dashboard', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.tap(find.text(AppStrings.skip));
    await tester.pumpAndSettle();

    // Dashboard greeting should be visible.
    expect(find.textContaining('👋'), findsOneWidget);
    // Bottom navigation should be visible.
    expect(find.text(AppStrings.home), findsOneWidget);
    expect(find.text(AppStrings.assistant), findsWidgets);
    expect(find.text(AppStrings.planner), findsWidgets);
  });

  testWidgets('Bottom navigation switches tabs', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Skip to dashboard.
    await tester.tap(find.text(AppStrings.skip));
    await tester.pumpAndSettle();

    // Tap "Profile" tab.
    await tester.tap(find.text(AppStrings.profile));
    await tester.pumpAndSettle();

    // Profile placeholder content should appear.
    expect(find.text('User'), findsOneWidget);

    // Tap back to "Home" tab.
    await tester.tap(find.text(AppStrings.home));
    await tester.pumpAndSettle();

    expect(find.textContaining('👋'), findsOneWidget);
  });

  testWidgets('Dashboard shows all key sections', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.tap(find.text(AppStrings.skip));
    await tester.pumpAndSettle();

    // AI Assistant card.
    expect(find.text(AppStrings.askLifePilot), findsOneWidget);

    // Hero title.
    expect(find.text(AppStrings.heroTitle), findsOneWidget);
  });
}
