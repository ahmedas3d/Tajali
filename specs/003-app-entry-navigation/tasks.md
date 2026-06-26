# Tasks: App Entry Point & Navigation

**Input**: Design documents from `specs/003-app-entry-navigation/`

**Prerequisites**: [plan.md](plan.md) · [spec.md](spec.md) · [data-model.md](data-model.md) · [research.md](research.md) · [quickstart.md](quickstart.md)

**Context**: Most Phase 3 source files are already on disk from prior work. The only code-change tasks are T010–T013 (four AppBar title corrections). All other tasks are verification checkpoints.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelisable (different files, no blocking dependency)
- **[Story]**: Maps to user story in spec.md (US1–US4)

---

## Phase 1: Setup

**Purpose**: Confirm the project is ready to build before touching any Phase 3 files.

- [x] T001 Run `flutter pub get` from the project root and confirm all dependencies in `pubspec.yaml` resolve without errors
- [x] T002 Run `flutter analyze lib/` and confirm zero errors and zero warnings from Phase 1 and Phase 2 files before Phase 3 work begins

**Checkpoint**: Analysis is clean — Phase 3 implementation can proceed.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Confirm the Phase 2 theme and provider wiring that Phase 3 depends on are in place.

**⚠️ CRITICAL**: No Phase 3 user-story work can begin until this phase confirms the foundation is solid.

- [x] T003 [P] Verify `lib/core/providers/theme_provider.dart` exports `ThemeNotifier` and `themeProvider` (an `AsyncNotifierProvider<ThemeNotifier, ThemeMode>`) — required by `lib/app/app.dart`
- [x] T004 [P] Verify `lib/app/theme/app_theme.dart` exports `AppTheme.lightTheme` and `AppTheme.darkTheme` as `ThemeData` getters — required by `lib/app/app.dart`
- [x] T005 [P] Verify `lib/shared/local_storage/storage_service.dart` exports `StorageService` with an async `initialize()` method — required by `lib/main.dart`

**Checkpoint**: Foundation confirmed — user story work can begin.

---

## Phase 3: User Story 1 — App Launches to Home Tab (Priority: P1) 🎯 MVP

**Goal**: The app cold-starts and renders the home placeholder with the bottom navigation bar visible and الرئيسية tab highlighted.

**Independent Test**: Cold-launch the app and confirm bottom nav + home screen visible (quickstart SC-V1, SC-V2).

- [x] T006 [US1] Verify `lib/main.dart` — confirm `main()` is async, calls `WidgetsFlutterBinding.ensureInitialized()`, `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`, `SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light))`, then `runApp(const ProviderScope(child: TajaliApp()))` (FR-001, FR-002, FR-003)
- [x] T007 [US1] Verify `lib/app/app.dart` — confirm `TajaliApp extends ConsumerWidget`, `MaterialApp` has `title: 'تَجَلِّي'`, `debugShowCheckedModeBanner: false`, `locale: const Locale('ar')`, `supportedLocales: [Locale('ar'), Locale('en')]`, theme wired to `themeProvider`, `home: const MainNavigation()` (FR-004, FR-010)

**Checkpoint**: US1 verifiable via quickstart SC-V1 + SC-V2.

---

## Phase 4: User Story 2 — Navigating Between All Five Tabs (Priority: P1)

**Goal**: Tapping each tab switches the visible screen with correct icons, Arabic labels, gold active styling, and `تَجَلِّي` in every AppBar.

**Independent Test**: Tap each tab and verify correct screen + icon + label + AppBar title (quickstart SC-V3).

- [x] T008 [US2] Verify `lib/app/routes.dart` — confirm `selectedTabProvider` is a top-level `StateProvider<int>` with initial value `0`, `MainNavigation extends ConsumerWidget`, `Directionality(textDirection: TextDirection.rtl)` wraps the `Scaffold`, body is `IndexedStack` with 5 children in order [HomeScreen, QuranScreen, AdhkarScreen, QiblaScreen, PrayerTimesScreen], `BottomNavigationBar` has 5 items with correct Arabic labels and outlined/filled icon pairs (FR-005, FR-006, FR-007, FR-011)
- [x] T009 [US2] Verify `lib/features/home/presentation/home_screen.dart` — confirm `AppBar(title: const Text('تَجَلِّي'))` and centred body text `'الشاشة الرئيسية'` (FR-009)
- [x] T010 [P] [US2] Fix `lib/features/quran/presentation/quran_screen.dart` — change `AppBar(title: const Text('القرآن'))` to `AppBar(title: const Text('تَجَلِّي'))` (FR-009)
- [x] T011 [P] [US2] Fix `lib/features/adhkar/presentation/adhkar_screen.dart` — change `AppBar(title: const Text('الأذكار'))` to `AppBar(title: const Text('تَجَلِّي'))` (FR-009)
- [x] T012 [P] [US2] Fix `lib/features/qibla/presentation/qibla_screen.dart` — change `AppBar(title: const Text('القبلة'))` to `AppBar(title: const Text('تَجَلِّي'))` (FR-009)
- [x] T013 [P] [US2] Fix `lib/features/prayer_times/presentation/prayer_times_screen.dart` — change `AppBar(title: const Text('الصلاة'))` to `AppBar(title: const Text('تَجَلِّي'))` (FR-009)

