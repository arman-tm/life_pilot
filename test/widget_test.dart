import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:life_pilot/app/app.dart';
import 'package:life_pilot/core/constants/app_strings.dart';

void main() {
  testWidgets('Splash screen shows app name and tagline', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LifePilotApp()),
    );

    // Initial frame — splash should be visible.
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
  });

  testWidgets('Splash navigates to onboarding after delay', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LifePilotApp()),
    );

    // Advance past splash duration + animation.
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Should now be on onboarding — look for the skip button.
    expect(find.text(AppStrings.skip), findsOneWidget);
    expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);
  });

  testWidgets('Onboarding skip navigates to dashboard', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LifePilotApp()),
    );

    // Get past splash.
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Tap skip.
    await tester.tap(find.text(AppStrings.skip));
    await tester.pumpAndSettle();

    // Should be on dashboard — greeting visible.
    expect(find.textContaining('👋'), findsOneWidget);
  });
}
