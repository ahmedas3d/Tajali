# Tasks: Theme System

**Input**: Design documents from `specs/002-theme-system/`

**Prerequisites**: [plan.md](plan.md) · [spec.md](spec.md) · [research.md](research.md) · [data-model.md](data-model.md) · [contracts/theme-provider.md](contracts/theme-provider.md)

**Tests**: Not requested — manual validation via [quickstart.md](quickstart.md) instead.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- Exact file paths are included in every task description

---

## Phase 1: Setup (Foundational Color Token)

**Purpose**: Add the `goldText` token that both US1 and US2 depend on. Must complete before any user story work begins.

**⚠️ CRITICAL**: US1 and US2 cannot proceed without this token.

- [x] T001 Add `goldText` color token (dark gold ~`#7B5F00`, verified ≥4.5:1 on `backgroundParchment`) to the Primary Palette section of `lib/app/theme/app_colors.dart`

**Checkpoint**: `AppColors.goldText` is accessible to all theme files.

---

## Phase 2: Foundational (Storage Infrastructure)

**Purpose**: Implement `StorageService` — required by US3 for theme mode persistence.

**⚠️ CRITICAL**: US3 cannot proceed without a working `StorageService`.

- [x] T002 Implement `StorageService` with `SharedPreferences` backend (`initialize()`, `write(key, value)`, `read(key)`) in `lib/shared/local_storage/storage_service.dart`
- [x] T003 Initialize `StorageService` and pass it as an `override` or global before `ProviderScope` is created in `lib/main.dart`

**Checkpoint**: `StorageService.read('theme_mode')` and `.write('theme_mode', 'dark')` function correctly.

---

## Phase 3: User Story 1 — Consistent Color Usage (Priority: P1) 🎯 MVP

**Goal**: Every theme-level color reference uses a named `AppColors` token — no anonymous inline `Color(0x...)` literals remain in the theme files.

**Independent Test**: Run `grep -rn "Color(0x" lib/app/theme/` — zero matches expected after these tasks.

### Implementation for User Story 1

- [x] T004 [P] [US1] Add `cardShadowLight` (`const Color(0x4DC9A84C)`) and `cardShadowDark` (`const Color(0x33C9A84C)`) named constants to the Navigation section of `lib/app/theme/app_colors.dart`
- [x] T005 [US1] Update `AppTheme.lightTheme` `CardThemeData` shadow to reference `AppColors.cardShadowLight` in `lib/app/theme/app_theme.dart`
- [x] T006 [P] [US1] Update `AppTheme.darkTheme` `CardThemeData` shadow to reference `AppColors.cardShadowDark` in `lib/app/theme/app_theme.dart`

**Checkpoint**: `grep -rn "Color(0x" lib/app/theme/` returns zero results. US1 acceptance scenarios pass.

---

## Phase 4: User Story 2 — Arabic Typography Renders Correctly (Priority: P1)

**Goal**: All text styles rendering on light backgrounds use the WCAG-compliant gold token; `textMuted` passes 4.5:1 on parchment.

**Independent Test**: Run `flutter analyze lib/app/theme/` — zero issues. Visually verify `heading1`, `goldLabel`, and `bodySmall` in the running app against light parchment background.

### Implementation for User Story 2

