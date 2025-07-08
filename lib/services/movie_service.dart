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
      final movies = await ApiClient.getRecentMovies<MovieApiModel>(
        limit: 1,
        fromJson: (json) => MovieApiModel.fromJson(json),
      );
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
    print('🎯 Endpoint: /api/radarr/movies/recent');

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

  /// Récupération des films récents
  static Future<List<MovieApiModel>> getRecentMovies({int limit = 10}) async {
    try {
      print('📥 Récupération des films récents (limite: $limit)...');

      final movies = await ApiClient.getRecentMovies<MovieApiModel>(
        limit: limit,
        fromJson: (json) => MovieApiModel.fromJson(json),
      );

      print('✅ ${movies.length} films récents récupérés avec succès');

      // Debug : afficher les titres
      if (movies.isNotEmpty) {
        print('🎬 Films récents récupérés:');
        for (var movie in movies.take(3)) {
          print('   - ${movie.title} (${movie.year}) - Note: ${movie.rating}');
        }
        if (movies.length > 3) {
          print('   ... et ${movies.length - 3} autres');
        }
      }

      return movies;
    } catch (e) {
      print('❌ Exception lors de la récupération des films récents: $e');
      return [];
    }
  }

  /// Récupération des films populaires
  static Future<List<MovieApiModel>> getPopularMovies({int limit = 10}) async {
    try {
      print('📥 Récupération des films populaires (limite: $limit)...');

      final movies = await ApiClient.getPopularMovies<MovieApiModel>(
        limit: limit,
        fromJson: (json) => MovieApiModel.fromJson(json),
      );

      print('✅ ${movies.length} films populaires récupérés avec succès');

      // Debug : afficher les titres
      if (movies.isNotEmpty) {
        print('🔥 Films populaires récupérés:');
        for (var movie in movies.take(3)) {
          print('   - ${movie.title} (${movie.year}) - Note: ${movie.rating}');
        }
        if (movies.length > 3) {
          print('   ... et ${movies.length - 3} autres');
        }
      }

      return movies;
    } catch (e) {
      print('❌ Exception lors de la récupération des films populaires: $e');
      return [];
    }
  }

  /// Récupération de tous les films
  static Future<List<MovieApiModel>> getAllMovies() async {
    try {
      print('📥 Récupération de tous les films...');

      final movies = await ApiClient.getAllMovies<MovieApiModel>(
        fromJson: (json) => MovieApiModel.fromJson(json),
      );

      print('✅ ${movies.length} films récupérés avec succès');
      return movies;
    } catch (e) {
      print('❌ Exception lors de la récupération de tous les films: $e');
      return [];
    }
  }

  /// Récupération d'un film par son ID
  static Future<MovieApiModel?> getMovieById(int movieId) async {
    try {
      print('📥 Récupération du film ID: $movieId...');

      final response = await ApiClient.getMovieById<MovieApiModel>(
        movieId,
        fromJson: (json) => MovieApiModel.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        final movie = response.data!;
        print('✅ Film récupéré: ${movie.title}');
        return movie;
      } else {
        print('❌ Erreur lors de la récupération du film: ${response.error}');
        return null;
      }
    } catch (e) {
      print('❌ Exception lors de la récupération du film: $e');
      return null;
    }
  }

  /// Récupérer les films du box office
  static Future<List<MovieApiModel>> getBoxOfficeMovies({
    int limit = 10,
  }) async {
    try {
      print('💰 Récupération des films box office via ApiClient...');

      final boxOfficeMovies = await ApiClient.getBoxOfficeMovies<MovieApiModel>(
        limit: limit,
        fromJson: (json) => MovieApiModel.fromJson(json),
      );

      // Filtrer le contenu NSFW
      final filteredMovies = boxOfficeMovies.where((movie) {
        final isNsfw = movie.tags.any(
          (tag) =>
              tag.toLowerCase().contains('nsfw') ||
              tag.toLowerCase().contains('adult') ||
              tag.toLowerCase().contains('porn'),
        );
        return !isNsfw;
      }).toList();

      print('📊 Résultats finaux box office:');
      print('   - Total récupéré: ${boxOfficeMovies.length}');
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
