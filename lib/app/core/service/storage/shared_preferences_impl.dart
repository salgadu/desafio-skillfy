import 'package:desafio_skillfy/app/core/service/storage/i_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesImpl implements IStorage {
  late final SharedPreferences _sharedPreferences;

  SharedPreferencesImpl() {
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
  }

  @override
  Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _sharedPreferences.containsKey(key);
  }
}
