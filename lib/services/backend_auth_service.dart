import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service d'authentification qui communique avec le backend
class BackendAuthService {
  static final BackendAuthService _instance = BackendAuthService._internal();
  factory BackendAuthService() => _instance;
  BackendAuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Connexion utilisateur
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // En développement, on simule la connexion
      if (kDebugMode) {
        return await _simulateBackendLogin(email, password);
      }

      // En production, on ferait un vrai appel HTTP
      // final response = await http.post(
      //   Uri.parse('https://votre-backend.com/api/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'email': email, 'password': password}),
      // );
      // return jsonDecode(response.body);

      throw UnimplementedError('Backend non configuré pour la production');
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
        'error': 'LOGIN_FAILED',
      };
    }
  }

  // Inscription utilisateur
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      // En développement, on simule l'inscription
      if (kDebugMode) {
        return await _simulateBackendRegister(email, password, name);
      }

      // En production, on ferait un vrai appel HTTP
      throw UnimplementedError('Backend non configuré pour la production');
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur d\'inscription: ${e.toString()}',
        'error': 'REGISTER_FAILED',
      };
    }
  }

  // Récupérer le profil utilisateur
  Future<Map<String, dynamic>> getProfile(String email) async {
    try {
      // En développement, on simule la récupération du profil
      if (kDebugMode) {
        return await _simulateBackendProfile(email);
      }

      // En production, on ferait un vrai appel HTTP
      throw UnimplementedError('Backend non configuré pour la production');
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de profil: ${e.toString()}',
        'error': 'PROFILE_FAILED',
      };
    }
  }

  // Sauvegarder la session utilisateur
  Future<void> saveSession(Map<String, dynamic> user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // Récupérer la session utilisateur
  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null;
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Simulation du backend pour les tests
  Future<Map<String, dynamic>> _simulateBackendLogin(String email, String password) async {
    // Simuler un délai réseau
    await Future.delayed(Duration(milliseconds: 800 + (DateTime.now().millisecond % 500)));

    // Base de données utilisateurs simulée
    final users = {
      'test@example.com': {
        'id': '1',
        'email': 'test@example.com',
        'password': '123456',
        'name': 'Utilisateur Test',
        'createdAt': '2024-01-01',
        'xp': 150,
        'level': 'Débutant',
      },
      'demo@lst.com': {
        'id': '2',
        'email': 'demo@lst.com',
        'password': 'demo123',
        'name': 'Demo LST',
        'createdAt': '2024-01-15',
        'xp': 320,
        'level': 'Intermédiaire',
      },
    };

    final user = users[email];
    
    if (user == null) {
      return {
        'success': false,
        'message': 'Utilisateur non trouvé',
        'error': 'USER_NOT_FOUND',
      };
    }

    if (user['password'] != password) {
      return {
        'success': false,
        'message': 'Mot de passe incorrect',
        'error': 'INVALID_PASSWORD',
      };
    }

    // Retourner les infos utilisateur (sans le mot de passe)
    final userResponse = Map<String, dynamic>.from(user);
    userResponse.remove('password');
    
    return {
      'success': true,
      'message': 'Connexion réussie',
      'user': userResponse,
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  Future<Map<String, dynamic>> _simulateBackendRegister(String email, String password, String name) async {
    // Simuler un délai réseau
    await Future.delayed(Duration(milliseconds: 1000 + (DateTime.now().millisecond % 500)));

    // Simuler la vérification si l'utilisateur existe déjà
    if (email == 'test@example.com' || email == 'demo@lst.com') {
      return {
        'success': false,
        'message': 'Cet email est déjà utilisé',
        'error': 'EMAIL_ALREADY_EXISTS',
      };
    }

    // Créer le nouvel utilisateur
    final newUser = {
      'id': (DateTime.now().millisecondsSinceEpoch).toString(),
      'email': email,
      'name': name,
      'createdAt': DateTime.now().toIso8601String().split('T')[0],
      'xp': 0,
      'level': 'Débutant',
    };

    return {
      'success': true,
      'message': 'Inscription réussie',
      'user': newUser,
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  Future<Map<String, dynamic>> _simulateBackendProfile(String email) async {
    // Simuler un délai réseau
    await Future.delayed(Duration(milliseconds: 500 + (DateTime.now().millisecond % 300)));

    final users = {
      'test@example.com': {
        'id': '1',
        'email': 'test@example.com',
        'name': 'Utilisateur Test',
        'createdAt': '2024-01-01',
        'xp': 150,
        'level': 'Débutant',
      },
      'demo@lst.com': {
        'id': '2',
        'email': 'demo@lst.com',
        'name': 'Demo LST',
        'createdAt': '2024-01-15',
        'xp': 320,
        'level': 'Intermédiaire',
      },
    };

    final user = users[email];
    
    if (user == null) {
      return {
        'success': false,
        'message': 'Utilisateur non trouvé',
        'error': 'USER_NOT_FOUND',
      };
    }

    return {
      'success': true,
      'user': user,
    };
  }

  // Afficher les comptes de test disponibles
  void printTestAccounts() {
    if (kDebugMode) {
      print('\n🔑 COMPTES DE TEST DISPONIBLES:');
      print('📧 test@example.com | 🔐 123456 | 👤 Utilisateur Test');
      print('📧 demo@lst.com | 🔐 demo123 | 👤 Demo LST');
      print('=====================================\n');
    }
  }
}
