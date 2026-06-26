import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/daily_verse_model.dart';
import '../data/services/daily_verse_service.dart';

final _service = DailyVerseService();

final dailyVerseProvider = FutureProvider<DailyVerseModel>((ref) {
  return _service.getVerseOfDay();
});
