# Tasks: Prayer Times (مواقيت الصلاة)

**Input**: Design documents from `specs/005-prayer-times/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/)

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: User story this task delivers (US1–US5 from spec.md)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the one missing dependency and extend existing storage infrastructure before any feature work begins.

- [x] T001 Add `dio: ^5.4.3` to `pubspec.yaml` dependencies and run `flutter pub get`
- [x] T002 Extend `StorageService` with `readDouble`, `writeDouble`, `readInt`, `writeInt` methods using `SharedPreferences` typed getters/setters in `lib/shared/local_storage/storage_service.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure required by all user stories. Nothing in Phase 3+ can start until this phase is complete.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T003 Replace the `LocationService` stub with a real implementation using `geolocator`: `getCurrentPosition()` with 10-second timeout, `getLastKnownPosition()` fallback, and `checkPermission()` in `lib/core/services/location_service.dart`
- [x] T004 [P] Add `TimeFormatter.toArabic12h(DateTime dt) → String` static method to `lib/core/utils/helpers.dart` — converts DateTime to 12-hour format with Arabic ص/م markers (e.g., `4:12 ص`, `3:48 م`)
- [x] T005 [P] Create `PrayerTimesModel` with `@HiveType(typeId: 10)` annotations and all fields (cacheKey, date, latitude, longitude, methodId, fajr, sunrise, dhuhr, asr, maghrib, isha, imsak, fetchedAt) in `lib/features/prayer_times/data/models/prayer_times_model.dart`
- [x] T006 [P] Create `HijriDateModel` with `@HiveType(typeId: 11)` annotations and all fields (gregorianDate, day, monthAr, year, readable) in `lib/features/prayer_times/data/models/hijri_date_model.dart`
- [x] T007 Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `prayer_times_model.g.dart` and `hijri_date_model.g.dart` Hive adapters (depends on T005, T006)
- [x] T008 Register `PrayerTimesModelAdapter` and `HijriDateModelAdapter`, and open `prayerTimesBox` and `hijriDateBox` Hive boxes in `lib/main.dart` (depends on T007)
- [x] T009 [P] Create `PrayerCalculationService` wrapping the `adhan` package: `PrayerTimesModel calculate(double lat, double lon, int methodId, DateTime date)` — maps method IDs (0–4) to `CalculationMethod` factories, derives Imsak as Fajr − 10 min, formats all times via `TimeFormatter.toArabic12h()` in `lib/features/prayer_times/data/services/prayer_calculation_service.dart`
- [x] T010 [P] Create `PrayerCacheService` with `save(PrayerTimesModel)`, `get(String cacheKey) → PrayerTimesModel?`, `isStale(String date) → bool`, and composite key builder `buildKey(lat, lon, methodId, date) → String` in `lib/features/prayer_times/data/services/prayer_cache_service.dart`

**Checkpoint**: Foundation complete — all user story phases can now begin.

---

## Phase 3: User Story 1 — View Today's Prayer Times (Priority: P1) 🎯 MVP

**Goal**: Full prayer times screen showing all 7 time slots, Hijri date header, and next-prayer highlight.

**Independent Test**: Navigate to the Prayer Times tab with location available and internet. All 7 times appear in Arabic 12-hour format, the Hijri date shows in the header, and the next upcoming prayer row is visually highlighted (gold).

- [x] T011 [P] [US1] Create `HijriDateService` with `getHijriDate(String gregorianDate) → Future<HijriDateModel>` — checks `hijriDateBox` cache first, fetches from `https://api.aladhan.com/v1/gToH/{DD-MM-YYYY}` on miss using `dio`, parses `data.hijri` fields in `lib/features/prayer_times/data/services/hijri_date_service.dart`
- [x] T012 [P] [US1] Create `PrayerTimeRow` widget — displays one prayer's Arabic name and 12-hour time; accepts `nameAr`, `time`, `isHighlighted` parameters; uses gold accent when highlighted in `lib/features/prayer_times/presentation/widgets/prayer_time_row.dart`
- [x] T013 [US1] Create `prayer_times_providers.dart` with all six providers: `locationProvider` (FutureProvider<Position> with CachedLocation fallback), `calculationMethodProvider` (StateProvider<int> default 0, reads `prayer_method_id` from SharedPreferences), `prayerTimesProvider` (FutureProvider — orchestrates cache check → calculate → save), `hijriDateProvider` (FutureProvider<HijriDateModel>), `nextPrayerProvider` (StreamProvider<NextPrayerModel> via Stream.periodic(1 min)), `manualCityProvider` (StateProvider<ManualCityEntry?>) in `lib/features/prayer_times/providers/prayer_times_providers.dart`
- [x] T014 [US1] Replace the `PrayerTimesScreen` stub with the full screen: header section (Hijri + Gregorian date from `hijriDateProvider`), 7 `PrayerTimeRow` widgets driven by `prayerTimesProvider`, loading skeleton while providers load, `AsyncError` fallback message in `lib/features/prayer_times/presentation/prayer_times_screen.dart`

