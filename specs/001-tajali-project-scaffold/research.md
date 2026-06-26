# Research: تَجَلِّي Project Scaffold

**Feature**: 001-tajali-project-scaffold
**Date**: 2026-06-25
**Plan**: [plan.md](plan.md)

---

## Decision 1: Tab State Preservation — IndexedStack

**Decision**: Use `IndexedStack` in `MainNavigation` to host all five screens simultaneously.

**Rationale**: `IndexedStack` renders every child widget on first build and toggling the visible index simply shows or hides the subtree — no rebuild occurs on tab switch. This gives free scroll-position and widget-state preservation across all five feature tabs (FR-007a). For a reading/reference app (Quran, Adhkar) this UX quality is non-negotiable.

**Alternatives considered**:

| Alternative | Why rejected |
|---|---|
| `PageView` + `AutomaticKeepAliveClientMixin` per screen | Preserves state but requires a `mixin` on every screen class — unnecessary boilerplate for Phase 1 placeholder screens |
| Rebuild on switch (`body: _screens[selectedIndex]`) | Resets scroll position on every tab change — rejected per clarification Q2 |
| Nested `Navigator` per tab | Correct for deep in-tab navigation but over-engineered for Phase 1; add in later phases when features need sub-routing |

---

## Decision 2: Minimum Flutter SDK Version — Flutter 3.19

**Decision**: Require Flutter ≥ 3.19.0 (stable).

**Rationale**: Binding constraint is `geolocator ^11.0.0`, which mandates Android Gradle Plugin (AGP) ≥ 8.0. AGP 8.x support in Flutter tooling shipped in Flutter 3.19. All other specified packages are compatible with 3.19:

| Package | Minimum Flutter |
|---|---|
| flutter_riverpod ^2.5.1 | Flutter 3.10 (Dart 3.0) |
| just_audio ^0.9.38 | Flutter 3.10 |
| flutter_local_notifications ^17.2.2 | Flutter 3.13 |
| geolocator ^11.0.0 | Flutter 3.19 ← binding constraint |

**Alternatives considered**:

| Alternative | Why rejected |
|---|---|
| Flutter 3.22+ (latest stable) | No blocking reason to require latest; 3.19 maximises compatibility with developer machines |
| Leave unspecified | Causes setup failures on older SDKs — rejected; SC-005 (zero errors) makes this a hard requirement |

---

## Decision 3: RTL Layout Strategy — Two-Layer Approach

**Decision**: Set `locale: const Locale('ar')` on `MaterialApp` AND wrap `MainNavigation`'s `Scaffold` in `Directionality(textDirection: TextDirection.rtl)`.

**Rationale**: Setting `locale` on `MaterialApp` propagates RTL semantics to all Material widgets automatically (AppBar actions appear on the left, BottomNavigationBar icons are mirrored). Adding an explicit `Directionality` at the scaffold level catches any widget that resolves direction from `Directionality` rather than from `Localizations`, ensuring no widget accidentally renders LTR. This two-layer defence is the Flutter community standard for fully-RTL apps.

**Alternatives considered**:

| Alternative | Why rejected |
|---|---|
| System locale detection only | App is Arabic-only; always RTL; dynamic detection adds unnecessary complexity in Phase 1 |
| Per-screen `Directionality` wrapper | Duplicates code; fails to cover widgets outside the main scaffold; rejected |

---

## Decision 4: Riverpod Scope — Minimal (selectedTabProvider only)

**Decision**: A single `StateProvider<int>` named `selectedTabProvider` tracks the active tab index. All five placeholder screens are stateless in Phase 1; no feature-specific providers are declared yet.

**Rationale**: FR-013 requires the `ProviderScope` to wrap the widget tree from the start to validate the state-management infrastructure. A single integer provider is the minimum viable Riverpod usage that:
1. Confirms `ProviderScope` works
2. Moves tab state out of a `StatefulWidget` (cleanly testable)
3. Avoids pre-creating provider stubs that will be deleted or significantly restructured in later phases

**Alternatives considered**:

| Alternative | Why rejected |
|---|---|
| `StatefulWidget` with `setState` for tab index | Cannot be watched by child widgets; breaks when any feature screen needs to programmatically switch tabs |
| Pre-create all feature providers as stubs | Over-engineering for scaffold; stubs create dead code that misleads future developers |

---

## Decision 5: Canonical App Name — تَجَلِّي (Tajali)

**Decision**: Root widget class is `TajaliApp`; `MaterialApp` title is `'تَجَلِّي'`; all code identifiers use `Tajali` prefix where a prefix is required.

**Rationale**: Confirmed by clarification Q1. The project folder, PLAN.md, spec.md, and user intent all use تَجَلِّي. The `NoorApp`/`نور` name present in the PLAN.md code snippets was an inconsistency that has been resolved in favour of تَجَلِّي.

**Alternatives considered**: `NoorApp` / `نور` — rejected per clarification Q1.

---

## Decision 6: Placeholder Screen Baseline

**Decision**: Each placeholder screen is a `StatelessWidget` returning a `Scaffold` with an `AppBar` (inheriting `AppBarTheme`) and a centred `Text` body using `AppTextStyles.heading2`.

**Rationale**: This is the minimum structure that:
- Passes the acceptance test (SC-002: all tabs show content without crashing)
- Validates `AppTextStyles` and `AppBarTheme` from the theme system
- Gives future developers a consistent baseline to replace

The Tasbih screen (`tasbih_screen.dart`) follows the same pattern but is not imported or referenced in `routes.dart` in Phase 1 (FR-004a).
