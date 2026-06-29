import 'package:hive_flutter/hive_flutter.dart';
import '../models/dhikr_model.dart';

class DhikrCounterService {
  static const String boxName = 'dhikrCounterBox';

  Box<int> get _box => Hive.box<int>(boxName);

  String _today() {
    final d = DateTime.now().toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _key(String categoryId, int index) =>
      '${_today()}_${categoryId}_$index';

  int getRemaining(DhikrModel dhikr) {
    final stored = _box.get(_key(dhikr.categoryId, dhikr.index));
    return stored ?? dhikr.repeat;
  }

  Future<void> decrement(DhikrModel dhikr) async {
    final current = getRemaining(dhikr);
    if (current <= 0) return;
    await _box.put(_key(dhikr.categoryId, dhikr.index), current - 1);
  }

  bool isComplete(DhikrModel dhikr) => getRemaining(dhikr) == 0;

  bool isCategoryComplete(List<DhikrModel> dhikrList) {
    if (dhikrList.isEmpty) return false;
    return dhikrList.every(isComplete);
  }

  Future<void> clearStaleKeys() async {
    final today = _today();
    final cutoff = DateTime.now().subtract(const Duration(days: 7));

    final staleKeys = _box.keys.cast<String>().where((key) {
      final parts = key.split('_');
      if (parts.isEmpty) return false;
      final dateStr = parts.first;
      if (dateStr == today) return false;
      try {
        final date = DateTime.parse(dateStr);
        return date.isBefore(cutoff);
      } catch (_) {
        return true;
      }
    }).toList();

    for (final key in staleKeys) {
      await _box.delete(key);
    }
  }
}