**Checkpoint**: User Story 1 independently testable — all 7 prayer times render for a real GPS location.

---

## Phase 4: User Story 2 — Countdown to Next Prayer + Home Card (Priority: P1)

**Goal**: Live countdown hero on the Prayer Times screen and a `PrayerCardWidget` on the Home screen, both updating every minute.

**Independent Test**: With prayer times loaded, the countdown shows the correct `"بعد h:mm"` value. Wait 1 minute (or mock time) — the countdown updates without a screen refresh. Home screen shows the same next-prayer name, time, and countdown.

- [x] T015 [P] [US2] Create `NextPrayerHero` widget — large display of next prayer Arabic name, formatted time, and `"بعد h:mm"` countdown string derived from `nextPrayerProvider`; shows shimmer while loading in `lib/features/prayer_times/presentation/widgets/next_prayer_hero.dart`
- [x] T016 [US2] Integrate `NextPrayerHero` into `PrayerTimesScreen` as the hero section above the prayer rows in `lib/features/prayer_times/presentation/prayer_times_screen.dart`
- [x] T017 [P] [US2] Create `PrayerCardWidget` (zero-parameter `ConsumerWidget`) — shows next prayer name, time, countdown from `nextPrayerProvider`; shows `"—"` on error; uses `IslamicCard` wrapper in `lib/features/prayer_times/presentation/widgets/prayer_card_widget.dart`
- [x] T018 [US2] Add `const PrayerCardWidget()` to `HomeScreen` body above the existing center text in `lib/features/home/presentation/home_screen.dart`

**Checkpoint**: User Stories 1 and 2 fully functional — full prayer screen + countdown + home card all working.

---

## Phase 5: User Story 3 — Offline Access with Cached Times (Priority: P2)

**Goal**: Cached prayer times shown with a "last updated" indicator when offline; auto-refresh on network restore / foreground resume.

**Independent Test**: Load prayer times, enable airplane mode, kill and reopen the app. Full prayer list appears with a visible "آخر تحديث" timestamp. Re-enable network, bring app to foreground — the indicator disappears.

- [x] T019 [US3] Add an `OfflineBanner` widget to `PrayerTimesScreen` — reads `fetchedAt` from the `PrayerTimesModel` returned by `prayerTimesProvider`; shows `"آخر تحديث: h:mm ص/م"` in a non-intrusive banner when the model's `date` matches today but no fresh fetch occurred in this session in `lib/features/prayer_times/presentation/prayer_times_screen.dart`
- [x] T020 [US3] Add foreground-resume refresh to `PrayerTimesScreen` using `WidgetsBindingObserver.didChangeAppLifecycleState`; call `ref.invalidate(prayerTimesProvider)` when `AppLifecycleState.resumed` fires and the cached date differs from today in `lib/features/prayer_times/presentation/prayer_times_screen.dart`

**Checkpoint**: Offline access verified — cached times display without error; auto-refresh fires on new-day foreground resume.

---

## Phase 6: User Story 4 — Change Calculation Method (Priority: P2)

**Goal**: A Settings screen reachable via AppBar gear icon, with a 5-option calculation method selector that persists and immediately refreshes prayer times.

**Independent Test**: Open Settings via gear icon. Select "رابطة العالم الإسلامي". Return to Prayer Times tab — Dhuhr time has changed. Kill and relaunch the app — Settings still shows "رابطة العالم الإسلامي" and times reflect that method.

