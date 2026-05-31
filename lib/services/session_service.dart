import 'package:shared_preferences/shared_preferences.dart';

/// Agrupa os dados mínimos da sessão persistida localmente.
class SessionData {
  const SessionData({required this.userId, required this.email});

  final int userId;
  final String email;
}

/// Persiste e recupera a sessão do usuário no armazenamento local.
class SessionService {
  const SessionService._();

  static const String _userIdKey = 'usuario_id';
  static const String _userEmailKey = 'usuario_email';

  /// Salva os dados principais do usuário autenticado.
  static Future<void> saveUserSession({
    required int userId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email.trim());
  }

  /// Retorna apenas o identificador do usuário em sessão, se existir.
  static Future<int?> getUserId() async {
    return (await getCurrentSession())?.userId;
  }

  /// Retorna apenas o e-mail do usuário em sessão, se existir.
  static Future<String?> getUserEmail() async {
    return (await getCurrentSession())?.email;
  }

  /// Carrega a sessão atual validando os dados salvos localmente.
  static Future<SessionData?> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    final email = prefs.getString(_userEmailKey)?.trim() ?? '';

    if (userId == null || userId <= 0 || email.isEmpty) {
      return null;
    }

    return SessionData(userId: userId, email: email);
  }

  /// Indica se há uma sessão completa disponível no dispositivo.
  static Future<bool> hasSession() async {
    return (await getCurrentSession()) != null;
  }

  /// Remove os dados locais da sessão atual.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
  }
}
