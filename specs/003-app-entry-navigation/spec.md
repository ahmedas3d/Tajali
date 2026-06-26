# Feature Specification: App Entry Point & Navigation

**Feature Branch**: `003-app-entry-navigation`

**Created**: 2026-06-25

**Status**: Draft

**Input**: User description: "Phase 3 of the تجلي (Tajali) Islamic Flutter app — wires together the app bootstrap and bottom navigation shell on top of the Phase 2 theme system."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — App Launches to Home Tab (Priority: P1)

A first-time user opens the تجلي app. The app initialises, the splash/system UI fades into the home screen, and the bottom navigation bar is immediately visible with "الرئيسية" (Home) selected.

**Why this priority**: Without a successful cold-start landing on the home tab, no other feature is reachable. This is the zero-to-one story.

**Independent Test**: Cold-launch the installed app on a device and confirm the home placeholder screen is visible with all five navigation items rendered at the bottom.

**Acceptance Scenarios**:

1. **Given** the device has the app installed and no session in progress, **When** the user taps the app icon, **Then** the home screen appears within 3 seconds with the bottom navigation bar showing five tabs, الرئيسية highlighted.
2. **Given** the app is launching, **When** system initialisation completes, **Then** the screen orientation is locked to portrait and the status bar is transparent with light-coloured icons.

---

### User Story 2 — Navigating Between All Five Tabs (Priority: P1)

A user taps each of the five bottom-navigation tabs in sequence. Each tap instantly switches the visible content area to the corresponding feature screen without restarting the app.

**Why this priority**: Navigation is the skeleton of the entire app. All future features depend on users being able to move between sections.

**Independent Test**: Tap each tab one by one and verify the correct Arabic label and screen appear for every tab.

**Acceptance Scenarios**:

1. **Given** any tab is currently selected, **When** the user taps a different tab, **Then** the active tab icon switches to its filled variant, its label becomes highlighted in gold, and the corresponding screen content is displayed.
2. **Given** the user is on the القرآن tab, **When** they tap الأذكار, **Then** the Adhkar placeholder screen appears and القرآن icon reverts to outlined style.
3. **Given** any tab is tapped, **When** the transition completes, **Then** the response is visually immediate (no perceptible delay).

---

### User Story 3 — Screen State Is Preserved Across Tab Switches (Priority: P2)

A user scrolls down on one screen, switches to another tab, then returns to the first. Their position on the first screen is exactly where they left it.

**Why this priority**: State preservation is a quality-of-life requirement that becomes critical once real content (Quran verses, Adhkar lists) is added. Establishing it now with placeholder screens prevents regressions later.

**Independent Test**: Scroll the home placeholder (if any scroll is present) or note any stateful widget, switch tabs, return, and confirm the state is unchanged.

**Acceptance Scenarios**:

1. **Given** a user has interacted with screen A, **When** they navigate away to screen B and then back to screen A, **Then** screen A's visual state (scroll position, input state) is exactly as they left it.
2. **Given** a screen has already been visited, **When** its tab is re-selected, **Then** the screen does not rebuild from scratch.

---

### User Story 4 — RTL Arabic Layout Throughout (Priority: P2)

An Arabic-speaking user sees all labels, icons, and navigation items arranged right-to-left, consistent with standard Arabic app conventions.

**Why this priority**: The app targets Arabic speakers. An LTR layout would be immediately jarring and unprofessional.

**Independent Test**: Launch the app without changing device locale and confirm text and nav items read right-to-left.

**Acceptance Scenarios**:

1. **Given** the app is running, **When** any screen is displayed, **Then** text flows right-to-left and layout direction is RTL.
2. **Given** the bottom navigation bar is visible, **When** rendered, **Then** الرئيسية appears on the right end and الصلاة appears on the left end.

---

### Edge Cases

