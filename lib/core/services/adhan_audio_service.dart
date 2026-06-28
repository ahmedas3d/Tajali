import 'package:just_audio/just_audio.dart';

/// Plays the Makkah adhan sound when the app is in the foreground.
/// Fajr uses a dedicated recording that includes "الصلاة خير من النوم".
class AdhanAudioService {
  AdhanAudioService._();
  static final AdhanAudioService instance = AdhanAudioService._();

  static const _fajrAsset    = 'assets/audio/adhan_fajr.mp3';
  static const _regularAsset = 'assets/audio/adhan_regular.mp3';

  final _player = AudioPlayer();

  bool get isPlaying => _player.playing;

  Future<void> play({bool isFajr = false}) async {
    try {
      await _player.stop();
      await _player.setAsset(isFajr ? _fajrAsset : _regularAsset);
      await _player.play();
    } catch (_) {
      // Silently swallow — audio failure must never crash the app.
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
