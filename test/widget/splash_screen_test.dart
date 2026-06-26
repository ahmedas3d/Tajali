import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tajali/features/splash/presentation/splash_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SplashScreen shows app name تجلي', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SplashScreen())),
    );
    await tester.pump();
    expect(find.text('تجلي'), findsOneWidget);
    // Drain the 2500ms timer so no pending-timer assertion fires
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();
  });

  testWidgets('SplashScreen shows tagline', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SplashScreen())),
    );
    await tester.pump();
    expect(find.text('رفيقك الروحي اليومي'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();
  });

  testWidgets('SplashScreen navigates to OnboardingScreen for first launch',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SplashScreen())),
    );
    await tester.pump(); // process SharedPreferences microtask
    await tester.pump(const Duration(milliseconds: 2600)); // fire 2500ms timer
    await tester.pumpAndSettle(); // complete navigation
    expect(find.text('أهلاً بك في تجلي'), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to MainNavigation for returning user',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SplashScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
