# Implementation Plan: تَجَلِّي Project Scaffold

**Branch**: `001-tajali-project-scaffold` | **Date**: 2026-06-25 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-tajali-project-scaffold/spec.md`

## Summary

Create a complete Flutter project scaffold for the تَجَلِّي Islamic app: establish the full `lib/` directory hierarchy, configure `pubspec.yaml` with all required packages and assets, wire up five placeholder feature screens into a bottom navigation bar with RTL Arabic layout and tab-state preservation via `IndexedStack`, and validate the Riverpod scope is active from the root. The result is a compilable, runnable app skeleton on iOS and Android — the foundation every later phase builds on.

## Technical Context

**Language/Version**: Dart / Flutter stable channel — minimum Flutter 3.19.0 (binding constraint: `geolocator ^11.0.0` requires Android Gradle Plugin 8.x, introduced in Flutter 3.19)

**Primary Dependencies**:
- State management: flutter_riverpod ^2.5.1
- Local storage: hive_flutter ^1.1.0 + shared_preferences ^2.2.3
- Location & compass: geolocator ^11.0.0 + flutter_compass ^0.7.0 + permission_handler ^11.3.1
- Prayer times: adhan ^1.1.0
- Audio: just_audio ^0.9.38
- Notifications: flutter_local_notifications ^17.2.2
- UI extras: flutter_svg ^2.0.10+1 + google_fonts ^6.2.1 + vibration ^2.0.0
- Dev: hive_generator ^2.0.1 + build_runner ^2.4.9 + flutter_lints ^3.0.0

**Storage**: Hive (structured local), SharedPreferences (key-value) — no remote backend in any phase

**Testing**: flutter_test (SDK built-in) — no tests in Phase 1 scaffold; test suite belongs to later phases

**Target Platform**: iOS 13+ and Android API 21+ — portrait-only, RTL Arabic primary locale

**Project Type**: mobile-app (single Flutter project, no backend)

**Performance Goals**: App cold-start to first frame < 2 s on a mid-range device; tab switch imperceptible (IndexedStack avoids rebuild cost); developer setup < 5 minutes (SC-001)

**Constraints**: Portrait-only orientation locked at startup; RTL enforced at root `Directionality` widget; fully offline (all storage local); no remote API calls in Phase 1

**Scale/Scope**: Single-user app; Phase 1 ~15 source files; full app will grow to ~50+ screens across 5 feature modules

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution file contains only template placeholders — no project-specific principles are defined. No gates to enforce. ✅ Cleared to proceed.

**Post-Phase 1 re-check**: No architectural decisions in Phase 1 violate any constitution principle. ✅ Cleared.

## Project Structure

### Documentation (this feature)

```text
specs/001-tajali-project-scaffold/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── screen-contract.md   # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
tajali/
├── pubspec.yaml                         # Package manifest
├── pubspec.lock                         # Generated
├── analysis_options.yaml                # flutter_lints config
│
├── assets/
│   ├── fonts/                           # Amiri-Regular.ttf, Amiri-Bold.ttf, AmiriQuran.ttf
│   ├── images/                          # Raster assets (empty in Phase 1)
│   ├── svg/                             # Vector assets (empty in Phase 1)
│   ├── audio/                           # Audio clips (empty in Phase 1)
│   └── data/                            # JSON data (empty in Phase 1)
│
└── lib/
    ├── main.dart                        # Entry: orientation lock + ProviderScope + TajaliApp
    ├── app/
    │   ├── app.dart                     # TajaliApp ConsumerWidget (MaterialApp, RTL, theme)
    │   ├── routes.dart                  # MainNavigation + selectedTabProvider + IndexedStack
    │   └── theme/
    │       ├── app_colors.dart
    │       ├── app_fonts.dart
    │       ├── app_text_styles.dart
    │       └── app_theme.dart
    ├── core/
    │   ├── constants/app_constants.dart
    │   ├── utils/helpers.dart
    │   ├── widgets/
    │   │   ├── islamic_card.dart
    │   │   ├── gold_divider.dart
    │   │   └── arabesque_header.dart
    │   └── services/location_service.dart
    ├── features/
    │   ├── home/presentation/home_screen.dart
    │   ├── prayer_times/presentation/prayer_times_screen.dart
    │   ├── quran/presentation/quran_screen.dart
    │   ├── adhkar/presentation/adhkar_screen.dart
    │   └── qibla/presentation/
    │       ├── qibla_screen.dart        # Wired to navigation tab 3
    │       └── tasbih_screen.dart       # Scaffolded only — not wired (Phase 1)
    └── shared/
        └── local_storage/storage_service.dart
```

**Structure Decision**: Single Flutter project with feature-based module separation under `lib/`. No separate backend or API project. Asset directories are pre-declared in `pubspec.yaml` and may be empty in Phase 1 (the project compiles without asset files present).
