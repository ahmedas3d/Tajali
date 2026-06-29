# Feature Specification: Notifications & Settings (إشعارات الأذان والإعدادات)

**Feature Branch**: `009-notifications-settings`

**Created**: 2026-06-29

**Status**: Draft

**Input**: User description: "Phase 7 — Notifications & Settings (إشعارات الأذان والإعدادات)"

---

## Overview

A redesigned **Settings screen** that unifies all user preferences in one place — prayer calculation, adhan notifications (sound source, mode), Quran reciter, language, and app links — alongside the background notification scheduling engine that fires local adhan alerts at each prayer time.

The reference design (screenshot provided) shows a welcome header card, grouped settings rows with trailing value chips, and individual per-prayer notification toggles under the "تنبيهات الأذان" sub-section.

---

## Clarifications

### Session 2026-06-29

- Q: Per-prayer notification control — global toggle vs per-prayer toggles? → A: Per-prayer on/off toggles — each prayer (Fajr, Dhuhr, Asr, Maghrib, Isha) has its own independent on/off switch.
- Q: Midnight rescheduling reliability mechanism — background task vs app-open trigger? → A: Schedule 2 days ahead on every app open; no background execution needed. Covers tomorrow even if user opens app before midnight.
- Q: Settings option-picker navigation style — bottom sheet vs push screen vs inline? → A: Modal bottom sheet for all option pickers (calculation method, sound source, fiqh school, reciter).
- Q: Fiqh school scope — fully implement or defer? → A: Implement fully in this phase: picker visible, choice persisted, Asr time recalculated accordingly.
- Q: Notification permission denied — where/how to surface the recovery prompt? → A: Inline warning banner at the top of the "تنبيهات الأذان" sub-section, visible only when permission is denied, with an "افتح الإعدادات" button that opens system settings.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Enable Adhan Notifications (Priority: P1)

A user wants to be notified when each prayer time arrives. They open Settings, confirm "تنبيهات الأذان" is enabled, and trust the app will alert them even when the phone screen is off.

**Why this priority**: Core value proposition of the app. Without it, users miss prayers.

**Independent Test**: Enable notifications → wait for a prayer time (or use the test button) → notification appears with sound. Delivers full value on its own.

**Acceptance Scenarios**:

1. **Given** the app is installed, **When** the user opens Settings and turns ON the Fajr toggle, **Then** a local notification fires at Fajr time with the selected adhan sound.
2. **Given** a prayer's individual toggle is OFF, **When** that prayer time arrives, **Then** no notification is sent for that prayer (others with their toggle ON still fire).
3. **Given** the app is in the background or killed, **When** a prayer time arrives for an enabled prayer, **Then** the notification still appears on the lock screen with sound.
4. **Given** the user opens the app at any time, **When** the app initialises, **Then** notifications for today and tomorrow are scheduled for every prayer whose toggle is ON — no manual action required.

---

### User Story 2 — Choose Adhan Sound (Priority: P1)

A user wants to pick their preferred adhan voice. They tap "صوت الأذان" in Settings, see two options (Makkah / Egyptian Radio), select one, and from that point all notifications and in-app audio use that voice.

**Why this priority**: Tied with P1 because sound preference is set at the same moment as enabling notifications.

**Independent Test**: Select Egyptian sound → trigger adhan test → confirm Egyptian voice plays.

**Acceptance Scenarios**:

1. **Given** the user taps "صوت الأذان", **When** they select "المسجد الحرام", **Then** all future notifications and foreground adhan play the Makkah sound.
2. **Given** the user taps "صوت الأذان", **When** they select "إذاعة القرآن الكريم المصرية", **Then** all future notifications and foreground adhan play the Egyptian Radio sound.
3. **Given** the user has selected a sound, **When** they close and reopen the app, **Then** the selected sound is preserved.
4. **Given** Fajr notification mode is active, **When** Fajr time arrives, **Then** the Fajr-specific recording (including "الصلاة خير من النوم") plays — for whichever source was selected.

---

### User Story 3 — Redesigned Settings Screen (Priority: P2)

A user opens the Settings tab and sees a well-structured, visually branded page: a welcome header card at the top, then clearly grouped sections (الصلاة والمواقيت, القرآن الكريم, عام) with trailing value chips on each row.

