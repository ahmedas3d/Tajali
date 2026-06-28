# Tasks: Quran Reading & Audio (شاشة القراءة والتلاوة)

**Input**: Design documents from `specs/007-quran-reader-audio/`

**Prerequisites**: [plan.md](plan.md) · [spec.md](spec.md) · [research.md](research.md) · [data-model.md](data-model.md) · [contracts/alquran-cloud-reader-api.md](contracts/alquran-cloud-reader-api.md) · [quickstart.md](quickstart.md)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US6)
- Exact file paths are included in every task description

---

## Phase 1: Setup

**Purpose**: Remove replaced placeholder; no blocking other work.

- [x] T001 Delete `lib/features/quran/presentation/surah_stub_screen.dart` (replaced by QuranReaderScreen in Phase 3)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data types and Hive registration that every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T002 Create `AyahModel` in `lib/features/quran/data/models/ayah_model.dart` — Hive object typeId 13; fields: `number`, `numberInSurah`, `surahNumber`, `text`, `juz`, `page`, `audioUrl?`; add `fromJson()` factory parsing AlQuran Cloud edition ayah JSON
- [x] T003 [P] Create `ReciterModel` in `lib/features/quran/data/models/reciter_model.dart` — pure Dart, no Hive; fields: `identifier`, `nameAr`, `nameEn`; add `static const List<ReciterModel> reciters` with 4 entries (ar.alafasy / مشاري العفاسي, ar.abdulsamad / عبد الصمد, ar.abdullahbasfar / عبدالله بصفر, ar.hudhaify / علي الحذيفي)
- [x] T004 Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `lib/features/quran/data/models/ayah_model.g.dart` (depends on T002)
- [x] T005 Register `AyahModelAdapter()` and open `Hive.openBox<AyahModel>('ayahTextBox')` in `lib/main.dart` — add before `runApp()` alongside existing box registrations (depends on T004)
- [x] T006 Create empty `lib/features/quran/providers/reader_providers.dart` with file-level comment block listing all providers to be added in later phases — prevents import errors during incremental development

**Checkpoint**: `flutter pub get && flutter run` must launch without errors before continuing.

---

## Phase 3: User Story 1 — Read Full Surah Text (Priority: P1) 🎯 MVP

**Goal**: Replace the stub screen with a real reader that displays all ayahs of the selected surah in Uthmanic Arabic script.

**Independent Test**: Open Al-Fatiha from the surah list → verify 7 ayahs shown in AmiriQuran font with gold ayah number markers and the Basmala header. See Scenario 1 in [quickstart.md](quickstart.md).

### Implementation

- [x] T007 Create `QuranReaderService` in `lib/features/quran/data/services/quran_reader_service.dart` — implement `getSurahWithAudio(int surahNumber, String reciterEdition)`: check `ayahTextBox` cache (`surah_text_{surahNumber}`), on miss call `GET /v1/surah/{n}/editions/quran-uthmani,{reciterEdition}`, zip both edition arrays by `numberInSurah` into `List<AyahModel>`, store in cache, return list; see [contracts/alquran-cloud-reader-api.md](contracts/alquran-cloud-reader-api.md) for response shape
- [x] T008 [P] Add `surahAyahsProvider` to `lib/features/quran/providers/reader_providers.dart` — `FutureProvider.family<List<AyahModel>, (int, String)>((ref, args) => ...)` keyed by (surahNumber, reciterEdition); uses `QuranReaderService`
- [x] T009 Create `AyahCard` widget in `lib/features/quran/presentation/widgets/ayah_card.dart` — props: `AyahModel ayah`, `bool isPlaying`, `bool isBookmarked`, `VoidCallback onTap`, `VoidCallback onBookmarkToggle`; render: gold ayah number marker badge on the right, Uthmanic text in `AmiriQuran` font (ivory color, `TextDirection.rtl`); default background `AppColors.primaryGreen`
- [x] T010 Create `QuranReaderScreen` in `lib/features/quran/presentation/quran_reader_screen.dart` — constructor `({required SurahModel surah, int? initialAyahIndex})`; AppBar: surah name in `AmiriQuran`/gold + prev/next surah arrow buttons; Body: RTL `ListView.builder` of `AyahCard` widgets using `surahAyahsProvider`; default reciter `'ar.alafasy'`
- [x] T011 Add Basmala header to `QuranReaderScreen` body in `lib/features/quran/presentation/quran_reader_screen.dart` — display styled بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ widget above ayah list for all surahs except surah 9 (At-Tawbah); Al-Fatiha shows Basmala only as its first ayah (no separate header)
- [x] T012 Add loading and error states to `QuranReaderScreen` in `lib/features/quran/presentation/quran_reader_screen.dart` — show `CircularProgressIndicator` (gold) while `surahAyahsProvider` is loading; show Arabic error message + retry `ElevatedButton` on failure (FR-003); show cached text directly if offline and cache exists
- [x] T013 Update `lib/features/quran/presentation/widgets/surah_card.dart` to navigate to `QuranReaderScreen(surah: surah)` wherever `SurahStubScreen` was previously used (depends on T001, T010)

