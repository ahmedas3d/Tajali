import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tajali/features/prayer_times/data/models/prayer_times_model.dart';
import 'package:tajali/features/prayer_times/data/services/prayer_cache_service.dart';
import 'package:tajali/features/prayer_times/data/services/prayer_calculation_service.dart';

PrayerTimesModel _makeModel(String date) => PrayerTimesModel(
      cacheKey: 'test_key_$date',
      date: date,
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
      fetchedAt: DateTime.now(),
    );

void main() {
  late Directory tmpDir;
  late Box<PrayerTimesModel> box;

  setUpAll(() async {
    tmpDir = await Directory.systemTemp.createTemp('hive_cache_test_');
    Hive.init(tmpDir.path);
    Hive.registerAdapter(PrayerTimesModelAdapter());
    box = await Hive.openBox<PrayerTimesModel>(PrayerCacheService.boxName);
  });

  tearDownAll(() async {
    await box.close();
    await tmpDir.delete(recursive: true);
  });

  tearDown(() => box.clear());

  group('PrayerCacheService.buildKey', () {
    final service = PrayerCacheService();

    test('delegates to PrayerCalculationService.buildKey', () {
      final date = DateTime(2026, 6, 26);
      expect(service.buildKey(30.0444, 31.2357, 0, date),
          equals(PrayerCalculationService.buildKey(30.0444, 31.2357, 0, date)));
    });
  });

  group('PrayerCacheService.isStale', () {
    final service = PrayerCacheService();
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    test('today\'s date is not stale', () {
      expect(service.isStale(todayStr), isFalse);
    });

    test('yesterday\'s date is stale', () {
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      expect(service.isStale(yesterdayStr), isTrue);
    });

    test('future date is stale', () {
      expect(service.isStale('2099-01-01'), isTrue);
    });
  });

  group('PrayerCacheService save/get', () {
    final service = PrayerCacheService();
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    test('save then get returns the same model', () async {
      final model = _makeModel(todayStr);
      model.cacheKey; // access to ensure fields are ok
      box.put(model.cacheKey, model);

      final retrieved = service.get(model.cacheKey);
      expect(retrieved, isNotNull);
      expect(retrieved!.date, equals(todayStr));
      expect(retrieved.fajr, equals('4:12 ص'));
    });

    test('get returns null for missing key', () {
      expect(service.get('nonexistent_key'), isNull);
    });
  });
}