**Why this priority**: UX polish that makes settings discoverable and consistent with the app's Islamic design language.

**Independent Test**: Open Settings → confirm welcome card, section headers, and all setting rows render with correct current values.

**Acceptance Scenarios**:

1. **Given** the user navigates to Settings, **When** the screen loads, **Then** a welcome header card appears at the top with a greeting and the moon/crescent icon.
2. **Given** the settings screen is open, **When** any preference value is already saved, **Then** its row shows the current value as a trailing chip (e.g., "المسجد الحرام ›").
3. **Given** the user changes a setting, **When** they return to the settings list, **Then** the trailing chip reflects the new value immediately.
4. **Given** the General section, **When** the user taps "تقييم التطبيق", **Then** the device's app store listing opens.
5. **Given** the General section, **When** the user taps "مشاركة التطبيق", **Then** the system share sheet opens with an app download link.

---

### User Story 4 — Disable Individual Prayer Notifications (Priority: P2)

A user who attends Dhuhr at work and doesn't need a reminder wants to turn off only Dhuhr notifications while keeping all other prayers enabled.

**Why this priority**: Respects diverse daily schedules without forcing the user to disable all notifications as a blunt instrument.

**Independent Test**: Turn OFF Dhuhr toggle only → confirm Dhuhr passes silently → confirm Asr notification still fires.

**Acceptance Scenarios**:

1. **Given** the user turns OFF the Dhuhr toggle, **When** Dhuhr time arrives, **Then** no notification fires for Dhuhr.
2. **Given** only Dhuhr is OFF, **When** Asr time arrives, **Then** the Asr notification fires normally with adhan sound.
3. **Given** all five prayer toggles are turned OFF, **When** any prayer time arrives, **Then** no notifications fire at all.
4. **Given** the user turns a prayer back ON, **When** that prayer time next arrives, **Then** the notification fires with the currently selected adhan sound — no app restart needed.

---

### User Story 5 — Preferred Quran Reciter (Priority: P3)

A user who primarily uses the Quran reader wants to set their preferred reciter once in Settings so it's pre-selected every time they open a surah.

**Why this priority**: Convenience setting; Quran feature already works without it.

**Independent Test**: Set reciter to Al-Husary in Settings → open any surah → reciter is pre-selected.

**Acceptance Scenarios**:

1. **Given** the user selects "الحصري" in القارئ المفضل, **When** they open any surah in the Quran reader, **Then** Al-Husary is pre-selected as the active reciter.
2. **Given** the user changes reciter in Settings, **When** they restart the app, **Then** the saved reciter persists.

---

### User Story 6 — Adhan Test Button (Priority: P2)

A developer or curious user wants to immediately verify the adhan sound works. They use the test button to hear the sound right now and receive a test notification in 10 seconds.

**Why this priority**: Debug/confidence tool that prevents silent failures going unnoticed until a real prayer time.

**Independent Test**: Tap test button → hear adhan immediately → receive notification after 10s.

**Acceptance Scenarios**:

1. **Given** the user taps "اختبر أذان الفجر", **When** the button is pressed, **Then** the Fajr adhan plays in-app immediately AND a test notification is scheduled for 10 seconds later.
2. **Given** the user taps "اختبر أذان الصلاة", **When** the button is pressed, **Then** the regular adhan plays using the currently selected sound source.
3. **Given** the app is in the foreground when the test notification fires, **When** 10 seconds elapse, **Then** the notification banner appears with sound (foreground notification presentation enabled).

---

### Edge Cases

- What happens when the user denies notification permission on iOS/Android? → An inline amber warning banner appears at the top of the "تنبيهات الأذان" sub-section (not a dialog or toast). The banner contains the message "الإشعارات معطّلة" and an "افتح الإعدادات" button that deep-links to the device's app notification settings. The prayer toggles remain visible below the banner but tapping them has no effect until permission is granted. The banner disappears automatically when the user grants permission and returns to the app.
- What happens if prayer times haven't loaded yet when the user enables notifications? → Notifications are scheduled as soon as prayer times become available; a loading indicator is shown.
- What happens if two prayers are very close together (< 1 minute apart)? → Each prayer fires its own notification; no deduplication.
- What happens when the user is in a different timezone than their saved city? → Notifications always use the prayer times calculated for the saved city in its local timezone.
- What happens when the adhan sound file is missing or corrupted? → App silently falls back to system default notification sound; no crash.
- What if the user has Do Not Disturb enabled on the device? → System DND overrides app notifications; app cannot bypass this and does not attempt to.

