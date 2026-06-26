import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tajali/features/quran/data/models/surah_model.dart';
import 'package:tajali/features/quran/data/services/quran_service.dart';

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

Map<String, dynamic> _apiPayload(int count) => {
      'code': 200,
      'status': 'OK',
      'data': List.generate(
        count,
        (i) => {
          'number': i + 1,
          'name': 'سورة ${i + 1}',
          'englishName': 'Surah-${i + 1}',
          'englishNameTranslation': 'Chapter ${i + 1}',
          'numberOfAyahs': 7 + i,
          'revelationType': i % 2 == 0 ? 'Meccan' : 'Medinan',
        },
      ),
    };

void main() {
  late Directory tmpDir;
  late Box<SurahModel> box;

  setUpAll(() async {
    tmpDir = await Directory.systemTemp.createTemp('hive_quran_test_');
    Hive.init(tmpDir.path);
    Hive.registerAdapter(SurahModelAdapter());
    box = await Hive.openBox<SurahModel>(QuranService.boxName);
  });

  tearDown(() async {
    await box.clear();
  });

  tearDownAll(() async {
    await box.close();
    await tmpDir.delete(recursive: true);
  });

  test('fetches and caches 114 surahs on first call', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeAdapter(_apiPayload(114));
    final service = QuranService(dio: dio);

    final result = await service.getSurahs();

    expect(result.length, 114);
    expect(box.length, 114);
    expect(result.first.number, 1);
    expect(result.last.number, 114);
  });

  test('returns cached surahs without network on second call', () async {
    // Pre-populate cache
    final setupDio = Dio();
    setupDio.httpClientAdapter = _FakeAdapter(_apiPayload(114));
    await QuranService(dio: setupDio).getSurahs();

    // Second call with a fake adapter that would throw if called
    final failingDio = Dio();
    failingDio.httpClientAdapter = _FakeAdapter({'code': 500});
    final service = QuranService(dio: failingDio);

    final result = await service.getSurahs();
    expect(result.length, 114);
  });

  test('parses revelationType correctly', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeAdapter(_apiPayload(114));
    final service = QuranService(dio: dio);

    final result = await service.getSurahs();
    expect(result[0].revelationType, 'Meccan');
    expect(result[0].revelationTypeAr, 'مكية');
    expect(result[1].revelationType, 'Medinan');
    expect(result[1].revelationTypeAr, 'مدنية');
  });

  test('throws QuranServiceException on network error', () async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 100),
      receiveTimeout: const Duration(milliseconds: 100),
    ));
    final service = QuranService(dio: dio);

    expect(
      () => service.getSurahs(),
      throwsA(isA<QuranServiceException>()),
    );
  });
}
