import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/features/prayer_times/presentation/widgets/prayer_card_widget.dart';
import 'package:tajali/features/prayer_times/providers/prayer_times_providers.dart';

void main() {
  testWidgets('shows prayer name, time, and countdown when data is available',
      (tester) async {
    const model = NextPrayerModel(
      name: 'maghrib',
      nameAr: 'المغرب',
      scheduledTime: '7:12 م',
      remaining: Duration(hours: 1, minutes: 23),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nextPrayerProvider.overrideWith((_) => Stream.value(model)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: PrayerCardWidget()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('المغرب'), findsOneWidget);
    expect(find.text('7:12 م'), findsOneWidget);
    expect(find.textContaining('بعد'), findsOneWidget);
  });

  testWidgets('shows "—" placeholders on error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nextPrayerProvider.overrideWith(
              (_) => Stream.error(Exception('error'), StackTrace.empty)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: PrayerCardWidget()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('—'), findsWidgets);
  });
}
