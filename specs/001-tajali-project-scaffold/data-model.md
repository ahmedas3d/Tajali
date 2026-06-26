# Data Model: تَجَلِّي Project Scaffold

**Feature**: 001-tajali-project-scaffold
**Date**: 2026-06-25
**Plan**: [plan.md](plan.md)

## Overview

Phase 1 introduces no persistent data entities. All placeholder screens are stateless. The only runtime state is navigation state (which tab is active), held in memory and managed through the global state-management scope.

---

## Runtime Entities

### NavigationState

Tracks which of the five bottom-nav tabs is currently displayed.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| `selectedIndex` | `int` | 0 ≤ value ≤ 4 | 0 = Home, 1 = Quran, 2 = Adhkar, 3 = Qibla, 4 = Prayer Times |

**Lifecycle**: Created at app startup (defaults to 0 = Home); updated on each tab tap via `BottomNavigationBar.onTap`; destroyed when the OS terminates the process.

**Validation**: Out-of-range values are structurally impossible — the `BottomNavigationBar` widget only emits indices 0–4 and the provider is only updated from that callback.

**State preservation**: `IndexedStack` keeps all five screen subtrees alive while `selectedIndex` changes, so each screen's internal scroll/widget state persists across tab switches (FR-007a).

---

## Configuration Entities (declared in pubspec.yaml, not runtime)

### AssetDirectory

Directories pre-registered so the Flutter asset bundler includes them at build time.

| Directory path | Purpose | Must be non-empty in Phase 1? |
|---|---|---|
| `assets/fonts/` | Arabic typefaces | **Yes** — Amiri-Regular.ttf, Amiri-Bold.ttf, AmiriQuran.ttf required |
| `assets/images/` | Raster images (PNG/JPG) | No — directory must exist; files optional |
| `assets/svg/` | Vector graphics (SVG) | No — directory must exist; files optional |
| `assets/audio/` | Audio clips | No — directory must exist; files optional |
| `assets/data/` | JSON data files | No — directory must exist; files optional |

**Note**: `pubspec.yaml` registers the directory (e.g., `- assets/images/`) not individual files. The build tool resolves all files present at build time. An empty directory with only a `.gitkeep` placeholder is sufficient for Phase 1.

---

### FontFamily

Custom font families bundled with the app binary.

| Family name | File | Weight | Usage |
|---|---|---|---|
| Amiri | Amiri-Regular.ttf | 400 (regular) | All UI text: headings, body, labels, navigation |
| Amiri | Amiri-Bold.ttf | 700 (bold) | Bold variants of all UI text |
| AmiriQuran | AmiriQuran.ttf | 400 (regular) | Quranic Arabic text exclusively |

**Note**: `AmiriQuran` is a specialised subset of the Amiri family optimised for Quranic script (vowel marks, special Unicode points). It must not be used for general UI text; `Amiri` must not be used for Quranic display.

---

## Screen Registry

The five screens wired into `MainNavigation` via `IndexedStack`.

| Index | Class | File | Arabic label | Arabic tab label |
|---|---|---|---|---|
| 0 | `HomeScreen` | `features/home/presentation/home_screen.dart` | الشاشة الرئيسية | الرئيسية |
| 1 | `QuranScreen` | `features/quran/presentation/quran_screen.dart` | القرآن الكريم | القرآن |
| 2 | `AdhkarScreen` | `features/adhkar/presentation/adhkar_screen.dart` | الأذكار | الأذكار |
| 3 | `QiblaScreen` | `features/qibla/presentation/qibla_screen.dart` | القبلة | القبلة |
| 4 | `PrayerTimesScreen` | `features/prayer_times/presentation/prayer_times_screen.dart` | مواقيت الصلاة | الصلاة |

**Deferred screen** (scaffolded, not wired):

| Class | File | Status |
|---|---|---|
| `TasbihScreen` | `features/qibla/presentation/tasbih_screen.dart` | Phase 1: file exists, not imported in routes.dart |
