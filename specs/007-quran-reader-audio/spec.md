# Feature Specification: Quran Reading & Audio (شاشة القراءة والتلاوة)

**Feature Branch**: `007-quran-reader-audio`

**Created**: 2026-06-27

**Status**: Draft

**Input**: Phase 3 of PLAN2.md — Quran Reading & Audio (depends on Phase 2: Quran Surah List)

---

## Clarifications

### Session 2026-06-27

- Q: When audio is playing and the user navigates away from the reader screen, what should happen? → A: Stop audio immediately when the user leaves the reader screen; audio is scoped to the screen lifecycle (no background audio service in this phase).
- Q: What repeat options should the audio player expose? → A: Single ayah repeat only — a repeat button that loops the currently highlighted ayah; full-surah loop is deferred to a future phase.
- Q: When a user taps a bookmark in the Bookmarks tab, what should happen? → A: Open the reader screen for that surah and auto-scroll to the bookmarked ayah.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Read Full Surah Text (Priority: P1)

A user selects a surah from the surah list and the app opens the Quran reader screen displaying the complete surah text in Uthmanic Arabic script. The user can scroll through all ayahs comfortably with an appropriate font size.

**Why this priority**: Reading the Quran text is the core value of this feature. All other capabilities (audio, bookmarks) extend this foundation. Without readable text, no other story delivers value.

**Independent Test**: Can be fully tested by navigating from the surah list to a reader screen and verifying all ayahs of Al-Fatiha are displayed in correct Uthmanic Arabic text.

**Acceptance Scenarios**:

1. **Given** the user is on the surah list screen, **When** they tap on any surah, **Then** the reader screen opens showing all ayahs of that surah in Uthmanic Arabic script with correct numbering.
2. **Given** the reader screen is open, **When** the user scrolls, **Then** all ayahs are visible sequentially with clear ayah separators and number markers.
3. **Given** the reader screen is open, **When** the surah has a Basmala, **Then** "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ" appears at the top (except for Surah At-Tawbah, surah 9).
4. **Given** the screen loads for the first time with no cache, **When** the data is being fetched, **Then** a loading indicator is shown and the screen does not appear blank.
5. **Given** the device has no internet connection, **When** the user opens a previously read surah, **Then** the cached text is displayed with no error.
6. **Given** the device has no internet connection and no cache exists, **When** the user opens a surah, **Then** a clear offline error message is shown with a retry option.

---

### User Story 2 - Play Audio Recitation (Priority: P2)

A user plays an audio recitation of the full surah or individual ayahs. The currently recited ayah is highlighted in gold while audio plays. The user can pause, resume, and stop playback at any time.

**Why this priority**: Audio recitation is the most-used companion to reading in Islamic practice (listening while following along). It differentiates the app from a plain text reader.

**Independent Test**: Can be tested by opening Al-Fatiha, pressing the play button, and verifying audio plays, ayah 1 highlights, then ayah 2 highlights as audio advances — without any bookmark or font-size functionality needed.

**Acceptance Scenarios**:

1. **Given** the reader screen is open, **When** the user taps the play button, **Then** audio recitation begins from the first ayah (or from the currently highlighted ayah if one is selected).
2. **Given** audio is playing, **When** the reciter moves to the next ayah, **Then** that ayah is visually highlighted in gold and the previous highlight is cleared.
3. **Given** audio is playing, **When** the user taps the pause button, **Then** audio pauses and the button changes to a play icon; the highlighted ayah remains highlighted.
4. **Given** audio is paused, **When** the user taps the play button again, **Then** recitation resumes from where it was paused.
5. **Given** audio is playing, **When** the user taps any individual ayah, **Then** playback jumps to that ayah and the highlight moves there.
6. **Given** audio is playing and reaches the last ayah, **When** that ayah finishes, **Then** playback stops automatically and all highlights are cleared.
7. **Given** the device is offline, **When** the user tries to play audio, **Then** a clear message explains audio requires an internet connection.
8. **Given** the user activates the repeat toggle, **When** the current ayah finishes playing, **Then** that same ayah restarts automatically instead of advancing to the next one.
9. **Given** the repeat toggle is active and the user taps a different ayah, **When** that new ayah finishes, **Then** the new ayah loops (repeat follows the active ayah, not the original one).

---

### User Story 3 - Choose Reciter (Priority: P2)

A user can select their preferred reciter from a list of available reciters. The preference is saved so it persists across sessions.

**Why this priority**: Reciter preference is a core personalization feature for Quran listeners and is expected by users familiar with Islamic apps.

**Independent Test**: Can be tested by changing the reciter in settings/picker and verifying that subsequent audio playback uses audio files from the newly selected reciter.

**Acceptance Scenarios**:

