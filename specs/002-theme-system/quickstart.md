# Quickstart Validation Guide: Theme System

**Feature**: [002-theme-system](spec.md) | **Date**: 2026-06-25

This guide describes how to validate the Theme System feature end-to-end on a simulator or device. It is not a test suite — it is a human-readable walkthrough of the acceptance scenarios from the spec.

---

## Prerequisites

1. Flutter 3.x stable installed (`flutter --version`)
2. An iOS simulator or Android emulator running
3. Phase 1 complete: project builds, all 5 nav tabs open without errors
4. Font assets present at `assets/fonts/Amiri-Regular.ttf`, `Amiri-Bold.ttf`, `AmiriQuran.ttf`

---

## Setup

```bash
cd <project-root>
flutter pub get
flutter run
```

---

## Validation Scenarios

### SC-001 — Zero Hardcoded Hex Values in Feature Screens

**Goal**: Verify all screens use color tokens, not raw values.

```bash
# Search for hardcoded hex colors in feature screen files
grep -rn "Color(0xFF" lib/features/
grep -rn "Color(0x" lib/features/
```

**Expected**: No matches (all colors flow through `AppColors.*` or `Theme.of(context)`).

---

### SC-002 / User Story 2 — Arabic Typography Renders Correctly

**Steps**:
1. Launch the app (`flutter run`)
2. Observe the HomeScreen AppBar title — should render in Amiri font, bold, ivory color
3. Navigate to the Quran tab — Quran verse text should use AmiriQuran font with generous line height

**Expected**:
- No "font not found" warnings in the terminal
- Arabic heading text is visually distinct from body text and small labels
- Quran text has noticeably more line spacing than body text

---

### SC-003 / User Story 3 — Light/Dark Toggle Changes All Themed Widgets

**Steps**:
1. Launch the app (starts in light mode: parchment background, green AppBar)
2. Tap the moon/sun icon in the HomeScreen AppBar
3. Verify the following change immediately:
   - Scaffold background → near-black (`#1A1209`)
   - AppBar → near-black background with gold title text
   - BottomNavigationBar → very dark background with gold active icon

**Expected**: All above changes happen in a single tap with no per-widget inconsistency.

---

### SC-003 (persistence) — Theme Preference Survives App Restart

**Steps**:
1. Toggle to dark mode (see SC-003 above)
2. Force-stop the app (`Ctrl+C` in terminal or kill from device)
3. Relaunch (`flutter run`)

**Expected**: App opens in dark mode — no need to toggle again.

**Reverse test**:
1. Toggle back to light mode
2. Restart
3. App opens in light mode ✓

---

### SC-004 — All 9 Text Styles Are Visually Distinct

**Steps**:
1. Navigate to a debug/test screen that renders all 9 text style variants side-by-side (if created during implementation), OR manually inspect each style in the appropriate screen during development.

**Expected**: Each of `heading1`, `heading2`, `heading3`, `body`, `bodySmall`, `quranText`, `goldLabel`, `onDark`, `onDarkBold` is visually distinguishable by size, weight, or color.

---

### SC-005 — No Build Warnings from Theme Files

```bash
flutter analyze lib/app/theme/
flutter analyze lib/core/providers/theme_provider.dart
```

**Expected**: `No issues found!` — zero deprecation warnings, zero lint errors.

---

### SC-006 — WCAG AA Contrast Check

**Steps** (offline tool check, not in-app):
1. Open a WCAG contrast checker (e.g., webaim.org/resources/contrastchecker)
2. Check: `goldText` value (dark gold ~`#7B5F00`) on `backgroundParchment` (`#F5E6C8`)
   - Expected: ≥ 4.5:1
3. Check: `textDark` (`#3D1F00`) on `backgroundParchment`
   - Expected: ≥ 4.5:1
4. Check: `gold` (`#C9A84C`) on `navBackground` (`#0A1A10`)
   - Expected: ≥ 3:1 (UI component threshold)
5. Check: `textOnDark` (`#FAF0DC`) on `darkBackground` (`#1A1209`)
   - Expected: ≥ 4.5:1

---

## Known Edge Cases

| Scenario | How to Trigger | Expected Behavior |
|----------|---------------|-------------------|
| First launch (no pref stored) | Fresh install / clear app data | Opens in light mode |
| Missing font asset | Remove one `.ttf` from `assets/fonts/` and `flutter run` | System font rendered, no crash, no user-visible error |
| Rapid toggle taps | Tap toggle 5× quickly | Final state matches last tap; storage reflects final value |

---

## References

- Color tokens and text styles → [data-model.md](data-model.md)
- Theme provider API → [contracts/theme-provider.md](contracts/theme-provider.md)
- Functional requirements → [spec.md](spec.md)
