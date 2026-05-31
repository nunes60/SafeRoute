import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  const SessionService._();

  static const String _userIdKey = 'usuario_id';
  static const String _userEmailKey = 'usuario_email';

  static Future<void> saveUserSession({
    required int userId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<bool> hasSession() async {
    final userId = await getUserId();
    return userId != null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
  }
}
