import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalIdentity {
  static const _keyUserId = 'local_user_id';
  static const _keyUserName = 'local_user_name';

  static Future<String> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyUserId);
    if (saved != null && saved.isNotEmpty) return saved;

    final id = const Uuid().v4();
    await prefs.setString(_keyUserId, id);
    return id;
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'PixpleUser';
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name.trim());
  }
}
