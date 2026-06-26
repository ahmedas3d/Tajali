# Implementation Plan: Quran Surah List (قائمة السور)

**Branch**: `006-quran-surah-list` | **Date**: 2026-06-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/006-quran-surah-list/spec.md`

---

## Summary

Implement the Quran Surah List screen for Tajali: replace the existing `QuranScreen` stub with a full three-tab screen (السور / الأجزاء / المفضلة) that displays all 114 surahs fetched once from AlQuran Cloud API and cached in Hive. Each surah card shows the Arabic name, English transliteration, revelation type badge, verse count, and a 🔖 bookmark toggle. The Surahs tab includes a real-time diacritic-normalised search bar. The Juz tab renders a flat list with 30 sticky section headers. The Bookmarks tab shows saved surahs (stored as a `List<int>` in Hive). A "Continue Reading" banner reads last-read position from SharedPreferences (written by Phase 3 reader — always hidden in Phase 2). Tapping any surah navigates to a minimal `SurahStubScreen` ("قريباً") wired for Phase 3 replacement. No new pub.dev dependencies required.

---

## Technical Context

**Language/Version**: Dart 3.3 / Flutter 3.x (SDK `>=3.3.0 <4.0.0`)

**Primary Dependencies** (all already in `pubspec.yaml`):
- `flutter_riverpod: ^2.5.1` — state management
- `hive_flutter: ^1.1.0` — surah list cache + bookmarks storage
- `hive_generator: ^2.0.1` + `build_runner: ^2.4.9` — Hive adapter codegen for `SurahModel`
- `shared_preferences: ^2.2.3` — last-read position (read-only in Phase 2)
- `dio: ^5.4.3` — HTTP client (already added for Phase 1 Hijri API)
- `flutter_svg: ^2.0.10+1` — SVG empty-state illustrations (if needed)

**No new dependencies required.**

**Storage**:
- Hive box `surahListBox`: stores all 114 `SurahModel` objects under individual keys `"surah_{number}"`. Populated once on first launch; no TTL (surah metadata is immutable).
- Hive box `bookmarksBox`: stores a single `List<int>` (surah numbers) under key `"bookmarks"`. Native Hive list — no custom type adapter needed.
- SharedPreferences keys (read-only in Phase 2, written by Phase 3):
  - `quran_last_read_surah` (int) — surah number of last reading position
  - `quran_last_read_ayah` (int) — ayah number of last reading position

**Testing**: `flutter_test` (built-in) — unit + widget tests

**Target Platform**: Android + iOS (portrait-only, RTL Arabic)

**Performance Goals**:
- Surah list visible within 2 seconds on first launch (SC-001) — one HTTP call caches all 114 records
- Search results within 200 ms per keystroke (SC-003) — local in-memory filter, well within budget for 114 items
- Subsequent launches: zero network calls (served from Hive cache), near-instant

**Constraints**:
- Portrait-only, RTL layout (inherited from app shell)
- Search diacritic-normalised: queries with/without tashkeel match identically
- Search bar visible on Surahs tab only — hidden when Juz or Bookmarks tab is active
- Juz view: flat scrollable list with sticky headers (no collapse/expand)
- Last read banner: always hidden in Phase 2 (no writer exists yet); fully built and reactive
- Surah tap target: `SurahStubScreen` — accepts surah number, displays Arabic name + "قريباً"
- Hive type ID: `SurahModel` uses `typeId: 12` (IDs 10 and 11 are used by Phase 1)

**Scale/Scope**: 1 expanded screen (QuranScreen), 1 new stub screen (SurahStubScreen), 7 new widget components, 1 new service (QuranService), 1 new service (BookmarkService), 6 new Riverpod providers, 1 Hive model (SurahModel typeId 12), 1 static Juz mapping constant

---

## Constitution Check

Constitution file is a blank template — no project-specific gates defined. No violations to evaluate.

---

## Project Structure

### Documentation (this feature)

```text
specs/006-quran-surah-list/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
├── contracts/
│   ├── providers.md         ← Phase 1 output
│   └── alquran_api.md       ← Phase 1 output
├── checklists/
│   └── requirements.md      ← quality checklist (all items passing)
└── tasks.md             ← Phase 2 output (/speckit-tasks — not yet created)
```

### Source Code

```text
lib/
├── app/
│   └── routes.dart                                        ← no change needed (QuranScreen already in nav)
├── features/
│   └── quran/
│       ├── data/
│       │   ├── models/
│       │   │   └── surah_model.dart                       ← NEW (Hive @HiveType(12))
│       │   └── services/
│       │       ├── quran_service.dart                     ← NEW (AlQuran Cloud API + Hive cache)
│       │       └── bookmark_service.dart                  ← NEW (Hive bookmarks List<int>)
│       ├── providers/
│       │   └── quran_providers.dart                       ← NEW (6 providers)
│       └── presentation/
│           ├── quran_screen.dart                          ← REPLACE stub
│           ├── surah_stub_screen.dart                     ← NEW (Phase 3 entry point placeholder)
│           └── widgets/
│               ├── last_read_banner.dart                  ← NEW (always hidden in Phase 2)
│               ├── quran_search_bar.dart                  ← NEW (Surahs tab only)
│               ├── surah_card.dart                        ← NEW
│               ├── surah_list_view.dart                   ← NEW (Surahs tab content)
│               ├── juz_list_view.dart                     ← NEW (sticky headers, flat list)
│               ├── bookmarks_view.dart                    ← NEW (Bookmarks tab content)
│               └── surah_skeleton_card.dart               ← NEW (shimmer placeholder)
└── core/
    └── constants/
        └── juz_data.dart                                  ← NEW (static const Map<int,int> surahToJuz)

