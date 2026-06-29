# Research: Qibla Compass (القبلة)

## 1. flutter_compass Accuracy Field — Platform Differences

**Decision**: Map `CompassEvent.accuracy` to a 3-level `AccuracyLevel` enum (low / medium / high) using platform-specific thresholds applied in the provider layer.

**Platform behavior**:

| Platform | `accuracy` value meaning | Mapping |
|----------|--------------------------|---------|
| iOS | Degrees of error (negative = invalid) | `< 0 or null` → low; `0–5` → high; `5–20` → medium; `> 20` → low |
| Android | `SensorManager.SENSOR_STATUS_*` integer | `null or < 0` → low; `0–1` → low; `2` → medium; `3` → high |

**Implementation note**: Since Dart cannot detect the runtime platform inside a pure provider, use `Platform.isIOS` / `Platform.isAndroid` from `dart:io` to select the threshold branch.

**Rationale**: The `flutter_compass` package does not normalize accuracy across platforms. Using raw `accuracy` in the UI would display meaningless values. Mapping to a 3-level enum keeps the UI layer simple and testable.

**Alternatives considered**:
- Display raw accuracy value as degrees — rejected: value is not comparable across iOS/Android
- Omit accuracy display entirely — rejected: spec requires persistent accuracy badge (FR-009a, clarification 2026-06-29)

---

## 2. Compass Heading Smoothing

**Decision**: Apply a low-pass filter with alpha = 0.15 in the Riverpod `StreamProvider` that emits the smoothed heading. Handle 359° → 1° wrap-around using shortest-angle interpolation before each filter step.

**Algorithm** (applied per sensor event):
```
// Normalize angle difference to [-180, 180]
double delta = newHeading - smoothed;
while (delta > 180) delta -= 360;
while (delta < -180) delta += 360;
smoothed = smoothed + alpha * delta;
smoothed = (smoothed + 360) % 360;
```

**Alpha = 0.15**: Provides ~8-event lag at 10 Hz sensor rate (~800 ms visual delay), eliminating flicker while still feeling responsive when the user pans slowly. Values above 0.3 feel jittery on a shaky device; below 0.05 feel unresponsive.

**Widget layer**: `AnimatedRotation` with `duration: Duration(milliseconds: 150)` adds visual easing on top of the filtered stream, preventing any residual step jumps.

**Rationale**: Compass sensors — especially on mid-range Android devices — emit noisy readings that cause the needle to vibrate erratically at rest. A single low-pass filter in the stream layer is simpler and more testable than trying to smooth in the widget's build method.

**Alternatives considered**:
- Kalman filter — rejected: over-engineered for a UI compass; adds complexity without perceptible benefit at typical user rotation speeds
- No smoothing + high `AnimatedRotation` duration — rejected: wrapping artefacts (359° → 1°) would cause the widget to spin 359° the wrong way

---

## 3. AlAdhan Qibla API

**Endpoint**: `GET https://api.aladhan.com/v1/qibla/{latitude}/{longitude}`

**Response shape**:
```json
{
  "code": 200,
  "status": "OK",
  "data": {
    "latitude": 30.0616,
    "longitude": 31.2497,
    "direction": 136.87
  }
}
```

**Fields used**: `data.direction` (double, degrees from true North toward Mecca).

**Error handling**: On any non-200 response or network error, fall back to SharedPreferences cache. If no cache exists, show error state (FR-014).

**Caching**: Stored in SharedPreferences under `qibla_direction`. Cache is invalidated when the user moves > 50 km from the coordinates stored in `qibla_ref_lat` / `qibla_ref_lon` (checked via Haversine before deciding to re-fetch).

**No authentication required**. No rate limit documented by AlAdhan.

---

## 4. Overpass API — Nearest Mosque Query

**Endpoint**: `POST https://overpass-api.de/api/interpreter`  
Content-Type: `application/x-www-form-urlencoded`  
Body: `data=<query>`

**Query** (2 km search radius, limit 1 result):
```
[out:json][timeout:10];
node["amenity"="place_of_worship"]["religion"="muslim"](around:2000,{lat},{lon});
out 1;
```

