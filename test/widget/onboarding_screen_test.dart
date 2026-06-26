import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tajali/features/splash/presentation/onboarding_screen.dart';
import 'package:tajali/features/splash/providers/onboarding_providers.dart';

// Set a realistic phone viewport (360×800 logical pixels)
void _setPhoneView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _wrap({int initialPage = 0}) {
  return ProviderScope(
    overrides: [
      onboardingPageProvider.overrideWith((ref) => initialPage),
    ],
    child: const MaterialApp(home: OnboardingScreen()),
  );
}

Future<void> _pumpSlideTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Slide 1 shows welcome title and التالي button', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();
    expect(find.text('أهلاً بك في تجلي'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
  });

  testWidgets('Skip button navigates to slide 3 (permissions)', (tester) async {
    _setPhoneView(tester);
    await tester.pumpWidget(_wrap());
    await tester.pump();
    await tester.tap(find.text('تخطي'));
    await _pumpSlideTransition(tester);
    expect(find.text('نحتاج إذنك'), findsOneWidget);
  });

  testWidgets('Slide 1 shows تخطي button', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();
    expect(find.text('تخطي'), findsOneWidget);
  });

  testWidgets('السابق on slide 2 returns to slide 1', (tester) async {
    await tester.pumpWidget(_wrap(initialPage: 1));
    await tester.pump();
    expect(find.text('كل ما تحتاجه في مكان واحد'), findsOneWidget);
    await tester.tap(find.text('السابق').first);
    await _pumpSlideTransition(tester);
    expect(find.text('أهلاً بك في تجلي'), findsOneWidget);
  });

  testWidgets('السابق on slide 3 returns to slide 2', (tester) async {
    _setPhoneView(tester);
    await tester.pumpWidget(_wrap(initialPage: 2));
    await tester.pump();
    expect(find.text('نحتاج إذنك'), findsOneWidget);
    await tester.tap(find.text('السابق').first);
    await _pumpSlideTransition(tester);
    expect(find.text('كل ما تحتاجه في مكان واحد'), findsOneWidget);
  });
}