1. **Given** the reader screen is open, **When** the user taps the reciter selector, **Then** a list of available reciters is shown (minimum: Mishary Alafasy, Abdul Samad, Abdullah Basfar, Ali Hudhaify).
2. **Given** the user selects a different reciter, **When** they close the picker and play audio, **Then** the recitation is from the newly selected reciter.
3. **Given** the user has previously chosen a reciter, **When** they reopen the app and navigate to any surah, **Then** the previously selected reciter is pre-selected without requiring re-selection.
4. **Given** no reciter has been selected before, **When** the user opens the reader for the first time, **Then** Mishary Alafasy is the default reciter.

---

### User Story 4 - Bookmark Individual Ayahs (Priority: P3)

A user can bookmark any ayah and later access all bookmarked ayahs from the Quran screen. Bookmarks are stored locally and persist across sessions.

**Why this priority**: Bookmarking is a common reading companion feature but is not needed for the core reading or listening experience. It adds value for users who study or revisit specific verses.

**Independent Test**: Can be tested by long-pressing an ayah to bookmark it, closing the app, reopening, and verifying the bookmark still appears.

**Acceptance Scenarios**:

1. **Given** the reader screen is open, **When** the user long-presses or taps the bookmark icon on an ayah, **Then** that ayah is bookmarked and the icon changes to a filled/active state.
2. **Given** an ayah is already bookmarked, **When** the user taps the bookmark icon again, **Then** the bookmark is removed and the icon returns to its inactive state.
3. **Given** the user has bookmarked one or more ayahs, **When** they reopen the app, **Then** all bookmarks are still present and visually indicated on the reader screen.
4. **Given** the user navigates to the Bookmarks tab on the Quran screen, **When** the tab loads, **Then** all bookmarked ayahs are listed with their surah name, ayah number, and text preview.
5. **Given** the user taps a bookmark entry in the Bookmarks tab, **When** the reader opens, **Then** the app navigates to that surah's reader screen and auto-scrolls to the bookmarked ayah, visually highlighting it.

---

### User Story 5 - Adjustable Font Size (Priority: P3)

A user can increase or decrease the Arabic text font size in the reader to their comfort level. The preference is saved and applied to all surahs.

**Why this priority**: Accessibility and reading comfort are important but are an enhancement over the core experience. This supports a wider range of users including those with visual difficulties.

**Independent Test**: Can be tested independently by adjusting the font size slider and verifying text in the reader grows/shrinks accordingly, then closing and reopening the app to verify the size persists.

**Acceptance Scenarios**:

1. **Given** the reader screen is open, **When** the user opens the display settings (font size control), **Then** they see a slider or size selector with at least 3 size options (small, medium, large).
2. **Given** the user changes the font size, **When** they apply the change, **Then** all ayah text in the current surah immediately updates to the new size.
3. **Given** the user has set a custom font size, **When** they navigate to a different surah, **Then** the same font size is applied.
4. **Given** the user closes and reopens the app, **When** they navigate to the reader, **Then** their saved font size preference is applied.

---

### User Story 6 - Save & Restore Last Read Position (Priority: P3)

When a user returns to a surah they previously read, the reader automatically scrolls to or highlights where they left off.

**Why this priority**: Reading continuity reduces friction for users who read the Quran across multiple sessions, but the core functionality works without it.

**Independent Test**: Can be tested by reading to ayah 10 of Al-Baqara, closing the app, reopening and navigating back to Al-Baqara, and verifying the screen shows or highlights ayah 10.

**Acceptance Scenarios**:

1. **Given** the user has scrolled to ayah N of a surah and closes the app, **When** they navigate back to that surah, **Then** the screen scrolls to ayah N automatically.
2. **Given** the user opens a surah for the first time, **When** the reader loads, **Then** it starts from the beginning (ayah 1).
3. **Given** the user reads multiple surahs, **When** they return to any of them, **Then** each surah independently restores its own last position.

---

### Edge Cases

