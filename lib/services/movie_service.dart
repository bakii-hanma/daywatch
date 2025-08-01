import '../models/movie_model.dart';
import 'api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/server_config.dart';

class MovieService {
  /// Test de connectivité avec l'API Radarr
  static Future<bool> testConnection() async {
    try {
      print('🔗 Test de connexion Radarr vers ${ApiClient.baseUrl}...');
      final movies = await getEssentialMovies(limit: 1);
      return movies.isNotEmpty;
    } catch (e) {
      print('❌ Erreur de connexion Radarr: $e');
      return false;
    }
  }

  /// Diagnostic réseau pour l'API Radarr
  static Future<void> diagnoseNetwork() async {
    print('\n🔍 === DIAGNOSTIC RÉSEAU RADARR ===');
    print('📍 URL de base: ${ApiClient.baseUrl}');
    print('🎯 Endpoint: /api/radarr/movies/essentials');

    try {
      final isConnected = await testConnection();
      print(
        isConnected ? '✅ Connectivité confirmée' : '❌ Test de connexion échoué',
      );
    } catch (e) {
      print('❌ Erreur lors du diagnostic: $e');
    }
    print('=== FIN DIAGNOSTIC ===\n');
  }

  /// Récupération des films essentiels (nouvelle route)
  static Future<List<MovieApiModel>> getEssentialMovies({
    int limit = 20,
  }) async {
    try {
      print('📥 Récupération des films essentiels (limite: $limit)...');

      final endpoint = '/api/radarr/movies/essentials?limit=$limit';
      final response = await ApiClient.get<dynamic>(endpoint);

      if (response.isSuccess && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> moviesData = responseData['data'] ?? [];

        final movies = moviesData
            .map((json) => MovieApiModel.fromEssentialJson(json))
            .toList();

        print('✅ ${movies.length} films essentiels récupérés avec succès');

        // Debug : afficher les titres
        if (movies.isNotEmpty) {
          print('🎬 Films essentiels récupérés:');
          for (var movie in movies.take(3)) {
            print(
              '   - ${movie.title} (${movie.year}) - Note: ${movie.rating}',
            );
          }
          if (movies.length > 3) {
            print('   ... et ${movies.length - 3} autres');
          }
        }

        return movies;
      } else {
        print(
          '❌ Erreur lors de la récupération des films essentiels: ${response.error}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Exception lors de la récupération des films essentiels: $e');
      return [];
    }
  }

  /// Récupération des films récents (alias pour getEssentialMovies)
  static Future<List<MovieApiModel>> getRecentMovies({int limit = 10}) async {
    return getEssentialMovies(limit: limit);
  }

  /// Récupération des films populaires (alias pour getEssentialMovies)
  static Future<List<MovieApiModel>> getPopularMovies({int limit = 10}) async {
    return getEssentialMovies(limit: limit);
  }

  /// Récupération de tous les films (alias pour getEssentialMovies)
  static Future<List<MovieApiModel>> getAllMovies() async {
    return getEssentialMovies(
      limit: 100,
    ); // Limite élevée pour récupérer tous les films
  }

  /// Récupération d'un film par son TMDB ID (nouvelle route)
  static Future<MovieApiModel?> getMovieByTmdbId(int tmdbId) async {
    try {
      print('📥 Récupération du film TMDB ID: $tmdbId...');

      final endpoint = '/api/radarr/movies/$tmdbId';
      final response = await ApiClient.get<dynamic>(endpoint);

      if (response.isSuccess && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final movieData = responseData['data'];

        if (movieData != null) {
          final movie = MovieApiModel.fromJson(movieData);
          print('✅ Film récupéré: ${movie.title}');
          return movie;
        } else {
          print('❌ Données de film non trouvées dans la réponse');
          return null;
        }
      } else {
        print('❌ Erreur lors de la récupération du film: ${response.error}');
        return null;
      }
    } catch (e) {
      print('❌ Exception lors de la récupération du film: $e');
      return null;
    }
  }

  /// Récupération d'un film par son ID (alias pour getMovieByTmdbId)
  static Future<MovieApiModel?> getMovieById(int movieId) async {
    return getMovieByTmdbId(movieId);
  }

  /// Récupérer les films du box office (utilise getEssentialMovies pour l'instant)
  static Future<List<MovieApiModel>> getBoxOfficeMovies({
    int limit = 10,
  }) async {
    try {
      print('💰 Récupération des films box office...');

      final movies = await getEssentialMovies(limit: limit);

      // Filtrer le contenu NSFW
      final filteredMovies = movies.where((movie) {
        final isNsfw = movie.tags.any(
          (tag) =>
              tag.toLowerCase().contains('nsfw') ||
              tag.toLowerCase().contains('adult') ||
              tag.toLowerCase().contains('porn'),
        );
        return !isNsfw;
      }).toList();

      print('📊 Résultats finaux box office:');
      print('   - Total récupéré: ${movies.length}');
      print('   - Après filtrage NSFW: ${filteredMovies.length}');
      for (final movie in filteredMovies.take(3)) {
        final earnings = movie.boxOffice != null
            ? formatEarnings(movie.boxOffice!.revenue)
            : 'N/A';
        print('   - ${movie.title} (${movie.year}) - Earnings: $earnings');
      }

      return filteredMovies;
    } catch (e) {
      print('❌ Erreur lors du chargement des films box office: $e');
      return [];
    }
  }

  /// Méthode utilitaire pour formater les gains
  static String formatEarnings(int revenue) {
    if (revenue >= 1000000000) {
      return '\$${(revenue / 1000000000).toStringAsFixed(1)}B';
    } else if (revenue >= 1000000) {
      return '\$${(revenue / 1000000).toStringAsFixed(1)}M';
    } else if (revenue >= 1000) {
      return '\$${(revenue / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$$revenue';
    }
  }
}
