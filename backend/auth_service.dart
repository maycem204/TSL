import 'dart:convert';
import 'dart:io';

// Service d'authentification backend simple pour les tests
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

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

  // Simuler une connexion HTTP
  Future<Map<String, dynamic>> _simulateHttpRequest(String method, String endpoint, Map<String, dynamic>? data) async {
    // Simuler un délai réseau
    await Future.delayed(Duration(milliseconds: 800 + (DateTime.now().millisecond % 500)));

    switch (endpoint) {
      case '/login':
        return _handleLogin(data!);
      case '/register':
        return _handleRegister(data!);
      case '/profile':
        return _handleProfile(data!['email']);
      default:
        throw Exception('Endpoint not found: $endpoint');
    }
  }

  // Gérer la connexion
  Map<String, dynamic> _handleLogin(Map<String, dynamic> data) {
    final email = data['email'] as String;
    final password = data['password'] as String;

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

  // Gérer l'inscription
  Map<String, dynamic> _handleRegister(Map<String, dynamic> data) {
    final email = data['email'] as String;
    final password = data['password'] as String;
    final name = data['name'] as String;

    // Vérifier si l'utilisateur existe déjà
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
    };

    _users[email] = newUser;

    // Retourner les infos utilisateur (sans le mot de passe)
    final userResponse = Map<String, dynamic>.from(newUser);
    userResponse.remove('password');

    return {
      'success': true,
      'message': 'Inscription réussie',
      'user': userResponse,
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Gérer la récupération du profil
  Map<String, dynamic> _handleProfile(String email) {
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

  // Méthodes publiques pour l'application
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _simulateHttpRequest('POST', '/login', {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
        'error': 'NETWORK_ERROR',
      };
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await _simulateHttpRequest('POST', '/register', {
        'email': email,
        'password': password,
        'name': name,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
        'error': 'NETWORK_ERROR',
      };
    }
  }

  Future<Map<String, dynamic>> getProfile(String email) async {
    try {
      final response = await _simulateHttpRequest('GET', '/profile', {
        'email': email,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
        'error': 'NETWORK_ERROR',
      };
    }
  }

  // Afficher les utilisateurs disponibles pour les tests
  void printAvailableUsers() {
    print('\n=== UTILISATEURS DISPONIBLES POUR LES TESTS ===');
    for (final entry in _users.entries) {
      final user = entry.value;
      print('Email: ${user['email']} | Mot de passe: ${user['password']} | Nom: ${user['name']}');
    }
    print('================================================\n');
  }
}

// Point d'entrée pour tester le backend
void main() {
  final authService = AuthService();
  
  print('🚀 Backend d\'authentification LST démarré');
  authService.printAvailableUsers();
  
  // Tests de connexion
  print('📝 Test 1: Connexion avec utilisateur valide');
  authService.login('test@example.com', '123456').then((result) {
    print('Résultat: ${result['success']} - ${result['message']}');
  });
  
  print('📝 Test 2: Connexion avec mot de passe incorrect');
  authService.login('test@example.com', 'wrong').then((result) {
    print('Résultat: ${result['success']} - ${result['message']}');
  });
  
  print('📝 Test 3: Connexion avec utilisateur inexistant');
  authService.login('nonexistent@test.com', '123456').then((result) {
    print('Résultat: ${result['success']} - ${result['message']}');
  });
}
