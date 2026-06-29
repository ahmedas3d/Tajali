import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

class TasbihAudioService {
  AudioPlayer? _tapPlayer;
  AudioPlayer? _completePlayer;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _tapPlayer = AudioPlayer();
      _completePlayer = AudioPlayer();
      await _tapPlayer!.setAsset('assets/audio/tasbih_tap.mp3');
      await _completePlayer!.setAsset('assets/audio/tasbih_complete.mp3');
      _initialized = true;
    } catch (e) {
      debugPrint('TasbihAudioService: audio init failed: $e');
    }
  }

  Future<void> playTap() async {
    try {
      await _tapPlayer?.seek(Duration.zero);
      _tapPlayer?.play().ignore();
    } catch (_) {}
  }

  Future<void> playRoundComplete() async {
    try {
      await _completePlayer?.seek(Duration.zero);
      _completePlayer?.play().ignore();
    } catch (_) {}
  }

  Future<void> vibrateTap() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        await Vibration.vibrate(duration: 30);
      }
    } catch (_) {}
  }

  Future<void> vibrateRoundComplete() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        await Vibration.vibrate(pattern: [0, 100, 50, 100]);
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _tapPlayer?.dispose();
    await _completePlayer?.dispose();
    _tapPlayer = null;
    _completePlayer = null;
    _initialized = false;
  }
}
