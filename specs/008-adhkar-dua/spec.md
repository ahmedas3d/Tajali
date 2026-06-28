# Feature Specification: Adhkar & Dua (الأذكار والدعاء)

**Feature Branch**: `008-adhkar-dua`

**Created**: 2026-06-28

**Status**: Draft

**Input**: Phase 4 of PLAN2.md — Adhkar & Dua (fully offline Islamic remembrances)

---

## Clarifications

### Session 2026-06-28

- Q: Is sound feedback (صوت) on the tasbih screen in scope for this phase? → A: Yes — a short tap sound plays on each count and a distinct sound plays on round completion.
- Q: What does the "سجّل" (log) button on the tasbih screen do? → A: Opens a session history view listing past tasbih sessions by date (dhikr type, total count, date).
- Q: Should category cards visually indicate when all adhkar in that category are completed for the day? → A: Yes — completed category cards show a visual badge/checkmark when all adhkar in the category are fully counted for the day.
- Q: When a user partially counts dhikr #1, navigates to dhikr #2, then navigates back — does dhikr #1 show the remaining count or the full count? → A: Always shows remaining count; counter progress is preserved on every navigation (not only on app-restart).
- Q: Does the in-progress tasbih count (current round count + completed rounds) persist across app restarts? → A: Yes — the live tasbih session is restored when the app restarts so the user can resume from where they left off.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Adhkar Categories (Priority: P1)

A user opens the Adhkar section from the main navigation and sees all available categories of Islamic remembrances displayed as a grid. Each category shows its name and the number of adhkar it contains. The user selects a category to begin reading.

**Why this priority**: Discovering and entering a category is the mandatory first step for all other interactions. Without a working category browser, no dhikr can be read or counted.

**Independent Test**: Can be fully tested by navigating to the Adhkar tab, verifying that all expected categories appear with their correct names and counts, and tapping one to confirm it opens the first dhikr in that category.

**Acceptance Scenarios**:

1. **Given** the user opens the Adhkar tab, **When** the screen loads, **Then** a 2-column grid of category cards is displayed, each showing a category name, an icon, and the total number of adhkar in that category.
2. **Given** the category grid is visible, **When** the user views the screen, **Then** the Quranic inscription "أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ" is displayed as a subtitle beneath the screen title.
3. **Given** the category grid is loaded, **When** the user counts the categories, **Then** at least 8 categories are present: أذكار الصباح, أذكار المساء, أذكار الصلاة, أذكار النوم, أذكار الاستيقاظ, أدعية متنوعة, ذكر الأكل, الاستغفار.
4. **Given** the category grid is visible, **When** the user taps any category card, **Then** they are taken to the dhikr detail screen showing the first dhikr in that category.
5. **Given** the screen loads with no internet connection, **When** the category grid appears, **Then** all categories are still displayed correctly (data is fully offline).
6. **Given** the user has completed all adhkar in a category today, **When** they view the category grid, **Then** that category card displays a visual completion badge/checkmark.
7. **Given** a new calendar day begins, **When** the user views the category grid, **Then** all completion badges are cleared and no category shows as completed.

---

### User Story 2 - Read & Count a Dhikr (Priority: P1)

A user is on the dhikr detail screen. They read the Arabic dhikr text, its source, and its virtue. They tap the counter to record each repetition. When the required number of repetitions is reached, the counter visually indicates completion.

**Why this priority**: Counting repetitions while reading is the core spiritual interaction of the Adhkar feature. Every other screen exists to deliver the user to this moment.

**Independent Test**: Can be fully tested by opening any category, tapping the counter the required number of times, and verifying the counter dims/marks complete without needing navigation or persistence features.

**Acceptance Scenarios**:

1. **Given** the user is on a dhikr detail screen, **When** the screen loads, **Then** the dhikr text is displayed in large, legible Arabic script in a card-style layout.
2. **Given** a dhikr has a source (e.g., "رواه مسلم"), **When** the screen loads, **Then** the source is displayed below the dhikr text.
3. **Given** a dhikr has a virtue text, **When** the screen loads, **Then** the virtue is shown beneath the source.
4. **Given** the counter shows the required repetition count, **When** the user taps the counter once, **Then** the count decrements by one.
5. **Given** the counter is at 1, **When** the user taps it, **Then** the count reaches 0, the counter visually changes to a dimmed/completed state, and the main action button changes from "تقبل الله" to "أتممت الذكر".
6. **Given** the counter has already reached 0, **When** the user taps the counter, **Then** no further decrement occurs (the counter is locked at completion).

