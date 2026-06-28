# API Contract: AlQuran Cloud — Reader & Audio

**Feature**: 007-quran-reader-audio  
**Base URL**: `https://api.alquran.cloud/v1`  
**CDN Base**: `https://cdn.islamic.network/quran/audio/128`  
**Auth**: None required  
**Rate limit**: None documented

---

## Endpoint 1: Fetch Surah (Text + Audio — Primary)

Used by `QuranReaderService.getSurahWithAudio()`.

```
GET /v1/surah/{surahNumber}/editions/quran-uthmani,{reciterEdition}
```

**Path parameters**:
- `surahNumber` — integer 1–114
- `reciterEdition` — one of: `ar.alafasy`, `ar.abdulsamad`, `ar.abdullahbasfar`, `ar.hudhaify`

**Example**:
```
GET /v1/surah/1/editions/quran-uthmani,ar.alafasy
```

**Success response** (HTTP 200):
```json
{
  "code": 200,
  "status": "OK",
  "data": [
    {
      "number": 1,
      "name": "سُورَةُ ٱلْفَاتِحَةِ",
      "numberOfAyahs": 7,
      "revelationType": "Meccan",
      "edition": { "identifier": "quran-uthmani" },
      "ayahs": [
        {
          "number": 1,
          "numberInSurah": 1,
          "text": "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
          "juz": 1,
          "page": 1,
          "audio": null
        }
      ]
    },
    {
      "number": 1,
      "edition": { "identifier": "ar.alafasy" },
      "ayahs": [
        {
          "number": 1,
          "numberInSurah": 1,
          "text": "...",
          "audio": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3",
          "audioSecondary": []
        }
      ]
    }
  ]
}
```

**Parsing strategy**: Response `data` is an array of two edition objects. Index 0 = text (quran-uthmani), index 1 = audio. Zip by `numberInSurah` to build `List<AyahModel>` with both `text` and `audioUrl` populated.

**Error handling**:

| HTTP | `code` field | Action |
|---|---|---|
| 200 | 200 | Parse normally |
| 200 | 404 | Surah not found — throw `QuranReaderException` |
| 4xx / 5xx | any | Show cached text if available; show error + retry for audio |
| Timeout | — | Same as above |

---

## Endpoint 2: Fetch Surah Text Only (fallback / reciter switch)

Used when switching reciter (text already cached, only re-fetch audio edition).

```
GET /v1/surah/{surahNumber}/{reciterEdition}
```

**Example**:
```
GET /v1/surah/1/ar.abdulsamad
```

**Response**: Same structure as Endpoint 1 but `data` is a single edition object (the audio one). Parse `ayahs[*].audio` to update audio URLs.

---

## Endpoint 3: Audio CDN (direct MP3 stream)

Audio files are served directly by the CDN. The `just_audio` player resolves these URLs at playback time — no explicit API call needed from app code.

```
https://cdn.islamic.network/quran/audio/128/{reciterEdition}/{globalAyahNumber}.mp3
```

**Example** (Al-Fatiha, ayah 1, Alafasy):
```
https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3
```

**Global ayah number**: The `number` field on each `AyahModel` (1–6236), not the `numberInSurah`.

**Quality**: `128` kbps is the default; the CDN also serves `64` kbps at `audio/64/`. Use 128 for this phase.

---

## Caching Contract

| Data | Cache mechanism | Key | TTL |
|---|---|---|---|
| Ayah text list | Hive (`ayahTextBox`) | `surah_text_{surahNumber}` | Permanent (Quran text never changes) |
| Audio URLs | Derived from cached `AyahModel.audioUrl` | — | Same as above |
| Reciter preference | SharedPreferences | `quran_selected_reciter` | Permanent |

**Audio files** are NOT cached locally — streamed on demand.

---

## Offline Behaviour

| Scenario | Response |
|---|---|
| Text already cached | Display from cache; no network call |
| Text not cached, offline | Show error: "لا يوجد اتصال بالإنترنت. لم يتم تحميل هذه السورة مسبقاً." with retry button |
| Audio offline | Show info banner: "يتطلب التشغيل اتصالاً بالإنترنت"; disable play button |
