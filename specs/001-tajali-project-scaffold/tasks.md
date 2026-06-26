# Tasks: تَجَلِّي Project Scaffold

**Input**: Design documents from `specs/001-tajali-project-scaffold/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/screen-contract.md ✅, quickstart.md ✅

**No tests**: Spec does not request a test suite for Phase 1 scaffold.

**Current project state**: Flutter project exists at repo root with only `lib/main.dart` (default counter app) and a bare `pubspec.yaml` (no feature dependencies, no assets).

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies on other incomplete tasks)
- **[US1/2/3]**: User story this task belongs to
- Exact file paths in every description

---

## Phase 1: Setup (Project Configuration)

**Purpose**: Replace the default project config with the full تَجَلِّي configuration. Blocks everything else.

- [x] T001 Update `pubspec.yaml`: set description to "تَجَلِّي — Islamic companion app", update `sdk` environment to `^3.3.0`, add all production dependencies (flutter_riverpod ^2.5.1, google_fonts ^6.2.1, hive_flutter ^1.1.0, shared_preferences ^2.2.3, geolocator ^11.0.0, flutter_compass ^0.7.0, permission_handler ^11.3.1, adhan ^1.1.0, just_audio ^0.9.38, flutter_local_notifications ^17.2.2, flutter_svg ^2.0.10+1, vibration ^2.0.0), replace dev_dependencies (keep flutter_test, replace flutter_lints with ^3.0.0, add hive_generator ^2.0.1 and build_runner ^2.4.9), add assets section (assets/images/, assets/svg/, assets/audio/, assets/data/), and add fonts section (Amiri with Amiri-Regular.ttf + Amiri-Bold.ttf weight:700, AmiriQuran with AmiriQuran.ttf)
- [x] T002 Run `flutter pub get` in the repo root to install all declared packages and generate `pubspec.lock`

**Checkpoint**: `pubspec.lock` updated, all packages installed with zero conflicts — proceed to Phase 2.

---

## Phase 2: Foundational (Theme System)

**Purpose**: Create the theme layer that every placeholder screen imports. MUST complete before any feature screen can be written.

**⚠️ CRITICAL**: No US1, US2, or US3 task can compile until this phase is complete.

- [x] T003 [P] Create `lib/app/theme/app_colors.dart`: define `AppColors` class (private constructor) with all colour constants from plan.md — primaryGreen (0xFF1B4332), primaryGreenDark (0xFF0D2218), gold (0xFFC9A84C), goldLight (0xFFE8C97A), goldDark (0xFF9A7A2E), backgroundParchment (0xFFF5E6C8), surfaceIvory (0xFFFAF0DC), surfaceCard (0xFFF0E0BE), textDark (0xFF3D1F00), textMedium (0xFF6B3A1F), textMuted (0xFF9C7A5A), textOnDark (0xFFFAF0DC), darkBackground (0xFF1A1209), darkSurface (0xFF2A1F0E), darkCard (0xFF332810), success (0xFF2D6A4F), warning (0xFFC9A84C), error (0xFF8B0000), navBackground (0xFF0A1A10), navActive (0xFFC9A84C), navInactive (0x80FAF0DC)
- [x] T004 [P] Create `lib/app/theme/app_fonts.dart`: define `AppFonts` class (private constructor) with string constants `amiri = 'Amiri'` and `amiriQuran = 'AmiriQuran'`
- [x] T005 Create `lib/app/theme/app_text_styles.dart`: define `AppTextStyles` class (private constructor) with all `TextStyle` constants from plan.md — heading1 (Amiri, 28, bold, gold, height 1.4), heading2 (Amiri, 22, bold, textDark, 1.4), heading3 (Amiri, 18, bold, textDark, 1.4), body (Amiri, 16, textDark, 1.6), bodySmall (Amiri, 13, textMedium, 1.5), quranText (AmiriQuran, 24, textDark, 2.0), goldLabel (Amiri, 14, bold, gold, letterSpacing 0.5), onDark (Amiri, 16, textOnDark, 1.6), onDarkBold (Amiri, 18, bold, textOnDark) — imports app_colors.dart and app_fonts.dart
- [x] T006 Create `lib/app/theme/app_theme.dart`: define `AppTheme` class (private constructor) with `lightTheme` and `darkTheme` static getters exactly as specified in plan.md — Material3, light ColorScheme (primaryGreen, gold, surfaceIvory), dark ColorScheme (gold, primaryGreen, darkSurface), AppBarTheme, CardTheme, DividerTheme, BottomNavigationBarTheme (navBackground, fixed type), full TextTheme mapping — imports app_colors.dart, app_fonts.dart, app_text_styles.dart

**Checkpoint**: All four theme files compile with zero errors. Proceed to Phase 3.

---

## Phase 3: User Story 1 — Developer Sets Up and Runs the App (Priority: P1) 🎯 MVP

**Goal**: A compilable, runnable app with five navigable RTL bottom-nav tabs; each tab preserves widget state via IndexedStack.

**Independent Test**: Run the app on a simulator, tap all five tabs, confirm no crashes and each tab displays its Arabic label. See `quickstart.md` SC-001 through SC-003.

### Implementation for User Story 1

- [x] T007 [P] [US1] Create `lib/features/home/presentation/home_screen.dart`: `HomeScreen` StatelessWidget, `const HomeScreen({super.key})`, returns `Scaffold(appBar: AppBar(title: Text('نور')), body: Center(child: Text('الشاشة الرئيسية', style: AppTextStyles.heading2)))` — imports app_text_styles.dart
- [x] T008 [P] [US1] Create `lib/features/quran/presentation/quran_screen.dart`: `QuranScreen` StatelessWidget, same pattern, AppBar title 'القرآن', body label 'القرآن الكريم', style AppTextStyles.heading2
- [x] T009 [P] [US1] Create `lib/features/adhkar/presentation/adhkar_screen.dart`: `AdhkarScreen` StatelessWidget, AppBar title 'الأذكار', body label 'الأذكار'
- [x] T010 [P] [US1] Create `lib/features/prayer_times/presentation/prayer_times_screen.dart`: `PrayerTimesScreen` StatelessWidget, AppBar title 'الصلاة', body label 'مواقيت الصلاة'
- [x] T011 [P] [US1] Create `lib/features/qibla/presentation/qibla_screen.dart`: `QiblaScreen` StatelessWidget, AppBar title 'القبلة', body label 'القبلة'
- [x] T012 [P] [US1] Create `lib/features/qibla/presentation/tasbih_screen.dart`: `TasbihScreen` StatelessWidget scaffold only (AppBar title 'المسبحة', body label 'المسبحة') — file must compile but MUST NOT be imported in routes.dart per FR-004a and contracts/screen-contract.md
- [x] T013 [US1] Create `lib/app/routes.dart`: declare `selectedTabProvider` as `StateProvider<int>((ref) => 0)`; implement `MainNavigation` as `ConsumerWidget` wrapping a `Directionality(textDirection: TextDirection.rtl)` → `Scaffold` with `body: IndexedStack(index: selectedIndex, children: _screens)` and `BottomNavigationBar` (five items: الرئيسية/home icons, القرآن/menu_book icons, الأذكار/self_improvement icons, القبلة/explore icons, الصلاة/access_time icons; `type: fixed`; `onTap` writes to selectedTabProvider) — imports all five screens (T007-T011) and flutter_riverpod
- [x] T014 [US1] Create `lib/app/app.dart`: implement `TajaliApp` as `ConsumerWidget` returning `MaterialApp(title: 'تَجَلِّي', debugShowCheckedModeBanner: false, locale: Locale('ar'), supportedLocales: [Locale('ar'), Locale('en')], theme: AppTheme.lightTheme, darkTheme: AppTheme.darkTheme, themeMode: ThemeMode.light, home: MainNavigation())` — imports app_theme.dart and routes.dart
- [x] T015 [US1] Rewrite `lib/main.dart`: `main()` marked `async`, calls `WidgetsFlutterBinding.ensureInitialized()`, `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`, `SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light))`, then `runApp(ProviderScope(child: TajaliApp()))` — imports flutter/services.dart, flutter_riverpod, app.dart

**Checkpoint**: `flutter run` launches a five-tab app with RTL layout. All tabs navigate without crashes. User Story 1 is independently functional.

---

## Phase 4: User Story 2 — Developer Starts Building a Feature Module (Priority: P2)

**Goal**: All core and shared stub files exist with compilable placeholder content so a developer can immediately import and extend them.

**Independent Test**: Open any feature folder; confirm `presentation/` and placeholder screen file exist. Run `flutter analyze` — zero errors across all modules.

### Implementation for User Story 2

- [x] T016 [P] [US2] Create `lib/core/constants/app_constants.dart`: define `AppConstants` class (private constructor) with placeholder string constants: `appName = 'تَجَلِّي'`, `appVersion = '1.0.0'`, `defaultLocale = 'ar'`
- [x] T017 [P] [US2] Create `lib/core/utils/helpers.dart`: define `AppHelpers` class (private constructor) with a single static stub method `formatDate(DateTime date) => date.toIso8601String()` — ready to be extended in later phases
- [x] T018 [P] [US2] Create `lib/core/services/location_service.dart`: define `LocationService` class with stub `Future<void> initialize() async {}` and stub `Future<Map<String, double>> getCurrentLocation() async => {}` — placeholder for Phase 4 (Qibla/Prayer Times)
- [x] T019 [P] [US2] Create `lib/shared/local_storage/storage_service.dart`: define `StorageService` class with stub `Future<void> initialize() async {}`, stub `Future<void> write(String key, dynamic value) async {}`, stub `dynamic read(String key) => null` — placeholder for Hive/SharedPreferences wiring in later phases
- [x] T020 [P] [US2] Create `lib/core/widgets/islamic_card.dart`: define `IslamicCard` StatelessWidget with required `child` Widget parameter; returns `Card(child: Padding(padding: EdgeInsets.all(16), child: child))` — minimal stub matching the card theme set in app_theme.dart
- [x] T021 [P] [US2] Create `lib/core/widgets/gold_divider.dart`: define `GoldDivider` StatelessWidget; returns `Divider(color: AppColors.gold, thickness: 0.8)` — imports app_colors.dart
- [x] T022 [P] [US2] Create `lib/core/widgets/arabesque_header.dart`: define `ArabesqueHeader` StatelessWidget with required `String title` parameter; returns `Container` with gold border and centred `Text(title, style: AppTextStyles.heading1)` — imports app_colors.dart, app_text_styles.dart

**Checkpoint**: `flutter analyze` reports zero errors or warnings. Every module directory has its files. User Story 2 independently satisfied.

---

## Phase 5: User Story 3 — Developer Adds Assets and Custom Fonts (Priority: P3)

**Goal**: Asset directories exist and are git-tracked; pubspec.yaml asset declarations point to real directories; font families compile and render correctly once font files are placed.

**Independent Test**: Place a test PNG in `assets/images/`, hot-restart — image renders. Verify Amiri font renders on screen (visually distinct from system default). See `quickstart.md` SC-004 and SC-006.

### Implementation for User Story 3

- [x] T023 [P] [US3] Create all asset directories with `.gitkeep` files to ensure git tracks them: `assets/images/.gitkeep`, `assets/svg/.gitkeep`, `assets/audio/.gitkeep`, `assets/data/.gitkeep` — `assets/fonts/` directory must exist but fonts themselves are not committed (developer places them manually)
- [x] T024 [P] [US3] Create `assets/fonts/` directory and add a `README.md` inside it documenting the three required font files: `Amiri-Regular.ttf` (Amiri family, weight 400), `Amiri-Bold.ttf` (Amiri family, weight 700), `AmiriQuran.ttf` (AmiriQuran family, weight 400) — links to the Amiri project on GitHub for download instructions
- [x] T025 [US3] Run `flutter pub get` again (if pubspec.yaml was not already synced) then run `flutter analyze` to confirm the full project (all phases combined) has zero errors

**Checkpoint**: Asset directories are committed. Font directory has instructions. `flutter analyze` reports zero errors across the entire codebase. User Story 3 satisfied.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation pass across all three user stories.

- [x] T026 [P] Run `flutter build apk --debug` to confirm Android build completes without errors (SC-005)
- [x] T027 [P] Run `flutter build ios --debug --no-codesign` to confirm iOS build completes without errors (SC-005)
- [x] T028 Execute all validation scenarios in `specs/001-tajali-project-scaffold/quickstart.md` (SC-001 through SC-006 and FR-007a) and confirm each passes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Requires Phase 1 complete (packages installed)
- **Phase 3 (US1)**: Requires Phase 2 complete (theme files must exist for screens to compile)
- **Phase 4 (US2)**: Requires Phase 2 complete; can run in parallel with Phase 3
- **Phase 5 (US3)**: Requires Phase 1 complete (pubspec.yaml with asset declarations); can run in parallel with Phases 3 and 4
- **Phase 6 (Polish)**: Requires Phases 3, 4, and 5 complete

### User Story Dependencies

- **US1 (P1)**: Depends on Foundational phase — no dependency on US2 or US3
- **US2 (P2)**: Depends on Foundational phase — no dependency on US1 or US3; can run in parallel with US1
- **US3 (P3)**: Depends only on pubspec.yaml (T001) — mostly independent; can run in parallel with US1 and US2

### Within Each Phase

- All `[P]`-marked tasks within a phase can start simultaneously
- T005 depends on T003 and T004 (needs colours and fonts)
- T006 depends on T003, T004, and T005 (full theme assembly)
- T013 (routes.dart) depends on T007–T011 (all five screens)
- T014 (app.dart) depends on T013 and T006
- T015 (main.dart) depends on T014

---

## Parallel Opportunities

### Phase 2 parallel batch

```text
Start simultaneously:
  T003 — app_colors.dart
  T004 — app_fonts.dart
