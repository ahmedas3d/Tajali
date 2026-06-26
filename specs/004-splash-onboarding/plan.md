# Implementation Plan: Splash Screen & Onboarding

**Branch**: `004-splash-onboarding` | **Date**: 2026-06-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/004-splash-onboarding/spec.md`

---

## Summary

Implement the Phase 0 first-launch experience for Tajali: a branded animated splash screen (cold-start only, ~2.5 s) that checks onboarding completion state and routes to either the 3-slide onboarding flow or the existing `MainNavigation`. The onboarding flow features individually tappable permission cards (location + notifications) with granted/denied visual states, a mandatory slide-3 permissions step that cannot be bypassed, and a persistent completion flag via SharedPreferences. The primary entry point in `app.dart` is updated from `MainNavigation` to `SplashScreen`.

---

## Technical Context

**Language/Version**: Dart 3.3 / Flutter 3.x (SDK `>=3.3.0 <4.0.0`)

**Primary Dependencies**:
- `flutter_riverpod ^2.5.1` — state management (already present)
- `shared_preferences ^2.2.3` — onboarding completion flag persistence (already present)
- `permission_handler ^11.3.1` — location + notification permission dialogs (already present)
- `flutter_svg ^2.0.10+1` — slide illustrations (already present)
- Flutter built-in animation APIs (`AnimationController`, `Tween`, `CurvedAnimation`, `PageController`)

**Storage**: SharedPreferences — single boolean key `onboarding_complete`

**Testing**: `flutter_test` (built-in), widget tests + unit tests

**Target Platform**: Android + iOS (portrait-only, RTL Arabic)

**Project Type**: Flutter mobile app, feature-first clean architecture

**Performance Goals**: Splash animation completes and navigation triggers within 3 s on mid-range device; onboarding slide transitions are instantaneous (< 100 ms perceived)

**Constraints**: Portrait-only (enforced in `main.dart`), RTL Directionality (enforced in `MainNavigation`), cold-start only splash, offline (no network calls in this phase)

**Scale/Scope**: 4 screens (1 splash + 3 onboarding slides), 2 permission flows

---

## Constitution Check

Constitution file is a blank template — no project-specific gates defined. No violations to evaluate.

---

## Project Structure

### Documentation (this feature)

```text
specs/004-splash-onboarding/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
└── tasks.md             ← Phase 2 output (speckit-tasks)
```

### Source Code

```text
lib/
├── app/
│   └── app.dart                              ← MODIFY: home → SplashScreen
├── features/
│   └── splash/                               ← NEW feature module
│       ├── data/
│       │   └── services/
│       │       └── onboarding_service.dart   ← NEW
│       ├── providers/
│       │   └── onboarding_providers.dart     ← NEW
│       └── presentation/
│           ├── splash_screen.dart            ← NEW
│           ├── onboarding_screen.dart        ← NEW
│           └── widgets/
│               ├── permission_card_widget.dart   ← NEW
│               └── page_indicator_widget.dart    ← NEW
└── shared/
    └── local_storage/
        └── storage_service.dart              ← MODIFY: add bool read/write

assets/
└── svg/
    ├── onboarding_mosque.svg                 ← NEW (slide 1 illustration)
    ├── onboarding_features.svg               ← NEW (slide 2 illustration)
    ├── onboarding_permissions.svg            ← NEW (slide 3 illustration)
    ├── corner_ornament.svg                   ← NEW (shared decorative element)
    └── arabesque_band_icon.svg               ← NEW (top/bottom band icon)

test/
├── unit/
│   └── onboarding_service_test.dart          ← NEW
└── widget/
    ├── splash_screen_test.dart               ← NEW
    └── onboarding_screen_test.dart           ← NEW
```

**Structure Decision**: Feature-first layout matching the existing pattern (`lib/features/[name]/data|providers|presentation`). No new packages required — all dependencies already declared in `pubspec.yaml`.

---

## Key Design Decisions

### 1. Entry Point Routing

`app.dart` currently sets `home: const MainNavigation()`. This changes to `home: const SplashScreen()`. The splash screen itself handles the routing decision (onboarding vs. home) after the animation completes. Cold-start only is guaranteed by Flutter's lifecycle: `SplashScreen` is a `StatefulWidget` whose `initState` triggers the animation and navigation; warm-start resumes wherever `MainNavigation` left off without re-instantiating `SplashScreen`.

### 2. Animation Architecture

`SplashScreen` uses a single `AnimationController` (duration 1600 ms) driving two `CurvedAnimation`s:
- Scale: `Tween(0.7 → 1.0)` with `Curves.easeOutBack`, full duration
- Fade: `Tween(0.0 → 1.0)` with `Curves.easeIn`, full duration

Navigation fires via `Future.delayed(2500 ms)` started concurrently in `initState`. The first-launch check (`isFirstLaunch()`) runs inside the same `Future.delayed` call, so the 2.5 s timer and the storage read run concurrently — navigation never fires before 2.5 s but also never waits additional time for a fast storage read.

### 3. Onboarding Navigation

`OnboardingScreen` uses a `PageController` + `PageView` with `physics: NeverScrollableScrollPhysics()`. Swipe is enabled by wrapping in a `GestureDetector` that calls `pageController.nextPage()` on a left-swipe in RTL context. Skip always jumps to page 2 (`pageController.jumpToPage(2)`). Back/next buttons call `previousPage`/`nextPage` with `Curves.easeInOut`.

### 4. Permission Card State

Each card's permission status is tracked in a `StateProvider<PermissionCardState>` (enum: `pending`, `granted`, `denied`). Tapping a card calls `permission_handler` and updates the provider. "ابدأ الآن" reads the current states and only requests permissions still in `pending` state before completing. Visual states map to distinct widget presentations (gold checkmark / muted grey warning).

### 5. StorageService Extension

`StorageService` currently only supports `String` read/write. The `OnboardingService` will call `SharedPreferences` directly (not via `StorageService`) using `setBool`/`getBool` to avoid widening the `StorageService` interface unnecessarily. The key `onboarding_complete` is a module-private constant.

### 6. RTL & Directionality

`MainNavigation` already wraps content in `Directionality(textDirection: TextDirection.rtl)`. Splash and onboarding screens are self-contained and do not rely on the navigation shell, so each screen applies `Directionality` independently or uses `textDirection: TextDirection.rtl` on individual text widgets. All button layouts use RTL-aware positioning.

---

## Complexity Tracking

No constitution violations. No complexity justification required.