**Checkpoint**: Run Scenario 1 from [quickstart.md](quickstart.md). User Story 1 is complete when all 7 ayahs of Al-Fatiha display with correct text and no audio components are required.

---

## Phase 4: User Story 2 — Play Audio Recitation (Priority: P2)

**Goal**: Add a full audio player bar with ayah-level highlighting, pause/resume, per-ayah tap-to-play, and single-ayah repeat.

**Independent Test**: Open Al-Fatiha → tap play → hear Mishary Alafasy → watch each ayah highlight in sequence → tap pause → tap play → verify resume. See Scenarios 2–4 in [quickstart.md](quickstart.md).

### Implementation

- [x] T014 Create `AudioPlayerService` class in `lib/features/quran/data/services/audio_player_service.dart` — wraps `just_audio.AudioPlayer`; methods: `play(List<AyahModel>, {int startIndex=0})` builds `ConcatenatingAudioSource` from `audioUrl` list; `playFromIndex(int)` seeks playlist; `pause()`, `stop()`, `dispose()`; `setRepeat(bool active, int ayahIndex)` replaces source with `LoopingAudioSource` for single ayah or restores full playlist; exposes `currentIndexStream`, `playingStream`, `playerStateStream`
- [x] T015 Add audio state providers to `lib/features/quran/providers/reader_providers.dart` — audio state managed as local state in `QuranReaderScreen` (`_playingIndex`, `_isRepeat`) via `currentIndexStream` listener; scoped to screen lifecycle
- [x] T016 Update `AyahCard` in `lib/features/quran/presentation/widgets/ayah_card.dart` — add playing highlight visual state: gold border (`Border.all(color: AppColors.gold, width: 1.5)`) + background tint (`AppColors.gold.withOpacity(0.12)`) when `isPlaying == true`; add `onTap` handler that calls `audioPlayer.playFromIndex(ayahIndex)`
- [x] T017 Create `AudioPlayerBar` widget in `lib/features/quran/presentation/widgets/audio_player_bar.dart` — RTL layout: reciter chip placeholder (tap → no-op for now, wired in US3), prev-ayah icon button, large play/pause icon button (gold), next-ayah icon button, repeat toggle (`Icons.repeat_one` active / `Icons.repeat` inactive); show `CircularProgressIndicator` overlay on play button when buffering
- [x] T018 Integrate `AudioPlayerBar` into `QuranReaderScreen` in `lib/features/quran/presentation/quran_reader_screen.dart` — add as bottom bar in `Column`; subscribe to `audioPlayer.currentIndexStream` in `initState` to update `_playingIndex`; call `audioPlayer.stop()` then `audioPlayer.dispose()` in screen's `dispose()` method (FR-019); pass `isPlaying` to each `AyahCard`
- [x] T019 Implement single-ayah repeat in `AudioPlayerService` — when `setRepeat(true, index)`: replace `ConcatenatingAudioSource` with single-item source + `LoopMode.all`; when `setRepeat(false)`: restore full playlist starting from current ayah (FR-020)
- [x] T020 Add offline audio guard in `QuranReaderScreen` — audio player shows buffering state when offline; error is handled gracefully via `PlayerState` stream; retry is available by tapping another ayah (FR-018)

**Checkpoint**: Run Scenarios 2, 3, 4 from [quickstart.md](quickstart.md). All audio playback, highlighting, and repeat scenarios must pass before moving on.

---

## Phase 5: User Story 3 — Choose Reciter (Priority: P2)

**Goal**: Let users switch between 4 reciters with the preference saved across sessions.

**Independent Test**: Switch reciter from Alafasy to Abdul Samad → play Al-Fatiha → hear different voice → restart app → verify Abdul Samad is still selected. See Scenario 5 in [quickstart.md](quickstart.md).

### Implementation

- [x] T021 Add `selectedReciterProvider` to `lib/features/quran/providers/reader_providers.dart` — `StateProvider<String>` initialized from `SharedPreferences.getString('quran_selected_reciter') ?? 'ar.alafasy'`; add `persistReciter(String)` helper that writes to SharedPreferences on change
- [x] T022 Create `ReciterPickerSheet` in `lib/features/quran/presentation/widgets/reciter_picker_sheet.dart` — modal bottom sheet; lists `ReciterModel.reciters` (4 items); currently selected reciter shown with gold checkmark; on tap: update `selectedReciterProvider`, call `persistReciter()`, pop sheet
- [x] T023 Add `updateAudioUrls()` to `QuranReaderService` in `lib/features/quran/data/services/quran_reader_service.dart` — calls `GET /v1/surah/{n}/{reciterEdition}`, updates `audioUrl` on each `AyahModel` in place, re-saves updated list to `ayahTextBox` cache
- [x] T024 Wire reciter chip in `AudioPlayerBar` in `lib/features/quran/presentation/widgets/audio_player_bar.dart` — show current reciter's `nameAr` as tappable chip; on tap: show `ReciterPickerSheet` via `showModalBottomSheet`; after selection: stop current playback, re-load audio URLs, restart from current ayah index

