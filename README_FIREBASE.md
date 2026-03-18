# Configuration Firebase pour l'application

## 📋 Prérequis

1. **Créer un projet Firebase** :
   - Allez sur [Firebase Console](https://console.firebase.google.com/)
   - Créez un nouveau projet ou utilisez un projet existant

2. **Activer les services** :
   - **Authentication** → Email/Password
   - **Firestore Database** → Créer une base de données

## 🔧 Configuration

### 1. Obtenir les clés Firebase

Dans votre projet Firebase :
1. Cliquez sur **Paramètres du projet** (icône ⚙️)
2. Allez dans **Applications web**
3. Cliquez sur **"Créer une application"**
4. Copiez la configuration `firebaseConfig`

### 2. Mettre à jour `web/index.html`

Remplacez les valeurs de démonstration dans `web/index.html` :

```javascript
const firebaseConfig = {
  apiKey: "VOTRE_API_KEY",
  authDomain: "votre-projet.firebaseapp.com",
  projectId: "votre-id-projet",
  storageBucket: "votre-projet.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};
```

### 3. Configurer Firestore

Dans la console Firebase :
1. Allez dans **Firestore Database**
2. Créez une base de données en mode **test**
3. Créez la collection `users` avec les règles suivantes :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Configurer Authentication

1. Allez dans **Authentication**
2. Dans **"Méthode de connexion"**
3. Activez **Email/Mot de passe**
4. Configurez si nécessaire

## 🚀 Lancement

1. **Installez les dépendances** :
   ```bash
   flutter pub get
   ```

2. **Lancez l'application** :
   ```bash
   flutter run -d edge
   ```

3. **Comptes de test** :
   - 📧 `test@example.com` | 🔐 `123456` | 👤 `Utilisateur Test`
   - 📧 `demo@lst.com` | 🔐 `demo123` | 👤 `Demo LST`

## 📊 Structure des données

### Collection `users`

```javascript
{
  email: "user@example.com",
  name: "Nom Utilisateur",
  createdAt: timestamp,
  xp: 150,
  level: "Débutant",
  games_played: 5,
  last_game_score: 30
}
```

## 🎯 Fonctionnalités

- ✅ **Authentification** : Inscription et connexion
- ✅ **Base de données** : Stockage persistant des utilisateurs
- ✅ **XP dynamiques** : Mise à jour après chaque jeu
- ✅ **Statistiques** : Niveau, jeux joués, scores
- ✅ **Session** : Maintien de connexion

## 🔒 Sécurité

- Les mots de passe sont gérés par Firebase Auth
- Les données utilisateurs sont protégées par les règles Firestore
- Les sessions utilisent des tokens JWT

## 📝 Notes

- L'application utilise Firebase en mode **développement**
- Pour la production, configurez les règles de sécurité appropriées
- Les comptes de test sont créés automatiquement au premier lancement
