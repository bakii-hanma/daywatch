# Configuration des Serveurs DayWatch

## 📍 Fichier de Configuration

Le fichier `lib/config/server_config.dart` centralise toutes les URLs des serveurs utilisés par l'application.

## 🔧 Modification des Adresses IP

Pour changer les adresses IP des serveurs, modifiez uniquement les constantes dans `ServerConfig` :

```dart
class ServerConfig {
  // ====== SERVEUR API (Radarr, Sonarr, Trailers) ======
  static const String apiBaseUrl = 'http://192.168.137.111:5000';
  
  // ====== SERVEUR DE FILMS/STREAMING ======
  static const String streamingBaseUrl = 'http://192.168.222.19';
}
```

## 🌐 Serveurs Configurés

### 1. Serveur API (`apiBaseUrl`)
- **Utilisation** : Communication avec Radarr, Sonarr, et API des trailers
- **Par défaut** : `http://192.168.137.111:5000`
- **Endpoints** :
  - `/api/radarr/movies/*` (Films)
  - `/api/sonarr/series/*` (Séries)
  - `/api/trailers/*` (Bandes-annonces)

### 2. Serveur de Streaming (`streamingBaseUrl`)
- **Utilisation** : Lecture directe des fichiers vidéo
- **Par défaut** : `http://192.168.222.19`
- **Contenu** : Fichiers vidéo (MP4, AVI, MKV, etc.)

## ⚙️ Méthodes Utilitaires

```dart
// Générer une URL complète pour le streaming
String videoUrl = ServerConfig.getStreamingUrl('/movies/example.mp4');
// Résultat: 'http://192.168.222.19/movies/example.mp4'

// Générer une URL complète pour l'API
String apiUrl = ServerConfig.getApiUrl('/api/radarr/movies');
// Résultat: 'http://192.168.137.111:5000/api/radarr/movies'
```

## 🔍 Debug et Tests

```dart
// Afficher la configuration actuelle
ServerConfig.printConfig();

// Vérifier si la configuration est valide
if (ServerConfig.isConfigValid) {
  print('Configuration OK');
}

// URLs de test
String apiTest = ServerConfig.apiTestUrl;
String streamTest = ServerConfig.streamingTestUrl;
```

## 📂 Fichiers Modifiés

Cette configuration centralisée est utilisée dans :

- `lib/services/api_client.dart` - Client API principal
- `lib/services/tv_channel_service.dart` - Service chaînes TV
- `lib/screens/movie_detail_screen.dart` - Lecture vidéo
- `lib/screens/home_screen.dart` - Messages d'erreur
- `lib/screens/movies_screen.dart` - Messages d'erreur

## 🚀 Avantages

✅ **Centralisation** : Une seule modification pour changer toutes les URLs
✅ **Maintenance** : Plus facile de gérer différents environnements
✅ **Debug** : Messages d'erreur avec les bonnes IPs
✅ **Flexibilité** : Méthodes utilitaires pour construire les URLs

## ⚠️ Important

- Redémarrez l'application après avoir modifié les URLs
- Vérifiez que les serveurs sont accessibles depuis votre réseau WiFi
- Les deux serveurs peuvent être sur des machines différentes 