Then (after both complete):
  T005 — app_text_styles.dart
Then:
  T006 — app_theme.dart
```

### Phase 3 + Phase 4 + Phase 5 parallel batch (after Phase 2)

```text
Phase 3 parallel batch:
  T007 — home_screen.dart
  T008 — quran_screen.dart
  T009 — adhkar_screen.dart
  T010 — prayer_times_screen.dart
  T011 — qibla_screen.dart
  T012 — tasbih_screen.dart
Then T013 → T014 → T015 (sequential)

Phase 4 parallel batch (can run alongside Phase 3):
  T016 — app_constants.dart
  T017 — helpers.dart
  T018 — location_service.dart
  T019 — storage_service.dart
  T020 — islamic_card.dart
  T021 — gold_divider.dart
  T022 — arabesque_header.dart

Phase 5 parallel batch (can run alongside Phases 3 and 4):
  T023 — asset directory .gitkeep files
  T024 — assets/fonts/README.md
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (T001–T002)
2. Complete Phase 2 (T003–T006)
3. Complete Phase 3 US1 tasks (T007–T015)
4. **STOP AND VALIDATE**: `flutter run` → five tabs, RTL, no crash
5. Demo the running scaffold

### Full Scaffold (All Stories)

1. Phase 1 → Phase 2 → launch Phases 3, 4, 5 in parallel → Phase 6
2. After Phase 3: US1 functional (running app)
3. After Phase 4: US2 functional (all modules importable)
4. After Phase 5: US3 functional (assets pipeline proven)
5. Phase 6: full quickstart validation confirms all success criteria

---

## Notes

- `[P]` tasks write to different files — safe to run in parallel
- `TasbihScreen` (T012) must exist but MUST NOT be imported in routes.dart
- Font files (Amiri-Regular.ttf, Amiri-Bold.ttf, AmiriQuran.ttf) are not auto-generated — developer must obtain and place in `assets/fonts/` before SC-004 can be validated
- `analysis_options.yaml` already exists at repo root with flutter_lints config — no change needed
- `cupertino_icons` package in original pubspec.yaml should be removed in T001 (not needed for this project)
