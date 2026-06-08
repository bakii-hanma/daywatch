import 'dart:convert';
import '../models/movie_model.dart';
import 'api_client.dart';

// ─── Helper interne ────────────────────────────────────────────────────────────
List<dynamic> _extractList(dynamic responseData) {
  if (responseData is List) return responseData;
  if (responseData is Map<String, dynamic>) {
    return responseData['data'] as List<dynamic>? ?? [];
  }
  return [];
}

void _logRoute(String route, int count, {String? extra}) {
  final suffix = extra != null ? ' | $extra' : '';
  print('🎬 [Films] $route → $count résultat(s)$suffix');
}

void _logError(String route, dynamic e) {
  print('❌ [Films] $route → Erreur: $e');
}

// ─── Parseur avec rapport d'erreurs ───────────────────────────────────────────
List<MovieApiModel> _parseMovies(
  List<dynamic> data,
  MovieApiModel Function(Map<String, dynamic>) factory,
  String route,
) {
  final movies = <MovieApiModel>[];
  for (int i = 0; i < data.length; i++) {
    try {
      movies.add(factory(data[i] as Map<String, dynamic>));
    } catch (e) {
      final title = (data[i] as Map?)?['title'] ?? '?';
      print('⚠️ [Films] $route → Parsing[$i] "$title" échoué: $e');
    }
  }
  return movies;
}

class MovieService {
  static List<MovieApiModel>? _cachedAllMovies;

  static void clearCache() {
    _cachedAllMovies = null;
  }

  static Future<List<MovieApiModel>> getOrFetchAllMovies() async {
    if (_cachedAllMovies != null && _cachedAllMovies!.isNotEmpty) {
      return _cachedAllMovies!;
    }
    _cachedAllMovies = await getAllMovies(limit: 1500);
    return _cachedAllMovies!;
  }

