import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/features/prayer_times/data/models/hijri_date_model.dart';
import 'package:tajali/features/prayer_times/data/models/prayer_times_model.dart';
import 'package:tajali/features/prayer_times/presentation/prayer_times_screen.dart';
import 'package:tajali/features/prayer_times/providers/prayer_times_providers.dart';

final _today = () {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}();

PrayerTimesModel _model({DateTime? fetchedAt}) => PrayerTimesModel(
      cacheKey: 'test',
      date: _today,
      latitude: 30.0444,
      longitude: 31.2357,
      methodId: 0,
      fajr: '4:12 ص',
      sunrise: '5:48 ص',
      dhuhr: '12:18 م',
      asr: '3:48 م',
      maghrib: '7:12 م',
      isha: '8:48 م',
      imsak: '4:02 ص',
      fetchedAt: fetchedAt ?? DateTime.now(),
    );

final _hijri = HijriDateModel(
  gregorianDate: _today,
  day: 29,
  monthAr: 'ذو الحجة',
  year: 1447,
  readable: '29 ذو الحجة 1447',
);

const _nextPrayer = NextPrayerModel(
  name: 'maghrib',
  nameAr: 'المغرب',
  scheduledTime: '7:12 م',
  remaining: Duration(hours: 1, minutes: 5),
);

Widget buildScreen({
  AsyncValue<PrayerTimesModel>? times,
  AsyncValue<HijriDateModel>? hijri,
  AsyncValue<NextPrayerModel>? next,
}) {
  return ProviderScope(
    overrides: [
      prayerTimesProvider
          .overrideWith((_) async => (times ?? AsyncData(_model())).value!),
      hijriDateProvider
          .overrideWith((_) async => (hijri ?? AsyncData(_hijri)).value!),
      nextPrayerProvider.overrideWith(
          (_) => Stream.value((next ?? const AsyncData(_nextPrayer)).value!)),
      locationProvider.overrideWith((_) async => throw UnimplementedError()),
      manualCityProvider.overrideWith((_) => null),
      calculationMethodProvider.overrideWith((_) => 0),
    ],
    child: const MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: PrayerTimesScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('renders all 7 prayer name rows', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('الفجر'), findsOneWidget);
    expect(find.text('الشروق'), findsOneWidget);
    expect(find.text('الظهر'), findsOneWidget);
    expect(find.text('العصر'), findsOneWidget);
    expect(find.text('المغرب'), findsOneWidget);
    expect(find.text('العشاء'), findsOneWidget);
    expect(find.text('الإمساك'), findsOneWidget);
  });

  testWidgets('shows Hijri date in header', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('ذو الحجة'), findsOneWidget);
  });

  testWidgets('shows countdown banner when next prayer is available',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('بعد'), findsOneWidget);
    expect(find.textContaining('التالي'), findsOneWidget);
  });

  testWidgets('shows offline banner when fetchedAt is yesterday', (tester) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    final stale = PrayerTimesModel(
      cacheKey: 'stale',
      date: yesterdayStr,
      latitude: 30.0,
      longitude: 31.0,
      methodId: 0,
      fajr: '4:12 ص',
      sunrise: '5:48 ص',
      dhuhr: '12:18 م',
      asr: '3:48 م',
      maghrib: '7:12 م',
      isha: '8:48 م',
      imsak: '4:02 ص',
      fetchedAt: DateTime.now().subtract(const Duration(days: 1)),
    );

    await tester.pumpWidget(buildScreen(times: AsyncData(stale)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('آخر تحديث'), findsOneWidget);
  });

  testWidgets('shows loading skeleton while prayerTimesProvider is loading',
      (tester) async {
    // Completer that never completes — no pending timer unlike Future.delayed
    final neverComplete = Completer<PrayerTimesModel>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prayerTimesProvider.overrideWith((_) => neverComplete.future),
          hijriDateProvider.overrideWith((_) => Completer<HijriDateModel>().future),
          nextPrayerProvider.overrideWith((_) => const Stream.empty()),
          locationProvider.overrideWith((_) async => throw UnimplementedError()),
          manualCityProvider.overrideWith((_) => null),
          calculationMethodProvider.overrideWith((_) => 0),
        ],
        child: const MaterialApp(
          home: PrayerTimesScreen(),
        ),
      ),
    );
    await tester.pump();

    // Skeleton containers are visible while loading
    expect(find.byType(Container), findsWidgets);
    // Prayer names should NOT be visible yet
    expect(find.text('الفجر'), findsNothing);
  });
}
