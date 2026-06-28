import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ayah_model.dart';

class QuranReaderException implements Exception {
  const QuranReaderException(this.message);
  final String message;
  @override
  String toString() => 'QuranReaderException: $message';
}

class QuranReaderService {
  static const _baseUrl = 'https://api.alquran.cloud/v1/surah';
  static const _boxName = 'ayahTextBox';

  final Dio _dio;

  QuranReaderService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
            ));

  Box get _box => Hive.box(_boxName);

  String _cacheKey(int surahNumber) => 'surah_text_$surahNumber';

  List<AyahModel>? _fromCache(int surahNumber) {
    final raw = _box.get(_cacheKey(surahNumber));
    if (raw == null || raw is! List || raw.isEmpty) return null;
    try {
      return raw.cast<AyahModel>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _toCache(int surahNumber, List<AyahModel> ayahs) async {
    await _box.put(_cacheKey(surahNumber), ayahs);
  }

  Future<List<AyahModel>> getSurahWithAudio(
    int surahNumber,
    String reciterEdition,
  ) async {
    final cached = _fromCache(surahNumber);
    if (cached != null) {
      // Update audio URLs in-memory if the cached edition differs.
      final firstUrl = cached.first.audioUrl ?? '';
      if (firstUrl.isNotEmpty && !firstUrl.contains('/$reciterEdition/')) {
        return updateAudioUrls(surahNumber, reciterEdition, cached);
      }
      return cached;
    }

    try {
      final url = '$_baseUrl/$surahNumber/editions/quran-uthmani,$reciterEdition';
      final response = await _dio.get<Map<String, dynamic>>(url);
      final data = response.data;

      if (data == null || data['code'] != 200) {
        throw const QuranReaderException('Invalid API response');
      }

      final editions = data['data'] as List<dynamic>;
      if (editions.length < 2) {
        throw const QuranReaderException('Expected 2 editions in response');
      }

      final textAyahs = (editions[0]['ayahs'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final audioAyahs = (editions[1]['ayahs'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final ayahs = List.generate(textAyahs.length, (i) {
        final t = textAyahs[i];
        final a = audioAyahs[i];
        return AyahModel.fromTextJson(t, surahNumber)
          ..audioUrl = a['audio'] as String?;
      });

      await _toCache(surahNumber, ayahs);
      return ayahs;
    } on DioException catch (e) {
      throw QuranReaderException(e.message ?? 'Network error');
    }
  }

  Future<List<AyahModel>> updateAudioUrls(
    int surahNumber,
    String reciterEdition,
    List<AyahModel> existing,
  ) async {
    try {
      final url = '$_baseUrl/$surahNumber/$reciterEdition';
      final response = await _dio.get<Map<String, dynamic>>(url);
      final data = response.data;

      if (data == null || data['code'] != 200) return existing;

      final audioAyahs =
          (data['data']['ayahs'] as List<dynamic>).cast<Map<String, dynamic>>();

      for (var i = 0; i < existing.length && i < audioAyahs.length; i++) {
        existing[i].audioUrl = audioAyahs[i]['audio'] as String?;
      }

      await _toCache(surahNumber, existing);
      return existing;
    } catch (_) {
      return existing;
    }
  }
}