- [x] T021 [P] [US4] Create `SettingsService` with `getMethodId() → int`, `saveMethodId(int id) → Future<void>` using `StorageService.readInt`/`writeInt` with key `prayer_method_id` in `lib/features/settings/data/services/settings_service.dart`
- [x] T022 [P] [US4] Create `CalculationMethodTile` widget — a `ListTile` showing the method Arabic name with a radio or trailing checkmark when selected; accepts `method`, `isSelected`, `onTap` parameters in `lib/features/settings/presentation/widgets/calculation_method_tile.dart`
- [x] T023 [US4] Create `SettingsScreen` (`ConsumerWidget`) — section "طريقة الحساب" listing all 5 `CalculationMethodConfig` entries as `CalculationMethodTile`s; tapping a tile writes to `calculationMethodProvider` and calls `SettingsService.saveMethodId()` in `lib/features/settings/presentation/settings_screen.dart`
- [x] T024 [US4] Add `settings_outlined` `IconButton` to the `AppBar` of `MainNavigation` that pushes `SettingsScreen` via `Navigator.push` in `lib/app/routes.dart`
- [x] T025 [US4] Initialise `calculationMethodProvider` from `SettingsService.getMethodId()` at startup — add override in `ProviderScope` or load in a top-level `initProvider` in `lib/app/app.dart`

**Checkpoint**: Calculation method change persists and updates prayer times within 2 seconds.

---

## Phase 7: User Story 5 — Location Denied / Manual City Fallback (Priority: P3)

**Goal**: When GPS is denied, show a prompt with a "تحديد المدينة يدوياً" action that opens a searchable city list; the selected city persists across restarts.

**Independent Test**: Revoke location permission. Open Prayer Times tab. The location-denied prompt appears. Tap "تحديد المدينة يدوياً". Search for "القاهرة", confirm. Prayer times for Cairo load. Kill and relaunch — Cairo's times still show without re-prompting.

- [x] T026 [P] [US5] Create `cities_data.dart` with a `const List<ManualCityEntry> kCities` containing ~50 cities (Egyptian cities, Arab capitals, major global Muslim-population cities) in `lib/core/constants/cities_data.dart`
- [x] T027 [US5] Implement `manualCityProvider` persistence: on write, save `selected_city_name`, `selected_city_lat`, `selected_city_lon` to `StorageService`; on app init, restore from `StorageService` in `lib/features/prayer_times/providers/prayer_times_providers.dart`
- [x] T028 [P] [US5] Create `CitySearchSheet` — a modal bottom sheet with an Arabic `TextField` search bar filtering `kCities` by `nameAr`; tapping a city sets `manualCityProvider` and closes the sheet in `lib/features/prayer_times/presentation/widgets/city_search_sheet.dart`
- [x] T029 [US5] Add location-denied UI state to `PrayerTimesScreen` — when `locationProvider` throws a `LocationException` and `manualCityProvider` is null, show an explanatory message and a "تحديد المدينة يدوياً" `ElevatedButton` that opens `CitySearchSheet`; when `manualCityProvider` is non-null, show a small "📍 cityName" chip with a tap-to-change action in `lib/features/prayer_times/presentation/prayer_times_screen.dart`

**Checkpoint**: All 5 user stories independently functional and testable.

---

## Phase 8: Polish & Tests

**Purpose**: Verify correctness with targeted unit and widget tests, then run the quickstart validation guide.