test/
├── unit/
│   ├── quran_service_test.dart                            ← NEW
│   ├── bookmark_service_test.dart                         ← NEW
│   └── diacritic_normalisation_test.dart                  ← NEW
└── widget/
    ├── quran_screen_test.dart                             ← NEW
    ├── surah_card_test.dart                               ← NEW
    └── juz_list_view_test.dart                            ← NEW
```

**Structure Decision**: Feature-first layout matching the existing pattern (`lib/features/quran/data|providers|presentation`). The static Juz mapping lives in `lib/core/constants/` because it is immutable Islamic data shared across Phase 2 (list view) and Phase 3 (reader, Juz indicator). `SurahStubScreen` is a sibling of `QuranScreen` under `presentation/` — Phase 3 will replace its body without moving the file.

---

## Key Design Decisions

### 1. Single HTTP Call, Permanent Hive Cache

`GET /v1/surah` returns all 114 surah metadata records in one response. After the first successful call, the data is written to Hive and never fetched again (surah names and metadata are immutable). This satisfies SC-001 (< 2s on standard connection) and SC-005 (full offline access after first load).

### 2. `SurahModel` as Hive Type (typeId: 12)

`SurahModel` is annotated with `@HiveType(typeId: 12)` and stored with key `"surah_{number}"` in `surahListBox`. This allows O(1) individual lookups by surah number without deserialising the full list. The presence check (`surahListBox.length == 114`) determines cache completeness.

### 3. Bookmarks as Native `List<int>`

Bookmarks are a `List<int>` of surah numbers stored at a fixed Hive key (`"bookmarks"` in `bookmarksBox`). Hive stores primitive lists natively — no custom type adapter. The `BookmarksNotifier` holds a `Set<int>` in memory for O(1) contains checks and persists the list to Hive on every change.

### 4. Last Read Position — Read-Only in Phase 2

`LastReadPositionReader` reads `quran_last_read_surah` and `quran_last_read_ayah` from SharedPreferences. If either key is absent, `lastReadProvider` resolves to `null` and `LastReadBanner` renders a zero-height widget. Phase 3 writes these keys after each ayah scroll. No migration required — this is additive.

### 5. Diacritic Normalisation

Arabic diacritics (tashkeel: ً ٌ ٍ َ ُ ِ ّ ْ) are stripped from both the query and the stored Arabic name before comparison using a `RegExp` match against the Unicode diacritic range `[ؐ-ًؚ-ٟ]`. English transliteration search is case-folded with `toLowerCase()`. Both are applied in `filteredSurahsProvider`.

### 6. Sticky Juz Headers via `SliverList` + `SliverPersistentHeader`

The Juz tab uses a `CustomScrollView` with alternating `SliverPersistentHeader` (pinned Juz header) and `SliverList` (surah entries for that Juz) — one pair per Juz (30 pairs). This is the standard Flutter pattern for indexed lists with sticky headers and requires no additional package.

### 7. `SurahStubScreen` as Stable Route Target

`SurahStubScreen` receives a `SurahModel` and renders the surah's Arabic name centred on a deep-green background with a "قريباً — الإصدار القادم" message. The route signature (`/quran/reader/{surahNumber}`) is the same entry point Phase 3 will fill. No navigation changes needed in Phase 3.

### 8. Tab State Management

`quranTabProvider` (`StateProvider<int>`) holds the active tab index. The search bar's visibility (Surahs tab only) is derived from `ref.watch(quranTabProvider) == 0` in `QuranScreen`. This avoids stateful widget overhead and keeps the tab state accessible from any widget that needs it.

---

## Complexity Tracking

No constitution violations. No complexity justification required.
