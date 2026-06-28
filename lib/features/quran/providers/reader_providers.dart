import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/ayah_bookmark.dart';
import '../data/models/ayah_model.dart';
import '../data/services/ayah_bookmark_service.dart';
import '../data/services/quran_reader_service.dart';

// ── Singleton service instances ──────────────────────────────────────────────

final _readerService = QuranReaderService();
final _bookmarkService = AyahBookmarkService();

// ── Preferences keys ─────────────────────────────────────────────────────────

const _kReciter = 'quran_selected_reciter';
const _kFontSize = 'quran_font_size';

// ── Reciter ───────────────────────────────────────────────────────────────────

final selectedReciterProvider = StateProvider<String>((ref) => 'ar.alafasy');

Future<void> initReciterFromPrefs(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kReciter);
  if (saved != null) {
    ref.read(selectedReciterProvider.notifier).state = saved;
  }
}

Future<void> persistReciter(String identifier) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kReciter, identifier);
}

// ── Font size ─────────────────────────────────────────────────────────────────

final fontSizeProvider = StateProvider<double>((ref) => 20.0);

Future<void> initFontSizeFromPrefs(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getDouble(_kFontSize);
  if (saved != null) {
    ref.read(fontSizeProvider.notifier).state = saved;
  }
}

Future<void> persistFontSize(double size) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(_kFontSize, size);
}

// ── Surah ayahs ───────────────────────────────────────────────────────────────

typedef SurahReciterArgs = (int surahNumber, String reciterEdition);

final surahAyahsProvider =
    FutureProvider.family<List<AyahModel>, SurahReciterArgs>((ref, args) {
  final (surahNumber, reciterEdition) = args;
  return _readerService.getSurahWithAudio(surahNumber, reciterEdition);
});

// ── Ayah bookmarks ────────────────────────────────────────────────────────────

class AyahBookmarksNotifier extends StateNotifier<List<AyahBookmark>> {
  AyahBookmarksNotifier() : super(_bookmarkService.loadAll());

  AyahBookmarksNotifier.withInitial(super.initial);

  Future<void> toggle(AyahBookmark bookmark) async {
    await _bookmarkService.toggle(bookmark);
    state = _bookmarkService.loadAll();
  }

  bool isBookmarked(int surahNumber, int ayahNumberInSurah) {
    return _bookmarkService.isBookmarked(surahNumber, ayahNumberInSurah);
  }
}

final ayahBookmarksProvider =
    StateNotifierProvider<AyahBookmarksNotifier, List<AyahBookmark>>(
  (ref) => AyahBookmarksNotifier(),
);
