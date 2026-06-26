# Tasks: Splash Screen & Onboarding

**Input**: Design documents from `specs/004-splash-onboarding/`

**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, quickstart.md ✓

**Organization**: Tasks grouped by user story — each story is independently implementable and testable.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Each task includes the exact file path to create or modify

## Path Conventions

Flutter feature-first layout (matches existing codebase):
- Source: `lib/features/splash/data/`, `lib/features/splash/providers/`, `lib/features/splash/presentation/`
- Tests: `test/unit/`, `test/widget/`
- Assets: `assets/svg/`

---

## Phase 1: Setup

**Purpose**: Create the `splash` feature module directory structure and asset placeholders so all subsequent tasks have valid import targets and the app compiles throughout development.

- [x] T001 Create feature module directories: `lib/features/splash/data/models/`, `lib/features/splash/data/services/`, `lib/features/splash/providers/`, `lib/features/splash/presentation/widgets/`, `test/unit/`, `test/widget/`
- [x] T002 [P] Add 5 empty placeholder SVG files (valid minimal `<svg></svg>`) in `assets/svg/`: `onboarding_mosque.svg`, `onboarding_features.svg`, `onboarding_permissions.svg`, `corner_ornament.svg`, `arabesque_band_icon.svg`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Data layer and providers that every user story depends on. No user story work can begin until this phase is complete.

**⚠️ CRITICAL**: Complete before any Phase 3+ tasks.

- [x] T003 [P] Create `PermissionCardState` enum (`pending`, `granted`, `denied`) and `PermissionType` enum (`location`, `notification`) in `lib/features/splash/data/models/permission_models.dart`
- [x] T004 [P] Create `OnboardingSlide` immutable data class with fields: `index` (int), `title` (String), `subtitle` (String), `illustrationAsset` (String), `showSkip` (bool), `showBack` (bool), `isPermissionSlide` (bool); include 3 static const instances in `lib/features/splash/data/models/onboarding_slide.dart`
- [x] T005 [P] Create `OnboardingService` with `Future<bool> isFirstLaunch()` (reads SharedPreferences key `onboarding_complete`, returns true when absent) and `Future<void> markOnboardingComplete()` (sets key to true) in `lib/features/splash/data/services/onboarding_service.dart`
- [x] T006 Create Riverpod providers: `onboardingPageProvider` (`StateProvider<int>`, init 0), `locationPermissionProvider` (`StateProvider<PermissionCardState>`, init `pending`), `notificationPermissionProvider` (`StateProvider<PermissionCardState>`, init `pending`), `onboardingSlidesProvider` (`Provider<List<OnboardingSlide>>` returning the 3 static instances) in `lib/features/splash/providers/onboarding_providers.dart`
- [x] T007 [P] Write unit tests for `OnboardingService`: (a) `isFirstLaunch()` returns `true` when key is absent; (b) `isFirstLaunch()` returns `false` after `markOnboardingComplete()` is called; use `SharedPreferences.setMockInitialValues({})` for isolation in `test/unit/onboarding_service_test.dart`

**Checkpoint**: Data layer complete — all Phase 3+ tasks can begin.

---

## Phase 3: User Story 1 — First-Time Launch Path (Priority: P1) 🎯 MVP

**Goal**: A user fresh-installing the app sees the branded splash animation for ~2.5 s, then lands on slide 1 of the onboarding flow, advances through all 3 slides, taps "ابدأ الآن" on slide 3 which requests permissions and navigates to the home screen.

**Independent Test**: Fresh-install (or clear data), launch app, complete the full flow — confirm splash animation plays, all 3 slides appear with correct Arabic text and illustrations, "ابدأ الآن" triggers OS permission dialogs then navigates to `MainNavigation`. See quickstart.md Scenario 1.

