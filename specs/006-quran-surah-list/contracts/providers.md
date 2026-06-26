# Contract: Riverpod Providers

**Feature**: Quran Surah List (قائمة السور)  
**File location**: `lib/features/quran/providers/quran_providers.dart`

---

## surahListProvider

```
Type:     FutureProvider<List<SurahModel>>
```

Returns all 114 surahs in canonical order. On first call, checks Hive `surahListBox` for 114 entries; if complete, returns the cached list. Otherwise, fetches from AlQuran Cloud API (`GET /v1/surah`), writes all entries to Hive, and returns the list.

**Consumed by**: `filteredSurahsProvider`, `bookmarkedSurahsProvider`, `SurahListView`, `JuzListView`, `BookmarksView`

**Error states**:

| Condition | State emitted |
|---|---|
| Hive cache complete (114 entries) | `AsyncData(List<SurahModel>)` — no network call |
| Cache empty + network success | `AsyncData(List<SurahModel>)` after API response |
| Cache empty + network failure | `AsyncError(QuranServiceException)` |
| Cache partial (corrupted) | Treats as empty; re-fetches |

---

## filteredSurahsProvider

```
Type:     Provider<List<SurahModel>>
```

Derived provider. Returns the surah list filtered by the current search query. If the query is empty, returns all 114 surahs. Filtering applies diacritic normalisation to both the query and `surah.name`, and case-folding to `surah.englishName`.

**Depends on**: `surahListProvider`, `quranSearchProvider`  
**Consumed by**: `SurahListView`

**Behaviour when `surahListProvider` is loading or error**: Returns an empty list (the view handles loading/error state independently via `surahListProvider`).

---

## bookmarkedSurahsProvider

```
Type:     Provider<List<SurahModel>>
```

Derived provider. Returns the subset of the full surah list whose surah numbers are in the current bookmarks set, sorted in canonical surah order (ascending by number).

**Depends on**: `surahListProvider`, `bookmarksProvider`  
**Consumed by**: `BookmarksView`

---

## bookmarksProvider

```
Type:     StateNotifierProvider<BookmarksNotifier, Set<int>>
Initial:  Set loaded from Hive bookmarksBox["bookmarks"] on notifier init; empty Set if key absent
```

Holds the set of bookmarked surah numbers. `BookmarksNotifier.toggle(surahNumber)` adds or removes a number and immediately persists the updated list to Hive.

**Consumed by**: `SurahCard` (to determine bookmark icon state), `bookmarkedSurahsProvider`

**Methods on `BookmarksNotifier`**:
- `toggle(int surahNumber)` — adds if absent, removes if present; persists to Hive

---

## quranSearchProvider

```
Type:     StateProvider<String>
Default:  ''  (empty string — no active search)
```

Holds the current value of the search bar on the Surahs tab. Updated on every keystroke. Cleared when the user switches tabs or clears the search field.

**Consumed by**: `filteredSurahsProvider`, `QuranSearchBar`

---

## quranTabProvider

```
Type:     StateProvider<int>
Default:  0  (Surahs tab)
Values:   0 = السور, 1 = الأجزاء, 2 = المفضلة
```

Holds the active tab index. Written by the `TabBar` `onTap` callback in `QuranScreen`. When changing from tab 0 to any other tab, `QuranScreen` also clears `quranSearchProvider`.

**Consumed by**: `QuranScreen` (tab visibility logic), `QuranSearchBar` (shown only when value == 0)

---

## lastReadProvider

```
Type:     FutureProvider<LastReadPosition?>
```

Reads `quran_last_read_surah` and `quran_last_read_ayah` from SharedPreferences. Returns a `LastReadPosition` value object if both keys are present and > 0; otherwise returns `null`.

**Phase 2 behaviour**: Always resolves to `null` (no writer exists yet).  
**Consumed by**: `LastReadBanner` (renders `SizedBox.shrink()` when null)

**Error states**: Any SharedPreferences read error → resolves to `null` (non-fatal; banner stays hidden)
