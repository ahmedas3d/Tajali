# Feature Specification: Theme System

**Feature Branch**: `002-theme-system`

**Created**: 2026-06-25

**Status**: Draft

**Input**: User description: "Phase 2 — Theme System for the تَجَلِّي (Tajali) Islamic Flutter app."

## Clarifications

### Session 2026-06-25

- Q: Is dark mode user-selectable (with persistence) in Phase 2, or is it fixed to light mode? → A: User can toggle light/dark in Phase 2; preference is saved between sessions
- Q: Does the app have a minimum color contrast or accessibility requirement? → A: WCAG AA compliance required — text pairs must achieve 4.5:1, UI components 3:1; colors must be adjusted if they fail
- Q: When a required font asset is missing at runtime, what is the correct behavior? → A: Silent fallback to system font; app continues normally with no user-visible error
- Q: Should `.withOpacity()` calls in CardTheme shadow be replaced with non-deprecated equivalents? → A: Yes — replace with pre-computed `const Color` ARGB values in the color token set; zero deprecation warnings allowed
- Q: Should the theme system define a text alignment convention for RTL Arabic, or is `Directionality` widget coverage sufficient? → A: `Directionality` is sufficient; `TextAlign.start` resolves to right-align automatically in an RTL context — no theme-level convention needed

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consistent Color Usage Across the App (Priority: P1)

A developer building any feature screen in the app can reference semantic, named color tokens instead of raw hex values. When they need the primary green, gold accent, or parchment background, a single source of truth tells them the exact value — and if it ever changes, it changes everywhere at once.

**Why this priority**: Color consistency is the most visible part of the visual identity. Without named tokens, different screens would diverge in shade and the Islamic aesthetic would break.

**Independent Test**: Can be validated by checking that all feature screens compile and reference colors exclusively from the color token set, and that the home screen renders with the correct background and accent colors.

**Acceptance Scenarios**:

1. **Given** a developer creates a new widget, **When** they apply a background color, **Then** they use a named token (e.g., `backgroundParchment`) and the widget renders with exactly that color value
2. **Given** the primary green color token is defined, **When** it is used in an AppBar and a Card border, **Then** both surfaces render identically — no visible shade difference
3. **Given** a dark-mode color token is defined, **When** the app is in dark mode, **Then** the background renders the dark brown value, not the light parchment

---

### User Story 2 - Arabic Typography Renders Correctly (Priority: P1)

An end user reading Quran verses, dhikr text, or UI labels sees Arabic text rendered in the Amiri typeface at the correct size and line spacing. Quran text uses the specialized AmiriQuran font. Headings, body text, and small labels each have a distinct, harmonious visual weight.

**Why this priority**: The app is Arabic-first; incorrect or missing font configuration produces unreadable text and breaks the entire UX.

**Independent Test**: Can be tested independently by running the app and verifying that Arabic heading text, body text, and a Quran verse each display in visibly distinct styles with correct font rendering.

**Acceptance Scenarios**:

1. **Given** the app launches, **When** an Arabic heading is displayed, **Then** the text uses the Amiri font at the correct size with the gold color
2. **Given** a screen shows Quran verses, **When** the verse text is rendered, **Then** it uses the AmiriQuran font with a generous line height for readability
3. **Given** a label needs the gold accent style, **When** `goldLabel` style is applied, **Then** the text renders bold with the defined letter spacing
4. **Given** a widget displays text over a dark background, **When** `onDark` or `onDarkBold` style is applied, **Then** the text is legible with the light ivory color

---

### User Story 3 - Light and Dark Theme Toggle with Persistence (Priority: P2)

The user can switch between a warm light theme (parchment background, deep green primary) and a dark theme (near-black background, gold primary) from within the app. Their choice is saved and restored the next time the app launches. Switching modes applies the correct colors and styles across all Material widgets — AppBar, Cards, BottomNavigationBar, and Dividers — without any per-widget overrides needed.

**Why this priority**: Dark mode is a user-expected feature on modern mobile apps, and persisting the preference is the minimum bar for it to feel finished.

**Independent Test**: Can be tested by switching to dark mode, force-closing the app, relaunching, and verifying the app opens in dark mode — then repeating for light mode.

**Acceptance Scenarios**:

1. **Given** the app is in light mode, **When** any screen is displayed, **Then** the scaffold background shows the parchment color and the AppBar shows deep green
2. **Given** the app is in dark mode, **When** any screen is displayed, **Then** the scaffold background shows the dark brown color and the AppBar shows the dark background with gold title text
3. **Given** either theme is active, **When** the BottomNavigationBar is rendered, **Then** the active tab item uses the gold accent color and inactive items are visually dimmed
4. **Given** either theme is active, **When** a Card widget is rendered, **Then** it displays the correct surface color with a gold-tinted border
5. **Given** the user switches to dark mode and closes the app, **When** the app is relaunched, **Then** it opens in dark mode without requiring the user to toggle again
6. **Given** the user has never set a preference, **When** the app launches for the first time, **Then** it defaults to light mode

---

### Edge Cases

