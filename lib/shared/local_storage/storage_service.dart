import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? read(String key) => _prefs.getString(key);
}
