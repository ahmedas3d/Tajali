import 'package:just_audio/just_audio.dart';
import '../models/ayah_model.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  List<AyahModel> _ayahs = [];
  bool _repeatMode = false;
  bool _hasBasmala = false;

  // Raw player streams
  Stream<bool> get playingStream => _player.playingStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  bool get playing => _player.playing;

  // Display index (null = basmala is playing, else = 0-based ayah index)
  int? get displayIndex {
    final idx = _player.currentIndex;
    if (idx == null) return null;
    if (_hasBasmala && idx == 0) return null; // basmala slot
    return _hasBasmala ? idx - 1 : idx;
  }

  Stream<int?> get displayIndexStream =>
      _player.currentIndexStream.map((idx) {
        if (idx == null) return null;
        if (_hasBasmala && idx == 0) return null;
        return _hasBasmala ? idx - 1 : idx;
      });

  // ── Playback ─────────────────────────────────────────────────────────────────

  Future<void> play(
    List<AyahModel> ayahs, {
    int startIndex = 0,
    String? basmalUrl,
  }) async {
    _ayahs = ayahs;
    _hasBasmala = basmalUrl != null;
    _repeatMode = false;

    final children = <AudioSource>[
      if (basmalUrl != null) AudioSource.uri(Uri.parse(basmalUrl)),
      ...ayahs.map((a) {
        final url = (a.audioUrl != null && a.audioUrl!.isNotEmpty)
            ? a.audioUrl!
            : 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${a.number}.mp3';
        return AudioSource.uri(Uri.parse(url));
      }),
    ];

    if (children.isEmpty) return;

    // When basmala is prepended and user tapped an ayah, start from basmala
    // only if starting from the very beginning (index 0). Otherwise skip to ayah.
    final adjustedStart =
        _hasBasmala && startIndex == 0 ? 0 : startIndex + (_hasBasmala ? 1 : 0);

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: children),
      initialIndex: adjustedStart,
    );
    await _player.setLoopMode(LoopMode.off);
    await _player.play();
  }

  Future<void> playFromIndex(int ayahIndex) async {
    if (_repeatMode) {
      await _setRepeatOnIndex(ayahIndex);
    } else {
      final adjusted = ayahIndex + (_hasBasmala ? 1 : 0);
      await _player.seek(Duration.zero, index: adjusted);
      if (!_player.playing) await _player.play();
    }
  }

  Future<void> setRepeat(bool active, int ayahIndex) async {
    _repeatMode = active;
    if (active) {
      await _setRepeatOnIndex(ayahIndex);
    } else {
      await _player.setLoopMode(LoopMode.off);
      if (_ayahs.isNotEmpty) {
        await play(_ayahs, startIndex: ayahIndex);
      }
    }
  }

  Future<void> _setRepeatOnIndex(int ayahIndex) async {
    if (ayahIndex >= _ayahs.length) return;
    final ayah = _ayahs[ayahIndex];
    final url = (ayah.audioUrl != null && ayah.audioUrl!.isNotEmpty)
        ? ayah.audioUrl!
        : 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${ayah.number}.mp3';

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: [AudioSource.uri(Uri.parse(url))]),
    );
    await _player.setLoopMode(LoopMode.all);
    if (!_player.playing) await _player.play();
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();
  Future<void> stop() => _player.stop();

  bool get hasPrevious => (_player.currentIndex ?? 0) > (_hasBasmala ? 1 : 0);
  bool get hasNext => _player.hasNext;

  Future<void> seekToPrevious() async {
    if (hasPrevious) await _player.seekToPrevious();
  }

  Future<void> seekToNext() async {
    if (_player.hasNext) await _player.seekToNext();
  }

  void dispose() => _player.dispose();
}
