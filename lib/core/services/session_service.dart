import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userLastNameKey = 'user_last_name';
  static const String _userEmailKey = 'user_email';

  // ============================================================
  // GUARDAR SESIÓN
  // ============================================================

  Future<void> saveSession({
    required String token,
    required String userId,
    required String name,
    required String lastName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );

    await prefs.setString(
      _userIdKey,
      userId,
    );

    await prefs.setString(
      _userNameKey,
      name,
    );

    await prefs.setString(
      _userLastNameKey,
      lastName,
    );

    await prefs.setString(
      _userEmailKey,
      email,
    );
  }

  // ============================================================
  // TOKEN
  // ============================================================

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  // ============================================================
  // ID USUARIO
  // ============================================================

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userIdKey);
  }

  // ============================================================
  // NOMBRE
  // ============================================================

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userNameKey);
  }

  // ============================================================
  // APELLIDO
  // ============================================================

  Future<String?> getUserLastName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userLastNameKey);
  }

  // ============================================================
  // CORREO
  // ============================================================

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userEmailKey);
  }

  // ============================================================
  // SESIÓN ACTIVA
  // ============================================================

  Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userLastNameKey);
    await prefs.remove(_userEmailKey);
  }
}