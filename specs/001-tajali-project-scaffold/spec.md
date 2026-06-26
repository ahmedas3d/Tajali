# Feature Specification: تَجَلِّي Project Scaffold

**Feature Branch**: `001-tajali-project-scaffold`

**Created**: 2026-06-25

**Status**: Draft

**Input**: User description: "Phase 1 of the تَجَلِّي Islamic Flutter app — folder structure and pubspec configuration"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Developer Sets Up and Runs the App (Priority: P1)

A developer checks out the repository for the first time, installs dependencies, and immediately has a running app with five navigable feature tabs and no errors.

**Why this priority**: This is the foundational milestone — nothing else in the project can be built or tested until the skeleton compiles and launches.

**Independent Test**: Run the app on a simulator or physical device. Navigate each of the five bottom-navigation tabs. Verify the app does not crash and each tab shows its labelled placeholder screen.

**Acceptance Scenarios**:

1. **Given** a fresh project checkout, **When** standard package install is run, **Then** all dependencies resolve without version conflicts
2. **Given** dependencies are installed, **When** the app is launched, **Then** a home screen appears with a five-tab bottom navigation bar
3. **Given** the app is running, **When** a developer taps each tab, **Then** each of the five feature screens (Home, Quran, Adhkar, Qibla, Prayer Times) is displayed with its Arabic label
4. **Given** the app is running on a device with an Arabic locale, **When** any screen is displayed, **Then** text flows right-to-left and the layout is mirrored correctly

---

### User Story 2 - Developer Starts Building a Feature Module (Priority: P2)

A developer picks one of the five feature areas and begins adding real functionality without restructuring the project.

**Why this priority**: The folder structure must anticipate the full feature set so that later phases slot in without reorganisation.

**Independent Test**: Open any feature folder (e.g., `features/prayer_times/`). Confirm the `presentation/` sub-folder and its placeholder screen file exist and are wired into the navigation.

**Acceptance Scenarios**:

1. **Given** the project scaffold exists, **When** a developer navigates to any feature folder, **Then** they find a `presentation/` layer directory with a placeholder screen already in place
2. **Given** the project scaffold exists, **When** shared utilities or constants are needed, **Then** a `core/` directory with `constants/`, `utils/`, `widgets/`, and `services/` sub-folders is available
3. **Given** the project scaffold exists, **When** app-wide configuration (theme, routing) is needed, **Then** an `app/` directory with a dedicated `theme/` sub-folder exists

---

### User Story 3 - Developer Adds Assets and Custom Fonts (Priority: P3)

A developer drops a new font file or image into the appropriate asset directory and the asset is immediately usable in the app after a rebuild.

**Why this priority**: Static assets (Arabic fonts, decorative SVGs, audio) are central to the Islamic aesthetic and must be wired in from day one.

**Independent Test**: Place a test image in the images asset folder and reference it in the home screen. Rebuild. Confirm the image renders.

**Acceptance Scenarios**:

1. **Given** the project is configured, **When** a file is added to any of the four asset directories (images, SVG, audio, data), **Then** the app can reference it after a rebuild without any additional configuration
2. **Given** the project is configured, **When** the Amiri or AmiriQuran font families are referenced in code, **Then** text renders in the correct Islamic calligraphic style on screen
3. **Given** the app is running, **When** Arabic Quran text is displayed, **Then** it uses the dedicated Quranic font variant and not the generic system font

---

### Edge Cases