**Response shape**:
```json
{
  "elements": [
    {
      "type": "node",
      "id": 123456789,
      "lat": 30.058,
      "lon": 31.243,
      "tags": {
        "amenity": "place_of_worship",
        "religion": "muslim",
        "name": "مسجد الفتح",
        "name:ar": "مسجد الفتح",
        "name:en": "Al-Fath Mosque"
      }
    }
  ]
}
```

**Fields used**: `elements[0].lat`, `elements[0].lon`, `elements[0].tags["name:ar"] ?? elements[0].tags["name"]`.

**Distance**: Compute using Haversine between user coordinates and mosque `(lat, lon)`. Format result as meters if < 1000 m (e.g., "١٥٠ م"), else as km (e.g., "٢٫٣ كم").

**Error / empty handling**: If `elements` is empty or the request fails, `MosqueService` returns `null`. The provider exposes `null` and the widget hides the card entirely (FR-010, clarification 2026-06-29).

**Rate limits**: Overpass API has a fair-use policy; a single query per screen open is well within acceptable use. No authentication required.

**Alternatives considered**:
- Google Places API — rejected: requires API key + billing; adds external dependency
- Bundled static mosque list — rejected: spec clarification A chose live-only (no local cache)

---

## 5. Reverse Geocoding — City Name Display

**Decision**: Use the `geocoding ^3.0.0` Flutter package. Call `placemarkFromCoordinates(lat, lon)` and extract `Placemark.locality` + `Placemark.country` for display.

**Output format**: `"${placemark.locality}، ${placemark.country}"` e.g., `"القاهرة، مصر"`.

**Fallback**: If `placemarkFromCoordinates` throws or returns an empty list, display the coordinates as `"${lat.toStringAsFixed(2)}°، ${lon.toStringAsFixed(2)}°"`.

**Package note**: `geocoding` uses the device's native geocoding service (Apple Maps on iOS, Google Maps on Android). It does not make an additional network call on devices with offline maps data. Requires no API key. iOS requires `NSLocationWhenInUseUsageDescription` in `Info.plist` — already present for `geolocator`.

**Alternatives considered**:
- Nominatim (OpenStreetMap) reverse geocoding via `dio` — rejected: adds another external API dependency; `geocoding` package is platform-native and simpler
- `geolocator` package geocoding — rejected: `geolocator` does not include reverse geocoding
- Display raw coordinates only — rejected: FR-005 requires city name + country

---

## 6. Haversine Distance Formula

**Implementation** (pure Dart, no package):
```dart
import 'dart:math';

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0; // Earth radius in km
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _rad(double deg) => deg * pi / 180;
```

**Mecca coordinates**: `lat = 21.3891`, `lon = 39.8579` (Masjid al-Haram centroid).

**Uses**:
1. Distance to Mecca displayed in stats card (FR-006, FR-007)
2. Mosque distance from user (Overpass result coordinates vs. user GPS)
3. Cache invalidation: if `haversineKm(currentLat, currentLon, qibla_ref_lat, qibla_ref_lon) >= 50`, re-fetch Qibla direction

**Precision target**: Within ±10 km of true geodesic distance (SC-004). The Haversine formula error is < 0.5% for distances up to 20,000 km, well within this tolerance.

---

## 7. Mid-Session Permission Revocation

**Detection strategy**: Watch `Geolocator.getPositionStream()`. If the stream emits a `LocationServiceDisabledException` or the provider receives a `LocationPermission.denied` from a periodic `checkPermission()` poll, the `qiblaScreenStateProvider` transitions to `permissionDenied` state, triggering the permission request card (US-5 scenario 3, clarification 2026-06-29).

**Alternative**: `Geolocator.getServiceStatusStream()` only detects location service toggle, not permission revocation. A combination of position stream error handling + `AppLifecycleObserver` (re-check permission on app resume) covers the mid-session case.

---

## 8. Cardinal Direction Abbreviation

**Mapping** (from degrees clockwise from North):
```
N:   337.5–360 or 0–22.5
NE:  22.5–67.5
E:   67.5–112.5
SE:  112.5–157.5
S:   157.5–202.5
SW:  202.5–247.5
W:   247.5–292.5
NW:  292.5–337.5
```

Display uses English abbreviation (SE, NW, etc.) as shown in the design screenshot. Direction badge format: `"SE ١٣٥°"` (cardinal abbreviation + Arabic-Indic numeral degrees).