---

## Requirements *(mandatory)*

### Functional Requirements

**Notification Scheduling**

- **FR-001**: The system MUST schedule a local notification for each prayer (Fajr, Dhuhr, Asr, Maghrib, Isha) whose individual toggle is ON, whenever prayer times are available.
- **FR-002**: The system MUST include Sunrise and Qiyam al-Layl as optional notification slots (both OFF by default, no UI toggle in this phase).
- **FR-003**: The system MUST reschedule notifications when: the user changes their city, calculation method, per-prayer toggle, or sound source — applying changes only to the affected prayers.
- **FR-004**: On every app open, the system MUST schedule notifications for today AND tomorrow for every prayer whose toggle is ON — ensuring coverage even if the user does not open the app at midnight.
- **FR-005**: Each prayer notification MUST display the prayer name in Arabic as the title (e.g., "حان وقت الفجر") with "تجلّي" as the subtitle.
- **FR-006**: Fajr notifications MUST use the Fajr-specific adhan recording (containing "الصلاة خير من النوم") for the selected sound source.
- **FR-007**: The system MUST cancel the scheduled notification for a specific prayer immediately when its toggle is turned OFF.

**Sound & Mode**

- **FR-008**: Users MUST be able to independently toggle each of the five daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) ON or OFF for adhan notifications.
- **FR-009**: Users MUST be able to choose between two adhan sound sources: Makkah (المسجد الحرام) and Egyptian Radio (إذاعة القرآن الكريم المصرية). The selected source applies to all enabled prayers.
- **FR-010**: The selected sound source MUST also be used for in-app foreground adhan playback when a prayer time arrives while the app is open.
- **FR-011**: Both sound sources MUST have dedicated Fajr and regular recordings.
- **FR-012**: Per-prayer toggle states and sound source selection MUST be persisted across app restarts.

**Settings Screen — Structure**

- **FR-013**: The Settings screen MUST display a welcome header card at the top with a greeting message and decorative icon, styled in the app's deep-green/gold palette.
- **FR-014**: Settings MUST be grouped into three labelled sections: "الصلاة والمواقيت", "القرآن الكريم", and "عام".
- **FR-015**: Each setting row MUST show the current value as a trailing chip with a disclosure chevron (›). Tapping the row opens a modal bottom sheet listing available options; selecting an option dismisses the sheet and updates the chip immediately.
- **FR-015a**: All option pickers (calculation method, fiqh school, sound source, reciter, language) MUST use a modal bottom sheet — not push navigation or inline expansion.
- **FR-016**: Adhan notification toggles MUST be exposed as inline toggle switches directly in the settings list (not behind a drill-down screen).

**Settings Screen — Prayer & Times Section**

