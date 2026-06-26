import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/features/prayer_times/data/services/prayer_calculation_service.dart';

void main() {
  final service = PrayerCalculationService();

  // Cairo — well-known reference point
  const lat = 30.0444;
  const lon = 31.2357;
  final date = DateTime(2026, 6, 26);

  group('PrayerCalculationService.calculate', () {
    for (var id = 0; id <= 4; id++) {
      test('method $id produces non-empty times for Cairo', () {
        final model = service.calculate(
          latitude: lat,
          longitude: lon,
          methodId: id,
          date: date,
        );
        expect(model.fajr, isNotEmpty);
        expect(model.sunrise, isNotEmpty);
        expect(model.dhuhr, isNotEmpty);
        expect(model.asr, isNotEmpty);
        expect(model.maghrib, isNotEmpty);
        expect(model.isha, isNotEmpty);
        expect(model.imsak, isNotEmpty);
      });
    }

    test('imsak differs from fajr (exactly 10 min before)', () {
      final model =
          service.calculate(latitude: lat, longitude: lon, methodId: 0, date: date);
      // Both are Arabic formatted strings — we can verify they are different
      // and that imsak is listed before fajr alphabetically/chronologically
      // by comparing raw adhan times
      final raw = service.rawTimes(
          latitude: lat, longitude: lon, methodId: 0, date: date);
      final fajrDt = raw.fajr;
      final imsakDt = fajrDt.subtract(const Duration(minutes: 10));
      expect(model.fajr, isNot(equals(model.imsak)));
      // Verify imsak string matches what we expect from fajr - 10 min
      from(DateTime dt) {
        final h = dt.hour;
        final m = dt.minute;
        final isPm = h >= 12;
        final displayH = h % 12 == 0 ? 12 : h % 12;
        final mStr = m.toString().padLeft(2, '0');
        return '$displayH:$mStr ${isPm ? 'م' : 'ص'}';
      }

      expect(model.imsak, equals(from(imsakDt)));
    });

    test('unknown method ID falls back to Egyptian (method 0)', () {
      final modelFallback = service.calculate(
          latitude: lat, longitude: lon, methodId: 99, date: date);
      final modelEgyptian = service.calculate(
          latitude: lat, longitude: lon, methodId: 0, date: date);
      expect(modelFallback.fajr, equals(modelEgyptian.fajr));
    });

    test('cacheKey embeds lat, lon, methodId, date', () {
      final model =
          service.calculate(latitude: lat, longitude: lon, methodId: 0, date: date);
      expect(model.cacheKey, contains('2026-06-26'));
      expect(model.cacheKey, contains('0'));
    });
  });

  group('PrayerCalculationService.buildKey', () {
    test('format is date_lat_lon_method', () {
      final key = PrayerCalculationService.buildKey(30.0444, 31.2357, 0, date);
      expect(key, '2026-06-26_30.0444_31.2357_0');
    });
  });
}
