# Quickstart & Validation Guide: Notifications & Settings

**Date**: 2026-06-29 | **Plan**: [plan.md](plan.md) | **Data Model**: [data-model.md](data-model.md)

---

## Prerequisites

```bash
cd /Users/ahmedasaad/projects/tajali
flutter pub get
flutter run -d <device-id>   # iOS simulator or physical device
```

Verify the app launches and reaches the main navigation (prayer times screen).

---

## Scenario 1 — Settings Screen Structure (US-3)

**Goal**: Confirm the redesigned settings screen renders correctly.

1. Tap the **Settings** tab (bottom nav)
2. Verify:
   - Welcome card at top: "أهلاً وسهلاً" with moon/crescent icon on dark-green background
   - Section header "الصلاة والمواقيت" in gold
   - Rows: طريقة حساب المواقيت, المذهب الفقهي, صوت الأذان
   - Sub-section "تنبيهات الأذان" with 5 prayer toggle rows (الفجر, الظهر, العصر, المغرب, العشاء)
   - Section header "القرآن الكريم" → row: القارئ المفضل
   - Section header "عام" → rows: اللغة, تقييم التطبيق, مشاركة التطبيق, سياسة الخصوصية, من نحن
   - Footer: "تجلّي v[version]"

**Expected**: All sections and rows visible; trailing chips show current saved values.

---

## Scenario 2 — Per-Prayer Notification Toggles (US-1, US-4)

**Goal**: Confirm each prayer can be independently toggled.

1. In Settings → تنبيهات الأذان, turn OFF **الظهر** toggle
2. Force-quit and reopen the app
3. Go back to Settings → verify الظهر toggle is still OFF, others are ON

**Expected**: Toggle state persists across restarts.

**Quick notification test**:
1. Ensure الفجر toggle is ON and desired sound is selected
2. Tap **"اختبر أذان الفجر"** button
3. Hear Fajr adhan immediately in-app
4. Wait 10 seconds → notification banner appears on lock screen with adhan sound

**Expected**: Notification fires with correct sound (not system default).

---

## Scenario 3 — Fiqh School Change (US, FR-018)

**Goal**: Confirm switching Madhab changes Asr time.

1. Note the current Asr time shown on the prayer times screen
2. Go to Settings → tap "المذهب الفقهي" row
3. Bottom sheet appears — select "الحنفي"
4. Sheet dismisses; trailing chip updates to "الحنفي ›"
5. Navigate to prayer times screen

**Expected**: Asr time is now ~30–60 minutes later than before (Hanafi shadow = 2×).

6. Repeat: go back to Settings, switch back to "الشافعي"
7. Asr time returns to original value

**Expected**: Change is bidirectional and takes effect without restart.

---

## Scenario 4 — Adhan Sound Selection (US-2)

**Goal**: Confirm sound source affects both in-app audio and notifications.

1. Go to Settings → tap "صوت الأذان"
2. Bottom sheet shows two options; select "إذاعة القرآن الكريم المصرية"
3. Tap "اختبر أذان الصلاة"

**Expected**: Egyptian Radio adhan plays immediately (distinct voice from Makkah).

4. Wait 10 seconds → test notification fires

**Expected**: Notification sound is Egyptian Radio adhan.

5. Switch back to "المسجد الحرام" and repeat test

**Expected**: Makkah adhan plays.

---

## Scenario 5 — 2-Day-Ahead Scheduling

**Goal**: Confirm tomorrow's prayers are scheduled on app open.

1. Open the app (any screen)
2. In a terminal, run:
   ```bash
   # iOS simulator — list pending notifications (requires flutter_local_notifications debug)
   # Or: use the test button and verify notification fires after 10s
   ```
3. Tap "اختبر أذان الصلاة" → note notification arrives in 10 seconds ✓

**Simulated midnight test** (manual):
1. Go to Settings → turn ON all 5 prayer toggles
2. Force-quit the app
3. Advance device clock past midnight
4. Reopen the app
5. Verify in the prayer times screen that times reflect the new day
6. Tap "اختبر أذان الفجر" → notification arrives in 10s

**Expected**: Tomorrow's prayers were scheduled when app opened on the new day.

---

## Scenario 6 — Notification Permission Denied (FR-031–033)

**Goal**: Confirm inline permission banner appears when permission is denied.

1. On iOS: Settings app → Tajali → Notifications → turn OFF
2. Return to Tajali → Settings tab
3. Scroll to "تنبيهات الأذان" sub-section

**Expected**: Amber warning banner shows "الإشعارات معطّلة" with "افتح الإعدادات" button above the prayer toggles.

4. Tap "افتح الإعدادات" → device notification settings for Tajali opens
5. Grant notification permission → return to Tajali

**Expected**: Banner disappears automatically; prayer toggles are now active.

---

## Scenario 7 — Preferred Reciter Bridge (US-5)

**Goal**: Confirm reciter set in Settings pre-populates the Quran reader.

1. Go to Settings → "القارئ المفضل" → select "الحصري"
2. Navigate to Quran tab → open any surah
3. Open the audio player or reciter selector

**Expected**: Al-Husary (الحصري) is pre-selected as the active reciter.

4. Change reciter in Settings to "عبد الصمد" → open Quran reader again

**Expected**: Abdul Samad is now pre-selected.

---

## Scenario 8 — Settings Persistence (SC-004)

**Goal**: Confirm all settings survive force-quit + device restart.

1. Set all preferences to non-default values:
   - Method: أم القرى
   - Madhab: الحنفي
   - Sound: إذاعة القرآن
   - Turn OFF الظهر and العصر toggles
   - Reciter: علي الحذيفي
2. Force-quit the app
3. Reopen

**Expected**: Every setting is exactly as left — no reset to defaults.

---

## Scenario 9 — About Screen (FR-027)

**Goal**: Confirm "من نحن" navigates to an About screen.

1. Go to Settings → tap "من نحن"
2. Verify About screen opens showing app version number and developer information
3. Back button returns to Settings

**Expected**: About screen renders without errors; version matches `pubspec.yaml` version.

---

## Known Limitations (in-scope for this phase)

- "تقييم التطبيق" and "مشاركة التطبيق" show "قريباً" snackbar — store URLs not yet available.
- "سياسة الخصوصية" opens a placeholder screen — legal copy TBD.
- "اللغة" shows "العربية ›" as a display-only row — multi-language is out of scope.
- Qiyam al-Layl has no toggle UI — scheduled but OFF by default, no user control yet.
