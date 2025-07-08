# Gestion du Wakelock - DayWatch

## 📱 Problématique

Par défaut, les téléphones se mettent en veille automatiquement après quelques secondes/minutes d'inactivité. Pendant la lecture vidéo, cela interrompt l'expérience utilisateur qui doit réveiller l'écran en permanence.

## ⚡ Solution : Wakelock Plus

Nous utilisons le package `wakelock_plus` pour maintenir l'écran allumé **uniquement** pendant la lecture vidéo.

### 📦 Dépendance

```yaml
dependencies:
  wakelock_plus: ^1.2.8
```

## 🎬 Implémentation

### 1. Lecteur Plein Écran (`fullscreen_video_player.dart`)

#### ✅ Activation Automatique
```dart
@override
void initState() {
  // Activer le wakelock dès l'ouverture du plein écran
  WakelockPlus.enable();
  print('🔋 Wakelock activé - Écran maintenu allumé');
}
```

#### ❌ Désactivation Automatique
```dart
@override
void dispose() {
  // Désactiver le wakelock à la fermeture
  WakelockPlus.disable();
  print('🔋 Wakelock désactivé - Retour à la gestion normale');
}

void _exitFullscreen() {
  // Désactiver aussi au bouton retour
  WakelockPlus.disable();
  Navigator.pop(context);
}
```

### 2. Lecteur Intégré (`movie_detail_screen.dart`)

#### 🎥 Lecture Vidéo Normale
```dart
// Activation quand on lance la lecture
void _launchFullscreenPlayer() {
  WakelockPlus.enable();
  print('🔋 Wakelock activé - Lecture intégrée démarrée');
}

// Désactivation quand on arrête
void _stopChewiePlayer() {
  WakelockPlus.disable();
  print('🔋 Wakelock désactivé - Lecture intégrée arrêtée');
}
```

#### 🎬 Bandes-Annonces YouTube
```dart
// Activation pour YouTube
void _launchTrailer() {
  WakelockPlus.enable();
  print('🔋 Wakelock activé - Bande-annonce démarrée');
}

// Désactivation
void _stopYouTubePlayer() {
  WakelockPlus.disable();
  print('🔋 Wakelock désactivé - Bande-annonce arrêtée');
}
```

#### 🔄 Gestion du Plein Écran
```dart
void _openFullscreenPlayer() {
  // Désactiver temporairement (le plein écran gère son propre wakelock)
  WakelockPlus.disable();
  
  Navigator.push(context, FullscreenVideoPlayer(...))
    .then((returnedPosition) {
      if (returnedPosition != null) {
        // Réactiver si on revient avec lecture
        WakelockPlus.enable();
      }
    });
}
```

#### 🛡️ Sécurité - Nettoyage
```dart
@override
void dispose() {
  // S'assurer que le wakelock est désactivé en quittant l'écran
  if (_isPlayerVisible || _isTrailerVisible) {
    WakelockPlus.disable();
  }
}
```

## 🔍 Scenarios de Test

### ✅ Cas où le wakelock doit être ACTIF

1. **Lecteur plein écran ouvert**
   - ✅ Écran reste allumé pendant toute la durée
   - ✅ Vidéo ne s'interrompt pas

2. **Lecture intégrée active**
   - ✅ Écran reste allumé pendant la lecture
   - ✅ Interface reste visible

3. **Bande-annonce YouTube en cours**
   - ✅ Écran reste allumé pendant la BA
   - ✅ YouTube fonctionne normalement

### ❌ Cas où le wakelock doit être INACTIF

1. **Navigation normale dans l'app**
   - ❌ Écran se met en veille normalement
   - ❌ Économie de batterie respectée

2. **Lecture en pause**
   - ❌ Écran peut se mettre en veille
   - ❌ Pas de gaspillage d'énergie

3. **Sortie de l'application**
   - ❌ Wakelock complètement désactivé
   - ❌ Aucun impact sur les autres apps

## 🐛 Debug et Logs

Chaque activation/désactivation du wakelock produit un log :

```
🔋 Wakelock activé - Écran maintenu allumé
🔋 Wakelock désactivé - Retour à la gestion normale de l'écran
🔋 Wakelock activé - Lecture intégrée démarrée
🔋 Wakelock désactivé - Lecture intégrée arrêtée
🔋 Wakelock activé - Bande-annonce démarrée
🔋 Wakelock désactivé - Bande-annonce arrêtée
```

## ⚠️ Points d'Attention

1. **Toujours désactiver** : Chaque `enable()` doit avoir son `disable()` correspondant
2. **Gestion des erreurs** : Le wakelock est désactivé même en cas d'erreur via `dispose()`
3. **Transitions d'écran** : Gestion propre entre lecteur intégré ↔ plein écran
4. **Économie batterie** : Désactivation immédiate dès l'arrêt de la lecture

## 🚀 Avantages

✅ **Expérience utilisateur fluide** - Pas d'interruption pendant la vidéo
✅ **Économie d'énergie** - Activé uniquement quand nécessaire  
✅ **Gestion automatique** - L'utilisateur n'a rien à faire
✅ **Compatible multi-plateforme** - Android, iOS, Web, Desktop
✅ **Fallback sécurisé** - Désactivation automatique en cas de problème 