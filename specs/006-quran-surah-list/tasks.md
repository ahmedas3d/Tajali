# Tasks: Quran Surah List (قائمة السور)

**Input**: Design documents from `specs/006-quran-surah-list/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/)

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: User story this task delivers (US1–US5 from spec.md)

---

## Phase 1: Setup (Hive Codegen)

**Purpose**: Register the one new Hive model and open the two new Hive boxes. Nothing else can be Hive-persisted until this phase is complete.

- [ ] T001 Create `SurahModel` with `@HiveType(typeId: 12)` and fields `number`, `name`, `englishName`, `revelationType`, `numberOfAyahs` in `lib/features/quran/data/models/surah_model.dart`
- [ ] T002 Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `lib/features/quran/data/models/surah_model.g.dart` (depends on T001)
- [ ] T003 Register `SurahModelAdapter` and open `surahListBox` and `bookmarksBox` Hive boxes in `lib/main.dart` (depends on T002)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Services, providers, and shared screens that all user stories depend on. No user story work can begin until this phase is complete.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T004 [P] Create `const Map<int, int> surahToJuz` — complete 114-entry mapping of surah number → primary Juz number (the Juz in which the surah begins) in `lib/core/constants/juz_data.dart`
- [ ] T005 [P] Create `QuranService` with `Future<List<SurahModel>> getAllSurahs()` — checks `surahListBox.length == 114` first; on cache miss, fetches `GET https://api.alquran.cloud/v1/surah` via `dio`, parses `data[].{number,name,englishName,numberOfAyahs,revelationType}`, writes all 114 entries to Hive, returns list; throws `QuranServiceException` on network failure with no cache in `lib/features/quran/data/services/quran_service.dart`
- [ ] T006 [P] Create `BookmarkService` with `Future<Set<int>> loadBookmarks()` and `Future<void> saveBookmarks(Set<int>)` — reads/writes native `List<int>` under key `"bookmarks"` in `bookmarksBox` in `lib/features/quran/data/services/bookmark_service.dart`
- [ ] T007 Create `quran_providers.dart` with core providers: `surahListProvider` (`FutureProvider<List<SurahModel>>` via `QuranService.getAllSurahs()`), `bookmarksProvider` (`StateNotifierProvider<BookmarksNotifier, Set<int>>` — `BookmarksNotifier` loads from `BookmarkService` on init, calls `saveBookmarks` on every `toggle(int)`), and `quranTabProvider` (`StateProvider<int>` default 0) in `lib/features/quran/providers/quran_providers.dart` (depends on T005, T006)
- [ ] T008 [P] Create `SurahStubScreen` — receives a `SurahModel`, displays the surah's Arabic name centred on a deep-green background with `"قريباً — الإصدار القادم"` subtitle and a back button; this is the Phase 3 reader entry point in `lib/features/quran/presentation/surah_stub_screen.dart`

**Checkpoint**: Foundation complete — all user story phases can now begin.

---

## Phase 3: User Story 1 — Browse All Surahs (Priority: P1) 🎯 MVP

**Goal**: All 114 surahs displayed in canonical order in the Quran screen's Surahs tab, each with number circle, Arabic name, English transliteration, revelation badge, and verse count.