- [x] T008 Create `SplashScreen` StatefulWidget with SingleTickerProviderStateMixin: `AnimationController` (1600 ms); `_scaleAnim` Tween(0.7→1.0) with `Curves.easeOutBack`; `_fadeAnim` Tween(0.0→1.0) with `Curves.easeIn`; `_controller.forward()` in `initState`; concurrent `Future.delayed(2500ms)` that calls `OnboardingService().isFirstLaunch()` and uses `Navigator.pushReplacement` to route to `OnboardingScreen` (true) or `MainNavigation` (false) guarded by `mounted` check in `lib/features/splash/presentation/splash_screen.dart`
- [x] T009 Add splash visual layout to `SplashScreen` build method: full-screen `Container` with gradient `#1B4332 → #0D2218`; Stack children: arabesque bands, corner ornament, radial bloom, halo ring, 8-pointed star logo, gold "تجلي" text, ornamental underline, tagline, loading indicator in `lib/features/splash/presentation/splash_screen.dart`
- [x] T010 Update `lib/app/app.dart`: change `home: const MainNavigation()` to `home: const SplashScreen()` and add import for `splash_screen.dart`
- [x] T011 [P] Create `PageIndicatorWidget` in `lib/features/splash/presentation/widgets/page_indicator_widget.dart`
- [x] T012 [P] Create `PermissionCardWidget` in `lib/features/splash/presentation/widgets/permission_card_widget.dart`
- [x] T013 Create `OnboardingScreen` ConsumerStatefulWidget in `lib/features/splash/presentation/onboarding_screen.dart`
- [x] T014 [US1] Implement slide 1 content widget within `OnboardingScreen`
- [x] T015 [US1] Implement slide 2 content widget within `OnboardingScreen`
- [x] T016 [US1] Implement slide 3 content widget within `OnboardingScreen`
- [x] T017 [US1] Implement `_onStartNow()` handler in `OnboardingScreen`
- [x] T018 [P] [US1] Write widget tests for `SplashScreen` in `test/widget/splash_screen_test.dart`

**Checkpoint**: Full first-time launch path is functional. Validate with quickstart.md Scenario 1.

---

## Phase 4: User Story 2 — Returning User Skips Onboarding (Priority: P1)

**Goal**: A user who has already completed onboarding sees the splash screen and is taken directly to `MainNavigation` — onboarding slides never appear.

**Independent Test**: Complete onboarding once, force-close the app, relaunch — confirm home screen appears after splash with zero onboarding slides shown. See quickstart.md Scenario 2.

- [x] T019 [US2] Write widget test confirming `SplashScreen` routes to `MainNavigation` when `onboarding_complete = true` in SharedPreferences in `test/widget/splash_screen_test.dart`
- [x] T020 [US2] Write unit test confirming `OnboardingService.isFirstLaunch()` returns `false` after `markOnboardingComplete()` in `test/unit/onboarding_service_test.dart`

**Checkpoint**: Returning-user path confirmed. Both US1 and US2 (P1 stories) are fully validated.

---

## Phase 5: User Story 3 — Skip to Slide 3 (Priority: P2)

**Goal**: Tapping "تخطي" on slide 1 or slide 2 jumps directly to slide 3 (permissions). The skip button is never visible on slide 3.

**Independent Test**: On slide 1, tap "تخطي" — confirm slide 3 appears. Confirm "تخطي" is absent on slide 3. See quickstart.md Scenario 3.

- [x] T021 [US3] Implement "تخطي" button in `OnboardingScreen` — shown on slides 0 and 1; jumps to slide 3 in `lib/features/splash/presentation/onboarding_screen.dart`
- [x] T022 [P] [US3] Write widget test for skip button in `test/widget/onboarding_screen_test.dart`

**Checkpoint**: Skip flow works end-to-end. Validate with quickstart.md Scenario 3.

---

## Phase 6: User Story 4 — Back Navigation (Priority: P3)

**Goal**: Tapping "السابق" on slide 2 returns to slide 1; on slide 3 returns to slide 2. "السابق" is never visible on slide 1.

**Independent Test**: Advance to slide 2, tap "السابق" — slide 1 appears. Advance to slide 3, tap "السابق" — slide 2 appears. Confirm slide 1 has no "السابق" button. See quickstart.md Scenario 5.

- [x] T023 [US4] Implement "السابق" button in `OnboardingScreen` — shown on slides 1 and 2 in `lib/features/splash/presentation/onboarding_screen.dart`
- [x] T024 [P] [US4] Write widget test for back navigation in `test/widget/onboarding_screen_test.dart`

**Checkpoint**: All 4 user stories implemented and tested. Full feature is complete.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Replace SVG placeholders with production artwork, verify RTL layout, complete visual polish, and run final validation.

