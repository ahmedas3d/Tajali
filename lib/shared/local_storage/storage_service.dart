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

  Future<void> writeInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? readInt(String key) => _prefs.getInt(key);

  Future<void> writeDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? readDouble(String key) => _prefs.getDouble(key);

  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? readBool(String key) => _prefs.getBool(key);
}
