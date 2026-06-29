import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/features/qibla/data/models/qibla_model.dart';
import 'package:tajali/features/qibla/data/services/qibla_service.dart';

void main() {
  // ── Haversine formula ────────────────────────────────────────────────────────

  group('haversineKm', () {
    const cairoLat = 30.0616, cairoLon = 31.2497;
    const meccaLat = 21.3891, meccaLon = 39.8579;
    // Giza pyramid (~6 km from Cairo center — within 50 km cache threshold)
    const gizaLat = 29.9792, gizaLon = 31.1342;
    const londonLat = 51.5074, londonLon = -0.1278;

    test('Cairo to Mecca is approximately 1292 km', () {
      final d = haversineKm(cairoLat, cairoLon, meccaLat, meccaLon);
      expect(d, closeTo(1292, 15));
    });

    test('Cairo to Giza is less than 50 km (cache-hit branch)', () {
      final d = haversineKm(cairoLat, cairoLon, gizaLat, gizaLon);
      expect(d, lessThan(50));
    });

    test('Cairo to London is greater than 50 km (cache-miss branch)', () {
      final d = haversineKm(cairoLat, cairoLon, londonLat, londonLon);
      expect(d, greaterThan(50));
    });

    test('same point returns 0', () {
      expect(haversineKm(30.0, 31.0, 30.0, 31.0), closeTo(0, 0.001));
    });
  });

  // ── Cardinal direction ───────────────────────────────────────────────────────

  group('cardinalFromDegrees', () {
    test('136° → SE', () => expect(cardinalFromDegrees(136.0), 'SE'));
    test('0° → N', () => expect(cardinalFromDegrees(0.0), 'N'));
    test('359.9° → N', () => expect(cardinalFromDegrees(359.9), 'N'));
    test('45° → NE', () => expect(cardinalFromDegrees(45.0), 'NE'));
    test('90° → E', () => expect(cardinalFromDegrees(90.0), 'E'));
    test('180° → S', () => expect(cardinalFromDegrees(180.0), 'S'));
    test('270° → W', () => expect(cardinalFromDegrees(270.0), 'W'));
    test('315° → NW', () => expect(cardinalFromDegrees(315.0), 'NW'));
    test('360° wraps to N', () => expect(cardinalFromDegrees(360.0), 'N'));
    test('negative wraps correctly', () => expect(cardinalFromDegrees(-45.0), 'NW'));
  });

  // ── AccuracyLevel mapping ────────────────────────────────────────────────────
  // NOTE: Platform.isIOS is always false in test environment (host = macOS/Linux).
  // Tests below validate the Android branch (default when not iOS).

  group('accuracyFromSensor (Android branch in test env)', () {
    test('null → low', () => expect(accuracyFromSensor(null), AccuracyLevel.low));
    test('-1 → low', () => expect(accuracyFromSensor(-1), AccuracyLevel.low));
    test('0 → low', () => expect(accuracyFromSensor(0), AccuracyLevel.low));
    test('1 → low', () => expect(accuracyFromSensor(1), AccuracyLevel.low));
    test('2 → medium', () => expect(accuracyFromSensor(2), AccuracyLevel.medium));
    test('3 → high', () => expect(accuracyFromSensor(3), AccuracyLevel.high));
    test('4 → high (clamped)', () => expect(accuracyFromSensor(4), AccuracyLevel.high));
  });
}