- [x] T007 [US2] Verify `textMuted` (#9C7A5A) contrast ratio against `backgroundParchment` using WCAG luminance formula; update to a WCAG-passing value (~`#7A5C3C`, ≥4.5:1) in `lib/app/theme/app_colors.dart`
- [x] T008 [P] [US2] Update `heading1` `TextStyle` to use `AppColors.goldText` instead of `AppColors.gold` in `lib/app/theme/app_text_styles.dart`
- [x] T009 [P] [US2] Update `goldLabel` `TextStyle` to use `AppColors.goldText` instead of `AppColors.gold` in `lib/app/theme/app_text_styles.dart`

**Checkpoint**: `heading1` and `goldLabel` now reference `goldText`; `bodySmall` references the updated `textMuted`. All text style tokens are visually distinct and WCAG-compliant on their intended backgrounds.

---

## Phase 5: User Story 3 — Light/Dark Theme Toggle with Persistence (Priority: P2)

**Goal**: User can toggle light/dark mode from the HomeScreen AppBar; the selected mode survives an app restart.

**Independent Test**: Toggle to dark mode → force-close app → relaunch → app opens in dark mode. Toggle back to light → restart → opens in light mode.

### Implementation for User Story 3

- [x] T010 [US3] Create `ThemeNotifier` as `AsyncNotifier<ThemeMode>` with `build()` (reads stored pref, defaults to `ThemeMode.light`), `toggle()`, and `setMode(ThemeMode mode)` methods — write and read via `StorageService` key `'theme_mode'` — in `lib/core/providers/theme_provider.dart`
- [x] T011 [US3] Replace hardcoded `themeMode: ThemeMode.light` with `themeMode: ref.watch(themeProvider).valueOrNull ?? ThemeMode.light` in `lib/app/app.dart`
- [x] T012 [US3] Convert `HomeScreen` from `StatelessWidget` to `ConsumerStatelessWidget` and add a moon/sun `IconButton` to AppBar `actions` that calls `ref.read(themeProvider.notifier).toggle()` in `lib/features/home/presentation/home_screen.dart`

**Checkpoint**: US3 acceptance scenarios 1–6 from spec.md all pass. Persistence verified by force-close + relaunch test.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Static analysis pass and full quickstart validation.

- [x] T013 [P] Run `flutter analyze lib/` and resolve any warnings or lint errors — target: `No issues found!`
- [x] T014 Execute all quickstart.md validation scenarios (SC-001 through SC-006) and confirm each passes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: No dependencies — can run in parallel with Phase 1
- **Phase 3 (US1)**: Depends on T001 (Phase 1) — needs `goldText` token and shadow constants
- **Phase 4 (US2)**: Depends on T001 (Phase 1) — needs `goldText` token
- **Phase 5 (US3)**: Depends on T002 + T003 (Phase 2) — needs working `StorageService`
- **Phase 6 (Polish)**: Depends on all user story phases complete

### User Story Dependencies

- **US1 (P1)**: Depends on T001 only — independent of US2 and US3
- **US2 (P1)**: Depends on T001 only — independent of US1 and US3
- **US3 (P2)**: Depends on T002 + T003 only — independent of US1 and US2

### Within Each User Story

- US1: T004 can run in parallel with T005 prep; T005 and T006 can run in parallel (different theme getter)
- US2: T008 and T009 can run in parallel (different style constants); T007 should run first
- US3: T010 → T011 → T012 (sequential — each step depends on the prior)

---

## Parallel Opportunities

```bash
# Phase 1 + Phase 2 can start simultaneously:
Task T001: "Add goldText token to lib/app/theme/app_colors.dart"
Task T002: "Implement StorageService in lib/shared/local_storage/storage_service.dart"

# Once T001 completes, US1 and US2 can run in parallel:
Task T004+T005+T006: "US1 — shadow constants and app_theme.dart updates"
Task T007+T008+T009: "US2 — textMuted fix, heading1 and goldLabel updates"

# Within US1 after T004:
Task T005: "lightTheme CardTheme shadow in app_theme.dart"
Task T006: "darkTheme CardTheme shadow in app_theme.dart"  # parallel with T005

# Within US2 after T007:
Task T008: "heading1 in app_text_styles.dart"
Task T009: "goldLabel in app_text_styles.dart"  # parallel with T008
```

---

## Implementation Strategy

### MVP First (US1 + US2 Only)

1. Complete T001 (Setup — goldText token)
2. Complete US1 (T004–T006) → zero anonymous Color literals in theme files
3. Complete US2 (T007–T009) → WCAG-compliant text styles
4. **STOP and VALIDATE**: `flutter analyze lib/app/theme/` clean; visual check of typography
5. Ship US1 + US2 as a working foundation

### Incremental Delivery

1. T001 + T002 + T003 → Token and storage foundation ready
2. US1 (T004–T006) → Named color tokens complete → test with grep check
3. US2 (T007–T009) → WCAG typography complete → test visually in simulator
4. US3 (T010–T012) → Toggle + persistence complete → test with force-close cycle
5. T013 + T014 → Polish and full validation

### Single Developer Sequence

```
T001 → T002 → T003 → T004 → T005 → T006 → T007 → T008 → T009 → T010 → T011 → T012 → T013 → T014
```

---

## Notes

- `[P]` tasks touch different files with no shared dependencies — safe to run in parallel
- `[US1]`, `[US2]`, `[US3]` map to User Stories 1–3 in spec.md
- T001 is the only true global prerequisite — two people can pair on it or it takes ~5 minutes solo
- `textMuted` WCAG fix (T007) must run before T008/T009 since all are in `app_colors.dart` / `app_text_styles.dart` and touching the same token set
- Commit after each checkpoint for clean rollback points
- US1 and US2 are both P1 — deliver both before moving to US3 (P2)
