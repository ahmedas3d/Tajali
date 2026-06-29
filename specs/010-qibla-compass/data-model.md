# Data Model: Qibla Compass (القبلة)

## 1. QiblaModel

**File**: `lib/features/qibla/data/models/qibla_model.dart`

Pure Dart class — no Hive serialization (cache is stored as primitive SharedPreferences keys).

```dart
class QiblaModel {
  final double direction;    // degrees from true North toward Mecca (from AlAdhan API)
  final double distanceKm;   // great-circle distance to Mecca, computed via Haversine
  final String cityName;     // reverse-geocoded display label, e.g. "القاهرة، مصر"
  final double refLat;       // latitude used for the API call (cache invalidation reference)
  final double refLon;       // longitude used for the API call (cache invalidation reference)
}
```

**Validation rules**:
- `direction` ∈ [0.0, 360.0)
- `distanceKm` > 0
- `cityName` non-empty (falls back to coordinate string if geocoding fails)
- `refLat` ∈ [-90.0, 90.0], `refLon` ∈ [-180.0, 180.0]

**Lifecycle**: Fetched once from AlAdhan API per location epoch. Cached in SharedPreferences. Invalidated when `haversineKm(currentLat, currentLon, refLat, refLon) >= 50`.

---

## 2. MosqueModel

**File**: `lib/features/qibla/data/models/mosque_model.dart`

Pure Dart class. Not persisted — always fetched live from Overpass API.

```dart
class MosqueModel {
  final String nameAr;         // Arabic name from OSM tags: "name:ar" → fallback "name"
  final double lat;            // mosque geographic latitude (from Overpass response)
  final double lon;            // mosque geographic longitude (from Overpass response)
  final double distanceMeters; // Haversine distance from user to mosque, in meters
}
```

**Display logic**:
- Distance < 1000 m → display as `"على بعد ١٥٠ م"` (Arabic-Indic meters)
- Distance ≥ 1000 m → display as `"على بعد ٢٫٣ كم"` (Arabic-Indic kilometers)
- Maps URL for "انتقل": `"geo:${lat},${lon}?q=${lat},${lon}(${nameAr})"`

**Nullability**: `MosqueService.findNearest()` returns `MosqueModel?`. Returns `null` if Overpass response is empty, request times out, or device is offline.

---

## 3. AccuracyLevel Enum

**File**: `lib/features/qibla/data/models/qibla_model.dart` (same file as QiblaModel)

```dart
enum AccuracyLevel { low, medium, high }
```

**Mapping from `CompassEvent.accuracy`**:

| Condition | AccuracyLevel |
|-----------|---------------|
| `accuracy == null` | low |
| iOS: `accuracy < 0` | low |
| iOS: `accuracy >= 0 && < 5` | high |
| iOS: `accuracy >= 5 && < 20` | medium |
| iOS: `accuracy >= 20` | low |
| Android: `accuracy < 0 or 0–1` | low |
| Android: `accuracy == 2` | medium |
| Android: `accuracy >= 3` | high |

**Display labels**:
- `low` → `"دقة منخفضة"` (red-tinted badge)
- `medium` → `"دقة متوسطة"` (amber-tinted badge)
- `high` → `"دقة عالية"` (green-tinted badge)

---

## 4. QiblaCacheEntry (SharedPreferences keys)

Not a class — 5 scalar keys stored directly in SharedPreferences.

| Key | Type | Description |
|-----|------|-------------|
| `qibla_direction` | `double` | Qibla bearing in degrees from North |
| `qibla_city` | `String` | Reverse-geocoded city name (display-ready) |
| `qibla_distance_km` | `double` | Distance to Mecca in km |
| `qibla_ref_lat` | `double` | Reference latitude for cache invalidation |
| `qibla_ref_lon` | `double` | Reference longitude for cache invalidation |

**Cache hit condition**: All 5 keys present AND `haversineKm(currentLat, currentLon, qibla_ref_lat, qibla_ref_lon) < 50`.

**Cache miss**: Any key missing OR haversine distance ≥ 50 km. Triggers fresh API call + re-geocode + re-cache.

---

## 5. Riverpod Provider State Summary

| Provider | Type | Emits |
|----------|------|-------|
| `locationProvider` | `FutureProvider<Position>` | Current GPS position (reuses `LocationService`) |
| `qiblaModelProvider` | `FutureProvider<QiblaModel>` | Fetched/cached Qibla direction + city + distance |
| `compassHeadingProvider` | `StreamProvider<double>` | Smoothed compass heading in degrees (0–360) |
| `compassAccuracyProvider` | `StreamProvider<AccuracyLevel>` | Mapped accuracy level from raw `CompassEvent.accuracy` |
| `qiblaRotationProvider` | `Provider<double>` | Derived: `(qiblaDirection - compassHeading + 360) % 360` |
| `nearestMosqueProvider` | `FutureProvider<MosqueModel?>` | Live mosque query result; `null` if offline/failed |

---

## 6. Compass Rotation Derivation

```
qiblaRotation = (qiblaDirection - compassHeading + 360) % 360
```

This value is the number of degrees to rotate the compass *widget* (not the needle). The compass widget rotates so that the fixed Qibla indicator always points toward Mecca relative to the user's current facing direction.

Applied in widget: `AnimatedRotation(turns: qiblaRotation / 360, duration: Duration(milliseconds: 150))`
