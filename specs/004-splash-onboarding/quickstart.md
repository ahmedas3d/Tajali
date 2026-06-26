# Quickstart Validation Guide: Splash Screen & Onboarding

**Feature**: 004-splash-onboarding | **Date**: 2026-06-26

---

## Prerequisites

- Flutter SDK ≥ 3.3.0 installed and on PATH
- A connected device or running emulator/simulator (Android or iOS)
- All dependencies resolved: `flutter pub get`
- SVG illustration assets placed in `assets/svg/` (see [plan.md](plan.md) for filenames)

---

## Running the App

```bash
flutter run
```

For a clean launch every time (simulates first install):

```bash
flutter run --no-fast-start
```

---

## Scenario 1: First-Time Launch — Full Onboarding Flow

**Goal**: Verify the complete first-launch path: splash → slide 1 → slide 2 → slide 3 → permissions → home.

**Setup**: Clear app data (or fresh install) so `onboarding_complete` is absent.

```bash
# Android: clear app data before run
adb shell pm clear com.example.tajali

# iOS Simulator: uninstall and reinstall
xcrun simctl uninstall booted com.example.tajali
```

**Steps**:
1. Launch the app.
2. **Verify**: Splash screen appears — animated logo (scale + fade), app name "تجلي", tagline "رفيقك الروحي اليومي", loading indicator at bottom.
3. **Verify**: After ~2.5 seconds the screen fades and slide 1 appears automatically.
4. On slide 1, **verify**: mosque illustration, title "أهلاً بك في تجلي", "تخطي" button (top-right in RTL), "التالي →" button (bottom-right in RTL), 3 page dots (last dot gold).
5. Tap "التالي". **Verify**: Slide 2 appears with hexagonal feature grid, "السابق" button now visible.
6. Tap "التالي". **Verify**: Slide 3 appears — compass rose illustration, two permission cards, "ابدأ الآن" button, no "تخطي" button visible.
7. **Verify**: Both permission cards show the pending (frosted-glass) state.
8. Tap the location card. **Verify**: OS location permission dialog appears. Grant it. **Verify**: Card shows gold checkmark.
9. Tap the notifications card. **Verify**: OS notification permission dialog appears. Deny it. **Verify**: Card shows dimmed/grey state with warning icon.
10. Tap "ابدأ الآن". **Verify**: No additional permission dialogs appear (both already resolved). App navigates to home screen.
11. **Verify**: Home screen is visible with the bottom navigation bar — onboarding is complete.

**Expected outcome**: All verifications pass. App is on home screen.

---

## Scenario 2: Returning User — Onboarding Skipped

**Goal**: Confirm the splash routes directly to home on subsequent cold starts.

**Setup**: Complete Scenario 1 first (or manually set `onboarding_complete = true` via adb).

**Steps**:
1. Close the app completely (swipe away from recents / force-stop).
2. Relaunch.
3. **Verify**: Splash screen animation plays (~2.5 s).
4. **Verify**: After splash, home screen appears — NO onboarding slides are shown at any point.

**Expected outcome**: Home screen reached without any onboarding slide appearing.

---

## Scenario 3: Skip Button — Jumps to Slide 3

**Goal**: Confirm "تخطي" on slide 1 or 2 always lands on slide 3 (never home).

**Setup**: Fresh install (onboarding not complete).

**Steps**:
1. Reach slide 1 (after splash).
2. Tap "تخطي".
3. **Verify**: Slide 3 (permissions) appears immediately — NOT home screen.
4. **Verify**: Slide 3 shows the "ابدأ الآن" button and no "تخطي" button.
5. Restart to slide 1, advance to slide 2, tap "تخطي".
6. **Verify**: Slide 3 appears (not slide 1, not home).

**Expected outcome**: Skip always lands on slide 3 regardless of starting slide.

---

## Scenario 4: "ابدأ الآن" Without Tapping Any Cards

**Goal**: Confirm the button still requests both permissions if neither card was tapped individually.

**Setup**: Fresh install. Navigate to slide 3 without tapping either card.

**Steps**:
1. Reach slide 3 (via "التالي" × 2 or "تخطي").
2. **Verify**: Both cards show pending (frosted) state.
3. Tap "ابدأ الآن" directly.
4. **Verify**: Location permission dialog appears first.
5. Make any choice (grant or deny).
6. **Verify**: Notification permission dialog appears next.
7. Make any choice.
8. **Verify**: App navigates to home screen.

**Expected outcome**: Both dialogs appeared sequentially; app reaches home.

---

## Scenario 5: Back Navigation

**Goal**: Confirm "السابق" button navigates to the correct previous slide.

**Setup**: Fresh install. Reach slide 2.

**Steps**:
1. Reach slide 2 (tap "التالي" on slide 1).
2. Tap "السابق". **Verify**: Slide 1 appears.
3. **Verify**: "السابق" button is NOT visible on slide 1.
4. Tap "التالي" twice to reach slide 3.
5. Tap "السابق". **Verify**: Slide 2 appears.

**Expected outcome**: Back navigation works correctly; slide 1 has no back button.

---

## Running Unit Tests

```bash
flutter test test/unit/onboarding_service_test.dart
```

**Expected outcome**: All tests pass — `isFirstLaunch` returns `true` before completion, `false` after `markOnboardingComplete()` is called.

---

## Running Widget Tests

```bash
flutter test test/widget/splash_screen_test.dart
flutter test test/widget/onboarding_screen_test.dart
```

**Expected outcome**: All widget tests pass — screens render key elements, buttons trigger correct callbacks, permission card state transitions are exercised.

---

## Running All Tests

```bash
flutter test
```

**Expected outcome**: Zero failures.

---

## References

- [Spec](spec.md) — functional requirements and visual design
- [Data Model](data-model.md) — entities, providers, state transitions
- [Research](research.md) — architectural decisions and rationale
- [Plan](plan.md) — source structure and key design decisions
