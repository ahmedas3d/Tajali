import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tajali/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:tajali/features/settings/presentation/settings_screen.dart';

Widget buildSettings({int initialMethod = 0}) {
  return ProviderScope(
    overrides: [
      calculationMethodProvider.overrideWith((ref) => initialMethod),
    ],
    child: const MaterialApp(
      home: SettingsScreen(),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('renders all 5 calculation method tiles', (tester) async {
    await tester.pumpWidget(buildSettings());
    await tester.pump();

    for (final method in CalculationMethodConfig.all) {
      expect(find.text(method.nameAr), findsOneWidget);
    }
  });

  testWidgets('currently selected method shows check icon', (tester) async {
    await tester.pumpWidget(buildSettings(initialMethod: 2));
    await tester.pump();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(4));
  });

  testWidgets('tapping a method tile updates calculationMethodProvider',
      (tester) async {
    late WidgetRef capturedRef;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calculationMethodProvider.overrideWith((ref) => 0),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            capturedRef = ref;
            return const MaterialApp(home: SettingsScreen());
          },
        ),
      ),
    );
    await tester.pump();

    // Tap the third method (id 2 — أم القرى)
    await tester.tap(find.text(CalculationMethodConfig.all[2].nameAr));
    await tester.pump();

    expect(capturedRef.read(calculationMethodProvider), 2);
  });
}
