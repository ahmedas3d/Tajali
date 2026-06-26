# Data Model: Theme System

**Feature**: [002-theme-system](spec.md) | **Date**: 2026-06-25

---

## Entities

### ThemeMode (runtime state)

The single piece of mutable state in this feature. Persisted to local storage; loaded on app start.

| Attribute | Type | Values | Notes |
|-----------|------|--------|-------|
| `value` | enum | `light`, `dark` | Persisted as string `'light'` / `'dark'` |
| `isDefault` | bool | `true` when no stored preference | Defaults to `light` on first launch |

**Storage key**: `'theme_mode'` in `shared_preferences`

**State transitions**:

```
[First launch / no preference] ──► light (default)
        light ──toggle──► dark
        dark  ──toggle──► light
[App restart] ──read pref──► stored value (light or dark)
```

---

### Color Token (compile-time constant)

Each color token is a named, immutable ARGB value. Tokens are grouped by semantic role.

| Token Name | Hex Value | Context | WCAG on Background |
|------------|-----------|---------|-------------------|
| `primaryGreen` | `#1B4332` | Primary actions, AppBar (light) | N/A (background) |
| `primaryGreenDark` | `#0D2218` | Deep primary variant | N/A |
| `gold` | `#C9A84C` | Decorative, dark-bg accents, UI components on dark | Passes 3:1 on `darkBackground` |
| `goldLight` | `#E8C97A` | Hover/highlight variant | Decorative only |
| `goldDark` | `#9A7A2E` | Card borders on dark surfaces | Passes 3:1 on `darkCard` |
| `goldText` | `~#7B5F00` | Text on light backgrounds | Passes 4.5:1 on `backgroundParchment` ✓ |
| `backgroundParchment` | `#F5E6C8` | Scaffold bg (light) | N/A (background) |
| `surfaceIvory` | `#FAF0DC` | Card surface (light), text-on-dark | N/A |
| `surfaceCard` | `#F0E0BE` | Alternate card surface | N/A |
| `textDark` | `#3D1F00` | Primary text on light bg | Passes 4.5:1 on parchment ✓ |
| `textMedium` | `#6B3A1F` | Secondary text | Verify 4.5:1 on parchment |
| `textMuted` | `#9C7A5A` | Tertiary/hint text | Verify 3:1 on parchment (large text) |
| `textOnDark` | `#FAF0DC` | Text on dark surfaces | Passes 4.5:1 on `darkBackground` ✓ |
| `darkBackground` | `#1A1209` | Scaffold bg (dark) | N/A (background) |
| `darkSurface` | `#2A1F0E` | Card surface (dark) | N/A |
| `darkCard` | `#332810` | Card bg (dark) | N/A |
| `success` | `#2D6A4F` | Status — success | Semantic only |
| `warning` | `#C9A84C` | Status — warning | Same as `gold` |
| `error` | `#8B0000` | Status — error | Semantic only |
| `navBackground` | `#0A1A10` | BottomNav background | N/A (background) |
| `navActive` | `#C9A84C` | Active nav icon/label | Passes 3:1 on `navBackground` |
| `navInactive` | `0x80FAF0DC` | Inactive nav (50% ivory) | Decorative |
| `cardShadowLight` | `0x4DC9A84C` | Card shadow (light theme) | Decorative |
| `cardShadowDark` | `0x33C9A84C` | Card shadow (dark theme) | Decorative |

> **WCAG verification required at implementation**: `textMedium` and `textMuted` must be measured against their actual usage backgrounds. If either fails, adjust the token value while preserving the warm-brown palette direction.

---

### TextStyle Token (compile-time constant)

| Token Name | Font | Size | Weight | Color Token | Line Height | Letter Spacing |
|------------|------|------|--------|-------------|-------------|----------------|
| `heading1` | AmiriQuran | 28px | Bold | `goldText` | 1.4 | — |
| `heading2` | Amiri | 22px | Bold | `textDark` | 1.4 | — |
| `heading3` | Amiri | 18px | Bold | `textDark` | 1.4 | — |
| `body` | Amiri | 16px | Regular | `textDark` | 1.6 | — |
| `bodySmall` | Amiri | 13px | Regular | `textMedium` | 1.5 | — |
| `quranText` | AmiriQuran | 24px | Regular | `textDark` | 2.0 | — |
| `goldLabel` | Amiri | 14px | Bold | `goldText` | — | 0.5 |
| `onDark` | Amiri | 16px | Regular | `textOnDark` | 1.6 | — |
| `onDarkBold` | Amiri | 18px | Bold | `textOnDark` | — | — |

> **Key change from Phase 1 scaffold**: `heading1` and `goldLabel` must reference the new `goldText` token (not `gold`) to meet WCAG AA on light backgrounds.

---

### ThemeData (compile-time constant, two instances)

| Attribute | `lightTheme` | `darkTheme` |
|-----------|-------------|------------|
| Material version | 3 | 3 |
| Brightness | light | dark |
| Font family | Amiri | Amiri |
| Scaffold bg | `backgroundParchment` | `darkBackground` |
| Primary | `primaryGreen` | `gold` |
| Secondary | `gold` | `primaryGreen` |
| Surface | `surfaceIvory` | `darkSurface` |
| AppBar bg | `primaryGreen` | `darkBackground` |
| AppBar title style | `onDarkBold` | Amiri 20px bold `gold` |
| Card surface | `surfaceIvory` | `darkCard` |
| Card shadow | `cardShadowLight` | `cardShadowDark` |
| Card border | `gold` 1px | `goldDark` 1px |
| Divider | `gold` 0.8px | (inherited) |
| BottomNav bg | `navBackground` | `#0A0A05` |
| BottomNav active | `navActive` | `gold` |
| BottomNav inactive | `navInactive` | `navInactive` |
| BottomNav type | fixed | fixed |

---

### FontFamily (compile-time constant)

| Constant | Value | Usage |
|----------|-------|-------|
| `amiri` | `'Amiri'` | All UI text |
| `amiriQuran` | `'AmiriQuran'` | Quran verse display |
