# Utilisation des Films avec Nouvelles Routes API

## Vue d'ensemble

Le système a été mis à jour pour utiliser les nouvelles routes API pour les films :
- **Route essentielle** : `GET /api/radarr/movies/essentials` - Pour la liste des films
- **Route détaillée** : `GET /api/radarr/movies/{tmdbId}` - Pour les détails d'un film

## Nouvelles Routes API

### 1. Films Essentiels (`/api/radarr/movies/essentials`)

Cette route retourne une liste de films avec les données essentielles :

```json
{
  "success": true,
  "message": "Films avec données essentielles récupérés",
  "count": 8,
  "data": [
    {
      "id": 4,
      "tmdbId": 24428,
      "title": "The Avengers",
      "originalTitle": "The Avengers",
      "rating": 7.772,
      "poster": "https://image.tmdb.org/t/p/original/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg",
      "runtime": "2h 23",
      "releaseDate": "25 avril 2012",
      "genres": ["Science Fiction", "Action", "Adventure"],
      "isAvailable": true
    }
  ]
}
```

### 2. Détails d'un Film (`/api/radarr/movies/{tmdbId}`)

Cette route retourne les détails complets d'un film :

```json
{
  "success": true,
  "message": "Film trouvé avec succès",
  "data": {
    "id": "tmdb_24428",
    "tmdbId": 24428,
    "title": "Avengers",
    "originalTitle": "The Avengers",
    "overview": "Lorsque la sécurité et l'équilibre de la planète...",
    "year": 2012,
    "rating": 7.772,
    "runtime": 145,
    "budget": 220000000,
    "revenue": 1518815515,
    "isAvailable": false,
    "images": {
      "poster": "https://image.tmdb.org/t/p/w500/ylsAO88v2tF0iXRFojPa0UaAJf1.jpg",
      "backdrop": "https://image.tmdb.org/t/p/w500/9BBTo63ANSmhC4e6r62OJFuK2GL.jpg"
    },
    "genres": [
      {"id": 878, "name": "Science-Fiction"},
      {"id": 28, "name": "Action"}
    ],
    "videos": [...],
    "trailers": [...],
    "cast": {...},
    "gallery": {...},
    "boxOffice": {...}
  }
}
```

## Utilisation dans le Code

### Récupération des Films Essentiels

```dart
// Récupérer les films essentiels
final movies = await MovieService.getEssentialMovies(limit: 20);

// Ou utiliser les alias existants
final recentMovies = await MovieService.getRecentMovies(limit: 10);
final popularMovies = await MovieService.getPopularMovies(limit: 10);
final allMovies = await MovieService.getAllMovies();
```

### Récupération des Détails d'un Film

```dart
// Récupérer les détails d'un film par son TMDB ID
final movieDetails = await MovieService.getMovieByTmdbId(24428);

// Ou utiliser l'alias existant
final movieDetails = await MovieService.getMovieById(24428);
```

## Modèles de Données

### MovieApiModel.fromEssentialJson()

Cette méthode parse les données essentielles et extrait automatiquement :
- **Année** : depuis `releaseDate` (ex: "25 avril 2012" → 2012)
- **Durée** : depuis `runtime` (ex: "2h 23" → 143 minutes)
- **Genres** : liste des genres
- **Poster** : URL du poster
- **Disponibilité** : statut `isAvailable`

### MovieApiModel.fromJson()

Cette méthode parse les données complètes avec :
- Toutes les informations détaillées
- Cast et équipe
- Galerie d'images
- Bandes-annonces
- Données box office
- Métadonnées techniques

## Migration

Les anciennes méthodes continuent de fonctionner comme des alias :
- `getRecentMovies()` → `getEssentialMovies()`
- `getPopularMovies()` → `getEssentialMovies()`
- `getAllMovies()` → `getEssentialMovies(limit: 100)`
- `getMovieById()` → `getMovieByTmdbId()`

## Avantages des Nouvelles Routes

1. **Performance** : Les données essentielles sont plus légères
2. **Flexibilité** : Séparation entre liste et détails
3. **Enrichissement** : Données TMDB complètes pour les détails
4. **Compatibilité** : Les anciens appels continuent de fonctionner

## Exemple d'Utilisation Complète

```dart
class MovieScreen extends StatefulWidget {
  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  List<MovieApiModel> movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final essentialMovies = await MovieService.getEssentialMovies(limit: 20);
      setState(() {
        movies = essentialMovies;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des films: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMovieDetails(int tmdbId) async {
    try {
      final movieDetails = await MovieService.getMovieByTmdbId(tmdbId);
      if (movieDetails != null) {
        // Naviguer vers l'écran de détails
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movieDetails),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors du chargement des détails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(
          movie: movie,
          onTap: () => _loadMovieDetails(movie.tmdbId),
        );
      },
    );
  }
}
```

## Notes Importantes

1. **TMDB ID** : Les nouvelles routes utilisent le TMDB ID comme identifiant principal
2. **Données Essentielles** : Contiennent uniquement les informations de base pour les listes
3. **Données Complètes** : Disponibles uniquement via la route de détails
4. **Rétrocompatibilité** : Tous les anciens appels continuent de fonctionner
5. **Performance** : Les listes sont plus rapides grâce aux données essentielles 