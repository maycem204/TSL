import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Service d'authentification Firebase
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  static const String _userKey = 'user_data';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialiser Firebase
  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      
      // Créer les comptes de test s'ils n'existent pas
      await _createTestAccounts();
      
      if (kDebugMode) {
        print('🔥 Firebase initialisé avec succès');
        print('🔑 COMPTES DE TEST DISPONIBLES:');
        print('📧 test@example.com | 🔐 123456 | 👤 Utilisateur Test');
        print('📧 demo@lst.com | 🔐 demo123 | 👤 Demo LST');
        print('=====================================');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur d\'initialisation Firebase: $e');
      }
    }
  }

  // Créer les comptes de test dans Firebase
  Future<void> _createTestAccounts() async {
    try {
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

            if (kDebugMode) {
              print('✅ Compte test créé: ${user['email']}');
            }
          }
        } catch (e) {
          // L'utilisateur existe déjà, pas d'erreur
          if (kDebugMode) {
            print('ℹ️ Compte déjà existant: ${user['email']}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur création comptes test: $e');
      }
    }
  }

  // Connexion utilisateur
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
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
        
        // Sauvegarder la session localement
        final token = await userCredential.user!.getIdToken() ?? '';
        await saveSession(userData, token);

        return {
          'success': true,
          'message': 'Connexion réussie',
          'user': userData,
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
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sauvegarder les données utilisateur dans Firestore
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

      // Sauvegarder la session localement
      final token = await userCredential.user!.getIdToken() ?? '';
      await saveSession(userData, token);

      return {
        'success': true,
        'message': 'Inscription réussie',
        'user': userData,
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
    try {
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return {
          'success': true,
          'user': userDoc.docs.first.data(),
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
    try {
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

      final userRef = userDoc.docs.first.reference;
      final userData = userDoc.docs.first.data()!;

      // Mettre à jour les XP
      final currentXP = userData['xp'] as int;
      final newXP = currentXP + xpToAdd;
      final newLevel = _calculateLevel(newXP);

      await userRef.update({
        'xp': newXP,
        'level': newLevel,
        'games_played': FieldValue.increment(1),
        'last_game_score': xpToAdd,
      });

      // Récupérer les données mises à jour
      final updatedDoc = await userRef.get();
      final updatedData = updatedDoc.data()!;

      // Mettre à jour la session locale
      await saveSession(updatedData, await _auth.currentUser?.getIdToken() ?? '');

      return {
        'success': true,
        'message': 'XP ajoutés avec succès',
        'xp_added': xpToAdd,
        'total_xp': newXP,
        'level': newLevel,
        'user': updatedData,
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
    try {
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé',
        };
      }

      final userData = userDoc.docs.first.data()!;
      
      return {
        'success': true,
        'stats': {
          'total_xp': userData['xp'],
          'level': userData['level'],
          'games_played': userData['games_played'],
          'last_game_score': userData['last_game_score'],
          'avg_score': userData['games_played'] > 0 
            ? (userData['xp'] as int) / (userData['games_played'] as int)
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

  // Sauvegarder la session
  Future<void> saveSession(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
    await prefs.setString('auth_token', token);
  }

  // Récupérer la session
  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(userJson));
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

  // Afficher les comptes de test disponibles
  void printTestAccounts() {
    print('\n🔑 COMPTES DE TEST DISPONIBLES:');
    print('📧 test@example.com | 🔐 123456 | 👤 Utilisateur Test');
    print('📧 demo@lst.com | 🔐 demo123 | 👤 Demo LST');
    print('=====================================\n');
  }
}
