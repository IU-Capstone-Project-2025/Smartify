import 'package:shared_preferences/shared_preferences.dart';

class ManageData {
  static final _storage = SharedPreferences.getInstance();

  static Future<bool> saveDataAsync(String name_var, String value) async {
    try {
      final storage = await _storage;
      storage.setString(name_var, value);
      return true;
    } catch (e) {
      return false;
    }
  }
  static Future<String> getDataAsync(String name_var) async {
    final storage = await _storage;
    return storage.getString(name_var) ?? "example@example.com";
  }
  static Future<bool> removeAllData() async {
    try {
      final storage = await _storage;
      await storage.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}