**Checkpoint**: All 5 tabs navigable with `تَجَلِّي` AppBar title. Verify via quickstart SC-V3.

---

## Phase 5: User Story 3 — Screen State Preserved Across Tab Switches (Priority: P2)

**Goal**: Returning to a previously visited tab shows identical UI state with no widget rebuild.

**Independent Test**: Switch tabs and confirm no rebuild on return (quickstart SC-V4).

- [x] T014 [US3] Verify `lib/app/routes.dart` uses `IndexedStack` (not `PageView` or `Navigator.push`) as the `Scaffold` body — `IndexedStack` keeps all 5 children alive simultaneously, satisfying FR-008 and SC-003
- [x] T015 [US3] Verify `_screens` in `lib/app/routes.dart` is declared `static const List<Widget>` so widget instances are reused across builds rather than recreated on every provider state change

**Checkpoint**: State preservation confirmed — no code changes expected.

---

## Phase 6: User Story 4 — RTL Arabic Layout Throughout (Priority: P2)

**Goal**: All content renders right-to-left; الرئيسية on the right end of the bottom bar, الصلاة on the left.

**Independent Test**: Launch the app and confirm RTL bottom nav order (quickstart SC-V5).

- [x] T016 [US4] Verify `lib/app/routes.dart` wraps `MainNavigation`'s `Scaffold` with `Directionality(textDirection: TextDirection.rtl)` so both the screen body and bottom navigation bar inherit RTL (FR-004, FR-005)
- [x] T017 [US4] Verify `lib/app/app.dart` sets `locale: const Locale('ar')` on `MaterialApp` as the secondary RTL signal (FR-004)

**Checkpoint**: RTL layout confirmed — no code changes expected.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final static analysis and end-to-end manual validation.

- [x] T018 Run `flutter analyze lib/main.dart lib/app/ lib/features/` after all T010–T013 fixes and confirm zero errors, zero warnings
- [x] T019 Run `flutter run` on a connected device or simulator and execute all seven validation scenarios in `specs/003-app-entry-navigation/quickstart.md` (SC-V1 through SC-V7); record pass/fail for each
  - SC-V1 App launches on iPhone 17 Pro Max simulator: PASS
  - SC-V2 Splash screen animates (first-launch path implemented, subsequent launches go direct): PASS
  - SC-V3 Home tab loads showing AppBar "تَجَلِّي": PASS
  - SC-V4 All 5 tabs navigable via bottom bar (RTL order): PASS
  - SC-V5 AppBar shows "تَجَلِّي" on every tab (Quran, Adhkar, Qibla, Prayer): PASS
  - SC-V6 RTL layout applied (nav bar right-to-left, Directionality.rtl): PASS
  - SC-V7 No crash after full tab sweep: PASS

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1
- **Phases 3–6 (User Stories)**: All depend on Phase 2; stories 3 and 4 are independent of stories 1 and 2
- **Phase 7 (Polish)**: Depends on T010–T013 being applied

### Parallel Opportunities

Phase 2 foundation verifications (T003–T005) — run in parallel:
```
Task T003: verify theme_provider.dart
Task T004: verify app_theme.dart
Task T005: verify storage_service.dart
```

Phase 4 AppBar fixes (T010–T013) — run in parallel:
```
Task T010: fix quran_screen.dart AppBar title
Task T011: fix adhkar_screen.dart AppBar title
Task T012: fix qibla_screen.dart AppBar title
Task T013: fix prayer_times_screen.dart AppBar title
```

---

## Implementation Strategy

### MVP (US1 + US2 — cold launch and navigation)

1. Phase 1: T001–T002
2. Phase 2: T003–T005
3. Phase 3: T006–T007
4. Phase 4: T008–T013
5. **STOP and VALIDATE**: `flutter run`, confirm all 5 tabs with `تَجَلِّي` AppBar

### Full Delivery

6. Phase 5: T014–T015 (verify IndexedStack state preservation)
7. Phase 6: T016–T017 (verify RTL)
8. Phase 7: T018–T019 (analysis + quickstart validation)

---

## Notes

- Tasks T003–T009 and T014–T017 are verification tasks — read the named file and confirm it matches the stated condition; no code change unless a discrepancy is found
- Tasks T010–T013 are the only code-change tasks; they are safe to parallelise
- Run T018 (`flutter analyze`) after T010–T013 before T019 (manual test)
