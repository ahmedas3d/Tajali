import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/features/quran/providers/quran_providers.dart';

void main() {
  group('normaliseArabic', () {
    test('strips common tashkeel from Arabic text', () {
      // Name with tashkeel from the API: "سُورَةُ ٱلْفَاتِحَةِ"
      const withTashkeel = 'سُورَةُ ٱلْفَاتِحَةِ';
      final result = normaliseArabic(withTashkeel);
      expect(result.contains('ُ'), isFalse);
      expect(result.contains('َ'), isFalse);
      expect(result.contains('ِ'), isFalse);
    });

    test('preserves base Arabic letters after stripping diacritics', () {
      const withTashkeel = 'سُورَةُ';
      final result = normaliseArabic(withTashkeel);
      // Base letters should remain
      expect(result, contains('س'));
      expect(result, contains('و'));
      expect(result, contains('ر'));
      expect(result, contains('ة'));
    });

    test('returns empty string unchanged', () {
      expect(normaliseArabic(''), isEmpty);
    });

    test('leaves ASCII text unchanged', () {
      expect(normaliseArabic('Al-Fatiha'), equals('Al-Fatiha'));
    });

    test('normalised query matches normalised surah name', () {
      // User types "البقرة" without tashkeel
      const query = 'البقرة';
      // API returns "سُورَةُ ٱلْبَقَرَةِ" with tashkeel
      const apiName = 'سُورَةُ ٱلْبَقَرَةِ';

      final normQuery = normaliseArabic(query);
      final normName = normaliseArabic(apiName);

      expect(normName.contains(normQuery), isTrue);
    });

    test('normalised query matches across different tashkeel variants', () {
      const query = 'الفاتحة';
      const apiName = 'سُورَةُ ٱلْفَاتِحَةِ';

      final normQuery = normaliseArabic(query);
      final normName = normaliseArabic(apiName);

      expect(normName.contains(normQuery), isTrue);
    });
  });
}
