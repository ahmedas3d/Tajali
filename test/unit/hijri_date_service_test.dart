import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tajali/features/prayer_times/data/models/hijri_date_model.dart';
import 'package:tajali/features/prayer_times/data/services/hijri_date_service.dart';

// Minimal Dio adapter that returns a canned JSON payload
class _FakeAdapter implements HttpClientAdapter {
  final Map<String, dynamic> body;
  _FakeAdapter(this.body);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _successPayload({
  String day = '29',
  String monthAr = 'ذو الحجة',
  String year = '1447',
}) =>
    {
      'data': {
        'hijri': {
          'day': day,
          'month': {'ar': monthAr},
          'year': year,
        }
      }
    };

void main() {
  late Directory tmpDir;
  late Box<HijriDateModel> box;
  const boxName = 'hijriDateBox';

  setUpAll(() async {
    tmpDir = await Directory.systemTemp.createTemp('hive_hijri_test_');
    Hive.init(tmpDir.path);
    Hive.registerAdapter(HijriDateModelAdapter());
    box = await Hive.openBox<HijriDateModel>(boxName);
  });

  tearDownAll(() async {
    await box.close();
    await tmpDir.delete(recursive: true);
  });

  tearDown(() => box.clear());

  group('HijriDateService — network path', () {
    test('parses API response and returns correct HijriDateModel', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter(
        _successPayload(day: '29', monthAr: 'ذو الحجة', year: '1447'),
      );
      final service = HijriDateService(dio: dio);

      final result = await service.getHijriDate(DateTime(2026, 6, 26));

      expect(result.day, 29);
      expect(result.monthAr, 'ذو الحجة');
      expect(result.year, 1447);
      expect(result.readable, '29 ذو الحجة 1447');
    });

    test('caches result after network fetch', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter(_successPayload());
      final service = HijriDateService(dio: dio);
      final date = DateTime(2026, 6, 26);

      await service.getHijriDate(date);

      // Box should now contain the cached entry
      expect(box.length, 1);
    });
  });

  group('HijriDateService — cache path', () {
    test('cache hit skips network call', () async {
      final date = DateTime(2026, 6, 26);
      const key = '2026-06-26';

      // Pre-populate cache
      final cached = HijriDateModel(
        gregorianDate: key,
        day: 29,
        monthAr: 'ذو الحجة',
        year: 1447,
        readable: '29 ذو الحجة 1447',
      );
      await box.put(key, cached);

      // Adapter that always throws — if network is called, test fails
      final dio = Dio();
      dio.httpClientAdapter =
          _FakeAdapter({'unexpected': true}); // should never be called
      final service = HijriDateService(dio: dio);

      // We need the service to actually hit the cache. Manually verify by
      // observing box doesn't grow (it already has 1 entry) and result matches
      final result = await service.getHijriDate(date);

      expect(result.day, 29);
      expect(result.monthAr, 'ذو الحجة');
      expect(box.length, 1); // no new writes
    });
  });

  group('HijriDateService — error path', () {
    test('throws HijriApiException on network error', () async {
      final dio = Dio();
      // Adapter that throws to simulate network failure
      dio.httpClientAdapter = _ThrowingAdapter();
      final service = HijriDateService(dio: dio);

      expect(
        () => service.getHijriDate(DateTime(2026, 6, 27)),
        throwsA(isA<HijriApiException>()),
      );
    });
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    throw DioException(
        requestOptions: options, message: 'simulated network failure');
  }

  @override
  void close({bool force = false}) {}
}