---

### User Story 3 - Navigate Through a Category Sequence (Priority: P2)

A user steps through all adhkar in a category one by one using "الذكر التالي" (next) and "الذكر السابق" (previous) buttons. A progress indicator shows how far through the category they are.

**Why this priority**: Completing all adhkar in sequence is the full intended experience. Navigation is essential but only meaningful after the core read-and-count interaction is in place.

**Independent Test**: Can be tested independently by opening أذكار الصباح, verifying the progress shows "1 / N", tapping next to advance through each dhikr, and confirming the progress indicator updates correctly.

**Acceptance Scenarios**:

1. **Given** the user is on the dhikr detail screen, **When** they view the app bar, **Then** a progress indicator shows the current dhikr index and the total count in the category (e.g., "٢ / ١٢").
2. **Given** the user is not on the last dhikr in the category, **When** they tap "الذكر التالي", **Then** the screen transitions to the next dhikr and the progress counter increments.
3. **Given** the user is on the last dhikr in the category, **When** they view the navigation area, **Then** the "الذكر التالي" button is disabled or hidden.
4. **Given** the user is not on the first dhikr, **When** they tap "الذكر السابق", **Then** the screen transitions to the previous dhikr and the progress counter decrements.
5. **Given** the user is on the first dhikr, **When** they view the navigation area, **Then** the "الذكر السابق" button is disabled or hidden.
6. **Given** the user navigates to a dhikr, **When** the screen appears, **Then** the counter shows that dhikr's remaining count for the day — full count if never started, or the saved remaining count if partially completed.
7. **Given** page dots are shown below the counter, **When** the user is on dhikr N, **Then** the Nth dot is visually active/filled.

---

### User Story 4 - Use the Digital Tasbih Counter (Priority: P2)

A user accesses the digital tasbih from a banner on the Adhkar screen. They select a dhikr type (e.g., "سبحان الله"), tap the large button to count repetitions, and the counter tracks their progress toward a target (e.g., 33). Completed rounds are recorded. The user can enable haptic feedback.

**Why this priority**: The digital tasbih is a standalone spiritual tool with wide everyday use. It is placed in the Adhkar section as a natural companion.

**Independent Test**: Can be tested by tapping "ابدأ الآن" from the Adhkar screen banner, selecting "سبحان الله", tapping the counter 33 times, and verifying one completed round is recorded and the counter resets.

**Acceptance Scenarios**:

1. **Given** the user is on the Adhkar screen, **When** they view the bottom of the screen, **Then** a "المسبحة الإلكترونية" banner with an "ابدأ الآن" button is visible.
2. **Given** the user taps "ابدأ الآن", **When** the tasbih screen opens, **Then** three dhikr selector tabs are shown: "سبحان الله" (default), "الحمد لله", "الله أكبر".
3. **Given** a dhikr is selected, **When** the user views the counter area, **Then** the current count and the target (e.g., "٢٣ من ٣٣") are prominently displayed.
4. **Given** the tasbih screen is open, **When** the user taps "اضغط للتسبيح", **Then** the counter increments by one.
5. **Given** the counter reaches the target (e.g., 33), **When** that tap occurs, **Then** one completed round is recorded, a round completion indicator increments, and the counter resets to 0.
6. **Given** a completed round is recorded, **When** the round indicator is visible, **Then** it displays the number of completed rounds (e.g., "دورتان مكتملتان").
7. **Given** the vibration toggle is on, **When** the user taps the counter, **Then** the device vibrates briefly on each tap and with a distinct pattern on round completion.
8. **Given** the user taps "إعادة" (reset), **When** the action completes, **Then** the current count and completed rounds both reset to zero.
9. **Given** the user taps "تحديد العدد", **When** a picker/dialog appears, **Then** the user can set a custom repetition target for the current dhikr.
10. **Given** the user taps "سجّل", **When** the history screen opens, **Then** a list of past tasbih sessions is shown, each entry displaying the dhikr type, total count achieved, and the date of the session.
11. **Given** the user has no prior tasbih sessions, **When** they open the history screen, **Then** an empty state message is displayed.
12. **Given** the user has an in-progress tasbih session (e.g., 20 taps into the current round, 2 completed rounds) and closes the app, **When** they reopen the app and navigate to the tasbih screen, **Then** the session resumes at the same count and round state.