**Independent Test**: Open the Quran tab. After a brief skeleton loading phase, all 114 surahs appear in order (Al-Faatiha #1 at top, An-Nas #114 at bottom). Each card shows all five data points. Tapping any card pushes `SurahStubScreen`. Clearing app cache and opening with airplane mode on triggers a visible error state with a retry button.

- [ ] T009 [P] [US1] Create `SurahSkeletonCard` — a fixed-height shimmer placeholder card matching the dimensions of a real `SurahCard`; used during `surahListProvider` loading state in `lib/features/quran/presentation/widgets/surah_skeleton_card.dart`
- [ ] T010 [P] [US1] Create `SurahCard` — displays surah number in a gold-bordered circle (Amiri Regular, gold), Arabic name (Amiri Bold 18sp, gold), English transliteration (Amiri Regular 13sp, ivory), revelation type badge (مكية/مدنية pill, gold at 15% opacity), verse count (ivory 12sp), and a 🔖 bookmark icon on the right; wires bookmark icon state to `bookmarksProvider` (outlined = not saved, filled gold = saved); tap anywhere on card (except icon) calls `Navigator.push` to `SurahStubScreen(surah: surah)` in `lib/features/quran/presentation/widgets/surah_card.dart`
- [ ] T011 [US1] Create `SurahListView` — `ConsumerWidget` watching `surahListProvider`; on loading renders 6 `SurahSkeletonCard`s; on data renders `ListView` of `SurahCard`s; on error renders centred Arabic error message with a gold-bordered "إعادة المحاولة" retry button that calls `ref.invalidate(surahListProvider)` in `lib/features/quran/presentation/widgets/surah_list_view.dart` (depends on T009, T010)
- [ ] T012 [US1] Replace `QuranScreen` stub with the full three-tab shell: `DefaultTabController` with `TabBar` (السور / الأجزاء / المفضلة, gold underline on active tab), deep-green `AppBar` with "القرآن الكريم" title in gold Amiri; Surahs tab body is `SurahListView`; Juz and Bookmarks tab bodies are placeholder `SizedBox.shrink()` for now; `quranTabProvider` updated on tab change in `lib/features/quran/presentation/quran_screen.dart` (depends on T011)

**Checkpoint**: User Story 1 independently testable — 114 surah cards render, tap opens stub screen, error state shows on no-cache offline launch.

---

## Phase 4: User Story 2 — Search for a Surah (Priority: P1)

**Goal**: Real-time diacritic-normalised search bar on the Surahs tab, filtering by Arabic name or English transliteration, with a clear empty-state message when no surahs match.

**Independent Test**: On the Surahs tab, type "البقرة" — only Al-Baqara remains. Type "Al-Baqara" — same result. Type "zzz" — empty-state message appears with the query quoted. Clear the field — all 114 surahs return immediately. Switch to Juz tab — search bar disappears.

- [ ] T013 [P] [US2] Create `QuranSearchBar` — a rounded `TextField` with an Arabic hint text `"ابحث عن سورة..."`, search icon, and a clear (×) button that appears when the field is non-empty; on change, writes to `quranSearchProvider`; styled with dark green fill and ivory text in `lib/features/quran/presentation/widgets/quran_search_bar.dart`
- [ ] T014 [US2] Add `quranSearchProvider` (`StateProvider<String>` default `''`) and `filteredSurahsProvider` (`Provider<List<SurahModel>>`) to `quran_providers.dart` — `filteredSurahsProvider` watches `surahListProvider` and `quranSearchProvider`; strips Arabic diacritics from both query and `surah.name` using `RegExp(r'[ؐ-ًؚ-ٟ]')` before comparison; folds English query and `surah.englishName` to lowercase; returns full list when query is empty in `lib/features/quran/providers/quran_providers.dart`
- [ ] T015 [US2] Integrate `QuranSearchBar` into `QuranScreen` — shown as a `SliverToBoxAdapter` above the surah list only when `quranTabProvider == 0`; hidden (replaced with `SizedBox.shrink()`) on Juz and Bookmarks tabs; clears `quranSearchProvider` when tab changes away from Surahs in `lib/features/quran/presentation/quran_screen.dart` (depends on T013, T014)
- [ ] T016 [US2] Update `SurahListView` to show an empty-search state — when `filteredSurahsProvider` returns an empty list and `quranSearchProvider` is non-empty, render a centred `"لا توجد نتائج لـ «{query}»"` message with a search icon illustration and a text button to clear the search in `lib/features/quran/presentation/widgets/surah_list_view.dart` (depends on T013)

**Checkpoint**: Search fully functional on Surahs tab only; Juz and Bookmarks tabs unaffected; empty state renders correctly.

---

## Phase 5: User Story 3 — Resume Last Read (Priority: P1)

**Goal**: A "Continue Reading" banner above the tab content reads last-read position from SharedPreferences. Always hidden in Phase 2 (no writer yet). Infrastructure fully built and reactive.

**Independent Test**: Inject `quran_last_read_surah = 18` and `quran_last_read_ayah = 50` directly into SharedPreferences (via flutter_test override or manual device storage edit). Open the Quran screen — the banner appears showing "سورة الكهف — الآية ٥٠". Tap it — navigates to `SurahStubScreen` for Al-Kahf. Without the injected values, no banner appears.

- [ ] T017 [P] [US3] Create `LastReadBanner` — `ConsumerWidget` watching `lastReadProvider`; when value is `null` renders `SizedBox.shrink()`; when non-null renders a gold-bordered card showing "📖 استكمل القراءة", the surah Arabic name, and "الآية {ayahNumber}"; tap calls `Navigator.push` to `SurahStubScreen` for the saved surah; surah name is resolved from `surahListProvider` by surah number in `lib/features/quran/presentation/widgets/last_read_banner.dart`
- [ ] T018 [US3] Add `lastReadProvider` (`FutureProvider<LastReadPosition?>`) to `quran_providers.dart` — reads `quran_last_read_surah` and `quran_last_read_ayah` from `SharedPreferences`; returns a `LastReadPosition` value object if both keys are present and > 0, otherwise returns `null`; any read error also returns `null` (non-fatal) in `lib/features/quran/providers/quran_providers.dart`
- [ ] T019 [US3] Integrate `LastReadBanner` into `QuranScreen` above the `TabBar` — rendered inside a `SliverToBoxAdapter` at the top of the scroll content; has no impact on tab layout when hidden (zero height) in `lib/features/quran/presentation/quran_screen.dart` (depends on T017, T018)

**Checkpoint**: Banner infrastructure complete and reactive; always hidden in Phase 2; activates automatically when Phase 3 writes SharedPreferences keys.

---

## Phase 6: User Story 4 — Browse Surahs by Juz (Priority: P2)

**Goal**: The Juz tab shows a flat, scrollable list of all 114 surahs grouped under 30 sticky Juz section headers using native Flutter slivers.

**Independent Test**: Switch to Juz tab. Verify 30 Juz headers are present in order. Scroll slowly — the current Juz header sticks to the top until the next one pushes it off. All 114 surahs are visible without any expand/collapse interaction. Tapping any surah card pushes `SurahStubScreen`.

- [ ] T020 [P] [US4] Create `JuzListView` — `CustomScrollView` with 30 alternating pairs of `SliverPersistentHeader(pinned: true)` (Juz header: gold text "الجزء {n}", dark-green pill background) and `SliverList` (surah cards for that Juz, derived from `surahToJuz` in `juz_data.dart`); each surah card within the Juz view is a `SurahCard` widget; the sliver pairs are built from `surahListProvider` data grouped by Juz number in `lib/features/quran/presentation/widgets/juz_list_view.dart`
- [ ] T021 [US4] Replace the Juz tab placeholder in `QuranScreen` with `JuzListView`; pass `surahListProvider` data to it; handle loading and error states matching the Surahs tab in `lib/features/quran/presentation/quran_screen.dart` (depends on T020)

**Checkpoint**: Juz tab shows full sticky-header list; all surahs reachable; surah tap works identically to Surahs tab.

---

## Phase 7: User Story 5 — Bookmark a Surah (Priority: P2)

**Goal**: The 🔖 icon on each `SurahCard` toggles the surah's bookmark state, persists across restarts, and saved surahs appear in the Bookmarks tab. Empty Bookmarks tab shows a friendly message.

**Independent Test**: Tap 🔖 on Al-Kahf (surah 18) — icon fills gold. Switch to Bookmarks tab — Al-Kahf appears. Kill and reopen the app — Al-Kahf is still bookmarked. Tap the filled 🔖 on Al-Kahf — it is removed from Bookmarks tab immediately. Bookmarks tab with zero items shows the empty-state message.

- [ ] T022 [P] [US5] Add `bookmarkedSurahsProvider` (`Provider<List<SurahModel>>`) to `quran_providers.dart` — watches `surahListProvider` and `bookmarksProvider`; returns the subset of surahs whose `number` is in the bookmarks set, sorted ascending by number in `lib/features/quran/providers/quran_providers.dart`
- [ ] T023 [P] [US5] Create `BookmarksView` — `ConsumerWidget` watching `bookmarkedSurahsProvider`; when non-empty renders `ListView` of `SurahCard`s; when empty renders centred illustration (open-book SVG or icon) with `"لا توجد سور محفوظة بعد"` heading, `"احفظ سورة لتجدها هنا"` subtitle, and a text button pointing the user to the Surahs tab in `lib/features/quran/presentation/widgets/bookmarks_view.dart`
- [ ] T024 [US5] Replace the Bookmarks tab placeholder in `QuranScreen` with `BookmarksView`; no loading/error state needed (derived from already-loaded `surahListProvider`) in `lib/features/quran/presentation/quran_screen.dart` (depends on T022, T023)

**Checkpoint**: All 5 user stories independently functional and testable — surah list, search, last-read banner, Juz view, and bookmarks all working.

---

## Phase 8: Polish & Tests

**Purpose**: Verify correctness with targeted unit and widget tests, then run quickstart validation.

- [ ] T025 [P] Write unit tests for `QuranService` — API response parsing with all 114 surahs; Hive cache hit (no network call); cache miss triggers fetch; partial cache (`length < 114`) treated as miss and re-fetches; `QuranServiceException` thrown on network failure with empty cache in `test/unit/quran_service_test.dart`
- [ ] T026 [P] Write unit tests for `BookmarkService` — `loadBookmarks()` returns empty set on first use; `saveBookmarks` round-trips correctly; toggle via `BookmarksNotifier` adds and removes correctly; persisted state survives notifier rebuild in `test/unit/bookmark_service_test.dart`
- [ ] T027 [P] Write unit tests for diacritic normalisation — `normalise("سُورَةُ ٱلْفَاتِحَةِ")` equals `normalise("سورة الفاتحة")`; `"Al-Faatiha".toLowerCase()` matches `"al-faatiha"`; empty string returns empty; query with only diacritics returns empty string after normalisation in `test/unit/diacritic_normalisation_test.dart`
- [ ] T028 [P] Write widget tests for `QuranScreen` — tab switching shows/hides search bar; loading state shows skeleton cards; error state shows retry button; tap retry triggers `ref.invalidate(surahListProvider)` in `test/widget/quran_screen_test.dart`
- [ ] T029 [P] Write widget tests for `SurahCard` — all five data fields render with correct values; 🔖 icon reflects bookmarks state; tap on card (not icon) calls navigation; tap on icon calls `BookmarksNotifier.toggle` in `test/widget/surah_card_test.dart`
- [ ] T030 [P] Write widget tests for `JuzListView` — 30 Juz headers present; total surah card count is 114; tap on a surah card triggers navigation in `test/widget/juz_list_view_test.dart`
- [ ] T031 Run all quickstart.md validation scenarios (7 scenarios) — happy path, search, bookmark, Juz view, stub screen tap, offline mode, error state with retry

**Checkpoint**: All stories validated, tests passing, quickstart scenarios confirmed.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion — **BLOCKS all user stories**
- **User Stories (Phases 3–7)**: All depend on Phase 2 completion; can then proceed sequentially in P1 → P2 priority order (or in parallel if staffed)
- **Polish (Phase 8)**: Depends on all desired user story phases complete

### User Story Dependencies

- **US1 (P1)**: Can start after Phase 2 — no dependency on other stories
- **US2 (P1)**: Can start after Phase 2 — depends on US1 `SurahListView` (modifies it for empty-search state)
- **US3 (P1)**: Can start after Phase 2 — independent of US1 and US2 (adds a separate banner widget)
- **US4 (P2)**: Can start after Phase 2 — depends on US1's `SurahCard` reuse
- **US5 (P2)**: Can start after Phase 2 — depends on `BookmarksNotifier` already in `bookmarksProvider` (Phase 2); `SurahCard` bookmark icon is already wired to `bookmarksProvider` from T010

### Within Each User Story

- Models before services (Phase 1 → Phase 2)
- Services before providers (T005, T006 → T007)
- Providers before widgets
- Widgets before screen integration
- Story complete at checkpoint before moving to next priority

### Parallel Opportunities

- T004, T005, T006, T008 (all Phase 2) — different files, run in parallel
- T009, T010 (Phase 3 US1) — different files, run in parallel
- T013 (Phase 4 US2) — can start in parallel with T014
- T017 (Phase 5 US3) — can start in parallel with T018
- T020 (Phase 6 US4) — independent of Phase 5
- T022, T023 (Phase 7 US5) — different files, run in parallel
- T025–T030 (Phase 8) — all test files, all parallel

---

## Parallel Example: Phase 2 Foundational

```
# All four tasks can run simultaneously:
Task T004: "Create juz_data.dart const map in lib/core/constants/juz_data.dart"
Task T005: "Create QuranService in lib/features/quran/data/services/quran_service.dart"
Task T006: "Create BookmarkService in lib/features/quran/data/services/bookmark_service.dart"
Task T008: "Create SurahStubScreen in lib/features/quran/presentation/surah_stub_screen.dart"

# Then run sequentially (T005+T006 complete required):
Task T007: "Create quran_providers.dart with surahListProvider, bookmarksProvider, quranTabProvider"
```

## Parallel Example: Phase 8 Polish

```
# All test files can run simultaneously:
Task T025: "Unit tests for QuranService in test/unit/quran_service_test.dart"
Task T026: "Unit tests for BookmarkService in test/unit/bookmark_service_test.dart"
Task T027: "Unit tests for diacritic normalisation in test/unit/diacritic_normalisation_test.dart"
Task T028: "Widget tests for QuranScreen in test/widget/quran_screen_test.dart"
Task T029: "Widget tests for SurahCard in test/widget/surah_card_test.dart"
Task T030: "Widget tests for JuzListView in test/widget/juz_list_view_test.dart"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup (Hive codegen)
2. Complete Phase 2: Foundational (services, providers, stub screen)
3. Complete Phase 3: US1 — 114 surahs visible, surah tap works
4. Complete Phase 4: US2 — search bar filters the list
5. **STOP and VALIDATE**: Run Scenarios 1, 2, and 5 from `quickstart.md`
6. Ship MVP — full surah list with search

### Incremental Delivery

1. Setup + Foundational → infrastructure ready
2. Add US1 → 114 surahs browsable (MVP!)
3. Add US2 → search enabled
4. Add US3 → banner infrastructure ready for Phase 3
5. Add US4 → Juz view available
6. Add US5 → bookmarks fully functional
7. Polish + tests → production-ready

---

## Notes

- `[P]` tasks = different files, no incomplete-task dependencies — run in parallel
- `[Story]` label maps each task to a specific user story for traceability
- `SurahCard` (T010) builds the complete card including the 🔖 icon wired to `bookmarksProvider` — bookmark toggle works from US1 onward even before the Bookmarks tab (US5) exists
- `LastReadBanner` (T017) is always hidden in Phase 2 — do not add fake test data; use `SharedPreferences` injection in tests
- `SurahStubScreen` (T008) is the sole navigation target for all surah taps across all three tabs — Phase 3 replaces its body, not its route
- Run `flutter pub run build_runner build --delete-conflicting-outputs` (T002) before any Hive-dependent code is compiled
