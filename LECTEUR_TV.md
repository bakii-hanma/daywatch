# Système de Lecteurs Vidéo DayWatch

## 🎬 Architecture Multi-Lecteurs

L'application DayWatch utilise **3 systèmes de lecture** différents selon le type de contenu :

### 1. **YouTube Player** (Bandes-annonces)
- **Usage** : Lecture des trailers YouTube
- **Package** : `youtube_player_flutter`
- **Plein écran** : **Natif YouTube** (pas de contrôles personnalisés)
- **Avantages** :
  - Contrôles YouTube intégrés
  - Gestion automatique de la qualité
  - Plein écran natif optimisé
  - Support des annotations YouTube

### 2. **Chewie Player** (Vidéos standards)  
- **Usage** : Films/séries MP4, WEBM
- **Package** : `chewie` + `video_player`
- **Plein écran** : **Contrôles personnalisés**
- **Formats supportés** : MP4, WEBM (limité)

### 3. **MediaKit Player** (Formats avancés)
- **Usage** : **Fallback automatique** quand Chewie échoue
- **Package** : `media_kit` + `media_kit_video`
- **Plein écran** : **Contrôles personnalisés**
- **Formats supportés** : **300+ formats** (AVI, MKV, FLV, TS, etc.)

## 🔄 Logique de Fallback Intelligente

```
📹 Fichier vidéo détecté
    ↓
🎯 Tentative Chewie (MP4, WEBM)
    ↓ (si échec)
🚀 Fallback MediaKit (300+ formats)
    ↓ (si échec)  
❌ Erreur finale
```

## 🎮 Gestion du Plein Écran

### YouTube Trailers
```dart
// ✅ Contrôles NATIFS YouTube
YoutubePlayerFlags(
  showLiveFullscreenButton: true,  // Plein écran YouTube
  useHybridComposition: true,      // Performance optimisée
)

// ❌ PAS de contrôles personnalisés
// YouTube gère tout automatiquement
```

### Vidéos Films/Séries  
```dart
// ✅ Contrôles PERSONNALISÉS
if (_isVideoInitialized && 
    !_isTrailerVisible &&  // Pas si YouTube actif
    (_chewieController != null || _isUsingMediaKit))
  _buildVideoControls(isDarkMode)  // Nos contrôles
```

## 🔋 Gestion du Wakelock

| Lecteur | Activation | Désactivation |
|---------|------------|---------------|
| **YouTube** | `_launchTrailer()` | `_stopYouTubePlayer()` |
| **Chewie** | `_launchFullscreenPlayer()` | `_stopChewiePlayer()` |
| **MediaKit** | `_initializeMediaKitPlayer()` | Dans `_stopChewiePlayer()` |

## 🎯 Expérience Utilisateur

### Bandes-annonces (YouTube)
1. Clic sur "Bande-annonce" → **YouTube Player**
2. Contrôles YouTube natifs (play, pause, plein écran, qualité)
3. Bouton "X" pour fermer
4. **Pas de navigation vers FullscreenVideoPlayer**

### Films/Séries (Fichiers locaux)
1. Clic sur "Regarder maintenant" → **Chewie** ou **MediaKit**  
2. Contrôles personnalisés (play, pause, plein écran)
3. Navigation vers `FullscreenVideoPlayer` pour le plein écran
4. Fallback automatique si format non supporté

## 🛠️ Configuration Optimale

### YouTube
```dart
YoutubePlayerFlags(
  autoPlay: true,
  mute: false,
  enableCaption: true,
  captionLanguage: 'fr',
  showLiveFullscreenButton: true,    // ✅ Plein écran natif
  useHybridComposition: true,        // ✅ Performance
)
```

### Chewie
```dart
ChewieController(
  autoPlay: true,
  looping: false,
  allowFullScreen: true,             // ✅ Nos contrôles
  allowMuting: true,
  showControlsOnInitialize: false,   // Interface clean
)
```

### MediaKit
```dart
Player() + VideoController()
// Support universel de formats
// Fallback transparent pour l'utilisateur
```

Cette architecture garantit la **meilleure expérience** selon le type de contenu tout en maximisant la **compatibilité des formats**. 