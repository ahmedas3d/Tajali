# Data Model: Quran Surah List (قائمة السور)

**Phase**: 1 — Design & Contracts  
**Date**: 2026-06-26  
**Research**: [research.md](research.md)

---

## Entities

### SurahModel

Represents a chapter (surah) of the Holy Quran. Fetched from AlQuran Cloud API and persisted to Hive. Immutable after first write.

| Field | Type | Source | Description |
|---|---|---|---|
| `number` | `int` | API `number` | Canonical surah number (1–114). Hive box key: `"surah_{number}"`. |
| `name` | `String` | API `name` | Full Arabic name with tashkeel, e.g. `"سُورَةُ ٱلْفَاتِحَةِ"` |
| `englishName` | `String` | API `englishName` | English transliteration, e.g. `"Al-Faatiha"` |
| `revelationType` | `String` | API `revelationType` | `"Meccan"` or `"Medinan"` — mapped to Arabic badge: `"مكية"` / `"مدنية"` |
| `numberOfAyahs` | `int` | API `numberOfAyahs` | Total verse count in the surah |

**Hive box name**: `surahListBox`  
**Hive type ID**: `12`  
**Key per record**: `"surah_{number}"` (e.g. `"surah_1"`, `"surah_114"`)  
**Cache completeness signal**: `surahListBox.length == 114`

**Validation rules**:
- `number` ∈ [1, 114]
- `name` non-empty, contains Arabic characters
- `englishName` non-empty, ASCII
- `revelationType` ∈ `{"Meccan", "Medinan"}`
- `numberOfAyahs` > 0

**Display mapping**:
```
revelationType "Meccan"  → badge label "مكية"
revelationType "Medinan" → badge label "مدنية"
```

---

### LastReadPosition

Represents the most recent position the user reached in the Quran reader. **Read-only in Phase 2.** Written exclusively by Phase 3 (Quran reader). Not a Hive entity — stored as two integer values in SharedPreferences.

| Field | SharedPreferences Key | Type | Description |
|---|---|---|---|
| `surahNumber` | `quran_last_read_surah` | `int` | Surah number (1–114) of the last reading position |
| `ayahNumber` | `quran_last_read_ayah` | `int` | Ayah number within that surah |

**Presence check**: Both keys must be present and > 0 for a valid last-read position to exist. If either is absent, `lastReadProvider` resolves to `null`.

**Phase 2 behaviour**: `lastReadProvider` reads these keys. `LastReadBanner` renders `SizedBox.shrink()` when value is `null`.  
**Phase 3 behaviour**: Quran reader writes both keys on each scroll position change.

---

### BookmarkStore

Represents the set of surahs the user has saved for quick access. Stored as a native `List<int>` in Hive (no custom type adapter required).

| Aspect | Value |
|---|---|
| **Hive box name** | `bookmarksBox` |
| **Hive key** | `"bookmarks"` |
| **Stored type** | `List<int>` (surah numbers) |
| **In-memory type** | `Set<int>` (in `BookmarksNotifier`) |
| **Order** | No intrinsic order in storage; displayed in canonical surah order (ascending by surah number) |

**Write contract**: `BookmarksNotifier.toggle(int surahNumber)` — adds if absent, removes if present. Immediately persists to Hive.  
**Read contract**: On app start, `BookmarksNotifier` reads the list from Hive, converts to `Set<int>`, and holds it in state.

---

### JuzMapping (Static Constant)

Not persisted. A compile-time constant mapping each surah number to its primary Juz (the Juz in which the surah begins).

```
Location: lib/core/constants/juz_data.dart
Type:     const Map<int, int>   // surahNumber → juzNumber
```

**Selected entries** (full 114-entry map in source):

| Surah | Juz | Surah | Juz |
|---|---|---|---|
| 1 | 1 | 36 | 22 |
| 2 | 1 | 37 | 23 |
| 9 | 10 | 67 | 29 |
| 10 | 11 | 78 | 30 |
| … | … | 114 | 30 |

**Inversion** (`juzToSurahs`): Derived at runtime from `JuzMapping` — groups surah numbers by Juz for the Juz tab list view. Not stored separately.

---

## State Transitions

### Surah List Load Flow

```
App opens / QuranScreen mounted
            │
            ▼
    surahListBox.length == 114?
            │
    Yes ────┼──── Serve from Hive → render list (near-instant)
            │
    No ─────┼──── GET /v1/surah (AlQuran Cloud)
                        │
                 Success ─┼─── Write 114 SurahModel entries to Hive
                        │              │
                 Error   │         Render list
                   │     │
                   ▼     └──── (cache incomplete; retry on next launch)
             Show error state + retry button
```

### Bookmark Toggle Flow

```
User taps 🔖 icon on SurahCard
            │
            ▼
  surahNumber ∈ bookmarksSet?
            │
    Yes ────┼──── Remove from Set → persist List<int> to Hive → icon = outlined
            │
    No ─────┼──── Add to Set    → persist List<int> to Hive → icon = filled gold
```

### Tab Switch + Search Visibility

```
User taps tab
            │
            ▼
   quranTabProvider updated (0 | 1 | 2)
            │
            ├── tab == 0 (السور)  → show QuranSearchBar + SurahListView
            ├── tab == 1 (الأجزاء) → hide QuranSearchBar + show JuzListView
            └── tab == 2 (المفضلة) → hide QuranSearchBar + show BookmarksView
```

### Search Filter Flow

```
User types in QuranSearchBar
            │
            ▼
  quranSearchProvider.state updated
            │
            ▼
  filteredSurahsProvider recomputes:
    query = normalise(quranSearchProvider.state)
    return surahList.where(
      s => normalise(s.name).contains(query) ||
           s.englishName.toLowerCase().contains(rawQuery.toLowerCase())
    )
            │
            ▼
    SurahListView rebuilds with filtered list
    (empty → EmptySearchState widget)
```

---

## Provider Dependency Graph

```
                  surahListProvider (FutureProvider)
                 ┌────────┴───────────────┐
                 │                        │
     filteredSurahsProvider        bookmarkedSurahsProvider
     (depends on search +          (depends on bookmarks +
      surahListProvider)            surahListProvider)
                 │
       quranSearchProvider
       (StateProvider<String>)

     bookmarksProvider
     (StateNotifierProvider<BookmarksNotifier, Set<int>>)

     lastReadProvider
     (FutureProvider<LastReadPosition?>)

     quranTabProvider
     (StateProvider<int>)
```

---

## Hive Adapter Notes

`SurahModel` requires a Hive type adapter generated via `build_runner`. The project already declares `hive_generator` and `build_runner` in `dev_dependencies`.

**Generate command** (run from project root after annotating `SurahModel`):
```
flutter pub run build_runner build --delete-conflicting-outputs
```

**Generated file**: `lib/features/quran/data/models/surah_model.g.dart`

`BookmarkStore` uses a native `List<int>` — **no code generation required**.
