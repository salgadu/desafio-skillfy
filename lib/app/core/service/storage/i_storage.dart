abstract class IStorage {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}
