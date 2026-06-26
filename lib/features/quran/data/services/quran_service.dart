import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/surah_model.dart';

class QuranServiceException implements Exception {
  const QuranServiceException(this.message);
  final String message;

  @override
  String toString() => 'QuranServiceException: $message';
}

class QuranService {
  static const String boxName = 'surahListBox';
  static const String _baseUrl = 'https://api.alquran.cloud/v1/surah';
  static const int _expectedCount = 114;

  final Dio _dio;

  QuranService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Box<SurahModel> get _box => Hive.box<SurahModel>(boxName);

  Future<List<SurahModel>> getSurahs() async {
    if (_box.length == _expectedCount) {
      return List.generate(
        _expectedCount,
        (i) => _box.get('surah_${i + 1}')!,
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(_baseUrl);
      final data = response.data;

      if (data == null || data['code'] != 200) {
        throw const QuranServiceException('Invalid API response');
      }

      final list = (data['data'] as List<dynamic>)
          .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
          .toList();

      for (final surah in list) {
        await _box.put('surah_${surah.number}', surah);
      }

      return list;
    } on DioException catch (e) {
      throw QuranServiceException(e.message ?? 'Network error');
    }
  }
}
