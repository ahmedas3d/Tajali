# API Contracts: Qibla Compass

## 1. AlAdhan — Qibla Direction

**Base URL**: `https://api.aladhan.com/v1`

### GET `/qibla/{latitude}/{longitude}`

Returns the Qibla bearing angle from the given coordinates toward Mecca.

**Path parameters**:
| Parameter | Type | Example | Notes |
|-----------|------|---------|-------|
| `latitude` | double | `30.0616` | Decimal degrees, -90 to 90 |
| `longitude` | double | `31.2497` | Decimal degrees, -180 to 180 |

**No authentication required. No rate limit documented.**

**Success response** (HTTP 200):
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

**Fields consumed**:
| Field | Type | Notes |
|-------|------|-------|
| `data.direction` | double | Degrees clockwise from true North; maps to `QiblaModel.direction` |

**Error handling**:
- Non-200 or network error → use SharedPreferences cache
- If no cache → show error state (compass needle hidden, error banner visible)

**Caching**: Result stored in SharedPreferences. Cache key: 5 scalar values (see data-model.md §4). Cache is valid until `haversineKm(current, ref) >= 50`.

---

## 2. Overpass API — Nearest Mosque

**Base URL**: `https://overpass-api.de/api/interpreter`

### POST `/api/interpreter`

Finds the nearest place of Islamic worship within a 2 km radius.

**Request**:
- Method: POST
- Content-Type: `application/x-www-form-urlencoded`
- Body: `data=<encoded-query>`

**Query template** (sent URL-encoded in POST body):
```
[out:json][timeout:10];
node["amenity"="place_of_worship"]["religion"="muslim"](around:2000,{lat},{lon});
out 1;
```

Replace `{lat}` and `{lon}` with the user's current GPS coordinates (6 decimal places).

**No authentication required. Subject to fair-use policy.**

**Success response** (HTTP 200):
```json
{
  "version": 0.6,
  "generator": "Overpass API",
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

**Fields consumed**:
| Field | Type | Notes |
|-------|------|-------|
| `elements[0].lat` | double | Mosque latitude; used for Haversine distance + maps URL |
| `elements[0].lon` | double | Mosque longitude |
| `elements[0].tags["name:ar"]` | String? | Arabic name; fallback to `tags["name"]` |

**Empty response** (`elements` is empty array):
- `MosqueService.findNearest()` returns `null` → nearest mosque card hidden

**Error handling**:
- Timeout (10 s), HTTP error, or network unavailable → return `null` → card hidden
- No retries (card appears on next screen open when online)

**Maps launch URL format** (for "انتقل" button via `url_launcher`):
```
geo:{lat},{lon}?q={lat},{lon}({nameAr})
```
Example: `geo:30.058,31.243?q=30.058,31.243(مسجد الفتح)`

Falls back to `https://maps.google.com/maps?q={lat},{lon}` if `geo:` scheme is not supported.

---

## 3. Geocoding (Device-Native via `geocoding` Package)

Not an external HTTP API — uses platform-native geocoding services.

**Call**: `placemarkFromCoordinates(latitude, longitude)`

**Returns**: `List<Placemark>` — first element used.

**Fields consumed**:
| Field | Type | Notes |
|-------|------|-------|
| `locality` | String? | City name in device locale (e.g., "القاهرة" on Arabic device) |
| `country` | String? | Country name in device locale (e.g., "مصر") |

**Display format**: `"${locality}، ${country}"` e.g., `"القاهرة، مصر"`

**Fallback**: If `locality` or `country` is null/empty, display `"${lat.toStringAsFixed(2)}°، ${lon.toStringAsFixed(2)}°"`
