# Contract: Theme Provider

**Feature**: [002-theme-system](../spec.md) | **Date**: 2026-06-25

This document defines the public API surface of the theme state layer — what consumers can call, what they can observe, and what guarantees the provider makes.

---

## Provider: `themeProvider`

**Location**: `lib/core/providers/theme_provider.dart`
**Type**: `AsyncNotifierProvider<ThemeNotifier, ThemeMode>`

### State

The provider exposes `ThemeMode` — one of `ThemeMode.light` or `ThemeMode.dark`.

| State | Meaning |
|-------|---------|
| `ThemeMode.light` | Light (parchment/green) theme active |
| `ThemeMode.dark` | Dark (near-black/gold) theme active |

On first launch (no stored preference), state resolves to `ThemeMode.light`.

### Read (observation)

```
// In any ConsumerWidget or ConsumerStatefulWidget:
final themeMode = ref.watch(themeProvider);

// themeMode is AsyncValue<ThemeMode>
// Use .when() or .valueOrNull for safe consumption
```

### Write (mutation)

```
// Toggle between light and dark:
ref.read(themeProvider.notifier).toggle();

// Set explicitly:
ref.read(themeProvider.notifier).setMode(ThemeMode.light);
ref.read(themeProvider.notifier).setMode(ThemeMode.dark);
```

### Guarantees

1. **Persistence**: Every `toggle()` or `setMode()` call writes the new value to `shared_preferences` before returning. The stored key is `'theme_mode'`.
2. **Default**: If no value is stored, `build()` returns `ThemeMode.light`.
3. **Idempotent set**: Calling `setMode(ThemeMode.light)` when already in light mode is a no-op (no storage write, no rebuild).
4. **No side effects on read**: Observing `themeProvider` never triggers a storage write.

---

## Integration Point: `TajaliApp`

`TajaliApp` in `lib/app/app.dart` is the sole consumer of `themeProvider` for the `MaterialApp.themeMode` prop.

```
// Expected shape in app.dart:
themeMode: ref.watch(themeProvider).valueOrNull ?? ThemeMode.light,
```

While the async value is loading (first frame), `ThemeMode.light` is shown — no flash of wrong theme if the stored value is `light`; a one-frame flash is acceptable if stored value is `dark`.

---

## Integration Point: Toggle UI

A single icon button in `HomeScreen`'s AppBar. Contract:

- Icon: sun icon when dark mode active (to indicate "switch to light"); moon icon when light mode active.
- On tap: calls `ref.read(themeProvider.notifier).toggle()`.
- No confirmation dialog — toggle is immediately reversible.

---

## StorageService Contract Extension

`StorageService` at `lib/shared/local_storage/storage_service.dart` must implement:

| Method | Signature | Behavior |
|--------|-----------|----------|
| `initialize` | `Future<void> initialize()` | Init SharedPreferences instance |
| `write` | `Future<void> write(String key, String value)` | Persist key/value |
| `read` | `String? read(String key)` | Return stored value or null |

**Key used by theme**: `'theme_mode'` — stored as `'light'` or `'dark'`.

`StorageService` must be initialized before `ProviderScope` is created (in `main.dart`), so `themeProvider` can read synchronously on first build.