---

### User Story 5 - Track Daily Adhkar Progress (Priority: P3)

The app tracks which adhkar the user has completed today. The daily record resets automatically at midnight so the user starts fresh each day.

**Why this priority**: Daily reset is an important correctness guarantee for a practice that is observed daily in Islamic tradition, but the core read-and-count experience works without it.

**Independent Test**: Can be tested by completing all adhkar in a category, verifying the completed state is shown, then simulating a date change (or waiting until midnight) and reopening the app to confirm counters have reset.

**Acceptance Scenarios**:

1. **Given** the user has tapped a dhikr counter to completion today, **When** they close and reopen the app on the same calendar day, **Then** the counter still shows the completed state for that dhikr.
2. **Given** a new calendar day begins (past midnight), **When** the user opens the Adhkar screen, **Then** all dhikr counters are reset to their full repetition counts.
3. **Given** the user has partially completed a dhikr's counter today, **When** they navigate away and return the same day, **Then** the counter reflects the number of remaining repetitions (progress is preserved within the day).

---

### Edge Cases

- What happens when a dhikr has no source or virtue text? The source and virtue fields are omitted without leaving blank space.
- What happens when the category contains only one dhikr? Both "الذكر التالي" and "الذكر السابق" are hidden or disabled; no page dots are shown.
- What happens when the user has completed all adhkar in a category? No automatic navigation occurs; the user must manually go back to the category list.
- What happens when the device does not support haptic feedback? The vibration option is hidden or silently ignored; the counter still works normally.
- What happens if the app crashes mid-count? Counter progress for the current day is restored from local storage when the app restarts.
- What happens when the tasbih target is set to a very large number (e.g., 1000)? The counter still functions correctly and rounds are tracked accurately.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display all adhkar categories in a 2-column grid on the Adhkar screen, each showing a category name, icon, and total dhikr count.
- **FR-002**: The system MUST display the Quranic inscription "أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ" as a subtitle on the Adhkar screen.
- **FR-003**: The system MUST include at least 8 categories: أذكار الصباح, أذكار المساء, أذكار الصلاة, أذكار النوم, أذكار الاستيقاظ, أدعية متنوعة, ذكر الأكل, الاستغفار.
- **FR-004**: Tapping a category MUST navigate to the dhikr detail screen showing the first dhikr in that category.
- **FR-005**: The dhikr detail screen MUST display the dhikr Arabic text, source attribution (when available), and virtue text (when available).
- **FR-006**: The dhikr detail screen MUST show a circular counter displaying the required repetition count for the current dhikr.
- **FR-007**: Users MUST be able to tap the counter to decrement it by one repetition per tap.
- **FR-008**: When the counter reaches zero, the system MUST visually change the counter to a dimmed/completed state and the action button label MUST change from "تقبل الله" to "أتممت الذكر".
- **FR-009**: Once a counter reaches zero, additional taps MUST NOT decrement it further.
- **FR-010**: The dhikr detail screen MUST show a progress indicator in the app bar displaying the current dhikr index and total count (e.g., "٢ / ١٢").
- **FR-011**: Users MUST be able to navigate to the next dhikr using "الذكر التالي" and to the previous dhikr using "الذكر السابق".
- **FR-012**: Navigation to next/previous MUST be disabled at the first and last dhikr respectively.
- **FR-013**: Each dhikr's counter MUST be independent; navigating to any dhikr MUST show that dhikr's current remaining count for the day — its full repetition count if untouched, or its saved remaining count if partially completed.
- **FR-014**: The Adhkar screen MUST include a banner linking to the digital tasbih (المسبحة الإلكترونية) with a clearly labeled action button.
- **FR-015**: The tasbih screen MUST offer at least 3 dhikr selector options: سبحان الله, الحمد لله, الله أكبر.
- **FR-016**: The tasbih counter MUST increment by one on each tap of the main button.
- **FR-017**: When the tasbih count reaches the target, the system MUST record one completed round, display a rounds-completed indicator, and reset the counter to zero.
- **FR-018**: The tasbih screen MUST provide a reset action that clears both the current count and completed rounds.
- **FR-019**: The tasbih screen MUST allow the user to toggle haptic (vibration) feedback on/off.
- **FR-019a**: The tasbih screen MUST allow the user to toggle sound (صوت) feedback on/off; when enabled, a short sound plays on each tap and a distinct sound plays on round completion.
- **FR-020**: The tasbih screen MUST allow the user to set a custom repetition target.
- **FR-024**: Tapping "سجّل" MUST open a session history screen listing all past tasbih sessions, each showing the dhikr type, total count achieved, and the date.
- **FR-025**: The session history screen MUST display an empty-state message when no sessions have been recorded yet.
- **FR-026**: The system MUST save a tasbih session record to history when the user taps "إعادة" (reset) after completing at least one round.
- **FR-029**: The system MUST persist the in-progress tasbih session state (current round count, completed rounds, selected dhikr, target) so it is restored when the app restarts.
- **FR-027**: The system MUST display a visual completion badge on a category card when all dhikr counters in that category have reached zero for the current calendar day.
- **FR-028**: The system MUST clear all category completion badges at the start of each new calendar day (aligned with FR-022 daily counter reset).
- **FR-021**: The system MUST store daily dhikr counter progress locally so it survives app restarts within the same calendar day.
- **FR-022**: The system MUST automatically reset all dhikr counters at the start of each new calendar day.
- **FR-023**: The entire feature MUST function with no internet connection at any time.