- What happens when the device is rotated to landscape? → Orientation must stay locked to portrait; the system should reject the rotation.
- What happens if a tab is tapped while already selected? → No navigation change; the screen stays as-is (no double-push or state reset).
- What happens on very small screen sizes? → Navigation labels must remain legible; they may truncate but must not overflow.
- What happens if the OS dark mode is enabled? → The app currently hard-codes light mode (`ThemeMode.light`); it must display the light theme regardless of system setting.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST complete initialisation (binding, orientation lock, status-bar styling) before rendering any UI.
- **FR-002**: The app MUST force portrait-up orientation at startup; landscape orientation MUST be rejected for the entirety of the session.
- **FR-003**: The status bar MUST be transparent with light-coloured icons on all screens.
- **FR-004**: The app MUST render in right-to-left text direction by default.
- **FR-005**: The app MUST display a bottom navigation bar containing exactly five tabs in this RTL order (right→left): الرئيسية, القرآن, الأذكار, القبلة, الصلاة.
- **FR-006**: Each navigation tab MUST display an outlined icon when inactive and a filled icon when active.
- **FR-007**: The active tab label MUST be visually distinct (gold colour per the Phase 2 theme) from inactive labels.
- **FR-008**: Tapping a tab MUST switch the visible screen without resetting the state of previously visited tabs.
- **FR-009**: Each feature screen MUST display an app bar with the title `تَجَلِّي` and a centred Arabic label identifying the screen's section.
- **FR-010**: The app MUST apply the Islamic parchment/gold light theme defined in Phase 2 regardless of system theme setting.
- **FR-011**: Global navigation state (active tab index) MUST be managed via a reactive state provider, not local widget state, so it is accessible to future features.

### Key Entities

- **Navigation State**: The currently active tab index (integer 0–4) owned by a global provider; drives both the bottom bar highlight and the visible screen.
- **Feature Screen**: A self-contained screen widget associated with one navigation tab, containing an app bar and a body; replaceable by a full implementation in later phases.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The app becomes fully interactive (bottom nav tappable) within 3 seconds of launch on a mid-range device.
- **SC-002**: Tab switches complete and the new screen is visible within 100 ms of a tap.
- **SC-003**: Returning to any previously visited tab results in zero state loss — the screen content is identical to how the user left it.
- **SC-004**: All five tab labels display correctly in Arabic with no garbled or missing characters.
- **SC-005**: Rotating the device to landscape has no visible effect — the app remains in portrait in 100% of attempts.
- **SC-006**: The status bar is transparent on every screen with no colour bleed from the app bar.

---

## Clarifications

### Session 2026-06-25

- Q: Should the app initialise a crash-reporting or analytics service during the Phase 3 bootstrap? → A: No crash reporting in Phase 3 — keep `main()` minimal, defer to a later phase.
- Q: What text should appear in the AppBar title of each placeholder screen? → A: Show the app name `تَجَلِّي` in every screen's AppBar.

---

## Assumptions

- Phase 1 project scaffold (folder structure, `pubspec.yaml`, registered assets and fonts) is already in place.
- Phase 2 theme files (`app_colors.dart`, `app_fonts.dart`, `app_text_styles.dart`, `app_theme.dart`) are implemented and error-free.
- The `flutter_riverpod` package is already declared in `pubspec.yaml` and available without further configuration.
- Arabic-speaking users are the primary audience; English locale support is included for fallback only.
- Dark mode switching is out of scope for this phase — `ThemeMode.light` is intentionally hard-coded; a user-controlled theme toggle will be addressed in a later phase.
- Deep linking, named routes, and push navigation are out of scope; the navigation shell uses a fixed bottom bar with `IndexedStack` only.
- No splash screen or onboarding flow is required for this phase; the app launches directly to the home tab.
- Each of the five placeholder screens is a standalone `StatelessWidget`; real feature content will replace them in subsequent phases.
- Crash reporting, analytics, and observability tooling are out of scope for Phase 3; `main()` initialises only Flutter binding, orientation, and status-bar styling.
