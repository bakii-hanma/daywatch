# Utilisation des Séries avec les Routes API Standardisées

## Vue d'ensemble

Le service de récupération des séries de l'application mobile Flutter a été migré vers le nouveau contrôleur d'API standardisé sous le préfixe `/api/series`. Ce nouveau service remplace l'ancienne API Sonarr `/api/sonarr/series` par des routes plus spécifiques, optimisées et cohérentes.

---

## Les 18 Routes de l'API Séries

### 1. Liste complète et paginée (`GET /api/series`)
Retourne la liste complète de toutes les séries de la médiathèque.
* **Méthode Dart** : `SeriesService.getAllSeries({int limit = 2000, bool enrich = false})`
* **Retour** : `Future<List<SeriesApiModel>>`

### 2. Détails d'une série (`GET /api/series/:id`)
Retourne les détails complets d'une série spécifique par son ID local ou son TMDB ID au format `tmdb_XXXXX`.
* **Méthode Dart** : `SeriesService.getSeriesById(String seriesId)`
* **Retour** : `Future<SeriesApiModel?>`

### 3. Casting de la série (`GET /api/series/:id/credits`)
Retourne la liste des acteurs et membres de l'équipe (crew) pour une série spécifique.
* **Méthode Dart** : `SeriesService.getSeriesCredits(String seriesId, {int limit = 30})`
* **Retour** : `Future<MovieCast?>`

### 4. Tous les épisodes (`GET /api/series/:id/episodes`)
Retourne la liste complète des épisodes d'une série.
* **Méthode Dart** : `SeriesService.getSeriesEpisodes(String seriesId)` ou `SeriesService.getAllSeriesEpisodes(String seriesId)`
* **Retour** : `Future<List<EpisodeApiModel>>`

### 5. Épisodes avec fichiers (`GET /api/series/:id/episodes-with-files`)
Retourne la liste complète des épisodes avec les métadonnées de fichier vidéo (chemin, taille, qualité, streaming URL).
* **Méthode Dart** : `SeriesService.getSeriesEpisodesWithFiles(String seriesId, {bool enrich = true})`
* **Retour** : `Future<List<EpisodeApiModel>>`

### 6. Affiches et images (`GET /api/series/:id/images`)
Retourne la galerie complète des images (backdrops et posters) associées à la série sur TMDB.
* **Méthode Dart** : `SeriesService.getSeriesImages(String seriesId)`
* **Retour** : `Future<MovieGallery?>`

### 7. Liste des saisons (`GET /api/series/:id/seasons`)
Retourne la liste des saisons d'une série avec leurs statistiques de complétion et posters.
* **Méthode Dart** : `SeriesService.getSeriesSeasons(String seriesId)`
* **Retour** : `Future<List<Season>>`

### 8. Détail d'une saison (`GET /api/series/:id/seasons/:seasonNumber`)
Retourne les détails d'une saison spécifique, y compris les épisodes associés avec l'information de présence de fichier.
* **Méthode Dart** : `SeriesService.getSeasonDetail(String seriesId, int seasonNumber)`
* **Retour** : `Future<Map<String, dynamic>?>`

### 9. Bandes-annonces/Trailers (`GET /api/series/:id/videos`)
Retourne la liste des trailers et vidéos YouTube officiels associés à la série.
* **Méthode Dart** : `SeriesService.getSeriesVideos(String seriesId)`
* **Retour** : `Future<List<dynamic>>`

### 10. Animés japonais (`GET /api/series/anime`)
Retourne les animés japonais présents dans la médiathèque.
* **Méthode Dart** : `SeriesService.getAnimeSeries({int limit = 50})`
* **Retour** : `Future<List<SeriesApiModel>>`

### 11. Animés à venir (`GET /api/series/anime/upcoming`)
Retourne les animés japonais planifiés pour une diffusion prochaine.
* **Méthode Dart** : `SeriesService.getUpcomingAnimes({int limit = 30})`
* **Retour** : `Future<List<SeriesApiModel>>`

### 12. Séries coréennes (K-Drama) (`GET /api/series/k-drama`)
Retourne les K-Dramas coréens présents dans la médiathèque.
* **Méthode Dart** : `SeriesService.getKDramaSeries({int limit = 50})`
* **Retour** : `Future<List<SeriesApiModel>>`

### 13. Séries par plateforme (`GET /api/series/platforms/:platform`)
Retourne les séries disponibles filtrées par plateforme de streaming (Netflix, Disney+, Prime, etc.).
* **Méthode Dart** : `SeriesService.getSeriesByPlatform(String platform, {int limit = 100, bool includeUnavailable = false})`
* **Retour** : `Future<List<SeriesApiModel>>`

### 14. Séries populaires (`GET /api/series/popular`)
Retourne les séries populaires de la médiathèque triées par popularité.
* **Méthode Dart** : `SeriesService.getPopularSeries({int limit = 20})`
* **Retour** : `Future<List<SeriesApiModel>>`

### 15. Séries récemment ajoutées (`GET /api/series/recent`)
Retourne les séries récemment importées dans la médiathèque locale.
* **Méthode Dart** : `SeriesService.getRecentSeries({int limit = 20})`
* **Retour** : `Future<List<SeriesApiModel>>`

### 16. Séries recommandées (`GET /api/series/recommended`)
Retourne les recommandations personnalisées basées sur le profil de visionnage de l'utilisateur.
* **Méthode Dart** : `SeriesService.getRecommendedSeries({int limit = 20})`
* **Retour** : `Future<List<SeriesApiModel>>`

### 17. Statistiques des séries (`GET /api/series/stats`)
Retourne les statistiques générales du catalogue de séries (taille totale, nombre d'épisodes, progression, etc.).
* **Méthode Dart** : `SeriesService.getSeriesStats()`
* **Retour** : `Future<Map<String, dynamic>?>`

### 18. Séries à venir (`GET /api/series/upcoming`)
Retourne les séries occidentales dont la diffusion d'un épisode est prochaine.
* **Méthode Dart** : `SeriesService.getUpcomingSeries({int limit = 30})`
* **Retour** : `Future<List<SeriesApiModel>>`

---

## Modèles de Données

Les données reçues sont analysées et converties automatiquement en modèles Dart typés :

1. **`SeriesApiModel`** (défini dans [series_model.dart](file:///c:/Developpement/daywatch/lib/models/series_model.dart)) : Objet principal contenant les détails d'une série.
2. **`EpisodeApiModel`** : Objet détaillant un épisode avec ses métadonnées et caractéristiques de streaming.
3. **`Season`** : Représentation d'une saison pour l'affichage de la progression et de sa couverture.
4. **`MovieCast`** : Contient le casting (`cast` de type `List<CastMember>`) et l'équipe technique (`crew` de type `List<CrewMember>`).
5. **`MovieGallery`** : Contient la collection d'images associées sous forme de `List<GalleryImage>`.