- [ ] T025 [P] Replace the 5 placeholder SVGs with production-ready artwork in `assets/svg/`
- [x] T026 [P] RTL audit complete: both `SplashScreen` and `OnboardingScreen` wrapped in `Directionality(textDirection: TextDirection.rtl)`
- [x] T027 [P] Widget tests for `OnboardingScreen` all 3 slides written in `test/widget/onboarding_screen_test.dart`
- [x] T028 Verify all `flutter test` pass — 12/12 tests passing (3 unit + 4 splash widget + 5 onboarding widget)
- [ ] T029 Run all 5 quickstart.md validation scenarios on a physical or emulated device

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — blocks all user stories
- **Phase 3 (US1, P1)**: Depends on Phase 2 — this is the MVP
- **Phase 4 (US2, P1)**: Depends on Phase 3 (routing logic must exist to test)
- **Phase 5 (US3, P2)**: Depends on Phase 3 (`OnboardingScreen` must exist)
- **Phase 6 (US4, P3)**: Depends on Phase 5 (skip must exist first to avoid back/skip conflicts)
- **Phase 7 (Polish)**: Depends on all user story phases

### User Story Dependencies

| Story | Depends On | Independent? |
|-------|-----------|-------------|
| US1 (P1) — First-time flow | Phase 2 foundational | Yes — start immediately after Phase 2 |
| US2 (P1) — Returning user | US1 (SplashScreen routing) | No — needs SplashScreen to exist |
| US3 (P2) — Skip | US1 (OnboardingScreen) | No — needs OnboardingScreen to exist |
| US4 (P3) — Back | US3 (navigation wired) | No — needs page switching to work |

### Within Each Phase

- Tasks marked `[P]` can run simultaneously (different files)
- T006 (providers) depends on T003 (PermissionCardState enum) and T004 (OnboardingSlide class)
- T013 (OnboardingScreen) depends on T011 (PageIndicatorWidget) and T012 (PermissionCardWidget)
- T017 ("ابدأ الآن" handler) depends on T016 (slide 3 layout) and T005 (OnboardingService)

---

## Parallel Opportunities

### Phase 2 — Run T003, T004, T005 simultaneously:

```
Task T003: lib/features/splash/data/models/permission_models.dart
Task T004: lib/features/splash/data/models/onboarding_slide.dart
Task T005: lib/features/splash/data/services/onboarding_service.dart
Task T007: test/unit/onboarding_service_test.dart
```

### Phase 3 — Run widget tasks after OnboardingScreen scaffold (T013):

```
After T013 exists:
Task T014: slide 1 layout
Task T015: slide 2 layout    ← different method in same file, sequential
Task T016: slide 3 layout

In parallel with slide layout:
Task T018: test/widget/splash_screen_test.dart  (only depends on T008/T010)
```

### Phase 7 — All polish tasks in parallel:

```
Task T025: assets/svg/ (artwork)
Task T026: RTL audit (presentation files)
Task T027: test/widget/onboarding_screen_test.dart
Task T028: flutter test run
```

---

## Implementation Strategy

### MVP First (User Story 1 — ~70% of the work)

1. Complete Phase 1 (Setup) — 2 tasks
2. Complete Phase 2 (Foundational) — 5 tasks
3. Complete Phase 3 (US1) — 11 tasks
4. **STOP and VALIDATE**: Run quickstart.md Scenario 1 end-to-end
5. Commit and demo the complete first-launch experience

### Incremental Delivery

1. Phase 1 + 2 → Data layer ready
2. Phase 3 (US1) → **MVP: first-launch path fully functional**
3. Phase 4 (US2) → Returning-user path confirmed (test coverage)
4. Phase 5 (US3) → Skip button works
5. Phase 6 (US4) → Full navigation complete
6. Phase 7 (Polish) → Production-ready visuals and passing tests

---

## Notes

- `[P]` tasks target different files with no shared dependencies — safe to parallelize
- `[Story]` label traces each task to its user story for independent validation
- SVG placeholders (T002) keep the app compilable during development — replace with production art in T025
- Permission dialogs only appear on physical devices or simulators with proper capabilities — use `SharedPreferences.setMockInitialValues` in widget tests to control the `isFirstLaunch` flag
- Slides 1–3 are methods/sections within `onboarding_screen.dart` — tasks T014–T016 are sequential (same file)
- `mounted` guard in `_navigateAfterDelay()` (T008) prevents setState calls after widget disposal if the user backgrounds the app during the 2.5 s window
