# Research: Quran Surah List (قائمة السور)

**Phase**: 0 — Outline & Research  
**Date**: 2026-06-26  
**Spec**: [spec.md](spec.md)

---

## Decision 1 — Surah Metadata Source

**Decision**: Fetch all surah metadata from AlQuran Cloud API (`GET https://api.alquran.cloud/v1/surah`) in a single call on first launch, then cache permanently in Hive. No further network calls for surah list data.

**Rationale**: The endpoint returns all 114 surahs in one response (~8 KB JSON), requires no API key, has no rate limit for this lightweight call, and the data is immutable — surah names and metadata do not change. One call + permanent Hive cache achieves both the 2-second load target (SC-001) and full offline support (SC-005). The same API is already used by Phase 1 (Hijri endpoint), so `dio` is already wired up.

**API response shape** (relevant fields):
```json
{
  "code": 200,
  "data": [
    {
      "number": 1,
      "name": "سُورَةُ ٱلْفَاتِحَةِ",
      "englishName": "Al-Faatiha",
      "englishNameTranslation": "The Opener",
      "numberOfAyahs": 7,
      "revelationType": "Meccan"
    }
  ]
}
```

**Fields used**: `number`, `name`, `englishName`, `numberOfAyahs`, `revelationType`  
**Field ignored**: `englishNameTranslation` (not in spec)

**Alternatives considered**:
- **Bundle surah list as a Dart constant / JSON asset**: Eliminates network dependency entirely. Rejected — adds ~10 KB to app bundle; API data is the same and more maintainable. Can be revisited if offline-first becomes a hard requirement.
- **Fetch lazily per surah**: N+1 calls for 114 surahs. Rejected — unnecessary latency, incompatible with the list-first design.

---

## Decision 2 — Hive Model for SurahModel

**Decision**: `SurahModel` is a `@HiveType(typeId: 12)` annotated class. Each surah is stored in `surahListBox` under key `"surah_{number}"` (e.g., `"surah_1"` through `"surah_114"`). Cache completeness is determined by `surahListBox.length == 114`.

**Rationale**: Hive's typed adapter provides strongly-typed reads with minimal boilerplate. Keying by surah number allows O(1) lookup by surah number (needed by `lastReadProvider` to resolve the surah name for the banner without loading the full list). TypeID `12` is the next available after Phase 1's `10` (PrayerTimesModel) and `11` (HijriDateModel).

**Alternatives considered**:
- **Store as single JSON string under one key**: Simpler (no codegen), but the entire list must be deserialised every read. Rejected — premature pessimisation for a permanent cache.
- **Use Isar instead of Hive**: Better query support, but Isar is not in the project and adds a significant dependency. Rejected.

---

## Decision 3 — Bookmarks Storage

**Decision**: Store bookmarks as a native `List<int>` (surah numbers) in Hive under key `"bookmarks"` in `bookmarksBox`. No custom type adapter. In-memory representation is `Set<int>` for O(1) contains checks.

**Rationale**: Hive stores `List<int>` natively without codegen. The `BookmarksNotifier` (a Riverpod `StateNotifier`) holds the set in memory, converts to list for persistence, and converts back to set on initialisation. This is the simplest correct implementation.

**Alternatives considered**:
- **SharedPreferences with comma-joined string**: SharedPreferences is not designed for list data; no type safety. Rejected.
- **Separate Hive object per bookmark**: Overkill for a `Set<int>`. Rejected.

---

## Decision 4 — Diacritic Normalisation for Search

**Decision**: Strip Arabic diacritics (tashkeel) from both the user's search query and the stored Arabic name using a single `RegExp` replacement against the Unicode range `[ؐ-ًؚ-ٟ]` before string comparison. English search is case-folded with `toLowerCase()`.

**Rationale**: The spec (FR-005) requires that `"البَقَرَة"` and `"البقرة"` return identical search results. Arabic keyboard input on iOS and Android typically omits tashkeel, but the AlQuran Cloud API returns names with tashkeel (e.g., `"سُورَةُ ٱلْفَاتِحَةِ"`). Stripping both sides before comparison is the standard approach, requiring no external package.

