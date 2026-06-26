# Contract: AlQuran Cloud API

**Feature**: Quran Surah List (قائمة السور)  
**Used by**: `lib/features/quran/data/services/quran_service.dart`

---

## Endpoint

```
GET https://api.alquran.cloud/v1/surah
```

- **Auth**: None required
- **Rate limit**: None documented for this metadata endpoint
- **Called**: Once per device lifetime (result cached permanently in Hive)

---

## Request

No parameters. Plain GET.

```
GET /v1/surah HTTP/1.1
Host: api.alquran.cloud
Accept: application/json
```

---

## Success Response

**HTTP Status**: `200 OK`

```json
{
  "code": 200,
  "status": "OK",
  "data": [
    {
      "number": 1,
      "name": "سُورَةُ ٱلْفَاتِحَةِ",
      "englishName": "Al-Faatiha",
      "englishNameTranslation": "The Opener",
      "numberOfAyahs": 7,
      "revelationType": "Meccan"
    },
    {
      "number": 2,
      "name": "سُورَةُ ٱلْبَقَرَةِ",
      "englishName": "Al-Baqara",
      "englishNameTranslation": "The Cow",
      "numberOfAyahs": 286,
      "revelationType": "Medinan"
    }
  ]
}
```

**`data` array**: Always 114 elements, ordered by `number` ascending (1 → 114).

---

## Fields Consumed by Phase 2

| API field | Maps to | SurahModel field |
|---|---|---|
| `number` | → | `number` (int) |
| `name` | → | `name` (String) — Arabic with tashkeel |
| `englishName` | → | `englishName` (String) |
| `numberOfAyahs` | → | `numberOfAyahs` (int) |
| `revelationType` | → | `revelationType` (String) — `"Meccan"` or `"Medinan"` |
| `englishNameTranslation` | — | **Ignored in Phase 2** |

---

## Error Responses

| HTTP Status | Meaning | App Behaviour |
|---|---|---|
| `400` | Malformed request | Log + show error state with retry |
| `404` | Endpoint not found | Log + show error state with retry |
| `5xx` | Server error | Log + show error state with retry |
| Network timeout | No connectivity | Show error state with retry; no cache available on first launch |

**Error handling rule**: If `code ≠ 200` in the response body despite a `200 HTTP status`, treat as a soft error, log, and return cached data if available (or throw `QuranServiceException` if not).

---

## Caching Contract

`QuranService` checks Hive `surahListBox` completeness (`length == 114`) **before** making any network call. If complete, the API is never called again regardless of connectivity state. The cache has no expiry — surah metadata is immutable.

---

## Phase 3 Extension

Phase 3 will use additional AlQuran Cloud endpoints for surah text and audio:
```
GET /v1/surah/{number}/quran-uthmani        — Uthmanic script text
GET /v1/surah/{number}/{reciter_edition}    — Audio URLs per ayah
```
These are out of scope for Phase 2 and are not consumed by `QuranService`.
