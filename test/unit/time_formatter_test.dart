import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/core/utils/helpers.dart';

void main() {
  group('TimeFormatter.toArabic12h', () {
    DateTime dt(int h, int m) => DateTime(2026, 1, 1, h, m);

    test('midnight (0:00) → 12:00 ص', () {
      expect(TimeFormatter.toArabic12h(dt(0, 0)), '12:00 ص');
    });

    test('4:02 AM → 4:02 ص', () {
      expect(TimeFormatter.toArabic12h(dt(4, 2)), '4:02 ص');
    });

    test('11:59 AM → 11:59 ص', () {
      expect(TimeFormatter.toArabic12h(dt(11, 59)), '11:59 ص');
    });

    test('noon (12:00) → 12:00 م', () {
      expect(TimeFormatter.toArabic12h(dt(12, 0)), '12:00 م');
    });

    test('1:08 PM → 1:08 م', () {
      expect(TimeFormatter.toArabic12h(dt(13, 8)), '1:08 م');
    });

    test('11:59 PM → 11:59 م', () {
      expect(TimeFormatter.toArabic12h(dt(23, 59)), '11:59 م');
    });

    test('minutes padded to two digits', () {
      expect(TimeFormatter.toArabic12h(dt(5, 7)), '5:07 ص');
    });
  });
}
