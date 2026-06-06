import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_storage_service.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';

class DownloadService {
  static const String _keyDownloadedMovies = 'downloaded_movies_list';
  static const String _keyDownloadedSeries = 'downloaded_series_list';

  /// Vérifie si l'utilisateur est autorisé à télécharger selon son plan d'abonnement
  static Future<bool> canDownload() async {
    try {
      final userData = await UserStorageService.getUserData();
      if (userData == null) return false;

      // Accéder à la configuration du plan d'abonnement
      final plan = userData['plan'];
      if (plan != null && plan['features'] != null) {
        return plan['features']['allowDownloads'] == true;
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification de l\'autorisation de téléchargement: $e');
    }
    return false;
  }

  /// Récupère la liste des films téléchargés localement
  static Future<List<MovieApiModel>> getDownloadedMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyDownloadedMovies);
      if (jsonStr != null) {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((json) => MovieApiModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des films téléchargés: $e');
    }
    return [];
  }

  /// Récupère la liste des séries téléchargées localement
  static Future<List<SeriesApiModel>> getDownloadedSeries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyDownloadedSeries);
      if (jsonStr != null) {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((json) => SeriesApiModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des séries téléchargées: $e');
    }
    return [];
  }

  /// Ajoute un film aux téléchargements locaux
  static Future<bool> downloadMovie(MovieApiModel movie) async {
    try {
      if (!await canDownload()) {
        print('🚫 Le plan actuel de l\'utilisateur ne permet pas le téléchargement.');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final List<MovieApiModel> current = await getDownloadedMovies();
      
      // Éviter les doublons
      if (current.any((m) => m.id == movie.id)) {
        return true;
      }

      // Simuler le téléchargement en ajoutant le flag downloaded = true
      final movieMap = movie.toJson();
      movieMap['downloaded'] = true;
      final enrichedMovie = MovieApiModel.fromJson(movieMap);

      current.add(enrichedMovie);
      
      final String jsonStr = jsonEncode(current.map((m) => m.toJson()).toList());
      await prefs.setString(_keyDownloadedMovies, jsonStr);
      return true;
    } catch (e) {
      print('❌ Erreur lors du téléchargement du film: $e');
      return false;
    }
  }

  /// Ajoute une série aux téléchargements locaux
  static Future<bool> downloadSeries(SeriesApiModel series) async {
    try {
      if (!await canDownload()) {
        print('🚫 Le plan actuel de l\'utilisateur ne permet pas le téléchargement.');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final List<SeriesApiModel> current = await getDownloadedSeries();

      // Éviter les doublons
      if (current.any((s) => s.id == series.id)) {
        return true;
      }

      current.add(series);

      final String jsonStr = jsonEncode(current.map((s) => s.toJson()).toList());
      await prefs.setString(_keyDownloadedSeries, jsonStr);
      return true;
    } catch (e) {
      print('❌ Erreur lors du téléchargement de la série: $e');
      return false;
    }
  }

  /// Supprime un film des téléchargements locaux
  static Future<bool> removeDownloadedMovie(int movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<MovieApiModel> current = await getDownloadedMovies();
      
      current.removeWhere((m) => m.id == movieId);
      
      final String jsonStr = jsonEncode(current.map((m) => m.toJson()).toList());
      await prefs.setString(_keyDownloadedMovies, jsonStr);
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression du film téléchargé: $e');
      return false;
    }
  }

  /// Supprime une série des téléchargements locaux
  static Future<bool> removeDownloadedSeries(String seriesId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<SeriesApiModel> current = await getDownloadedSeries();

      current.removeWhere((s) => s.id == seriesId);

      final String jsonStr = jsonEncode(current.map((s) => s.toJson()).toList());
      await prefs.setString(_keyDownloadedSeries, jsonStr);
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression de la série téléchargée: $e');
      return false;
    }
  }

  /// Vérifie si un film est déjà téléchargé
  static Future<bool> isMovieDownloaded(int movieId) async {
    final list = await getDownloadedMovies();
    return list.any((m) => m.id == movieId);
  }

  /// Vérifie si une série est déjà téléchargée
  static Future<bool> isSeriesDownloaded(String seriesId) async {
    final list = await getDownloadedSeries();
    return list.any((s) => s.id == seriesId);
  }

  /// Calcule l'espace disque total utilisé par les téléchargements (simulé)
  static Future<String> getStorageUsedString() async {
    final movies = await getDownloadedMovies();
    final series = await getDownloadedSeries();

    // Simulation : 1.2 Go par film, 600 Mo par série
    double totalGb = (movies.length * 1.2) + (series.length * 0.6);
    return '${totalGb.toStringAsFixed(1)} GB';
  }
}