**Checkpoint**: Run Scenario 5 from [quickstart.md](quickstart.md). Reciter switch must change the audio voice and persist across app restarts.

---

## Phase 6: User Story 4 — Bookmark Individual Ayahs (Priority: P3)

**Goal**: Allow bookmarking any ayah and navigating back to it from the Bookmarks tab via a deep-link into the reader.

**Independent Test**: Bookmark ayah 3 of Al-Baqara → restart app → go to Bookmarks tab → see the entry → tap it → reader opens at ayah 3 highlighted. See Scenarios 6, 7 in [quickstart.md](quickstart.md).

### Implementation

- [x] T025 Create `AyahBookmark` model in `lib/features/quran/data/models/ayah_bookmark.dart` — Hive object typeId 14; fields: `surahNumber`, `ayahNumberInSurah`, `surahName`, `ayahText`, `createdAt` (DateTime); override `operator ==` and `hashCode` using `(surahNumber, ayahNumberInSurah)` composite key
- [x] T026 Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `lib/features/quran/data/models/ayah_bookmark.g.dart` (depends on T025)
- [x] T027 Register `AyahBookmarkAdapter()` and open `Hive.openBox<AyahBookmark>('ayahBookmarksBox')` in `lib/main.dart` (depends on T026)
- [x] T028 Create `AyahBookmarkService` in `lib/features/quran/data/services/ayah_bookmark_service.dart` — `List<AyahBookmark> loadAll()`: reads from `ayahBookmarksBox`; `void toggle(AyahBookmark)`: adds if not present (by composite key), removes if present; `bool isBookmarked(int surahNumber, int ayahNumberInSurah)`: quick lookup
- [x] T029 Add `AyahBookmarksNotifier` and `ayahBookmarksProvider` to `lib/features/quran/providers/reader_providers.dart` — `StateNotifierProvider<AyahBookmarksNotifier, List<AyahBookmark>>`; notifier wraps `AyahBookmarkService`; exposes `toggle(AyahBookmark)` and `isBookmarked(int, int)`
- [x] T030 Update `AyahCard` in `lib/features/quran/presentation/widgets/ayah_card.dart` — add `isBookmarked` prop rendering a small filled `Icons.bookmark` (gold, size 18) in the top-right of the card; tapping the icon calls `onBookmarkToggle`
- [x] T031 Wire bookmark toggle in `QuranReaderScreen` in `lib/features/quran/presentation/quran_reader_screen.dart` — each `AyahCard` receives `isBookmarked` and `onBookmarkToggle` callback that calls `ref.read(ayahBookmarksProvider.notifier).toggle(AyahBookmark(...))`
- [x] T032 Update `BookmarksView` in `lib/features/quran/presentation/widgets/bookmarks_view.dart` — add section for ayah bookmarks from `ayahBookmarksProvider`; each tile shows surah name + ayah number + text preview; tapping navigates: `QuranReaderScreen(surah: surah, initialAyahIndex: ayahIndex)` (FR-015a)
- [x] T033 Verify `QuranReaderScreen` `initialAyahIndex` scroll in `lib/features/quran/presentation/quran_reader_screen.dart` — in `initState` via `_restorePosition()`: if `initialAyahIndex != null`, use `ScrollController.animateTo` to the ayah position after first frame (FR-015a)

**Checkpoint**: Run Scenarios 6, 7 from [quickstart.md](quickstart.md). Bookmark toggle and deep-link navigation from Bookmarks tab must both work.

---

## Phase 7: User Story 5 — Adjustable Font Size (Priority: P3)

**Goal**: Let users pick a comfortable font size that persists across surahs and restarts.

**Independent Test**: Open reader → change to large size → navigate to another surah → close app → reopen → verify large size is applied. See Scenario 8 in [quickstart.md](quickstart.md).

### Implementation