**Unicode range**:
```dart
static final _diacritics = RegExp(r'[ؐ-ًؚ-ٰٟۖ-ۜ۟-۪ۤۧۨ-ۭ]');
static String normalise(String s) => s.replaceAll(_diacritics, '');
```

**Alternatives considered**:
- **`dartz` or `characters` package utilities**: No standard utility covers Arabic diacritic stripping. Both packages are overkill. Rejected.
- **Server-side search**: Adds network latency per keystroke for 114 static records. Rejected.

---

## Decision 5 — Sticky Juz Headers Implementation

**Decision**: Use a `CustomScrollView` with alternating `SliverPersistentHeader(pinned: true)` (Juz header) and `SliverList` (surah cards within that Juz) — 30 pairs, one per Juz. No additional package required.

**Rationale**: Flutter's `SliverPersistentHeader` with `pinned: true` is the canonical way to implement sticky section headers. With 30 Juz, creating 60 slivers (30 headers + 30 lists) is well within Flutter's compositing budget. Total surah cards is 114, so performance is not a concern.

**Juz surah membership** (static `Map<int, int>` mapping `surahNumber → juzNumber`) is derived from the standard Islamic Quran division table, hard-coded in `lib/core/constants/juz_data.dart` as a Dart const.

**Alternatives considered**:
- **`sticky_headers` package**: Would work but adds a dependency for something achievable natively. Rejected.
- **`grouped_list` package**: Simpler API but less control over pinning behaviour. Rejected — native `SliverPersistentHeader` is sufficient.

---

## Decision 6 — Last Read Position Ownership

**Decision**: Phase 2 reads `quran_last_read_surah` and `quran_last_read_ayah` from SharedPreferences but never writes them. `lastReadProvider` returns `null` if either key is absent. The `LastReadBanner` widget renders a zero-height `SizedBox.shrink()` when `lastReadProvider` is null. Phase 3 (Quran reader) writes these keys after each scroll position update.

**Rationale**: This maintains a clean separation of concerns — the list screen is a consumer of reading state, not a producer. The banner is fully built and reactive in Phase 2 so it activates automatically the moment Phase 3 writes a position, with zero changes required on the list screen.

**SharedPreferences keys (Phase 2 reads, Phase 3 writes)**:
```
quran_last_read_surah  (int)  — surah number (1–114)
quran_last_read_ayah   (int)  — ayah number (1–N)
```

---

## Decision 7 — SurahStubScreen Route

**Decision**: `SurahStubScreen` is a `StatelessWidget` that accepts a `SurahModel` parameter. Navigation is via `Navigator.push(context, MaterialPageRoute(builder: (_) => SurahStubScreen(surah: surah)))`. The route does not use named routes to keep Phase 2 self-contained; Phase 3 will replace the builder target only.

**Rationale**: Named routes would require registering a route in `app/routes.dart`; since the stub is a Phase 2-only placeholder, a simple `MaterialPageRoute` keeps the change localised to the `QuranScreen` widget. Phase 3 will modify only the `builder` lambda (or the `SurahStubScreen` body itself) — not the call site.

---

## Resolved Unknowns

| Unknown | Resolution |
|---|---|
| Surah data source | AlQuran Cloud `/v1/surah` — one call, permanent Hive cache |
| Hive type ID for SurahModel | `typeId: 12` (IDs 10, 11 used by Phase 1) |
| Bookmark storage | Native `List<int>` in Hive `bookmarksBox`, key `"bookmarks"` |
| Diacritic normalisation | Unicode range RegExp, applied in `filteredSurahsProvider` |
| Sticky Juz headers | `SliverPersistentHeader(pinned: true)` + `SliverList` pairs |
| Last read write ownership | Phase 3 writes; Phase 2 reads only; banner hidden in Phase 2 |
| Surah tap destination | `SurahStubScreen(surah: surah)` via `MaterialPageRoute` |
| New dependencies required | None — all packages already in `pubspec.yaml` |
