import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hijri_date_model.dart';

class HijriApiException implements Exception {
  const HijriApiException(this.message);
  final String message;
}

class HijriDateService {
  static const _boxName = 'hijriDateBox';
  static const _baseUrl = 'https://api.aladhan.com/v1/gToH';

  final Dio _dio;

  HijriDateService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ));

  Box<HijriDateModel> get _box => Hive.box<HijriDateModel>(_boxName);

  Future<HijriDateModel> getHijriDate(DateTime date) async {
    final key = _gregKey(date);
    final cached = _box.get(key);
    if (cached != null) return cached;

    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();

    try {
      final response = await _dio.get('$_baseUrl/$dd-$mm-$yyyy');
      final hijri = response.data['data']['hijri'] as Map<String, dynamic>;

      final day = int.parse(hijri['day'].toString());
      final monthAr = hijri['month']['ar'] as String;
      final year = int.parse(hijri['year'].toString());
      final readable = '$day $monthAr $year';

      final model = HijriDateModel(
        gregorianDate: key,
        day: day,
        monthAr: monthAr,
        year: year,
        readable: readable,
      );

      await _box.put(key, model);
      return model;
    } catch (e) {
      throw HijriApiException('Failed to fetch Hijri date: $e');
    }
  }

  static String _gregKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
