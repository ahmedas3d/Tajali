import 'package:just_audio/just_audio.dart';

enum AdhanSound { makkah, egypt }

/// Plays the adhan when the app is in the foreground.
/// Fajr uses a dedicated recording that includes "الصلاة خير من النوم".
class AdhanAudioService {
  AdhanAudioService._();
  static final AdhanAudioService instance = AdhanAudioService._();

  static const _assets = {
    AdhanSound.makkah: (
      regular: 'assets/audio/adhan_regular.mp3',
      fajr:    'assets/audio/adhan_fajr.mp3',
    ),
    AdhanSound.egypt: (
      regular: 'assets/audio/adhan_egypt_regular.mp3',
      fajr:    'assets/audio/adhan_egypt_fajr.mp3',
    ),
  };

  final _player = AudioPlayer();

  bool get isPlaying => _player.playing;

  Future<void> play({bool isFajr = false, AdhanSound sound = AdhanSound.makkah}) async {
    try {
      final entry = _assets[sound]!;
      final asset = isFajr ? entry.fajr : entry.regular;
      await _player.stop();
      await _player.setAsset(asset);
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