- **FR-017**: Users MUST be able to select a prayer calculation method from the supported list (Egyptian, Muslim World League, Umm Al-Qura, ISNA, Karachi).
- **FR-018**: Users MUST be able to select a fiqh school (Shafi'i / Hanafi) via a bottom sheet picker. The selection MUST be persisted and MUST immediately cause Asr time to be recalculated and prayer times refreshed.
- **FR-019**: The "الصلاة والمواقيت" section MUST include a dedicated "تنبيهات الأذان" sub-group showing one toggle row per prayer (Fajr, Dhuhr, Asr, Maghrib, Isha) with the Arabic prayer name as label.
- **FR-020**: Users MUST be able to select their preferred adhan sound source.

**Settings Screen — Quran Section**

- **FR-021**: Users MUST be able to select a preferred Quran reciter from at least 4 options.
- **FR-022**: The selected reciter MUST pre-populate the reciter selector in the Quran reader screen.

**Settings Screen — General Section**

- **FR-023**: The General section MUST include: Language selector, Rate the App, Share the App, Privacy Policy, and About Us rows.
- **FR-024**: "تقييم التطبيق" MUST open the app's store listing on the device's native store (App Store / Play Store).
- **FR-025**: "مشاركة التطبيق" MUST open the system share sheet with a pre-filled message and app link.
- **FR-026**: "سياسة الخصوصية" MUST open an in-app web view or the system browser with the privacy policy URL.
- **FR-027**: "من نحن" MUST navigate to an About screen showing app version, developer info, and acknowledgements.
- **FR-028**: The Settings screen footer MUST display the current app version number and the app logo.

**Notification Permission**

- **FR-031**: When notification permission has been denied by the user, the "تنبيهات الأذان" sub-section MUST display an inline warning banner reading "الإشعارات معطّلة" with an "افتح الإعدادات" button that opens the device's system notification settings for the app.
- **FR-032**: The permission banner MUST disappear automatically when the user returns to the app after granting permission (checked on app resume via `AppLifecycleState.resumed`).
- **FR-033**: The per-prayer toggle rows MUST remain visible beneath the banner when permission is denied, but toggling them MUST have no scheduling effect until permission is granted.

**Test Buttons**

- **FR-029**: The Settings screen MUST provide two test buttons: one for regular prayer adhan and one for Fajr adhan.
- **FR-030**: Each test button MUST immediately play the adhan in-app using the currently selected sound source AND schedule a test notification for 10 seconds later.

### Key Entities

- **PrayerNotificationSettings**: Record of 5 booleans — `{fajr, dhuhr, asr, maghrib, isha}`. Each defaults to `true`. Persisted in local storage as individual keys.
- **AdhanSoundSource**: Enum — `makkah`, `egypt`. Persisted in local storage. Controls both notification sound and foreground playback. Applies uniformly to all enabled prayers.
- **FiqhSchool**: Enum — `shafii` (standard Asr), `hanafi` (later Asr). Persisted; fed into prayer time calculation.
- **PreferredReciter**: String identifier (e.g., `ar.alafasy`). Persisted; pre-populates Quran reader.
- **ScheduledNotification**: `{id, prayerName, scheduledAt, soundSource}` — represents one pending local notification for one prayer.

---

## Visual Design

### Settings Screen Layout

```
┌──────────────────────────────────────────────┐
│  🔔  نور                        ≡            │  ← app bar (gold on dark green)
├──────────────────────────────────────────────┤
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  🌙  أهلاً وسهلاً                    │   │  ← welcome card (dark green bg)
│  │      سعدنا بعودتك إلى رحاب التراث   │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ⚙  الصلاة والمواقيت                        │  ← section header (gold, small)
│  ─────────────────────────────────────       │
│  طريقة حساب المواقيت    رابطة العالم ›       │
│  المذهب الفقهي          الشافعي ›            │
│  صوت الأذان             المسجد الحرام ›      │
│                                              │
│  🔔  تنبيهات الأذان                          │  ← sub-section header
│  ─────────────────────────────────────       │
│  ┌─ ⚠ الإشعارات معطّلة ──────────────────┐  │  ← amber banner (permission denied only)
│  │          [افتح الإعدادات]              │  │
│  └────────────────────────────────────────┘  │
│  الفجر                  ◉────────── ●       │  ← per-prayer toggles (always visible)
│  الظهر                  ◉────────── ●       │
│  العصر                  ◉────────── ●       │
│  المغرب                 ◉────────── ●       │
│  العشاء                 ◉────────── ●       │
│                                              │
│  📖  القرآن الكريم                           │
│  ─────────────────────────────────────       │
│  القارئ المفضل          الحصري ›             │
│                                              │
│  ⚙  عام                                     │
│  ─────────────────────────────────────       │
│  اللغة                  العربية ›            │
│  ☆  تقييم التطبيق                    ›      │
│  ↗  مشاركة التطبيق                   ›      │
│  🔒  سياسة الخصوصية                  ›      │
│  ℹ  من نحن                           ›      │
│                                              │
│       [اختبر أذان الصلاة  🔊]               │  ← primary green button
│       [اختبر أذان الفجر   🌅]               │
│                                              │
│          🌿  تجلّي  v1.0.0                   │  ← footer (muted gold)
└──────────────────────────────────────────────┘
```

### Sound Selection Bottom Sheet

When the user taps "صوت الأذان", a modal bottom sheet slides up:

```
┌──────────────────────────────────────────────┐
│           صوت الأذان                         │
│  ─────────────────────────────────────       │
│  🕌  المسجد الحرام — مكة المكرمة      ✓     │  ← checkmark on selected
│      الشيخ علي بن أحمد مُلّا               │
│  ─────────────────────────────────────       │
│  📻  إذاعة القرآن الكريم المصرية            │
│      الأذان المصري الكلاسيكي                │
└──────────────────────────────────────────────┘
```

### Calculation Method Selection Bottom Sheet

```
┌──────────────────────────────────────────────┐
│       طريقة حساب المواقيت                    │
│  ─────────────────────────────────────       │
│  الهيئة المصرية العامة للمساحة               │
│  رابطة العالم الإسلامي                  ✓   │
│  أم القرى                                   │
│  ISNA                                        │
│  جامعة العلوم الإسلامية — كراتشي            │
└──────────────────────────────────────────────┘
```

### Design Tokens

| Element               | Value                        |
|-----------------------|------------------------------|
| Background            | `#FFF8F0` (parchment)        |
| Section header text   | `#C9A84C` (gold)             |
| Row title text        | `#1A1A1A` (dark)             |
| Trailing value chip   | `#888` (muted) + chevron     |
| Toggle (active)       | `#1B4332` (primary green)    |
| Welcome card bg       | `#1B4332` (primary green)    |
| Welcome card text     | `#FFF1E8` (ivory)            |
| Button bg             | `#1B4332`                    |
| Button text           | `#C9A84C` (gold)             |
| Footer text           | `#C9A84C` at 60% opacity     |
| Font family           | Amiri (Arabic), all screens  |

---

## Requirements *(mandatory)*

### Fiqh School — Calculation Impact

The Fiqh school (Shafi'i vs Hanafi) changes when Asr is calculated:
- **Shafi'i** (default): shadow length = 1× object height — earlier Asr
- **Hanafi**: shadow length = 2× object height — later Asr (~30–60 min difference)

Changing the school MUST invalidate the prayer times cache and trigger an immediate recalculation. Adhan notifications for Asr MUST be rescheduled to the new time.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can open Settings, change their adhan sound, and confirm it works — all within 60 seconds.
- **SC-002**: A prayer-time notification arrives within ±30 seconds of the scheduled prayer time on both iOS and Android.
- **SC-003**: After changing any setting, the change takes effect for the very next prayer without the user needing to restart the app.
- **SC-004**: Settings values survive app force-quit and device restart (100% persistence reliability).
- **SC-005**: The Settings screen loads in under 300ms (all data is local — no network calls needed).
- **SC-006**: The test buttons work correctly for both sound sources, with sound playing within 1 second of tapping.
- **SC-007**: Zero crash rate from notification scheduling or audio playback (failures degrade silently to system default sound).
- **SC-008**: All enabled prayer notifications are scheduled within 2 seconds of prayer times loading; toggling a single prayer takes effect within 1 second.

---

## Assumptions

- The app uses Riverpod for state management; all new settings preferences are exposed as `StateProvider`s with `overrideWith` at app startup from SharedPreferences.
- Notification scheduling uses `flutter_local_notifications` with `zonedSchedule` (exact alarm); the necessary Android permissions (`SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`) are already declared in `AndroidManifest.xml`.
- Audio files for both sound sources (Makkah + Egypt, regular + Fajr) are bundled in the app at `assets/audio/` and are already present in the Android `res/raw/` and iOS `Runner/` directories.
- iOS foreground notification display is already enabled via `UNUserNotificationCenterDelegate` in `AppDelegate.swift`.
- The "Language" setting in Settings is display-only for now (Arabic is the only supported language); tapping it shows a "قريباً" placeholder. Multi-language support is out of scope for this phase.
- "تقييم التطبيق" and "مشاركة التطبيق" require actual App Store / Play Store URLs which will be filled in at release time; for now they show a toast "قريباً".
- "سياسة الخصوصية" and "من نحن" open placeholder screens (static text) until legal copy is provided.
- Notification scheduling relies solely on app-open triggers (no background execution). The app schedules 2 days ahead on each open, so a user who opens the app at least once every 2 days never misses a prayer notification.
- Qiyam al-Layl notification is included in the scheduler but OFF by default; no UI toggle is exposed in this phase (will be added in a future polish pass).
- The existing `CalculationMethodConfig` list in `prayer_times_providers.dart` is the canonical source of calculation method options — no new methods need to be added.
- Fiqh school defaults to Shafi'i on first launch. Changing it in Settings immediately invalidates the prayer times cache and reschedules Asr notifications.
