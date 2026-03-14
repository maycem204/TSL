import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPassword = 'user_password';
  static const String _keyUserXP = 'user_xp';

  // Sauvegarder l'état de connexion
  static Future<void> saveLoginState({
    required String userName,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserPassword, password);
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Obtenir les informations de l'utilisateur
  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyUserName) ?? 'Ahmed Ben Ali',
      'email': prefs.getString(_keyUserEmail) ?? 'ahmed.benali@example.com',
      'password': prefs.getString(_keyUserPassword) ?? '',
    };
  }

  // Alias pour getUserInfo (compatibilité)
  static Future<Map<String, String>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyUserName);
    final email = prefs.getString(_keyUserEmail);
    if (name == null && email == null) return null;
    
    return {
      'name': name ?? '',
      'email': email ?? '',
    };
  }

  // Mettre à jour les informations de l'utilisateur
  static Future<void> updateUserInfo({
    String? userName,
    String? email,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (userName != null) {
      await prefs.setString(_keyUserName, userName);
    }
    if (email != null) {
      await prefs.setString(_keyUserEmail, email);
    }
    if (password != null) {
      await prefs.setString(_keyUserPassword, password);
    }
  }

  // Sauvegarder les XP de l'utilisateur
  static Future<void> saveUserXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserXP, xp);
  }

  // Obtenir les XP de l'utilisateur
  static Future<int> getUserXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserXP) ?? 0;
  }

  // Se déconnecter
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPassword);
  }

  // Alias pour logout (compatibilité)
  static Future<void> clearUserData() async {
    await logout();
  }

  // Alias pour updateUserProfile (compatibilité)
  static Future<void> updateUserProfile({
    required String name,
    required String email,
  }) async {
    await updateUserInfo(userName: name, email: email);
  }
}