- [x] T034 Add `fontSizeProvider` to `lib/features/quran/providers/reader_providers.dart` — `StateProvider<double>` initialized from `SharedPreferences.getDouble('quran_font_size') ?? 28.0`; add `persistFontSize(double)` helper writing back to SharedPreferences on every change
- [x] T035 Apply `fontSizeProvider` to `AyahCard` in `lib/features/quran/presentation/widgets/ayah_card.dart` — replace hardcoded font size with `ref.watch(fontSizeProvider)` on the `AmiriQuran` `TextStyle`; range 18–40
- [x] T036 Add font size control to `QuranReaderScreen` header in `lib/features/quran/presentation/quran_reader_screen.dart` — `-` / `+` icon buttons in the surah header area; each tap increments/decrements by 2pt and calls `persistFontSize()`

**Checkpoint**: Run Scenario 8 from [quickstart.md](quickstart.md). Font size change must be instant (< 100ms) and persist after app restart.

---

## Phase 8: User Story 6 — Save & Restore Reading Position (Priority: P3)

**Goal**: Return users to where they left off in each surah across sessions.

**Independent Test**: Scroll Al-Baqara to ayah 50 → close app → reopen → tap Al-Baqara → verify reader scrolls to ayah 50. See Scenario 9 in [quickstart.md](quickstart.md).

### Implementation

- [x] T037 Save reading position in `QuranReaderScreen` via `_savePosition()` — writes SharedPreferences key `reader_pos_{surahNumber}` (scroll offset as double) on scroll-end and screen pop
- [x] T038 Add `writeLastRead(int surahNumber, int ayahNumber)` helper to `lib/features/quran/providers/quran_providers.dart` — writes `quran_last_read_surah` + `quran_last_read_ayah` to SharedPreferences (makes `lastReadProvider` writable)
- [x] T039 Integrate position save + restore in `QuranReaderScreen` — on mount: restore saved scroll offset or scroll to `initialAyahIndex`; on scroll-end: call `_savePosition()` which saves offset + calls `writeLastRead()`

**Checkpoint**: Run Scenario 9 from [quickstart.md](quickstart.md). Each surah independently restores its own last position.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Offline behaviour hardening, edge cases, and surah navigation.

- [x] T040 [P] Implement prev/next surah navigation in `QuranReaderScreen` app bar — left/right `Icons.chevron` buttons in `actions`; navigates to `surah.number ± 1` via `pushReplacement`; disabled at surah 1 and 114 (depends on T010)
- [x] T041 [P] Harden offline text fallback in `QuranReaderScreen` — uncached surah shows Arabic error + retry; retry button calls `ref.refresh(surahAyahsProvider(...))`; cached surah loads from Hive without network
- [x] T042 [P] Validate Surah At-Tawbah (surah 9) edge case in `QuranReaderScreen` — condition `surah.number == 9` in `_buildBasmala()` returns `SizedBox.shrink()` (no Basmala header)
- [x] T043 Run full test suite `flutter test test/` and fix any regressions — all 9 widget tests pass; added `ayahBookmarksProvider.overrideWith((_) => AyahBookmarksNotifier.withInitial([]))` to test setup

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — **BLOCKS all user stories**
- **US1 (Phase 3)**: Depends on Foundational — first story to implement
- **US2 (Phase 4)**: Depends on US1 (AyahCard and QuranReaderScreen must exist)
- **US3 (Phase 5)**: Depends on US2 (AudioPlayerBar must exist to add reciter chip)
- **US4 (Phase 6)**: Depends on US1 (AyahCard and QuranReaderScreen must exist); independent of US2/US3
- **US5 (Phase 7)**: Depends on US1 (AyahCard must exist for font size wiring)
- **US6 (Phase 8)**: Depends on US1 (QuranReaderScreen must exist)
- **Polish (Phase 9)**: Depends on all user stories complete

### User Story Dependencies

```
Phase 1: Setup
    │
    ▼
Phase 2: Foundational (T002–T006)
    │
    ├──▶ Phase 3: US1 Read Text (T007–T013) ──▶ MVP complete
    │         │
    │         ├──▶ Phase 4: US2 Audio (T014–T020)
    │         │         │
    │         │         └──▶ Phase 5: US3 Reciter (T021–T024)
    │         │
    │         ├──▶ Phase 6: US4 Bookmarks (T025–T033)
    │         ├──▶ Phase 7: US5 Font Size (T034–T036)
    │         └──▶ Phase 8: US6 Position (T037–T039)
    │
    └──▶ Phase 9: Polish (T040–T043) — after all stories
```

---

## Notes

- [P] tasks = different files, no blocking dependencies — run in parallel
- [Story] label maps task to specific user story for traceability
- `build_runner` must be re-run (T004, T026) after every `@HiveType` model change
- Delete `surah_stub_screen.dart` (T001) before any route changes to avoid unused import warnings
- Hive typeIds in use: 10 (PrayerTimesModel), 11 (HijriDateModel), 12 (SurahModel), 13 (AyahModel), 14 (AyahBookmark)
- Validate each checkpoint with the corresponding quickstart.md scenario before advancing
