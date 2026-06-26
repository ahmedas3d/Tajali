import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _methodKey = 'prayer_method_id';

  Future<int> getMethodId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_methodKey) ?? 0;
  }

  Future<void> saveMethodId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_methodKey, id);
  }
}