- What happens when an audio file fails to load for a specific ayah mid-playback? The player should skip to the next ayah and show a brief error indicator without stopping the full session.
- What happens when the surah is Al-Fatiha (1) and the user tries to navigate to the previous surah? Navigation wraps or disables the previous button.
- What happens when the surah is An-Nas (114) and audio finishes? Playback stops and does not loop unless a repeat mode is active.
- How does the system handle Surah At-Tawbah (9) which has no Basmala? The Basmala is omitted and the first ayah is displayed directly.
- What happens if the device receives a phone call during playback? Audio pauses automatically (handled by OS audio focus); the user can resume after the call.
- What happens when the user has very slow internet and audio buffers mid-ayah? A buffering indicator is shown; the highlight stays on the current ayah until it is finished.
- What happens when the user navigates back to the surah list or switches tabs while audio is playing? Audio stops immediately; no background playback occurs (audio is scoped to the reader screen).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display all ayahs of a selected surah in Uthmanic Arabic script in correct order with ayah number markers.
- **FR-002**: The system MUST display the Basmala header for all surahs except Surah At-Tawbah (surah 9) and Surah Al-Fatiha (where it is the first ayah, not a header).
- **FR-003**: The system MUST show a loading state while surah text is being fetched and an error state with a retry option if the fetch fails.
- **FR-004**: The system MUST cache fetched surah text locally so it is available offline after first load.
- **FR-005**: Users MUST be able to play the full audio recitation of the displayed surah with a single tap on a play button.
- **FR-006**: Users MUST be able to tap any individual ayah to jump audio playback to that ayah.
- **FR-007**: The system MUST visually highlight the ayah currently being recited while audio is playing.
- **FR-008**: Users MUST be able to pause and resume audio playback.
- **FR-009**: The system MUST automatically advance the highlight to the next ayah as audio progresses through the surah.
- **FR-010**: The system MUST stop playback when the last ayah finishes and clear all highlights.
- **FR-011**: Users MUST be able to select a reciter from a list of at least 4 available reciters.
- **FR-012**: The system MUST save the user's reciter preference and apply it by default on subsequent sessions.
- **FR-013**: Users MUST be able to bookmark any ayah and the bookmark MUST persist across app restarts.
- **FR-014**: Users MUST be able to remove a bookmark from any previously bookmarked ayah.
- **FR-015**: The system MUST show a visual indicator on bookmarked ayahs within the reader.
- **FR-015a**: When the user taps a bookmark entry in the Bookmarks tab, the system MUST open the reader for the corresponding surah and auto-scroll to that ayah, highlighting it briefly to orient the user.
- **FR-016**: Users MUST be able to adjust the Arabic text font size from within the reader, with the preference persisting.
- **FR-017**: The system MUST save and restore each surah's last read scroll position independently.
- **FR-018**: The system MUST show a clear, user-friendly message when audio is unavailable due to no internet connection.
- **FR-019**: The system MUST stop audio playback when the user navigates away from the reader screen; audio is scoped to the reader screen lifecycle and does not continue in the background.
- **FR-020**: The audio player MUST include a repeat toggle that, when active, loops the currently highlighted (selected) ayah continuously until the user turns off repeat or taps a different ayah.

### Key Entities

- **Ayah**: A single verse of the Quran, identified by surah number and position within the surah, carrying its Uthmanic text, global number, juz, and page metadata.
- **Surah**: A chapter of the Quran (1–114), composed of ordered ayahs, with a revelation type (Meccan/Medinan) and total ayah count.
- **Reciter**: An audio edition identified by a code (e.g., `ar.alafasy`), with an Arabic display name and an English name, used to resolve audio file URLs for each ayah.
- **Bookmark**: A saved reference to a specific ayah (surah number + ayah number within surah), stored locally with a timestamp.
- **ReadingPosition**: A per-surah record of the last ayah index the user reached, stored locally to support session continuity.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can open a surah and see all its ayahs fully displayed within 2 seconds on a standard mobile connection.
- **SC-002**: Audio playback begins within 1.5 seconds of tapping the play button on a standard mobile connection.
- **SC-003**: The currently reciting ayah is highlighted within 200 milliseconds of audio reaching that ayah (no perceptible lag between audio and visual highlight).
- **SC-004**: Cached surahs (previously loaded) open in under 300 milliseconds with no network request.
- **SC-005**: 100% of bookmarked ayahs are preserved after app restart with no data loss.
- **SC-006**: Font size changes are reflected immediately (under 100ms) without requiring a screen reload.
- **SC-007**: The reciter selection and font size preference are restored correctly on every app launch with no configuration loss.
- **SC-008**: Users can complete a read-and-listen session of Al-Fatiha (play all 7 ayahs from start to finish) without any interaction errors or crashes.

---

## Assumptions

- The AlQuran Cloud API (`https://api.alquran.cloud/v1`) and its CDN for audio (`https://cdn.islamic.network/quran/audio/`) are stable and available as primary data sources; no alternative API is in scope.
- Audio files are streamed from the CDN on demand; full offline audio download/caching is out of scope for this phase.
- Translation of ayah text is out of scope for Phase 3; only the original Uthmanic Arabic text is displayed.
- Search within the reader (jump to a specific ayah by keyword) is out of scope for Phase 3; global Quran search may be addressed in a future phase.
- Surah-to-surah navigation (previous/next surah buttons) within the reader is included as a convenience UX improvement over the base plan.
- The user has completed Phase 2 (Quran Surah List) and the app already fetches and caches the surah metadata list; Phase 3 builds on top of this cache.
- The audio player includes a single-ayah repeat toggle (loops the active ayah); full-surah loop is out of scope for this phase.
- Sharing individual ayahs (text or image) is a P4 improvement deferred to a future phase to keep Phase 3 focused.
- The app supports right-to-left (RTL) text layout natively; no additional RTL configuration is required beyond what Phase 1–2 established.
- The reading position is saved per-surah on the device; cloud sync of reading position is out of scope.