- [x] T030 [P] Write unit tests for `PrayerCalculationService` — verify known lat/lon + method produces expected times, Imsak is Fajr−10 min, method ID 0–4 all produce non-null results in `test/unit/prayer_calculation_service_test.dart`
- [x] T031 [P] Write unit tests for `HijriDateService` — mock `dio` response; verify JSON parsing maps to `HijriDateModel` fields; verify cache hit skips network call in `test/unit/hijri_date_service_test.dart`
- [x] T032 [P] Write unit tests for `TimeFormatter.toArabic12h()` — boundary cases: midnight (12:00 ص), noon (12:00 م), 11:59 PM (11:59 م), 4:02 AM (4:02 ص) in `test/unit/time_formatter_test.dart`
- [x] T033 [P] Write unit tests for `PrayerCacheService` — composite key construction, stale detection (yesterday's date), Hive save/get round-trip in `test/unit/prayer_cache_service_test.dart`
- [x] T034 [P] Write widget tests for `PrayerTimesScreen` — verify 7 rows render from mocked `prayerTimesProvider`; verify highlighted row changes with mocked next prayer; verify offline banner visible when `fetchedAt` is stale in `test/widget/prayer_times_screen_test.dart`
- [x] T035 [P] Write widget tests for `PrayerCardWidget` — verify name/time/countdown render from mocked `nextPrayerProvider`; verify `"—"` on error state in `test/widget/prayer_card_widget_test.dart`
- [x] T036 [P] Write widget tests for `SettingsScreen` — verify 5 method tiles render; verify tapping a tile updates `calculationMethodProvider` in `test/widget/settings_screen_test.dart`
- [ ] T037 Run all validation scenarios from `specs/005-prayer-times/quickstart.md` on a physical device or emulator

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup (T001–T002) — **blocks all user stories**
- **US1 (Phase 3)**: Depends on Foundational complete (T003–T010)
- **US2 (Phase 4)**: Depends on US1 complete (T011–T014) — `nextPrayerProvider` consumes `prayerTimesProvider`
- **US3 (Phase 5)**: Depends on US1 complete (T013–T014) — adds UI state to existing screen
- **US4 (Phase 6)**: Depends on Foundational complete; can be built in parallel with US2/US3
- **US5 (Phase 7)**: Depends on US1 providers (T013) — extends `manualCityProvider`; can be built in parallel with US2–US4
- **Polish (Phase 8)**: Depends on all desired user stories complete

### User Story Dependencies

```
Setup (T001–T002)
    │
    ▼
Foundational (T003–T010)
    │
    ├──► US1 (T011–T014)
    │         │
    │         ├──► US2 (T015–T018)   ← depends on US1 providers
    │         ├──► US3 (T019–T020)   ← depends on US1 screen
    │         └──► US5 (T026–T029)   ← depends on US1 providers
    │
    └──► US4 (T021–T025)             ← depends only on Foundational
```

### Within Each Story

- [P]-marked tasks in the same phase touch different files and can be worked in parallel
- Services before providers; providers before screens; screens before integration
- Commit after each task or logical group (e.g., after each phase checkpoint)

---

## Parallel Execution Examples

### Phase 2 (Foundational) — 4 tasks can run in parallel

```
Parallel group A (T004 + T005 + T006 + T009 + T010):
  - T004: Add TimeFormatter to helpers.dart
  - T005: Create PrayerTimesModel
  - T006: Create HijriDateModel
  - T009: Create PrayerCalculationService
  - T010: Create PrayerCacheService

Sequential after group A:
  - T007: Run build_runner (depends on T005 + T006)
  - T008: Register adapters in main.dart (depends on T007)
```

### Phase 3 (US1) — 2 tasks can run in parallel

```
Parallel group (T011 + T012):
  - T011: Create HijriDateService
  - T012: Create PrayerTimeRow widget

Sequential after:
  - T013: Create all providers (depends on T009 + T010 + T011)
  - T014: Implement PrayerTimesScreen (depends on T012 + T013)
```

### Phase 4 (US2) — 2 tasks can run in parallel

```
Parallel group (T015 + T017):
  - T015: Create NextPrayerHero widget
  - T017: Create PrayerCardWidget

Sequential after:
  - T016: Integrate NextPrayerHero into PrayerTimesScreen (depends on T015)
  - T018: Add PrayerCardWidget to HomeScreen (depends on T017)
```

### Phase 8 (Polish) — All test tasks can run in parallel

```
Parallel group (T030–T036):
  - T030: PrayerCalculationService unit tests
  - T031: HijriDateService unit tests
  - T032: TimeFormatter unit tests
  - T033: PrayerCacheService unit tests
  - T034: PrayerTimesScreen widget tests
  - T035: PrayerCardWidget widget tests
  - T036: SettingsScreen widget tests
```

---

## Implementation Strategy

### MVP (User Stories 1 + 2 — both P1)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T010)
3. Complete Phase 3: US1 (T011–T014) — all 7 prayer times display
4. Complete Phase 4: US2 (T015–T018) — countdown + home card
5. **STOP and VALIDATE**: Run Scenarios 1 and 2 from `quickstart.md`
6. The app is usable at this point for the core prayer times experience

### Incremental Delivery

- After MVP: add US3 (offline) → US4 (settings) → US5 (city fallback)
- Each phase is independently demonstrable without the others
- US4 can be built in parallel with US3 if needed (no shared file conflicts)

---

## Notes

- `[P]` = parallel-safe: different files, no blocking dependency on an incomplete same-phase task
- US1 + US2 are both P1 and tightly coupled (same screen, shared providers) — implement sequentially
- The `adhan` package does all prayer time math locally; the only network call is Hijri date (1 req/day)
- After T007 (build_runner), generated `*.g.dart` files must be committed alongside model files
- `dio` (T001) is the only new pubspec dependency — all other packages are already declared