### Key Entities

- **Adhkar Category**: A named grouping of related remembrances (e.g., morning adhkar), with a unique identifier, Arabic display name, icon reference, and total dhikr count.
- **Dhikr**: A single Islamic remembrance within a category, containing its Arabic text, required repetition count, optional source attribution (e.g., hadith reference), and optional virtue/benefit text.
- **Daily Counter State**: A per-dhikr record of the user's remaining repetitions for the current calendar day; resets to the dhikr's full repetition count at midnight.
- **Tasbih Session**: A live counting session tracking the selected dhikr type, current count within the round, the round target, and the number of completed rounds. The session state is persisted locally so it survives app restarts.
- **Tasbih History Entry**: A persisted record of a completed tasbih session, containing the dhikr type, total count achieved across all rounds, and the date of the session.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can open the Adhkar tab and begin reading the first dhikr of any category within 2 taps from the main navigation.
- **SC-002**: The category grid loads and displays all categories within 1 second of opening the Adhkar tab (data is fully offline; no network wait).
- **SC-003**: The tasbih counter responds to each tap within 100 milliseconds with no perceptible lag.
- **SC-004**: All dhikr counters accurately reflect the correct remaining count after partial completion when the user returns to the app on the same calendar day.
- **SC-005**: Daily counter progress for all dhikr is fully reset by the time the user opens the app after midnight, with no manual action required.
- **SC-006**: The feature operates correctly with no internet connectivity from first launch through all interactions (100% offline).
- **SC-007**: Users can complete all adhkar in أذكار الصباح from start to finish (opening category → counting each dhikr → navigating through all entries) without any interaction errors or crashes.
- **SC-008**: Completed tasbih rounds are counted and displayed accurately after 10 consecutive round completions with no missed counts.

---

## Assumptions

- All adhkar text, sources, and virtue content are bundled within the app as a local JSON asset; no network request is ever made to fetch adhkar data.
- The bundled adhkar dataset includes all 8 categories listed in FR-003 with accurate Arabic text and hadith attribution.
- Daily progress reset is based on the device's local calendar date (midnight in the user's timezone), not a server time.
- The tasbih screen is accessible both from the Adhkar screen banner and from the bottom navigation bar (if a dedicated Tasbih tab exists in the app navigation).
- The tasbih's default targets are: سبحان الله → 33, الحمد لله → 33, الله أكبر → 33; لا إله إلا الله → 100; custom targets override these defaults.
- Sound feedback for the tasbih (صوت option) is in scope for this phase; a short tap sound and a distinct round-completion sound must be provided (see FR-019a).
- The dhikr text font is a dedicated Arabic typeface (e.g., Scheherazade New) already bundled in the app's assets from prior phases.
- Sharing a dhikr (text or image) is out of scope for this phase.
- Search within adhkar is out of scope for this phase.
- The app is RTL (right-to-left) by default; no additional RTL configuration is required beyond what was established in prior phases.
