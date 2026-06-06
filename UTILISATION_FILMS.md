# Utilisation des Films avec les Routes API Standardisées

## Vue d'ensemble

Le service de récupération des films de l'application mobile Flutter a été migré vers le nouveau contrôleur d'API standardisé sous le préfixe `/api/movies`. Ce nouveau service remplace l'ancienne API Radarr `/api/radarr/movies` par des routes plus spécifiques, optimisées et cohérentes.

---

## Les 9 Routes de l'API Films

### 1. Liste complète et paginée (`GET /api/movies`)
Retourne la liste complète de tous les films de la médiathèque.
* **Méthode Dart** : `MovieService.getAllMovies()`
* **Retour** : `Future<List<MovieApiModel>>`

### 2. Détails d'un film (`GET /api/movies/:id`)
Retourne les détails complets d'un film spécifique en utilisant son identifiant numérique local (Radarr) ou son TMDB ID au format `tmdb_XXXXX`.
* **Méthode Dart** : `MovieService.getMovieById(dynamic id)` ou `MovieService.getMovieByTmdbId(int tmdbId)`
* **Retour** : `Future<MovieApiModel?>`

### 3. Films bientôt disponibles (`GET /api/movies/coming-soon`)
Retourne les films en cours d'attente ou annoncés qui sortiront bientôt.
* **Méthode Dart** : `MovieService.getComingSoonMovies()`
* **Retour** : `Future<List<MovieApiModel>>`

### 4. Films populaires (`GET /api/movies/popular`)
Retourne les films populaires de la médiathèque en se basant sur les scores TMDB.
* **Méthode Dart** : `MovieService.getPopularMovies({int limit = 10})`
* **Retour** : `Future<List<MovieApiModel>>`

### 5. Films récents (`GET /api/movies/recent`)
Retourne les films récemment ajoutés à la médiathèque physique locale.
* **Méthode Dart** : `MovieService.getRecentMovies({int limit = 10})`
* **Retour** : `Future<List<MovieApiModel>>`

### 6. Ajouts récents - Version étendue (`GET /api/movies/recent-additions`)
Retourne les ajouts récents de films avec des informations détaillées et complètes.
* **Méthode Dart** : `MovieService.getRecentAdditions({int limit = 10})`
* **Retour** : `Future<List<MovieApiModel>>`

### 7. Ajouts récents - Version allégée (`GET /api/movies/recent-additions/essentials`)
Retourne la version légère (champs essentiels uniquement) des films récemment ajoutés pour optimiser les performances de chargement.
* **Méthode Dart** : `MovieService.getRecentAdditionsEssentials({int limit = 10})`
* **Retour** : `Future<List<MovieApiModel>>`

### 8. Top Recommandations - Version étendue (`GET /api/movies/top-recommendations`)
Retourne le catalogue complet des recommandations personnalisées avec tous les détails.
* **Méthode Dart** : `MovieService.getTopRecommendationsFull({int limit = 5})`
* **Retour** : `Future<List<MovieApiModel>>`

### 9. Top Recommandations - Version allégée (`GET /api/movies/top-recommendations/essentials`)
Retourne une version légère des recommandations personnalisées pour la page d'accueil de l'application.
* **Méthode Dart** : `MovieService.getTopRecommendations({int limit = 5})`
* **Retour** : `Future<List<MovieApiModel>>`

---

## Modèles de Données

L'application Dart utilise deux méthodes de parsing selon les routes consommées :

1. **`MovieApiModel.fromJson(json)`**
   Pour les routes retournant la structure de données complète (ex: détails d'un film, films populaires, ajouts récents étendus). Elle inclut le cast, la galerie d'images, le box-office, et les métadonnées de fichier vidéo.

2. **`MovieApiModel.fromEssentialJson(json)`**
   Pour les routes retournant des informations allégées (ex: `essentials`). Elle extrait uniquement le titre, le poster, les genres et la disponibilité pour minimiser l'usage réseau.

---

## Compatibilité et Rétrocompatibilité

Pour assurer une transition sans encombre :
* L'ancienne méthode `getEssentialMovies()` est préservée et appelle de manière transparente `/api/movies`.
* Les méthodes existantes `getRecentMovies()`, `getPopularMovies()` et `getAllMovies()` ont été refactorées pour interroger directement les nouvelles routes d'API dédiées au lieu de simuler des alias.
* Les tests de connectivité (`testConnection()`) interrogent désormais la racine de l'API des films `/api/movies?limit=1`.