import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tasbih_session_model.dart';
import '../models/tasbih_history_entry.dart';

class TasbihService {
  static const String sessionBoxName = 'tasbihSessionBox';
  static const String historyBoxName = 'tasbihHistoryBox';
  static const String _soundKey = 'tasbih_sound_enabled';
  static const String _vibrationKey = 'tasbih_vibration_enabled';
  static const String _customTargetsKey = 'tasbih_custom_targets';
  static const String _sessionKey = 'current';

  static const Map<String, int> defaultTargets = {
    'سبحان الله': 33,
    'الحمد لله': 33,
    'الله أكبر': 34,
  };

  // In-memory cache so getTargetFor() works synchronously after load
  final Map<String, int> _targetCache = {};

  Box<TasbihSessionModel> get _sessionBox =>
      Hive.box<TasbihSessionModel>(sessionBoxName);

  Box<TasbihHistoryEntry> get _historyBox =>
      Hive.box<TasbihHistoryEntry>(historyBoxName);

  // Call once at startup to populate _targetCache from SharedPreferences
  Future<void> loadCustomTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customTargetsKey) ?? '';
    if (raw.isEmpty) return;
    for (final part in raw.split(';')) {
      final kv = part.split(':');
      if (kv.length == 2) {
        final val = int.tryParse(kv[1]);
        if (val != null) _targetCache[kv[0]] = val;
      }
    }
  }

  int getTargetFor(String dhikrType) {
    return _targetCache[dhikrType] ?? defaultTargets[dhikrType] ?? 33;
  }

  TasbihSessionModel getOrCreateSession(String dhikrType) {
    final expectedTarget = getTargetFor(dhikrType);
    final existing = _sessionBox.get(_sessionKey);
    // Reuse existing session only when dhikrType AND target both match
    if (existing != null &&
        existing.dhikrType == dhikrType &&
        existing.target == expectedTarget) {
      return existing;
    }
    final session = TasbihSessionModel(
      dhikrType: dhikrType,
      currentCount: 0,
      completedRounds: 0,
      target: expectedTarget,
    );
    _sessionBox.put(_sessionKey, session);
    return session;
  }

  Future<TasbihSessionModel> tap(TasbihSessionModel session) async {
    final newCount = session.currentCount + 1;
    final roundCompleted = newCount >= session.target;
    final updated = TasbihSessionModel(
      dhikrType: session.dhikrType,
      currentCount: roundCompleted ? 0 : newCount,
      completedRounds: session.completedRounds + (roundCompleted ? 1 : 0),
      target: session.target,
    );
    await _sessionBox.put(_sessionKey, updated);
    return updated;
  }

  Future<TasbihSessionModel> reset(TasbihSessionModel session) async {
    final updated = TasbihSessionModel(
      dhikrType: session.dhikrType,
      currentCount: 0,
      completedRounds: 0,
      target: session.target,
    );
    await _sessionBox.put(_sessionKey, updated);
    return updated;
  }

  Future<void> logSession(TasbihSessionModel session) async {
    final total =
        (session.completedRounds * session.target) + session.currentCount;
    if (total == 0) return;
    final entry = TasbihHistoryEntry(
      dhikrType: session.dhikrType,
      totalCount: total,
      dateISO: DateTime.now().toIso8601String(),
    );
    await _historyBox.put(entry.dateISO, entry);
  }

  List<TasbihHistoryEntry> getHistory() {
    final entries = _historyBox.values.toList();
    entries.sort((a, b) => b.dateISO.compareTo(a.dateISO));
    return entries;
  }

  Future<void> setCustomTarget(String dhikrType, int target) async {
    // Update in-memory cache immediately so getTargetFor() reflects the change
    _targetCache[dhikrType] = target;
    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customTargetsKey) ?? '';
    final map = <String, String>{};
    if (raw.isNotEmpty) {
      for (final part in raw.split(';')) {
        final kv = part.split(':');
        if (kv.length == 2) map[kv[0]] = kv[1];
      }
    }
    map[dhikrType] = '$target';
    await prefs.setString(
      _customTargetsKey,
      map.entries.map((e) => '${e.key}:${e.value}').join(';'),
    );
  }

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  Future<void> setVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }
}
