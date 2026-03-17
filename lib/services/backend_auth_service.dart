import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Service d'authentification qui communique avec le backend
class BackendAuthService {
  static final BackendAuthService _instance = BackendAuthService._internal();
  factory BackendAuthService() => _instance;
  BackendAuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Base de données utilisateurs simulée (en mémoire)
  final Map<String, Map<String, dynamic>> _users = {
    'test@example.com': {
      'id': '1',
      'email': 'test@example.com',
      'password': '123456',
      'name': 'Utilisateur Test',
      'createdAt': '2024-01-01',
      'xp': 150,
      'level': 'Débutant',
      'games_played': 0,
      'last_game_score': 0,
    },
    'demo@lst.com': {
      'id': '2',
      'email': 'demo@lst.com',
      'password': 'demo123',
      'name': 'Demo LST',
      'createdAt': '2024-01-15',
      'xp': 320,
      'level': 'Intermédiaire',
      'games_played': 0,
      'last_game_score': 0,
    },
  };

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

  // Ajouter des XP à un utilisateur
  Future<Map<String, dynamic>> addXP(String email, int xpToAdd) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      
      final user = _users[email];
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé',
          'error': 'USER_NOT_FOUND',
        };
      }
      
      // Mettre à jour les XP
      final currentXP = user['xp'] as int;
      final newXP = currentXP + xpToAdd;
      user['xp'] = newXP;
      user['games_played'] = (user['games_played'] as int) + 1;
      user['last_game_score'] = xpToAdd;
      
      // Mettre à jour le niveau selon les XP
      user['level'] = _calculateLevel(newXP);
      
      // Sauvegarder la session mise à jour
      final userResponse = Map<String, dynamic>.from(user);
      userResponse.remove('password');
      final token = await _getToken();
      if (token != null) {
        await saveSession(userResponse, token);
      }
      
      return {
        'success': true,
        'message': 'XP ajoutés avec succès',
        'xp_added': xpToAdd,
        'total_xp': newXP,
        'level': user['level'],
        'user': userResponse,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'ajout des XP: ${e.toString()}',
        'error': 'XP_UPDATE_FAILED',
      };
    }
  }
  
  // Calculer le niveau selon les XP
  String _calculateLevel(int xp) {
    if (xp < 100) return 'Débutant';
    if (xp < 300) return 'Intermédiaire';
    if (xp < 600) return 'Avancé';
    if (xp < 1000) return 'Expert';
    return 'Maître';
  }
  
  // Récupérer le token sauvegardé
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Obtenir les statistiques de jeu
  Future<Map<String, dynamic>> getGameStats(String email) async {
    try {
      final user = _users[email];
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé',
        };
      }
      
      return {
        'success': true,
        'stats': {
          'total_xp': user['xp'],
          'level': user['level'],
          'games_played': user['games_played'],
          'last_game_score': user['last_game_score'],
          'avg_score': user['games_played'] > 0 
            ? (user['xp'] as int) / (user['games_played'] as int)
            : 0,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
      };
    }
  }
  // Simulation du backend pour les tests
  Future<Map<String, dynamic>> _simulateBackendLogin(String email, String password) async {
    // Simuler un délai réseau
    await Future.delayed(Duration(milliseconds: 800 + (DateTime.now().millisecond % 500)));

    final user = _users[email];
    
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
    if (_users.containsKey(email)) {
      return {
        'success': false,
        'message': 'Cet email est déjà utilisé',
        'error': 'EMAIL_ALREADY_EXISTS',
      };
    }

    // Créer le nouvel utilisateur
    final newUser = {
      'id': (_users.length + 1).toString(),
      'email': email,
      'password': password,
      'name': name,
      'createdAt': DateTime.now().toIso8601String().split('T')[0],
      'xp': 0,
      'level': 'Débutant',
      'games_played': 0,
      'last_game_score': 0,
    };
    
    _users[email] = newUser;

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

    final user = _users[email];
    
    if (user == null) {
      return {
        'success': false,
        'message': 'Utilisateur non trouvé',
        'error': 'USER_NOT_FOUND',
      };
    }

    // Retourner les infos utilisateur (sans le mot de passe)
    final userResponse = Map<String, dynamic>.from(user);
    userResponse.remove('password');

    return {
      'success': true,
      'user': userResponse,
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
