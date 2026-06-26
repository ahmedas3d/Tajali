# Contract: AlAdhan Hijri Date API

**Feature**: Prayer Times (مواقيت الصلاة)  
**Used by**: `HijriDateService`  
**File location**: `lib/features/prayer_times/data/services/hijri_date_service.dart`

---

## Endpoint

```
GET https://api.aladhan.com/v1/gToH/{DD-MM-YYYY}
```

No API key required. No rate limit documented.

---

## Request

| Parameter | Description | Example |
|---|---|---|
| `{DD-MM-YYYY}` | URL path segment — Gregorian date | `26-06-2026` |

---

## Successful Response (200)

```json
{
  "code": 200,
  "status": "OK",
  "data": {
    "hijri": {
      "date": "01-01-1448",
      "day": "01",
      "month": {
        "number": 1,
        "en": "Muharram",
        "ar": "مُحَرَّم"
      },
      "year": "1448",
      "designation": {
        "abbreviated": "AH",
        "expanded": "Anno Hegirae"
      }
    },
    "gregorian": { ... }
  }
}
```

**Extracted fields**:

| JSON path | Maps to `HijriDateModel` field |
|---|---|
| `data.hijri.day` | `day` (parsed as `int`) |
| `data.hijri.month.ar` | `monthAr` |
| `data.hijri.year` | `year` (parsed as `int`) |
| Derived from above | `readable` — formatted with Eastern Arabic numerals |

---

## Error Handling

| HTTP Status | `HijriDateService` behaviour |
|---|---|
| 200 | Parse and cache in Hive |
| 4xx / 5xx | Throw `HijriApiException`; `hijriDateProvider` emits `AsyncError`; UI hides Hijri date gracefully |
| Network timeout (5 s) | Same as 5xx |

---

## Caching Policy

- Hive box: `hijriDateBox`
- Cache key: Gregorian date string `YYYY-MM-DD`
- TTL: Indefinite (Hijri date for a given Gregorian date never changes)
- Cache check: Before every API call; if hit, return immediately without network request
