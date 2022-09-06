import 'package:shared_preferences/shared_preferences.dart';

class PersistentStorageManager {
  void setString(String key, String? value) async {
    SharedPreferences _storage = await SharedPreferences.getInstance();
    _storage.setString(key, value!);
  }

  void setInt(String key, int value) async {
    SharedPreferences _storage = await SharedPreferences.getInstance();
    _storage.setInt(key, value);
  }

  Future<String?> getString(String key) async {
    SharedPreferences _storage = await SharedPreferences.getInstance();
    return _storage.getString(key);
  }

  Future<int?> getInt(String key) async {
    SharedPreferences _storage = await SharedPreferences.getInstance();
    return _storage.getInt(key);
  }

  Future<bool> containsKey(String key) async {
    SharedPreferences _storage = await SharedPreferences.getInstance();
    return _storage.containsKey(key);
  }

  void remove(String key) async {
    SharedPreferences _storage = await SharedPreferences.getInstance();
    _storage.remove(key);
  }
}