  // ── 1. GET /api/movies ──────────────────────────────────────────────────────
  static Future<List<MovieApiModel>> getAllMovies({int limit = 20}) async {
    const route = 'GET /api/movies';
    try {
      final response = await ApiClient.get<dynamic>('/api/movies?limit=$limit');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return [];
      }
      final raw = _extractList(response.data);
      final movies = _parseMovies(raw, MovieApiModel.fromJson, route);
      _logRoute(route, movies.length, extra: '${raw.length} bruts');
      return movies;
    } catch (e) {
      _logError(route, e);
      return [];
    }
  }

  // ── 2. GET /api/movies/:id ──────────────────────────────────────────────────
  static Future<MovieApiModel?> getMovieById(dynamic movieId) async {
    final route = 'GET /api/movies/$movieId';
    int attempt = 0;
    const maxRetries = 3;

    while (attempt < maxRetries) {
      attempt++;
      try {
        final response = await ApiClient.get<dynamic>('/api/movies/$movieId');
        if (!response.isSuccess || response.data == null) {
          _logRoute(route, 0, extra: 'réponse vide ou échec (tentative $attempt/$maxRetries)');
          if (attempt < maxRetries) {
            await Future.delayed(Duration(milliseconds: 1500 * attempt));
            continue;
          }
          return null;
        }

        print('🎬 [DEBUG STREAM] Réponse brute pour les détails du film ($movieId) (tentative $attempt) :');
        print(jsonEncode(response.data));

        dynamic movieData;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          movieData = map.containsKey('data') ? map['data'] : map;
        } else {
          movieData = response.data;
        }

        if (movieData == null) {
          _logRoute(route, 0, extra: 'data null après extraction');
          if (attempt < maxRetries) {
            await Future.delayed(Duration(milliseconds: 1500 * attempt));
            continue;
          }
          return null;
        }

        final movie = MovieApiModel.fromJson(movieData as Map<String, dynamic>);
        print('🎬 [Films] $route → "${movie.title}" (id=${movie.id}, tmdb=${movie.tmdbId})');
        return movie;
      } catch (e, stackTrace) {
        _logError('$route (tentative $attempt/$maxRetries)', e);
        print(stackTrace);
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 1500 * attempt));
        } else {
          return null;
        }
      }
    }
    return null;
  }

  static Future<MovieApiModel?> getMovieByTmdbId(int tmdbId) async {
    return getMovieById('tmdb_$tmdbId');
  }

  // ── 3. GET /api/movies/coming-soon ─────────────────────────────────────────
  static Future<List<MovieApiModel>> getComingSoonMovies({int limit = 10}) async {
    const route = 'GET /api/movies/coming-soon';
    try {
      final response = await ApiClient.get<dynamic>('/api/movies/coming-soon?limit=$limit');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return [];
      }
      final raw = _extractList(response.data);
      final movies = _parseMovies(raw, MovieApiModel.fromJson, route);
      _logRoute(route, movies.length, extra: '${raw.length} bruts');
      return movies;
    } catch (e) {
      _logError(route, e);
      return [];
    }
  }

  // ── 4. GET /api/movies/popular ──────────────────────────────────────────────
  static Future<List<MovieApiModel>> getPopularMovies({int limit = 10}) async {
    const route = 'GET /api/movies/popular';
    try {
      final response = await ApiClient.get<dynamic>('/api/movies/popular?limit=$limit');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return [];
      }
      final raw = _extractList(response.data);
      final movies = _parseMovies(raw, MovieApiModel.fromJson, route);
      _logRoute(route, movies.length, extra: '${raw.length} bruts');
      return movies;
    } catch (e) {
      _logError(route, e);
      return [];
    }
  }

  // ── 5. GET /api/movies/recent ───────────────────────────────────────────────
  // Format Radarr natif : images en tableau [{coverType, remoteUrl}]
  static Future<List<MovieApiModel>> getRecentMovies({int limit = 10}) async {
    const route = 'GET /api/movies/recent';
    try {
      final response = await ApiClient.get<dynamic>('/api/movies/recent?limit=$limit');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return [];
      }
      final raw = _extractList(response.data);
      final movies = _parseMovies(raw, MovieApiModel.fromRadarrJson, route);
      _logRoute(route, movies.length, extra: '${raw.length} bruts, format Radarr');
      return movies;
    } catch (e) {
      _logError(route, e);
      return [];
    }
  }

  // ── 6. GET /api/movies/recent-additions ────────────────────────────────────
  static Future<List<MovieApiModel>> getRecentAdditions({int limit = 10}) async {
    const route = 'GET /api/movies/recent-additions';
    try {
      final response = await ApiClient.get<dynamic>('/api/movies/recent-additions?limit=$limit');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return [];
      }
      final raw = _extractList(response.data);
      final movies = _parseMovies(raw, MovieApiModel.fromJson, route);
      _logRoute(route, movies.length, extra: '${raw.length} bruts');
      return movies;
    } catch (e) {
      _logError(route, e);
      return [];
    }
  }

  // ── 7. GET /api/movies/recent-additions/essentials ─────────────────────────
  static Future<List<MovieApiModel>> getRecentAdditionsEssentials({int limit = 10}) async {
    const route = 'GET /api/movies/recent-additions/essentials';
    try {
      final response = await ApiClient.get<dynamic>('/api/movies/recent-additions/essentials?limit=$limit');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return [];
      }
      final raw = _extractList(response.data);
      final movies = _parseMovies(raw, MovieApiModel.fromEssentialJson, route);
      _logRoute(route, movies.length, extra: '${raw.length} bruts');
      return movies;
    } catch (e) {
      _logError(route, e);
      return [];
    }
  }

  // ── 8. GET /api/movies/top-recommendations ─────────────────────────────────
  static Future<List<MovieApiModel>> getTopRecommendationsFull({int limit = 5}) async {
    const route = 'GET /api/movies/top-recommendations';
    try {
      final response = await ApiClient.get<dynamic>('/api/movies/top-recommendations?limit=$limit');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return [];
      }
      final raw = _extractList(response.data);
      final movies = _parseMovies(raw, MovieApiModel.fromJson, route);
      _logRoute(route, movies.length, extra: '${raw.length} bruts');
      return movies;
    } catch (e) {
      _logError(route, e);
      return [];
    }
  }

  // ── 9. GET /api/movies/top-recommendations/essentials ──────────────────────
  static Future<List<MovieApiModel>> getTopRecommendations({int limit = 5}) async {
    const route = 'GET /api/movies/top-recommendations/essentials';
    try {
      final response = await ApiClient.get<dynamic>('/api/movies/top-recommendations/essentials?limit=$limit');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return [];
      }
      final raw = _extractList(response.data);
      final movies = _parseMovies(raw, MovieApiModel.fromEssentialJson, route);
      _logRoute(route, movies.length, extra: '${raw.length} bruts');
      return movies;
    } catch (e) {
      _logError(route, e);
      return [];
    }
  }

  // ── Alias / utilitaires ────────────────────────────────────────────────────

  /// Box office = films populaires filtrés NSFW
  static Future<List<MovieApiModel>> getBoxOfficeMovies({int limit = 10}) async {
    final movies = await getPopularMovies(limit: limit);
    return movies.where((m) {
      return !m.tags.any((t) =>
          t.toLowerCase().contains('nsfw') ||
          t.toLowerCase().contains('adult') ||
          t.toLowerCase().contains('porn'));
    }).toList();
  }

  /// Formater les gains en $X.XB / $X.XM / $X.XK
  static String formatEarnings(int revenue) {
    if (revenue >= 1000000000) return '\$${(revenue / 1000000000).toStringAsFixed(1)}B';
    if (revenue >= 1000000) return '\$${(revenue / 1000000).toStringAsFixed(1)}M';
    if (revenue >= 1000) return '\$${(revenue / 1000).toStringAsFixed(1)}K';
    return '\$$revenue';
  }

  /// Test de connectivité
  static Future<bool> testConnection() async {
    try {
      final r = await ApiClient.get<dynamic>('/api/movies?limit=1');
      return r.isSuccess;
    } catch (_) {
      return false;
    }
  }

  // ── Méthodes d'enrichissement client pour le casting, la galerie et les vidéos ──

  static Future<MovieCast?> getMovieCredits(dynamic id) async {
    final route = 'GET /api/radarr/movies/$id/credits';
    try {
      final response = await ApiClient.get<dynamic>('/api/radarr/movies/$id/credits');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return null;
      }
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final normalized = {
          'cast': data['data'] ?? data['cast'] ?? [],
          'crew': data['crew'] ?? [],
        };
        return MovieCast.fromJson(normalized);
      }
      return null;
    } catch (e) {
      _logError(route, e);
      return null;
    }
  }

  static Future<MovieGallery?> getMovieImages(dynamic id) async {
    final route = 'GET /api/radarr/movies/$id/images';
    try {
      final response = await ApiClient.get<dynamic>('/api/radarr/movies/$id/images');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return null;
      }
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final galleryData = data['data'] ?? data;
        if (galleryData is Map<String, dynamic>) {
          return MovieGallery.fromJson(galleryData);
        }
      }
      return null;
    } catch (e) {
      _logError(route, e);
      return null;
    }
  }

  static Future<List<dynamic>?> getMovieVideos(dynamic id) async {
    final route = 'GET /api/radarr/movies/$id/videos';
    try {
      final response = await ApiClient.get<dynamic>('/api/radarr/movies/$id/videos');
      if (!response.isSuccess || response.data == null) {
        _logRoute(route, 0, extra: 'réponse vide ou échec');
        return null;
      }
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      _logError(route, e);
      return null;
    }
  }
}
