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
  });
  final int surahNumber;
  final int ayahNumber;
}

// ── Diacritic Normalisation ──────────────────────────────────────────────

// U+0610–U+061A: Arabic extended signs; U+064B–U+065F: tashkeel diacritics.
// These two ranges deliberately skip U+0621–U+064A (Arabic base letters).
final _diacriticRe = RegExp('[ؐ-ًؚ-ٟ]');
// Alef wasla (U+0671) and hamza-bearing alefs → plain alef (U+0627)
final _alefRe = RegExp('[ٱأإآ]');

String normaliseArabic(String s) =>
    s.replaceAll(_diacriticRe, '').replaceAll(_alefRe, 'ا');

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

// ── Last Read (read-only in Phase 2) ─────────────────────────────────────────

const _kLastReadSurah = 'quran_last_read_surah';
const _kLastReadAyah = 'quran_last_read_ayah';

final lastReadProvider = FutureProvider<LastReadPosition?>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(_kLastReadSurah);
    final ayah = prefs.getInt(_kLastReadAyah);
    if (surah == null || ayah == null || surah <= 0 || ayah <= 0) return null;
    return LastReadPosition(surahNumber: surah, ayahNumber: ayah);
  } catch (_) {
    return null;
  }
});
