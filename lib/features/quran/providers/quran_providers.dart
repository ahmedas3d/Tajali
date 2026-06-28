import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/surah_model.dart';
import '../data/services/quran_service.dart';
import '../data/services/bookmark_service.dart';

// ── Value Objects ────────────────────────────────────────────────────────────

class LastReadPosition {
  const LastReadPosition({
    required this.surahNumber,
    required this.ayahNumber,
    this.scrollOffset,
  });
  final int surahNumber;
  final int ayahNumber;
  final double? scrollOffset;
}

// ── Diacritic Normalisation ──────────────────────────────────────────────────

// Returns true for Arabic diacritical marks that should be stripped.
// U+0610–U+061A: Arabic extended signs (not letters).
// U+064B–U+065F: tashkeel (fatha, damma, kasra, shadda, sukun …).
// Base Arabic letters (U+0621–U+063A, U+0641–U+064A) are outside both ranges.
bool _isDiacritic(int cp) =>
    (cp >= 0x0610 && cp <= 0x061A) || (cp >= 0x064B && cp <= 0x065F);

// Alef variants → plain alef (U+0627):
//   U+0671 alef wasla, U+0623 alef+hamza above, U+0625 alef+hamza below,
//   U+0622 alef+madda above.
int _normaliseAlef(int cp) =>
    (cp == 0x0671 || cp == 0x0623 || cp == 0x0625 || cp == 0x0622)
        ? 0x0627
        : cp;

String normaliseArabic(String s) {
  final buf = StringBuffer();
  for (final cp in s.runes) {
    if (!_isDiacritic(cp)) buf.writeCharCode(_normaliseAlef(cp));
  }
  return buf.toString();
}

// ── Singleton Services ───────────────────────────────────────────────────────

final _quranService = QuranService();
final _bookmarkService = BookmarkService();

// ── Surah List ───────────────────────────────────────────────────────────────

final surahListProvider = FutureProvider<List<SurahModel>>((ref) async {
  return _quranService.getSurahs();
});

// ── Search ───────────────────────────────────────────────────────────────────

final quranSearchProvider = StateProvider<String>((ref) => '');

final filteredSurahsProvider = Provider<List<SurahModel>>((ref) {
  final query = ref.watch(quranSearchProvider);
  final surahs = ref.watch(surahListProvider).valueOrNull ?? [];

  if (query.isEmpty) return surahs;

  final normQuery = normaliseArabic(query);
  final lowerQuery = query.toLowerCase();

  return surahs.where((s) {
    return normaliseArabic(s.name).contains(normQuery) ||
        s.englishName.toLowerCase().contains(lowerQuery);
  }).toList();
});

// ── Tab ──────────────────────────────────────────────────────────────────────

// 0 = السور, 1 = الأجزاء, 2 = المفضلة
final quranTabProvider = StateProvider<int>((ref) => 0);

// ── Bookmarks ────────────────────────────────────────────────────────────────

class BookmarksNotifier extends StateNotifier<Set<int>> {
  BookmarksNotifier(this._service) : super({}) {
    state = _service.loadBookmarks();
  }

  final BookmarkService _service;

  void toggle(int surahNumber) {
    final updated = Set<int>.from(state);
    if (updated.contains(surahNumber)) {
      updated.remove(surahNumber);
    } else {
      updated.add(surahNumber);
    }
    state = updated;
    _service.saveBookmarks(updated);
  }
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, Set<int>>((ref) {
  return BookmarksNotifier(_bookmarkService);
});

final bookmarkedSurahsProvider = Provider<List<SurahModel>>((ref) {
  final bookmarks = ref.watch(bookmarksProvider);
  final surahs = ref.watch(surahListProvider).valueOrNull ?? [];
  return surahs.where((s) => bookmarks.contains(s.number)).toList()
    ..sort((a, b) => a.number.compareTo(b.number));
});

// ── Last Read ─────────────────────────────────────────────────────────────────

const _kLastReadSurah = 'quran_last_read_surah';
const _kLastReadAyah = 'quran_last_read_ayah';
const _kLastReadOffset = 'quran_last_read_offset';

Future<void> writeLastRead(
  int surahNumber,
  int ayahNumber, {
  double? scrollOffset,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_kLastReadSurah, surahNumber);
  await prefs.setInt(_kLastReadAyah, ayahNumber);
  if (scrollOffset != null) {
    await prefs.setDouble(_kLastReadOffset, scrollOffset);
  }
}

final lastReadProvider = FutureProvider<LastReadPosition?>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(_kLastReadSurah);
    final ayah = prefs.getInt(_kLastReadAyah);
    if (surah == null || ayah == null || surah <= 0 || ayah <= 0) return null;
    final offset = prefs.getDouble(_kLastReadOffset);
    return LastReadPosition(
      surahNumber: surah,
      ayahNumber: ayah,
      scrollOffset: offset,
    );
  } catch (_) {
    return null;
  }
});
