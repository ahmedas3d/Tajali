# Feature Specification: Splash Screen & Onboarding

**Feature Branch**: `004-splash-onboarding`

**Created**: 2026-06-26

**Status**: Draft

**Input**: User description: "Phase 0 — Splash Screen & Onboarding. First-launch experience: branded splash screen followed by a 3-slide onboarding walkthrough with location and notification permission requests. Returning users skip onboarding and go directly to home."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — First-time user sees splash then onboarding (Priority: P1)

A brand-new user launches the app for the first time. They see a branded splash screen for roughly 2.5 seconds, then land on the first onboarding slide. They can swipe or tap "التالي" to advance through all three slides, and on the final slide tap "ابدأ الآن" which requests location and notification permissions, marks onboarding as complete, and navigates them to the main home screen.

**Why this priority**: This is the zero-to-one user experience. Without it, first-time users have no guided entry into the app and no permission consent flow.

**Independent Test**: Fresh-install the app (or clear app data), launch it, and confirm the splash → slide 1 → slide 2 → slide 3 → home flow completes end-to-end.

**Acceptance Scenarios**:

1. **Given** the app has never been launched on this device, **When** the user opens the app, **Then** the splash screen is shown for approximately 2.5 seconds with the branded animation, then the first onboarding slide appears automatically.
2. **Given** the user is on slide 1 or 2, **When** they tap "التالي", **Then** the view advances to the next slide.
3. **Given** the user is on slide 3, **When** they tap "ابدأ الآن", **Then** the system location permission dialog appears, followed by the notification permission dialog, and after both are resolved (regardless of the user's choice) the app navigates to the main home screen.
4. **Given** the user has completed onboarding, **When** the app is relaunched, **Then** the splash screen is shown then the home screen appears directly — the onboarding slides are never shown again.

---

### User Story 2 — Returning user skips onboarding (Priority: P1)

A user who has already completed onboarding relaunches the app. They see the splash screen animation and are taken directly to the main home screen without seeing any onboarding slides.

**Why this priority**: Showing onboarding repeatedly to returning users degrades the experience and undermines trust.

**Independent Test**: Complete onboarding once, close and relaunch the app, and confirm the onboarding screen never appears.

**Acceptance Scenarios**:

1. **Given** onboarding has been completed on a previous launch, **When** the app is opened, **Then** after the splash screen the main home screen is shown immediately.
2. **Given** the app was force-closed mid-session (not mid-onboarding), **When** relaunched, **Then** the splash leads directly to home, not onboarding.

---

### User Story 3 — User skips onboarding from slide 1 or 2 (Priority: P2)

A user taps the "تخطي" (Skip) button visible on slides 1 and 2. They are taken directly to slide 3 (the permissions slide), not to the home screen. Slide 3 must always be seen so the permission request is not bypassed.

**Why this priority**: Skip is a usability affordance that respects impatient users but must not bypass the required permission consent flow.

**Independent Test**: On slide 1, tap "تخطي" and confirm the view jumps to slide 3 (not home), then confirm "ابدأ الآن" completes the flow normally.

**Acceptance Scenarios**:

1. **Given** the user is on slide 1, **When** they tap "تخطي", **Then** the view jumps directly to slide 3.
2. **Given** the user is on slide 2, **When** they tap "تخطي", **Then** the view jumps directly to slide 3.
3. **Given** the user has skipped to slide 3, **When** they tap "ابدأ الآن", **Then** permissions are requested and onboarding completes normally.
4. **Given** the user is on slide 3, **When** they look at the top bar, **Then** no "تخطي" button is visible.

---

### User Story 4 — User navigates back to previous slide (Priority: P3)

A user on slide 2 or 3 taps "السابق" (Previous) and returns to the immediately preceding slide.

**Why this priority**: Back navigation is a standard onboarding affordance that reduces anxiety about missing information.

**Independent Test**: Advance to slide 2, tap "السابق", and confirm slide 1 appears.

**Acceptance Scenarios**:

1. **Given** the user is on slide 2, **When** they tap "السابق", **Then** slide 1 is shown.
2. **Given** the user is on slide 3, **When** they tap "السابق", **Then** slide 2 is shown.
3. **Given** the user is on slide 1, **Then** no "السابق" button is visible.

---

### Edge Cases

- What happens if the user denies a permission via the card tap? → The card updates its visual state to reflect denial; the flow continues. The user can still proceed via "ابدأ الآن" without that permission.
- What happens if the user taps "ابدأ الآن" without tapping any permission card? → "ابدأ الآن" requests both permissions sequentially before navigating to home.
- What happens if only one permission card was tapped before "ابدأ الآن"? → "ابدأ الآن" requests only the remaining unresolved permission before navigating.
- What happens if the user force-kills the app during onboarding before completing slide 3? → Onboarding is not marked complete; the next launch shows onboarding again from slide 1.
- What happens on a device that does not support notification permissions (e.g., older Android)? → The notification permission request is silently skipped; the flow completes normally.
- What happens if the app is updated but onboarding was already completed before the update? → Onboarding remains marked as complete; the user is not shown onboarding again.
- What happens if the splash animation is interrupted by a phone call? → The app resumes the splash from its current state when it regains focus; navigation still triggers after the 2.5-second total delay.
- What happens when the user backgrounds the app and returns after onboarding is complete? → The splash screen is NOT shown on foreground resume; the app resumes wherever the user left off in the main navigation.

---

## Requirements *(mandatory)*

### Functional Requirements

**Splash Screen**

- **FR-001**: The splash screen MUST be displayed on every cold start (first-time and returning users). It MUST NOT be shown when the app returns to the foreground from background suspension.
- **FR-002**: The splash screen MUST display for approximately 2.5 seconds before navigating away.
- **FR-003**: The splash screen MUST show the animated app logo (8-pointed Islamic star), the app name "تجلي", and the tagline "رفيقك الروحي اليومي".
- **FR-004**: The splash screen animation sequence MUST be: logo fades in and scales up (0.7 → 1.0 scale over ~800 ms), tagline fades in after a ~600 ms delay (~400 ms duration), hold for ~800 ms, then the screen fades out and navigation occurs.
- **FR-005**: After the splash animation completes, the app MUST check whether onboarding has been completed and navigate accordingly: first-time users go to the onboarding screen; returning users go to the main home screen.
- **FR-006**: The splash screen MUST have a full-screen deep-green gradient background (dark green `#1B4332` to darker green `#0D2218`).
- **FR-007**: The splash screen MUST display decorative arabesque elements: top and bottom ornamental bands (gold fleur-de-lis icons with horizontal dividers at low opacity), a corner ornament (top-left, 40% opacity), and a soft radial golden glow behind the logo.
- **FR-008**: The splash screen MUST display a loading indicator at the bottom (circular border + "جارٍ التحميل..." text in gold at low opacity).

**Onboarding Screen**

- **FR-009**: The onboarding screen MUST display exactly 3 slides navigable by swipe or by tapping navigation buttons.
- **FR-010**: All 3 slides MUST share a common layout: full-screen dark-green gradient background, decorative corner arabesque ornaments, illustration area (upper ~55% of screen), title text, subtitle text, page indicator dots, and navigation controls.
- **FR-011**: Slide 1 MUST show: illustration of a mosque silhouette with a golden star above it; title "أهلاً بك في تجلي"; subtitle "رفيقك الروحي في كل يوم — قرآن، أذكار، صلاة، وقبلة".
- **FR-012**: Slide 2 MUST show: illustration of 5 feature hexagonal cards arranged in a pentagonal/arc pattern (الصلاة, القرآن, الأذكار, القبلة — plus a larger central "تجلي" star hexagon); title "كل ما تحتاجه في مكان واحد"; subtitle "مواقيت الصلاة · القرآن الكريم · الأذكار · القبلة · التسبيح".
- **FR-013**: Slide 3 MUST show: illustration of an ornate compass rose with a location pin above it and a bell icon with ripple to the side; title "نحتاج إذنك"; subtitle "لنقدم لك أوقات الصلاة الدقيقة واتجاه القبلة حسب موقعك"; two individually tappable permission cards (location and notifications); security note "لن نشارك بياناتك مع أي طرف ثالث". Each card MUST be tappable and MUST trigger its corresponding OS permission dialog immediately on tap, independently of the "ابدأ الآن" button. Each card MUST update its visual appearance after the OS dialog resolves: a granted permission MUST show a gold checkmark indicator; a denied permission MUST show the card in a muted/greyed state with a subtle warning icon, signalling the denial without alarming the user.
- **FR-014**: Slides 1 and 2 MUST show a "تخطي" (Skip) button that jumps directly to slide 3. Slide 3 MUST NOT show a "تخطي" button.
- **FR-015**: Slides 1 and 2 MUST show a "التالي →" text button in the bottom-left (RTL layout) that advances to the next slide.
- **FR-016**: Slides 2 and 3 MUST show a "السابق" text button that returns to the previous slide. Slide 1 MUST NOT show a "السابق" button.
- **FR-017**: Slide 3 MUST replace "التالي" with a full-width primary "ابدأ الآن" button.
- **FR-018**: Tapping "ابدأ الآن" on slide 3 MUST request any permissions not yet requested via card taps (location first, then notifications, sequentially), then mark onboarding as complete, then navigate to the main home screen — regardless of the user's individual permission choices. Permissions already resolved via card taps MUST NOT be re-requested.
- **FR-019**: The page indicator MUST display 3 dots; the dot corresponding to the active slide MUST be filled gold; inactive dots MUST be outlined/muted.
- **FR-020**: Onboarding completion status MUST be persisted locally on the device so it survives app restarts and updates.

### Key Entities

- **Onboarding Completion Flag**: A boolean stored locally on the device that records whether the user has completed the onboarding flow. Defaults to `false` (not complete). Set to `true` when the user taps "ابدأ الآن" on slide 3 and the navigation to home is triggered.
- **Onboarding Slide**: A data record representing one slide's content — title (Arabic string), subtitle (Arabic string), and illustration reference. The three slides are defined statically; their order is fixed.

---

## Visual Design Specification

> Design source: Figma file `LCsFWsSdI93TyJBbWXmCl6`

### Color Tokens

| Token | Value | Usage |
|-------|-------|-------|
| Primary Green | `#1B4332` | Background gradient start, card fills |
| Deep Green | `#0D2218` | Background gradient end |
| Darkest Green | `#012D1D` | "ابدأ الآن" button text |
| Gold Primary | `#C9A84C` | Active dots, cards border, nav labels, button bg |
| Gold Light | `#E8C97A` | Logo star gradient start, ornament accents |
| Gold Glow | `#FFE08F` | Arabesque bands, halo ring |
| Ivory | `rgba(255,241,232,1)` | Headings (card), permission card text |
| Ivory 75% | `rgba(255,241,232,0.75)` | Subtitles |
| Ivory 60% | `rgba(255,241,232,0.60)` | Loading text, secondary labels |
| Ivory 45% | `rgba(255,241,232,0.45)` | Security note text |
| Card Surface | `rgba(255,241,232,0.08)` | Permission card background (frosted) |
| Card Border | `rgba(201,168,76,0.30)` | Permission card border |

### Typography

| Usage | Font | Weight | Size | Colour |
|-------|------|--------|------|--------|
| App name "تجلي" | Amiri | Regular | 38px | Gold gradient `#E8C97A` → `#C9A84C` |
| Tagline | Amiri | Regular | 16px | Ivory 75% |
| Slide title | Amiri | Bold | 26px | `#C9A84C` |
| Slide subtitle | Amiri | Regular | 14–15px | Ivory 75% |
| Permission card title | Amiri | Bold | 17px | Ivory |
| Permission card subtitle | Amiri | Regular | 13px | Ivory 60% |
| "ابدأ الآن" button | Amiri | Bold | 18px | `#012D1D` |
| Nav labels ("التالي", "السابق") | Amiri | Bold | 18px | Gold `#C9A84C` |
| Skip label ("تخطي") | Amiri | Regular | 14–16px | Ivory 50% |
| Loading text | Amiri-compatible | Regular | 11px | Ivory 60% |
| Security note | Amiri | Regular | 12px | Ivory 45% |

### Splash Screen Layout

- **Canvas size**: 390 × 884 px (full screen, no safe area chrome)
- **Background**: `linear-gradient(180deg, #1B4332 0%, #0D2218 100%)`
- **Top arabesque band**: Full-width, 32px tall, 30% opacity — three fleur-de-lis icons (11.67px each, 16px apart) flanked by horizontal gold dividers
- **Bottom arabesque band**: Mirror of top band at bottom edge
- **Corner ornament**: 96 × 96px container, top-left, 40% opacity
- **Radial bloom**: 320px circle behind logo, `#FFE08F` colour, 32px blur, 10% opacity
- **Halo ring**: 224px circle, border `rgba(255,224,143,0.3)`, with 8 gold diamond decorations (8px squares rotated 45°) at cardinal and diagonal positions
- **Logo star**: 160 × 160px 8-pointed star (Rub el Hizb), gold gradient `#E8C97A` → `#C9A84C`, with hammered texture overlay (20% opacity), inner geometric inlay (square rotated 45°)
- **App name "تجلي"**: centered below logo, 32px margin-top, gold gradient text, letter-spacing 3.8px
- **Ornamental underline**: symmetrical — two 48px gradient lines flanking a 6px gold diamond, centered below name
- **Tagline "رفيقك الروحي اليومي"**: centered below underline, 16px gap
- **Loading indicator**: bottom-center, 64px from bottom — 40 × 40px circular border `#C9A84C`, "جارٍ التحميل..." text below with 2.2px letter-spacing uppercase

### Onboarding Slides — Shared Layout

- **Background**: `linear-gradient(180deg, #1B4332 0%, #0D2218 100%)` with atmospheric blur spots
- **Top bar**: 48px padding-top; "تخطي" on the right (RTL), status bar icons on the left (slides 1 & 2 only)
- **Corner ornaments**: 96 × 96px, top-right and bottom-left (rotated 180°), 20–60% opacity
- **Illustration area**: occupies top ~55% of the content area, centered
- **Text block**: title then subtitle, centered, below illustration
- **Page dots**: 3 dots, 10px each, 12px gap; active = gold filled with glow shadow; inactive = gold outline 50% opacity
- **Bottom navigation**:
  - Slides 1 & 2: "التالي ←" (arrow + label) on the right (RTL left side visually), page dots center-right, "السابق →" on the left (slide 2 only)
  - Slide 3: Full-width "ابدأ الآن" button + "السابق" text button

### Slide 1 — Illustration Details

- Mosque SVG silhouette: 340 × 280px container, green-on-green tones, drop shadow `rgba(0,0,0,0.15)` 25px
- Central dome, flanking minarets with caps, arched door
- Gold 5-pointed star (30px) above the dome with golden glow
- Subtle atmospheric radial glow behind illustration (gold, blurred)

### Slide 2 — Illustration Details

- 320 × 320px illustration area
- 4 small hexagonal cards (85 × 98px each), positioned in top-left, top-right, bottom-left, bottom-right quadrants
- Each small card: frosted glass `rgba(27,67,50,0.7)`, gold border `rgba(201,168,76,0.6)`, hexagon mask, icon + Arabic label
  - Top-left: prayer icon, "الصلاة"
  - Top-right: Quran icon, "القرآن"
  - Bottom-left: beads/sparkle icon, "الأذكار"
  - Bottom-right: compass icon, "القبلة"
- 1 larger center hexagon (100 × 115px): frosted glass `rgba(27,67,50,0.8)`, gold border 2px `#C9A84C`, contains the Tajali 8-pointed star logo and "تجلي" label in gold
- Radial gold glow behind center hexagon (140px circle, blurred)

### Slide 3 — Illustration Details

- Compass base: 200 × 200px circle, border 2px `rgba(201,168,76,0.4)`, inner border 1px `rgba(201,168,76,0.2)`, padding 10px
- Ornate compass rose SVG (90 × 90px) inside
- 8-pointed star at exact center (31.67 × 33.33px)
- Location pin (21.33 × 26.67px) above the compass top point (offset -16px from top)
- Bell icon with ripple: 40 × 40px circle `rgba(201,168,76,0.3)` glow + `#1B4332` fill with gold border, positioned upper-right of compass
- Mandala background (280px, 10% opacity) behind compass
- Background dot pattern texture (8px tile, 5% opacity)
- Permission cards (pending state): full-width, padding 17px, border-radius 12px, backdrop blur 4px, `rgba(255,241,232,0.08)` fill, `rgba(201,168,76,0.3)` border; 12px gap between cards; icon badge 48×48px circle `rgba(201,168,76,0.1)` on the left (RTL: visually right)
- Permission card states after OS dialog resolves:
  - **Granted**: gold checkmark replaces icon badge; border shifts to `#C9A84C` (full opacity)
  - **Denied**: card fill dims to `rgba(255,241,232,0.04)`, border to `rgba(255,241,232,0.15)`, label text to `rgba(255,241,232,0.4)`, icon badge shows a subtle warning symbol at low opacity — non-alarming, calm
  - **Pending**: original frosted-glass state above
- "ابدأ الآن" button: full-width, 56px tall, border-radius 14px, `#C9A84C` fill, drop shadow `rgba(201,168,76,0.3)` 4px 10px

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The splash screen animation completes and navigation occurs within 3 seconds of app launch on a mid-range device.
- **SC-002**: A first-time user can complete the full onboarding flow (3 slides + permission dialogs) in under 60 seconds.
- **SC-003**: A returning user reaches the home screen within 3 seconds of launch with no onboarding slides appearing.
- **SC-004**: The onboarding completion flag persists across app restarts — once onboarding is marked complete, it is never shown again on the same device.
- **SC-005**: The permission flow triggers on slide 3 in 100% of "ابدأ الآن" taps — never skipped, never shown twice.
- **SC-006**: All Arabic text (titles, subtitles, labels, buttons) renders correctly with no garbled or missing characters on both Android and iOS.
- **SC-007**: The splash and all three onboarding slides render pixel-faithfully against the Figma designs — gold gradients, frosted glass cards, and geometric decorations are all present.
- **SC-008**: Skipping from slide 1 or 2 always lands on slide 3, never home — verified in 100% of skip-button taps.

---

## Clarifications

### Session 2026-06-26

- Q: Should the splash screen appear on every app foreground (warm start) or cold start only? → A: Cold start only — the splash is not shown when the app resumes from background suspension.
- Q: Are the permission cards on slide 3 individually tappable or decorative? → A: Individually tappable — each card triggers its own OS permission dialog immediately on tap, and updates its visual state after the dialog resolves. "ابدأ الآن" requests any not-yet-resolved permissions before completing the flow.
- Q: What visual state should a permission card show when the user denies the permission? → A: Muted/greyed — card dims with a subtle warning icon; non-alarming and consistent with the app's calm tone. Granted cards show a gold checkmark.

---

## Assumptions

- The Phase 1 project scaffold (folder structure, `pubspec.yaml`, registered assets and fonts) is already in place.
- The Phase 2 theme system (`AppColors`, `AppFonts`, `AppTextStyles`, `AppTheme`) is implemented and the `Amiri` font family is registered.
- The Phase 3 navigation shell (`MainNavigation`) is implemented and serves as the destination after onboarding.
- The Amiri Bold and Amiri Regular font variants are available as bundled assets.
- SVG illustrations (mosque, feature hexagons, compass rose, corner ornaments) are designed externally and delivered as SVG asset files; this spec does not define their internal vector paths.
- The app runs in portrait-only mode (established in Phase 3); the onboarding and splash screens do not need to handle landscape.
- All text is in Arabic; no English localisation is required for these screens.
- The "ابدأ الآن" button always requests both location and notification permissions regardless of prior device-level grant status — the OS handles showing or silently skipping dialogs for already-granted permissions.
- Permission denial does not block app usage; features that require permissions will prompt contextually when needed.
- No analytics or crash reporting is wired into the splash/onboarding flow.
- The onboarding status is stored using a local key-value store (e.g., SharedPreferences); no remote or account-linked state is required.
- Slide swipe gesture (horizontal drag) is supported in addition to tapping the navigation buttons, but is not independently specified beyond standard page-view behaviour.
