import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Service d'authentification Firebase sécurisé
class FirebaseAuthServiceSafe {
  static FirebaseAuthServiceSafe? _instance;
  static bool _isInitialized = false;
  static bool _isInitializing = false;
  
  // Instance différées - initialisées seulement après Firebase.initializeApp()
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  
  static const String _userKey = 'user_data';

  // Factory pattern avec initialisation sécurisée
  static Future<FirebaseAuthServiceSafe> getInstance() async {
    if (_instance == null) {
      _instance = FirebaseAuthServiceSafe._internal();
      await _instance!._initialize();
    }
    return _instance!;
  }
  
  // Constructeur privé
  FirebaseAuthServiceSafe._internal();
  
  // Initialisation sécurisée de Firebase
  Future<void> _initialize() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    
    try {
      // Initialiser Firebase avec configuration par défaut
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: _getFirebaseOptions(),
        );
      }
      
      // Maintenant on peut initialiser les instances Firebase
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      
      // Créer les comptes de test
      await _createTestAccounts();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('🔥 Firebase initialisé avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur d\'initialisation Firebase: $e');
      }
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }
  
  // Configuration Firebase pour Web
  FirebaseOptions _getFirebaseOptions() {
    // Pour le Web, on utilise la configuration depuis index.html
    // Firebase détecte automatiquement la configuration web
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyBsxg3BBVTj6ctvZ27S-JqmevjM90Ev7gA",
        authDomain: "tsl-p2m.firebaseapp.com",
        projectId: "tsl-p2m",
        storageBucket: "tsl-p2m.firebasestorage.app",
        messagingSenderId: "114371523579",
        appId: "1:114371523579:web:88cd1ee3966e6f0effd15e",
        measurementId: "G-YG4QPHXDCW"
      );
    }
    
    // Pour mobile, DefaultFirebaseOptions serait utilisé
    return const FirebaseOptions(
      apiKey: "AIzaSyBsxg3BBVTj6ctvZ27S-JqmevjM90Ev7gA",
      authDomain: "tsl-p2m.firebaseapp.com",
      projectId: "tsl-p2m",
      storageBucket: "tsl-p2m.firebasestorage.app",
      messagingSenderId: "114371523579",
      appId: "1:114371523579:web:88cd1ee3966e6f0effd15e",
      measurementId: "G-YG4QPHXDCW"
    );
  }
  
  // Vérifier si Firebase est prêt
  bool get isInitialized => _isInitialized;
  
  // Créer les comptes de test
  Future<void> _createTestAccounts() async {
    final testUsers = [
      {
        'email': 'test@example.com',
        'password': '123456',
        'name': 'Utilisateur Test',
        'xp': 150,
        'level': 'Débutant',
        'games_played': 0,
        'last_game_score': 0,
      },
      {
        'email': 'demo@lst.com',
        'password': 'demo123',
        'name': 'Demo LST',
        'xp': 320,
        'level': 'Intermédiaire',
        'games_played': 0,
        'last_game_score': 0,
      },
    ];

    for (final user in testUsers) {
      try {
        // Vérifier si l'utilisateur existe déjà
        final userDoc = await _firestore
            .collection('users')
            .where('email', isEqualTo: user['email'])
            .get();

        if (userDoc.docs.isEmpty) {
          // Créer l'utilisateur avec email/mot de passe
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: user['email'] as String,
            password: user['password'] as String,
          );

          // Sauvegarder les données supplémentaires dans Firestore
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': user['email'],
            'name': user['name'],
            'createdAt': FieldValue.serverTimestamp(),
            'xp': user['xp'],
            'level': user['level'],
            'games_played': user['games_played'],
            'last_game_score': user['last_game_score'],
          });
        }
      } catch (e) {
        // Ignorer les erreurs si les comptes existent déjà
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          // Compte existe déjà, c'est normal
        } else {
          if (kDebugMode) {
            print('⚠️ Compte ${user['email']} erreur: $e');
          }
        }
      }
    }
  }

  // Connexion utilisateur
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (!_isInitialized) {
      return {
        'success': false,
        'message': 'Firebase non initialisé',
        'error': 'FIREBASE_NOT_READY',
      };
    }
    
    try {
      await Future.delayed(Duration(milliseconds: 800));

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer les données utilisateur depuis Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        
        // Nettoyer les données Firebase avant de les sauvegarder
        final cleanData = _sanitizeFirebaseData(userData);
        
        // Sauvegarder la session localement
        final token = await userCredential.user!.getIdToken() ?? '';
        await saveSession(cleanData, token);

        return {
          'success': true,
          'message': 'Connexion réussie',
          'user': cleanData,
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé dans la base de données',
          'error': 'USER_NOT_FOUND',
        };
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur de connexion';
      if (e.code == 'user-not-found') {
        message = 'Utilisateur non trouvé';
      } else if (e.code == 'wrong-password') {
        message = 'Mot de passe incorrect';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide';
      }
      
      return {
        'success': false,
        'message': message,
        'error': e.code,
      };
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
    if (!_isInitialized) {
      return {
        'success': false,
        'message': 'Firebase non initialisé',
        'error': 'FIREBASE_NOT_READY',
      };
    }
    
    try {
      await Future.delayed(Duration(milliseconds: 1000));

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userData = {
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'xp': 0,
        'level': 'Débutant',
        'games_played': 0,
        'last_game_score': 0,
      };

      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);

      // Nettoyer les données avant de les sauvegarder
      final cleanData = _sanitizeFirebaseData(userData);

      // Sauvegarder la session localement
      final token = await userCredential.user!.getIdToken() ?? '';
      await saveSession(cleanData, token);

      return {
        'success': true,
        'message': 'Inscription réussie',
        'user': cleanData,
        'token': token,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur d\'inscription';
      if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible';
      } else if (e.code == 'email-already-in-use') {
        message = 'Cet email est déjà utilisé';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide';
      }
      
      return {
        'success': false,
        'message': message,
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur d\'inscription: ${e.toString()}',
        'error': 'REGISTRATION_FAILED',
      };
    }
  }

  // Récupérer le profil utilisateur
  Future<Map<String, dynamic>> getProfile(String email) async {
    if (!_isInitialized) {
      return {
        'success': false,
        'message': 'Firebase non initialisé',
        'error': 'FIREBASE_NOT_READY',
      };
    }
    
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data()!;
        final cleanData = _sanitizeFirebaseData(userData);
        return {
          'success': true,
          'user': cleanData,
        };
      } else {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé',
          'error': 'USER_NOT_FOUND',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
        'error': 'PROFILE_FAILED',
      };
    }
  }

  // Ajouter des XP à un utilisateur
  Future<Map<String, dynamic>> addXP(String email, int xpToAdd) async {
    if (!_isInitialized) {
      return {
        'success': false,
        'message': 'Firebase non initialisé',
        'error': 'FIREBASE_NOT_READY',
      };
    }
    
    try {
      await Future.delayed(Duration(milliseconds: 300));
      
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (userDoc.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé',
          'error': 'USER_NOT_FOUND',
        };
      }
      
      final userId = userDoc.docs.first.id;
      final currentData = userDoc.docs.first.data()!;
      
      final currentXP = currentData['xp'] as int;
      final newXP = currentXP + xpToAdd;
      final newLevel = _calculateLevel(newXP);
      
      await _firestore.collection('users').doc(userId).update({
        'xp': newXP,
        'level': newLevel,
        'games_played': (currentData['games_played'] as int) + 1,
        'last_game_score': xpToAdd,
      });
      
      final updatedDoc = await _firestore.collection('users').doc(userId).get();
      final updatedData = updatedDoc.data()!;
      
      // Nettoyer les données avant de les sauvegarder et retourner
      final cleanData = _sanitizeFirebaseData(updatedData);
      await saveSession(cleanData, await _auth.currentUser?.getIdToken() ?? '');
      
      return {
        'success': true,
        'message': 'XP ajoutés avec succès',
        'xp_added': xpToAdd,
        'total_xp': newXP,
        'level': newLevel,
        'user': cleanData,
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
  
  // Obtenir les statistiques de jeu
  Future<Map<String, dynamic>> getGameStats(String email) async {
    if (!_isInitialized) {
      return {
        'success': false,
        'message': 'Firebase non initialisé',
        'error': 'FIREBASE_NOT_READY',
      };
    }
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data()!;
        final cleanData = _sanitizeFirebaseData(userData);
        return {
          'success': true,
          'stats': {
            'total_xp': cleanData['xp'],
            'level': cleanData['level'],
            'games_played': cleanData['games_played'],
            'last_game_score': cleanData['last_game_score'],
            'avg_score': cleanData['games_played'] > 0 
              ? (cleanData['xp'] as int) / (cleanData['games_played'] as int)
              : 0,
          },
        };
      } else {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
      };
    }
  }

  // Transformer les objets Firebase en types simples pour JSON
  Map<String, dynamic> _sanitizeFirebaseData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is FieldValue) {
        // Ignorer les objets FieldValue
        return;
      } else if (value is Timestamp) {
        // Transformer Timestamp en String ISO 8601
        sanitized[key] = value.toDate().toIso8601String();
      } else if (value is Map<String, dynamic>) {
        // Récursivement nettoyer les objets imbriqués
        sanitized[key] = _sanitizeFirebaseData(value);
      } else if (value is List) {
        // Nettoyer les listes
        sanitized[key] = value.map((item) {
          if (item is Timestamp) {
            return item.toDate().toIso8601String();
          } else if (item is Map<String, dynamic>) {
            return _sanitizeFirebaseData(item);
          }
          return item;
        }).toList();
      } else {
        // Garder les autres valeurs telles quelles
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  // Sauvegarder la session utilisateur
  Future<void> saveSession(Map<String, dynamic> user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Nettoyer les données Firebase avant de les sauvegarder
    final safeUser = _sanitizeFirebaseData(user);
    
    await prefs.setString(_userKey, jsonEncode(safeUser));
    await prefs.setString('auth_token', token);
  }

  // Récupérer la session utilisateur
  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        return user;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null && _auth.currentUser != null;
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove('auth_token');
  }

  // Afficher les comptes de test disponibles (désactivé pour éviter le spam)
  void printTestAccounts() {
    // Plus d'affichage pour éviter le spam dans le terminal
  }
}