- What happens when a required package version is incompatible with the Flutter SDK version in use? → Treat as a blocking setup error; the developer must resolve the version conflict before the app can compile (SC-005).
- How does the navigation behave if a placeholder screen throws a build-time error? → The entire app fails to compile; all five screens must be error-free for the Phase 1 acceptance test to pass.
- What happens on tablets or large-screen devices given the portrait-only orientation constraint? → The app remains locked to portrait; tablet-specific layouts are out of scope for all phases.
- What happens to a tab's scroll or widget state when the user switches tabs? → State is preserved; returning to a tab restores the exact state the user left (see FR-007a).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Project MUST be organised into four top-level modules under `lib/`: `app/` (app-wide config), `core/` (shared utilities), `features/` (feature modules), and `shared/` (cross-cutting services)
- **FR-002**: `app/` MUST contain a `theme/` sub-directory for colour palette, typography, font constants, and the assembled Material theme
- **FR-003**: `core/` MUST contain sub-directories for `constants/`, `utils/`, `widgets/`, and `services/`
- **FR-004**: `features/` MUST contain five feature directories: `home/`, `prayer_times/`, `quran/`, `adhkar/`, and `qibla/`; each MUST expose at least a `presentation/` layer with a placeholder screen
- **FR-004a**: The `qibla/presentation/` directory MUST contain both `qibla_screen.dart` and `tasbih_screen.dart` as empty placeholders; only `qibla_screen.dart` is wired into navigation in Phase 1 — `tasbih_screen.dart` is scaffolded but deferred
- **FR-005**: `shared/` MUST contain a `local_storage/` sub-directory for a shared persistence service
- **FR-006**: Each placeholder screen MUST display the feature name in Arabic and be independently navigable via the bottom navigation bar
- **FR-007**: The bottom navigation bar MUST have five fixed tabs labelled in Arabic: الرئيسية، القرآن، الأذكار، القبلة، الصلاة
- **FR-007a**: Each tab MUST preserve its widget state (including scroll position) when the user navigates away and returns; no tab SHOULD reset to its initial state due to a tab switch
- **FR-008**: The entire app layout MUST default to right-to-left text direction to support Arabic
- **FR-009**: Package manifest MUST declare dependencies covering: state management, local persistence (key-value and structured), device location and compass, prayer-time calculation, audio playback, local push notifications, and SVG rendering
- **FR-010**: Package manifest MUST declare development-only dependencies for code generation and linting
- **FR-011**: Package manifest MUST register four asset directories (images, SVG files, audio clips, data files) and two font families (Amiri regular/bold, AmiriQuran)
- **FR-012**: App MUST lock to portrait orientation at startup
- **FR-013**: The app entry point MUST wrap the widget tree in the state-management scope so all feature screens can access global state from the outset
- **FR-014**: The app MUST be named **تَجَلِّي** (Tajali) consistently — in the displayed title, app metadata, and all code identifiers (e.g., root widget class)

### Key Entities

- **App Module**: Root configuration containing theme definitions, entry widget, and bottom-navigation routing
- **Feature Module**: A self-contained area of functionality with its own `presentation/` layer; the five modules are Home, Prayer Times, Quran, Adhkar, and Qibla — the Qibla module additionally contains a Tasbih screen file that is scaffolded but not wired to navigation in Phase 1
- **Core Module**: Shared, feature-agnostic code — constants, helper utilities, reusable widgets (Islamic card, gold divider, arabesque header), and location service stub
- **Shared Module**: Cross-cutting infrastructure services such as local storage
- **Asset Bundle**: Static resources (font files, images, vector graphics, audio, JSON data) declared in the package manifest and shipped with the app binary

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer who has never seen the project can install dependencies and reach the running app within five minutes of first checkout
- **SC-002**: All five navigation tabs are reachable and display content without crashes on both iOS and Android
- **SC-003**: Arabic text renders right-to-left throughout the app with no reversed or incorrectly mirrored elements
- **SC-004**: The Amiri and AmiriQuran font families are visible on screen — text set in those fonts must be distinguishably different from the system default font
- **SC-005**: The project compiles with zero errors and zero package version conflicts
- **SC-006**: Any file placed in the declared asset directories is resolvable by the app after a single rebuild, with no manual configuration changes required

## Clarifications

### Session 2026-06-25

- Q: What is the canonical app name — تَجَلِّي (Tajali) or نور (Noor)? → A: تَجَلِّي (Tajali) — used everywhere, including the displayed app title and all code class names (e.g., `TajaliApp`)
- Q: When a user switches between bottom-nav tabs and returns, should the tab's state (scroll position, widget state) be preserved or reset? → A: Preserve state — each tab retains its scroll position and widget state between switches
- Q: Is the Tasbih screen (inside the Qibla feature folder) in scope for Phase 1, and how is it accessed? → A: Deferred — the Tasbih file is created as an empty placeholder alongside `qibla_screen.dart` but is not wired into navigation in Phase 1

## Assumptions

- Developers have the Flutter SDK (stable channel) installed and a connected device or simulator available
- Font files for Amiri Regular, Amiri Bold, and AmiriQuran will be provided separately and placed in `assets/fonts/` before the first build
- The app targets iOS and Android mobile platforms only; desktop and web are out of scope for all phases
- Portrait-only orientation is acceptable for all screens and all phases; landscape support is not planned
- Light mode is the default visual theme; a dark-mode colour palette will be defined in Phase 2 but the toggle mechanism is out of scope for Phase 1
- The state-management layer (Riverpod) is configured at the root and available to all screens, but no actual providers are implemented in Phase 1 — placeholder screens are stateless
- Asset files (images, SVG, audio, data) do not need to be present for the project to compile; empty directories suffice for Phase 1
