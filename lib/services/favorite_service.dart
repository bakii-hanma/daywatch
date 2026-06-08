import 'api_client.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../models/tv_channel_model.dart';

class FavoriteService {
  /// Récupère la liste des films favoris de l'utilisateur
  static Future<List<MovieApiModel>> getFavoriteMovies(String userId) async {
    try {
      final endpoint = '/api/favorites/movies/$userId';
      final response = await ApiClient.get<dynamic>(endpoint);

      if (response.isSuccess && response.data != null) {
        List<dynamic> items = [];
        if (response.data is List) {
          items = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          items = responseMap['data'] as List<dynamic>? ?? [];
        }

        return items.map((json) => MovieApiModel.fromEssentialJson(json)).toList();
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des films favoris: $e');
    }
    return [];
  }

  /// Récupère la liste des séries favorites de l'utilisateur
  static Future<List<SeriesApiModel>> getFavoriteShows(String userId) async {
    try {
      final endpoint = '/api/favorites/shows/$userId';
      final response = await ApiClient.get<dynamic>(endpoint);

      if (response.isSuccess && response.data != null) {
        List<dynamic> items = [];
        if (response.data is List) {
          items = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          items = responseMap['data'] as List<dynamic>? ?? [];
        }

        return items.map((json) => SeriesApiModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des séries favorites: $e');
    }
    return [];
  }

  /// Récupère la liste des chaînes TV favorites de l'utilisateur
  static Future<List<TvChannelModel>> getFavoriteChannels(String userId) async {
    try {
      final endpoint = '/api/favorite-channels/favorites/channels/$userId';
      final response = await ApiClient.get<dynamic>(endpoint);

      if (response.isSuccess && response.data != null) {
        List<dynamic> items = [];
        if (response.data is List) {
          items = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          items = responseMap['data'] as List<dynamic>? ?? [];
        }

        return items.map((json) => TvChannelModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des chaînes favorites: $e');
    }
    return [];
  }

  /// Ajoute un film aux favoris
  static Future<bool> addMovieToFavorites(String userId, dynamic movieId) async {
    try {
      final endpoint = '/api/favorites/movies';
      final body = {
        'userID': userId,
        'movieID': movieId,
      };
      final response = await ApiClient.post<dynamic>(endpoint, body: body);
      return response.isSuccess;
    } catch (e) {
      print('❌ [FavoriteService] Erreur lors de l\'ajout du film aux favoris: $e');
      return false;
    }
  }

  /// Supprime un film des favoris
  static Future<bool> removeMovieFromFavorites(String userId, dynamic movieId) async {
    try {
      final endpoint = '/api/favorites/movies';
      final body = {
        'userID': userId,
        'movieID': movieId,
      };
      final response = await ApiClient.delete<dynamic>(endpoint, body: body);
      return response.isSuccess;
    } catch (e) {
      print('❌ [FavoriteService] Erreur lors de la suppression du film des favoris: $e');
      return false;
    }
  }

  /// Ajoute une série aux favoris
  static Future<bool> addShowToFavorites(String userId, int showId) async {
    try {
      final endpoint = '/api/favorites/shows';
      final body = {
        'userID': userId,
        'showID': showId,
      };
      final response = await ApiClient.post<dynamic>(endpoint, body: body);
      return response.isSuccess;
    } catch (e) {
      print('❌ [FavoriteService] Erreur lors de l\'ajout de la série aux favoris: $e');
      return false;
    }
  }

  /// Supprime une série des favoris
  static Future<bool> removeShowFromFavorites(String userId, int showId) async {
    try {
      final endpoint = '/api/favorites/shows';
      final body = {
        'userID': userId,
        'showID': showId,
      };
      final response = await ApiClient.delete<dynamic>(endpoint, body: body);
      return response.isSuccess;
    } catch (e) {
      print('❌ [FavoriteService] Erreur lors de la suppression de la série des favoris: $e');
      return false;
    }
  }

  /// Ajoute une chaîne TV aux favoris
  static Future<bool> addChannelToFavorites(String userId, int channelId) async {
    try {
      final endpoint = '/api/favorite-channels/favorites/channels';
      final body = {
        'userID': userId,
        'channelID': channelId,
      };
      final response = await ApiClient.post<dynamic>(endpoint, body: body);
      return response.isSuccess;
    } catch (e) {
      print('❌ Erreur lors de l\'ajout de la chaîne aux favoris: $e');
      return false;
    }
  }

  /// Supprime une chaîne TV des favoris
  static Future<bool> removeChannelFromFavorites(String userId, int channelId) async {
    try {
      final endpoint = '/api/favorite-channels/favorites/channels';
      final body = {
        'userID': userId,
        'channelID': channelId,
      };
      final response = await ApiClient.delete<dynamic>(endpoint, body: body);
      return response.isSuccess;
    } catch (e) {
      print('❌ Erreur lors de la suppression de la chaîne des favoris: $e');
      return false;
    }
  }
}
