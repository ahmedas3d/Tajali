import 'package:hive_flutter/hive_flutter.dart';
import '../models/ayah_bookmark.dart';

class AyahBookmarkService {
  static const boxName = 'ayahBookmarksBox';

  Box<AyahBookmark> get _box => Hive.box<AyahBookmark>(boxName);

  List<AyahBookmark> loadAll() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool isBookmarked(int surahNumber, int ayahNumberInSurah) {
    return _box.values.any(
      (b) =>
          b.surahNumber == surahNumber &&
          b.ayahNumberInSurah == ayahNumberInSurah,
    );
  }

  Future<void> toggle(AyahBookmark bookmark) async {
    final existing = _box.values.firstWhere(
      (b) =>
          b.surahNumber == bookmark.surahNumber &&
          b.ayahNumberInSurah == bookmark.ayahNumberInSurah,
      orElse: () => AyahBookmark(
        surahNumber: -1,
        ayahNumberInSurah: -1,
        surahName: '',
        ayahText: '',
        createdAt: DateTime.now(),
      ),
    );

    if (existing.surahNumber != -1) {
      // Remove: find key and delete
      final key = _box.keys.firstWhere(
        (k) {
          final v = _box.get(k);
          return v != null &&
              v.surahNumber == bookmark.surahNumber &&
              v.ayahNumberInSurah == bookmark.ayahNumberInSurah;
        },
        orElse: () => null,
      );
      if (key != null) await _box.delete(key);
    } else {
      await _box.add(bookmark);
    }
  }
}