- What happens when a font asset file is missing from the assets directory? The app silently falls back to the device system font with no user-visible error or crash; the layout may look different but remains functional.
- How does the system handle a device that doesn't support the `withOpacity` color modifier? All colors with opacity are pre-defined as constants to avoid runtime errors.
- What if a future developer uses a hardcoded hex value instead of a token? This is a process risk, not a runtime error — documented in assumptions.
- **Known contrast risk**: The gold (`#C9A84C`) on parchment (`#F5E6C8`) pairing has an estimated contrast ratio of ~2.6:1, which fails WCAG AA for normal text. Any style that renders gold text over a parchment or ivory background (e.g., `heading1`, `goldLabel`) MUST have its gold value darkened until the pairing passes 4.5:1. Gold used as a decorative border or large UI component must pass 3:1.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The theme system MUST provide a single file containing all named color tokens covering primary palette, backgrounds, text, dark mode surfaces, status states, and navigation states
- **FR-002**: The theme system MUST provide font family name constants for `Amiri` and `AmiriQuran` to prevent string literal duplication
- **FR-003**: The theme system MUST provide pre-defined text styles for all typographic roles: three heading levels, body, small body, Quran text, gold label, and two on-dark variants
- **FR-004**: The theme system MUST provide a light ThemeData instance using Material 3 with the full color scheme, AppBar, Card, Divider, BottomNavigationBar, and TextTheme configured
- **FR-005**: The theme system MUST provide a dark ThemeData instance using Material 3 with an inverted color scheme (gold as primary, green as secondary) and matching widget theme configurations
- **FR-006**: The light theme MUST set the default font family to Amiri so all Material widgets inherit Arabic typography without per-widget overrides
- **FR-007**: The dark theme MUST set the default font family to Amiri for the same reason
- **FR-008**: The BottomNavigationBar theme MUST be set to `fixed` type in both light and dark themes to support 5 navigation tabs without overflow behavior
- **FR-009**: All color tokens MUST be immutable, fixed values determined before the app starts; any color with partial transparency MUST be expressed as a pre-computed constant rather than computed at runtime through opacity calculations
- **FR-010**: All text style tokens MUST be `const` values for the same reason
- **FR-011**: The app MUST expose a mechanism for the user to toggle between light and dark modes at runtime
- **FR-012**: The selected theme mode MUST be persisted to local storage so it is restored on next app launch
- **FR-013**: When no stored preference exists, the app MUST default to light mode on first launch
- **FR-014**: Every foreground/background color pairing defined in the theme (text color over its intended background) MUST meet WCAG AA contrast ratios: 4.5:1 for normal text, 3:1 for large text (18px+ or 14px bold+) and interactive UI components
- **FR-015**: Any color token that fails WCAG AA in its intended pairing MUST be adjusted until it passes — the Islamic aesthetic should be preserved as closely as possible while meeting the threshold

### Key Entities

- **Color Token**: A named, immutable color value tied to a semantic role (e.g., "primary green", "gold accent", "dark background") rather than a generic shade name; semi-transparent tokens are expressed as pre-computed ARGB constants, never as runtime opacity modifiers
- **Text Style**: A named, immutable typographic configuration combining font family, size, weight, color, height, and optional letter spacing
- **ThemeData**: A Material framework object that bundles all visual configurations for a brightness mode (light or dark), applied globally to the widget tree
- **Font Family**: A named string constant identifying a bundled typeface (`Amiri` or `AmiriQuran`) declared in `pubspec.yaml` assets

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero hardcoded color hex values appear in any feature screen file — all colors reference the token set
- **SC-002**: The app compiles and runs without font-related errors or warnings on both iOS and Android simulators
- **SC-003**: Toggling between light and dark theme modes changes all themed widgets (scaffold, AppBar, Cards, BottomNav) in a single configuration change — no per-widget color overrides required; the selected mode persists across app restarts
- **SC-004**: All 9 text style variants render as visually distinct styles when displayed side-by-side in a test screen
- **SC-005**: The theme system introduces no measurable startup time overhead — all theme values are resolved before the app renders its first frame; the app build process emits zero warnings related to the theme layer
- **SC-006**: Every text color token achieves at least 4.5:1 contrast against its intended background in both light and dark themes; all interactive component color pairs achieve at least 3:1 contrast (verifiable via a WCAG contrast checker against the defined hex values)

## Assumptions

- Font asset files (`Amiri-Regular.ttf`, `Amiri-Bold.ttf`, `AmiriQuran.ttf`) are already declared in `pubspec.yaml` and present in `assets/fonts/` (Phase 1 responsibility)
- The `flutter` and `material` packages are available; no third-party theming library is needed
- Only light and dark themes are required for this phase — fully custom user-defined color schemes (beyond light/dark toggle) are out of scope
- The app uses a single locale at launch (`ar`) and RTL layout direction is handled by the `Directionality` widget in the navigation layer, not by the theme system; `TextAlign.start` (Flutter's default) automatically resolves to right-alignment within that RTL context — no per-widget `textAlign` override is needed
- Developers consuming this theme system will follow the convention of using named tokens; enforcement via lint rules is out of scope for this phase
- Theme preference persistence relies on the `StorageService` established in Phase 1; this phase depends on that service being available
- The `navInactive` color (50% opacity ivory) is stored as a pre-computed `Color` constant using the hex value `0x80FAF0DC` to avoid calling `.withOpacity()` at runtime, which cannot produce a `const` value
