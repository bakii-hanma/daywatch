# 📺 Intégration API IPTV - DAYWATCH

## 🚀 Vue d'ensemble

Cette documentation décrit l'intégration de l'API IPTV-ORG pour récupérer et afficher les chaînes TV françaises dans l'application DAYWATCH.

## 🛠️ Architecture

### Variables d'environnement (.env)
```env
API_BASE_URL=http://192.168.222.19:5000
IPTV_CHANNELS_ENDPOINT=/api/iptv-org/channels/french/only-with-streams
```

### Structure des fichiers
```
lib/
├── models/
│   └── tv_channel_model.dart       # Modèle de données pour les chaînes TV
├── services/
│   └── tv_channel_service.dart     # Service API pour récupérer les chaînes
├── screens/
│   ├── live_tv_screen.dart         # Page principale (8 chaînes)
│   └── tv_channels_screen.dart     # Page complète avec filtres
└── widgets/common/
    └── tv_channel_card.dart        # Widget de carte de chaîne
```

## 🔧 Fonctionnalités implémentées

### 1. **Service API** (`TvChannelService`)
- ✅ Récupération de toutes les chaînes françaises
- ✅ Limitation à 8 chaînes pour la page d'accueil
- ✅ Filtrage par catégories
- ✅ Mapping des catégories API vers filtres locaux
- ✅ Gestion des erreurs et fallbacks

### 2. **Modèle de données** (`TvChannelModel`)
- ✅ Parsing JSON depuis l'API
- ✅ Propriétés : id, nom, catégorie, logo, URL, langues, etc.
- ✅ Méthodes de sérialisation

### 3. **Interface utilisateur**

#### Page d'accueil (`LiveTvScreen`)
- ✅ Affichage de 8 chaînes populaires
- ✅ Indicateur de chargement
- ✅ Navigation vers la page complète
- ✅ Support des logos d'API et locaux

#### Page complète (`TvChannelsScreen`)
- ✅ Affichage de toutes les chaînes disponibles
- ✅ Filtres par catégories dynamiques
- ✅ Grille responsive (2 colonnes)
- ✅ Compteur de chaînes
- ✅ Indicateur "EN DIRECT"

### 4. **Widget de chaîne** (`TvChannelCard`)
- ✅ Support des deux sources (API + local)
- ✅ Affichage du logo depuis l'API ou assets locaux
- ✅ Badge "EN DIRECT" avec indicateur visuel
- ✅ Catégorie dynamique
- ✅ Gestion d'erreur pour les images réseau

## 🔄 Flux de données

```mermaid
graph TD
    A[Application Start] --> B[Load .env]
    B --> C[Initialize dotenv]
    C --> D[LiveTvScreen]
    D --> E[TvChannelService.getHomeChannels(8)]
    E --> F[API Call]
    F --> G[Parse JSON]
    G --> H[Filter NSFW]
    H --> I[Display 8 channels]
    
    J[TvChannelsScreen] --> K[TvChannelService.getAllChannels()]
    K --> L[API Call]
    L --> M[Parse JSON]
    M --> N[Apply category filter]
    N --> O[Display filtered channels]
```

## 📱 Utilisation

### Page d'accueil
1. L'application charge automatiquement 8 chaînes populaires
2. Les chaînes s'affichent en mode horizontal scrollable
3. Clic sur "Voir plus" → Navigation vers la page complète

### Page des chaînes
1. Affichage de toutes les chaînes disponibles
2. Utilisation des filtres par catégorie en haut
3. Grille responsive avec 2 colonnes
4. Compteur dynamique du nombre de chaînes

### Filtres disponibles
- **Toutes** : Affiche toutes les chaînes
- **Généralistes** : Chaînes généralistes
- **Sport** : Chaînes sportives
- **Info** : Chaînes d'information
- **Divertissement** : Chaînes de divertissement
- **Cinéma** : Chaînes de films
- **Documentaires** : Chaînes documentaires

## 🛡️ Gestion d'erreur

### Fallbacks implémentés
1. **API indisponible** : Affichage d'un message d'erreur
2. **Image logo manquante** : Utilisation d'assets locaux
3. **Catégorie inconnue** : Mapping vers "Généraliste"
4. **Données malformées** : Valeurs par défaut

### Logs de débogage
```dart
print('Erreur TvChannelService: $e');
print('Erreur lors du chargement des chaînes: $e');
```

## 🧪 Tests

### Tests unitaires inclus
- ✅ Création de modèle depuis JSON
- ✅ Validation des variables d'environnement
- ✅ Tests de mapping des catégories

```bash
flutter test test/tv_channel_service_test.dart
```

## 🔐 Configuration

### Prérequis
1. **Serveur API** accessible à `http://192.168.222.19:5000`
2. **Endpoint** : `/api/iptv-org/channels/french/only-with-streams`
3. **Dépendances** :
   - `http: ^1.1.0`
   - `flutter_dotenv: ^5.1.0`

### Variables d'environnement
Créer un fichier `.env` à la racine du projet :
```env
API_BASE_URL=http://192.168.222.19:5000
IPTV_CHANNELS_ENDPOINT=/api/iptv-org/channels/french/only-with-streams
```

## 🚨 Notes importantes

1. **Sécurité** : Le fichier `.env` doit être ajouté au `.gitignore`
2. **Performance** : Les appels API sont mis en cache pour éviter les requêtes redondantes
3. **Offline** : L'app fonctionne avec des données par défaut si l'API est indisponible
4. **NSFW** : Le contenu pour adultes est automatiquement filtré

## 🔮 Améliorations futures

- [ ] Cache local des chaînes
- [ ] Mode hors ligne complet
- [ ] Favoris utilisateur
- [ ] Historique de visionnage
- [ ] Support des sous-titres
- [ ] Qualité vidéo adaptative 