# Tasks: Adhkar & Dua (الأذكار والدعاء)

**Input**: Design documents from `specs/008-adhkar-dua/`

**Prerequisites**: [plan.md](plan.md) · [spec.md](spec.md) · [research.md](research.md) · [data-model.md](data-model.md) · [quickstart.md](quickstart.md)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Exact file paths are included in every task description

---

## Phase 1: Setup

**Purpose**: Asset acquisition and directory scaffolding — unblocks all other work.

- [x] T001 Download `https://raw.githubusercontent.com/nawajalqari/azkar-api/main/azkar.json` and save to `assets/data/azkar.json`
- [x] T002 [P] Add two short MP3 sound files to `assets/audio/`: `tasbih_tap.mp3` (click ~50ms) and `tasbih_complete.mp3` (ring tone ~500ms) — source any royalty-free Islamic click/ring audio
- [x] T003 Register new assets in `pubspec.yaml` under `flutter.assets`: add `assets/data/azkar.json`, `assets/audio/tasbih_tap.mp3`, `assets/audio/tasbih_complete.mp3`
- [x] T004 [P] Create full adhkar feature directory tree: `lib/features/adhkar/data/models/`, `lib/features/adhkar/data/services/`, `lib/features/adhkar/presentation/widgets/`, `lib/features/adhkar/providers/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data models, Hive registration, and service layer that every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T005 Create `AdhkarCategoryModel` in `lib/features/adhkar/data/models/adhkar_category_model.dart` — pure Dart class; fields: `id` (String), `nameAr` (String), `count` (int), `iconName` (String); add `fromJson(Map<String, dynamic>)` factory parsing the top-level azkar.json array objects
- [x] T006 [P] Create `DhikrModel` in `lib/features/adhkar/data/models/dhikr_model.dart` — pure Dart class; fields: `index` (int, 0-based position in category), `categoryId` (String), `text` (String), `repeat` (int), `source` (String?, nullable), `virtue` (String?, nullable); add `fromJson(Map<String, dynamic>, String categoryId, int index)` factory
- [x] T007 Create `TasbihSessionModel` in `lib/features/adhkar/data/models/tasbih_session_model.dart` — Hive object `@HiveType(typeId: 15)`; fields: `dhikrType` (HiveField 0, String), `currentCount` (HiveField 1, int), `completedRounds` (HiveField 2, int), `target` (HiveField 3, int); extend `HiveObject`
- [x] T008 [P] Create `TasbihHistoryEntry` in `lib/features/adhkar/data/models/tasbih_history_entry.dart` — Hive object `@HiveType(typeId: 16)`; fields: `dhikrType` (HiveField 0, String), `totalCount` (HiveField 1, int), `dateISO` (HiveField 2, String); extend `HiveObject`
- [x] T009 Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `lib/features/adhkar/data/models/tasbih_session_model.g.dart` and `lib/features/adhkar/data/models/tasbih_history_entry.g.dart` (depends on T007, T008)
- [x] T010 Register new Hive adapters and open boxes in `lib/main.dart` — add: `Hive.registerAdapter(TasbihSessionModelAdapter())`, `Hive.registerAdapter(TasbihHistoryEntryAdapter())`, `await Hive.openBox<int>('dhikrCounterBox')`, `await Hive.openBox<TasbihSessionModel>('tasbihSessionBox')`, `await Hive.openBox<TasbihHistoryEntry>('tasbihHistoryBox')` — alongside existing box registrations (depends on T009)
- [x] T011 Implement `AdhkarService` in `lib/features/adhkar/data/services/adhkar_service.dart` — `Future<List<AdhkarCategoryModel>> getCategories()`: load `assets/data/azkar.json` via `rootBundle.loadString`, parse JSON array, map to `AdhkarCategoryModel` list; `Future<List<DhikrModel>> getDhikrByCategory(String categoryId)`: find category by id, map adhkar array to `DhikrModel` list with 0-based index; cache parsed result in-memory after first call
- [x] T012 [P] Implement `DhikrCounterService` in `lib/features/adhkar/data/services/dhikr_counter_service.dart` — `String _key(String date, String categoryId, int index)` helper; `int getRemaining(DhikrModel dhikr)`: read `dhikrCounterBox.get(_key(today, ...), defaultValue: dhikr.repeat)`; `Future<void> decrement(DhikrModel dhikr)`: write remaining-1 (floor 0); `bool isComplete(DhikrModel dhikr)`: remaining == 0; `Future<void> clearStaleKeys()`: delete box keys whose date prefix ≠ today and are older than 7 days
- [x] T013 [P] Create `lib/features/adhkar/providers/adhkar_providers.dart` with empty provider stubs and imports — prevents import errors during incremental development; add `adhkarCategoriesProvider`, `dhikrListProvider`, `dhikrCounterProvider`, `categoryCompletionProvider`, `tasbihSessionProvider`, `tasbihHistoryProvider`, `tasbihSoundEnabledProvider`, `tasbihVibrationEnabledProvider` stubs (throw UnimplementedError)

**Checkpoint**: `flutter run` must launch without Hive errors and the Adhkar tab must show the existing stub screen before continuing.

---

## Phase 3: User Story 1 — Browse Adhkar Categories (Priority: P1) 🎯 MVP

**Goal**: Replace the stub `AdhkarScreen` with a real category grid loaded from the bundled JSON, showing category names, counts, and the Quranic inscription.

**Independent Test**: Navigate to Adhkar tab → 8+ category cards visible in 2-column grid with names and counts → no internet required. See Scenarios 1, 2 in [quickstart.md](quickstart.md).

### Implementation

- [x] T014 [US1] Wire `adhkarCategoriesProvider` in `lib/features/adhkar/providers/adhkar_providers.dart` — `FutureProvider<List<AdhkarCategoryModel>>((ref) => AdhkarService().getCategories())`
- [x] T015 [P] [US1] Create `AdhkarCategoryCard` widget in `lib/features/adhkar/presentation/widgets/adhkar_category_card.dart` — props: `AdhkarCategoryModel category`, `bool isCompleted`, `VoidCallback onTap`; card layout: ivory background, category icon (SVG from `assets/svg/`), Arabic name in gold text, count badge; when `isCompleted == true`: overlay a gold checkmark badge in top-right corner (FR-027)
- [x] T016 [US1] Rewrite `AdhkarScreen` in `lib/features/adhkar/presentation/adhkar_screen.dart` — `ConsumerWidget`; AppBar: "الأذكار والدعاء" title; Body: Quranic inscription subtitle "أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ" below app bar, `GridView.builder` 2-column of `AdhkarCategoryCard`s from `adhkarCategoriesProvider`, loading shimmer while fetching, bottom sticky banner "المسبحة الإلكترونية" with "ابدأ الآن" button (FR-001–004, FR-014)
- [x] T017 [US1] Wire `categoryCompletionProvider` in `lib/features/adhkar/providers/adhkar_providers.dart` — `Provider.family<bool, String>((ref, categoryId) { ... })` derived by watching all dhikr counters for the given categoryId and checking all are == 0 for today; pass result to each `AdhkarCategoryCard` (FR-027)
- [x] T018 [US1] Add navigation from `AdhkarCategoryCard` tap to `DhikrDetailScreen` in `lib/features/adhkar/presentation/adhkar_screen.dart` — `Navigator.push(DhikrDetailScreen(categoryId: category.id, initialIndex: 0))` (FR-004)

**Checkpoint**: Run Scenarios 1, 2 from [quickstart.md](quickstart.md). Category grid must display fully offline with correct names and counts.

---

## Phase 4: User Story 2 — Read & Count a Dhikr (Priority: P1)

**Goal**: Deliver the core dhikr reading and counting experience — text, source, virtue, circular counter with dimming on completion.

**Independent Test**: Open any category → read dhikr text + source + virtue → tap counter to 0 → counter dims + button changes to "أتممت الذكر" → tapping again does nothing. See Scenarios 3, 4 in [quickstart.md](quickstart.md).

### Implementation

- [x] T019 [US2] Wire `dhikrListProvider` and `dhikrCounterProvider` in `lib/features/adhkar/providers/adhkar_providers.dart` — `dhikrListProvider`: `FutureProvider.family<List<DhikrModel>, String>((ref, categoryId) => AdhkarService().getDhikrByCategory(categoryId))`; `dhikrCounterProvider`: `StateNotifierProvider.family<DhikrCounterNotifier, int, ({String categoryId, int index})>((ref, key) => DhikrCounterNotifier(key, ref))` — notifier reads initial value from `DhikrCounterService`, exposes `decrement()` method that writes to Hive immediately (FR-013, FR-021)
- [x] T020 [P] [US2] Create `DhikrCounterWidget` in `lib/features/adhkar/presentation/widgets/dhikr_counter_widget.dart` — circular inkwell button; shows count as large Arabic numeral; when `remaining == 0`: background dims to gray, `onTap` is no-op (FR-006–009); shows "مرة" / "مرات" label below counter
- [x] T021 [US2] Create `DhikrDetailScreen` in `lib/features/adhkar/presentation/dhikr_detail_screen.dart` — `ConsumerStatefulWidget`; constructor: `({required String categoryId, required int initialIndex})`; internal state: `int _currentIndex`; watches `dhikrListProvider(categoryId)` and `dhikrCounterProvider((categoryId, _currentIndex))`; Layout: AppBar with category name + back arrow, cream card with dhikr text in ScheherazadeNew font, source text below (if non-null), virtue text below source (if non-null), `DhikrCounterWidget`, large CTA button ("تقبل الله" / "أتممت الذكر"), bottom `DhikrNavBar` (FR-005–009)
- [x] T022 [US2] Implement counter decrement in `DhikrDetailScreen` — `DhikrCounterWidget.onTap`: call `ref.read(dhikrCounterProvider(...).notifier).decrement()`; action button label derives from `remaining == 0` (FR-007–008)

**Checkpoint**: Run Scenarios 3, 4 from [quickstart.md](quickstart.md). Counter must persist after relaunch (Scenario 7).

---

## Phase 5: User Story 3 — Navigate Through a Category Sequence (Priority: P2)

**Goal**: Add forward/backward navigation between dhikr, progress indicator, and page dots, with counter state preserved on back-navigation.

**Independent Test**: Open أذكار الصباح → progress shows "١ / N" → next/previous navigate correctly → back-navigation restores partial count. See Scenarios 5, 6 in [quickstart.md](quickstart.md).

### Implementation

- [x] T023 [US3] Create `DhikrNavBar` widget in `lib/features/adhkar/presentation/widgets/dhikr_nav_bar.dart` — RTL row: "< الذكر التالي" TextButton on right, "الذكر السابق >" TextButton on left; props: `bool canGoNext`, `bool canGoPrev`, `VoidCallback onNext`, `VoidCallback onPrev`; disabled state uses muted text color (FR-011–012)
- [x] T024 [P] [US3] Add page dots indicator to `DhikrDetailScreen` in `lib/features/adhkar/presentation/dhikr_detail_screen.dart` — row of small circles below `DhikrCounterWidget`: active dot is gold-filled, inactive dots are outlined ivory; only show dots when category has > 1 dhikr (FR — edge case single dhikr); limit visible dots to 5 with ellipsis for long categories (FR-007 page dots)
- [x] T025 [US3] Add progress indicator to `DhikrDetailScreen` app bar in `lib/features/adhkar/presentation/dhikr_detail_screen.dart` — show "N / Total" (Arabic numerals) in app bar subtitle or trailing widget; updates as `_currentIndex` changes (FR-010)
- [x] T026 [US3] Wire `DhikrNavBar` into `DhikrDetailScreen` in `lib/features/adhkar/presentation/dhikr_detail_screen.dart` — `onNext`: `setState(() => _currentIndex++)` if `_currentIndex < total - 1`; `onPrev`: `setState(() => _currentIndex--)` if `_currentIndex > 0`; `canGoNext`/`canGoPrev` derived from `_currentIndex` and list length; counter state persists because `dhikrCounterProvider` is keyed by (categoryId, index) and Hive-backed (FR-011–013, Clarification Q4)

**Checkpoint**: Run Scenarios 5, 6 from [quickstart.md](quickstart.md). Navigation must update progress indicator and preserve counter on back-navigation.

---

## Phase 6: User Story 4 — Use the Digital Tasbih Counter (Priority: P2)

**Goal**: Full digital tasbih: dhikr selector, incrementing counter, round completion, sound + vibration feedback, history log, session persistence across restarts.

**Independent Test**: Open tasbih → select "سبحان الله" → tap 33 times → one round recorded → reset → check history. See Scenarios 10–13 in [quickstart.md](quickstart.md).

### Implementation

- [x] T027 [US4] Implement `TasbihService` in `lib/features/adhkar/data/services/tasbih_service.dart` — `TasbihSessionModel loadSession()`: reads `tasbihSessionBox.get('current')` or returns default session (سبحان الله, 0, 0, 33); `Future<void> saveSession(TasbihSessionModel)`: writes to `tasbihSessionBox` under key `'current'`; `Future<void> saveHistory(TasbihHistoryEntry)`: adds to `tasbihHistoryBox` keyed by current ISO timestamp; `List<TasbihHistoryEntry> getHistory()`: returns all entries sorted by key descending; `Map<String, int> loadCustomTargets()` / `Future<void> saveCustomTargets(Map<String, int>)`: SharedPreferences `tasbih_custom_targets` as JSON
- [x] T028 [P] [US4] Implement `TasbihAudioService` in `lib/features/adhkar/data/services/tasbih_audio_service.dart` — wraps two `just_audio.AudioPlayer` instances (`_tapPlayer`, `_completePlayer`); `Future<void> init()`: preload both assets; `Future<void> playTap()` / `Future<void> playComplete()`; `void dispose()`; sound plays only when `soundEnabled == true`
- [x] T029 [US4] Implement `TasbihNotifier` as `StateNotifier<TasbihSessionModel>` in `lib/features/adhkar/providers/adhkar_providers.dart` — initialized from `TasbihService().loadSession()`; `Future<void> increment()`: currentCount++; if currentCount == target: completedRounds++, currentCount = 0 (round complete); save session via `TasbihService`; `Future<void> reset()`: if completedRounds > 0 save history entry first; reset session to (currentDhikr, 0, 0, target); `Future<void> selectDhikr(String type)`: reset counts, apply default/custom target for new type; wire `tasbihSessionProvider`, `tasbihHistoryProvider`, `tasbihSoundEnabledProvider`, `tasbihVibrationEnabledProvider` providers (FR-015–018, FR-024–026, FR-029)
- [x] T030 [P] [US4] Create `TasbihDhikrSelector` widget in `lib/features/adhkar/presentation/widgets/tasbih_dhikr_selector.dart` — horizontal row of 3 text buttons: "سبحان الله", "الحمد لله", "الله أكبر"; active tab has gold border + gold text, inactive is muted; `onSelect(String dhikrType)` callback (FR-015)
- [x] T031 [P] [US4] Create `TasbihBeadArc` widget in `lib/features/adhkar/presentation/widgets/tasbih_bead_arc.dart` — custom `CustomPainter` drawing a semicircular arc of bead circles; total beads = target; filled beads (gold) = currentCount; empty beads (gray outline); updates reactively from session state (design reference: user screenshot)
- [x] T032 [US4] Create `TasbihScreen` in `lib/features/adhkar/presentation/tasbih_screen.dart` — `ConsumerStatefulWidget`; AppBar: "التسبيح" title, leading "إعادة" text button, trailing "سجّل" text button; Body: `TasbihBeadArc`, `TasbihDhikrSelector`, large count display ("٢٣ من ٣٣" style), completed-rounds indicator ("دورتان مكتملتان"), large CTA "اضغط للتسبيح" `ElevatedButton`; bottom toolbar: sound toggle (صوت), vibration toggle (اهتزاز), "تحديد العدد" text button; init `TasbihAudioService` in `initState`, dispose in `dispose` (FR-015–020, FR-024)
- [x] T033 [US4] Wire tap handler in `TasbihScreen` in `lib/features/adhkar/presentation/tasbih_screen.dart` — CTA onPressed: call `ref.read(tasbihSessionProvider.notifier).increment()`; if vibration enabled: `Vibration.vibrate(duration: 30)`; if round completed: `Vibration.vibrate(pattern: [0, 100, 50, 100])`; play tap/complete sound via `TasbihAudioService` based on sound toggle (FR-016–017, FR-019, FR-019a)
- [x] T034 [P] [US4] Create `TasbihHistoryScreen` in `lib/features/adhkar/presentation/tasbih_history_screen.dart` — `ConsumerWidget`; shows list of `TasbihHistoryEntry` from `tasbihHistoryProvider`; each row: dhikr type + total count + formatted date; empty-state Arabic message when list is empty (FR-024, FR-025)
- [x] T035 [US4] Implement "تحديد العدد" dialog in `TasbihScreen` in `lib/features/adhkar/presentation/tasbih_screen.dart` — show `showDialog` with a number picker (or text field); on confirm: call `tasbihSessionProvider.notifier.selectDhikr(currentType)` with new target; persist custom target to `TasbihService.saveCustomTargets()` (FR-020)
- [x] T036 [US4] Add navigation from Adhkar screen banner to `TasbihScreen` in `lib/features/adhkar/presentation/adhkar_screen.dart` — "ابدأ الآن" button: `Navigator.push(TasbihScreen())`; wire "سجّل" button in `TasbihScreen` to `Navigator.push(TasbihHistoryScreen())` (FR-014)

**Checkpoint**: Run Scenarios 10–13 from [quickstart.md](quickstart.md). Round completion, sound, vibration, history, and session restore must all pass.

---

## Phase 7: User Story 5 — Track Daily Adhkar Progress (Priority: P3)

**Goal**: Counter progress persists across the day and resets automatically at midnight. Category completion badges reflect daily state.

**Independent Test**: Complete counters → force-quit → reopen same day → counters preserved. Change device date → reopen → counters reset. Category badge appears only when all counters in category are 0. See Scenarios 7–9 in [quickstart.md](quickstart.md).

### Implementation

- [x] T037 [US5] Implement midnight reset check in `DhikrCounterService` in `lib/features/adhkar/data/services/dhikr_counter_service.dart` — `String _today()` returns `DateTime.now().toLocal()` formatted as `yyyy-MM-dd`; all read/write operations use `_today()` as date prefix; add `Future<void> clearStaleKeys()`: iterate all box keys, delete those whose date prefix is earlier than today and older than 7 days
- [x] T038 [US5] Call `DhikrCounterService().clearStaleKeys()` on `AdhkarScreen` mount in `lib/features/adhkar/presentation/adhkar_screen.dart` — trigger in `ConsumerStatefulWidget.initState` so stale daily keys are cleaned on each Adhkar tab visit; this is also the implicit midnight reset (FR-022, FR-028)
- [x] T039 [US5] Validate `categoryCompletionProvider` recomputes after counter changes in `lib/features/adhkar/providers/adhkar_providers.dart` — ensure the derived provider watches all `dhikrCounterProvider` instances for the category; when any counter updates, `AdhkarCategoryCard` badge re-renders reactively (FR-027)

**Checkpoint**: Run Scenarios 7, 8, 9 from [quickstart.md](quickstart.md). Progress must persist across restarts and reset after midnight.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Wiring, edge cases, and validation of all quickstart scenarios.

- [ ] T040 Handle single-dhikr category edge case in `DhikrDetailScreen` in `lib/features/adhkar/presentation/dhikr_detail_screen.dart` — when `dhikrList.length == 1`: hide `DhikrNavBar` entirely and show no page dots (spec edge case)
- [ ] T041 [P] Handle null source/virtue fields in `DhikrDetailScreen` in `lib/features/adhkar/presentation/dhikr_detail_screen.dart` — when `dhikr.source == null`: omit source row; when `dhikr.virtue == null`: omit virtue row; no blank space left (spec edge case)
- [ ] T042 [P] Handle missing vibration hardware in `TasbihScreen` in `lib/features/adhkar/presentation/tasbih_screen.dart` — call `Vibration.hasVibrator()` in `initState`; if false: hide vibration toggle (spec edge case)
- [ ] T043 [P] Verify custom tasbih target persists across app restarts in `TasbihService` in `lib/features/adhkar/data/services/tasbih_service.dart` — `loadCustomTargets()` is called during `TasbihNotifier` initialization to restore any previously set target; validate against Scenario 14 in [quickstart.md](quickstart.md)
- [ ] T044 Write unit tests in `test/unit/adhkar_service_test.dart` — test: `getCategories()` parses all 8 required categories from bundled JSON; `getDhikrByCategory('morning')` returns correct dhikr count; null source/virtue handled without exception
- [ ] T045 [P] Write unit tests in `test/unit/dhikr_counter_service_test.dart` — test: `getRemaining()` returns `repeat` for untouched dhikr; `decrement()` stores remaining-1; `isComplete()` returns true at 0; stale key from yesterday is ignored on read
- [ ] T046 [P] Write unit tests in `test/unit/tasbih_service_test.dart` — test: `increment()` reaches target → round completes + count resets; `reset()` with completedRounds > 0 saves history entry; `loadSession()` restores previous session after save
- [ ] T047 Run full quickstart validation in `quickstart.md` — manually verify all 14 scenarios pass end-to-end on a physical device or simulator

---

## Dependencies

```
Phase 1 (Setup)
    └─► Phase 2 (Foundational)
            ├─► Phase 3 (US1 — Browse Categories) ──► Phase 8 begins in parallel
            ├─► Phase 4 (US2 — Read & Count)       ─── after Phase 3
            ├─► Phase 5 (US3 — Navigate)            ─── after Phase 4
            ├─► Phase 6 (US4 — Tasbih)              ─── independent of US2/US3
            └─► Phase 7 (US5 — Daily Progress)      ─── after Phase 4
```

## Parallel Execution Examples

**Within Phase 2**: T006 (DhikrModel), T008 (TasbihHistoryEntry), T012 (DhikrCounterService), T013 (providers skeleton) can all be worked simultaneously by different agents.

**US1 + US4 independence**: Phase 3 (category grid) and Phase 6 (tasbih) have no shared state and can be developed in parallel once Phase 2 is complete.

**Within Phase 6**: T028 (TasbihAudioService), T030 (TasbihDhikrSelector), T031 (TasbihBeadArc), T034 (TasbihHistoryScreen) are independent widgets/services that can be built in parallel.

## Implementation Strategy

**MVP (deliver first)**: Phases 1–4 — users can browse categories and complete dhikr with a working counter. This covers both P1 user stories and the core spiritual value of the feature.

**Increment 2**: Phase 5 (navigation) — users can step through full category sequences.

**Increment 3**: Phase 6 (tasbih) — digital tasbih with sound, vibration, history.

**Increment 4**: Phase 7 + 8 (daily tracking + polish) — daily reset, completion badges, edge cases, tests.
