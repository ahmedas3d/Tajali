# Contract: PrayerCardWidget (Home Screen)

**Feature**: Prayer Times (مواقيت الصلاة)  
**File location**: `lib/features/prayer_times/presentation/widgets/prayer_card_widget.dart`

---

## Purpose

A self-contained `ConsumerWidget` embedded in `HomeScreen` that displays the next upcoming prayer. It consumes `nextPrayerProvider` directly and requires no data to be passed from the parent — the parent only decides where to position the card.

---

## Widget Interface

```dart
class PrayerCardWidget extends ConsumerWidget {
  const PrayerCardWidget({super.key});
}
```

No constructor parameters. All data sourced from Riverpod providers.

---

## Visual Contract

Renders three pieces of information vertically:

1. **Prayer name** (`nameAr`) — `AppTextStyles.heading3`, gold colour
2. **Prayer time** (`scheduledTime`) — `AppTextStyles.heading2`, ivory colour
3. **Countdown** (`remaining`) formatted as `"بعد h:mm"` (e.g., `"بعد 1:23"`) — `AppTextStyles.bodySmall`, muted ivory

Card background: `AppColors.primaryGreen` with `AppColors.cardShadowLight` elevation shadow.  
Card dimensions: full-width with 16 px horizontal padding, 12 px vertical padding. Uses `IslamicCard` shared widget.

---

## Loading State

While `nextPrayerProvider` is loading, the card shows three shimmer placeholders (one per row). No spinner.

## Error State

If `nextPrayerProvider` errors (location unavailable, no cache), the card shows `"—"` in place of values. Does not propagate the error to the parent.

---

## Update Behaviour

The countdown text updates every minute via the `StreamProvider`. Only the countdown `Text` widget rebuilds; the prayer name and time rows are stable between prayer transitions.
