import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_verse_model.dart';

class DailyVerseService {
  static const _baseUrl = 'https://api.alquran.cloud/v1';
  static const _edition = 'quran-uthmani';
  static const _totalAyahs = 6236;

  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 8)));

  // Picks a consistent ayah per calendar day (cycles through all 6236 ayahs).
  int _ayahForToday() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return (dayOfYear % _totalAyahs) + 1;
  }

  Future<DailyVerseModel> getVerseOfDay() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = 'daily_verse_${DateTime.now().toIso8601String().substring(0, 10)}';

    final cached = prefs.getString(todayKey);
    if (cached != null) {
      return DailyVerseModel.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
    }

    final ayah = _ayahForToday();
    final response = await _dio.get('$_baseUrl/ayah/$ayah/$_edition');
    final raw = response.data as Map<String, dynamic>;

    await prefs.setString(todayKey, jsonEncode(raw));
    return DailyVerseModel.fromJson(raw);
  }
}
