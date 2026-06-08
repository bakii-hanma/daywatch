import 'api_client.dart';
import 'movie_service.dart';

class WatchHistoryService {
  /// Récupère l'historique de visionnage des films pour un utilisateur,
  /// enrichi avec les informations de chaque film (titre, poster, etc.)
  static Future<List<Map<String, dynamic>>> getMovieWatchHistory(String userId) async {
    try {
      final endpoint = '/api/history/movies/$userId';
      final response = await ApiClient.get<dynamic>(endpoint);

      if (response.isSuccess && response.data != null) {
        List<dynamic> items = [];
        if (response.data is List) {
          items = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          items = responseMap['data'] as List<dynamic>? ?? [];
        }

        // Enrichir chaque entrée d'historique avec les détails du film
        final List<Map<String, dynamic>> enrichedHistory = [];
        for (var item in items) {
          final mapItem = Map<String, dynamic>.from(item);
          // Gérer les variantes de casse du backend (movieID ou movieId)
          final movieId = mapItem['movieID'] ?? mapItem['movieId'];
          
          if (movieId != null) {
            final movieDetails = await MovieService.getMovieById(movieId);
            if (movieDetails != null) {
              mapItem['movie'] = movieDetails;
              enrichedHistory.add(mapItem);
            }
          }
        }
        return enrichedHistory;
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération de l\'historique des films: $e');
    }
    return [];
  }

  /// Récupère l'historique de visionnage des épisodes pour un utilisateur,
  /// enrichi avec les détails du show/série si possible
  static Future<List<Map<String, dynamic>>> getEpisodeWatchHistory(String userId) async {
    try {
      final endpoint = '/api/history/episodes/$userId';
      final response = await ApiClient.get<dynamic>(endpoint);

      if (response.isSuccess && response.data != null) {
        List<dynamic> items = [];
        if (response.data is List) {
          items = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          items = responseMap['data'] as List<dynamic>? ?? [];
        }

        final List<Map<String, dynamic>> enrichedHistory = [];
        for (var item in items) {
          final mapItem = Map<String, dynamic>.from(item);
          final episodeId = mapItem['episodeID'] ?? mapItem['episodeId'];

          // Note : Comme la récupération d'un épisode par ID peut nécessiter de connaître
          // la série, on peut stocker temporairement l'item d'historique brut.
          // Le UI pourra lier l'épisode si les données de séries sont pré-chargées,
          // ou on retourne au moins l'historique brut.
          enrichedHistory.add(mapItem);
        }
        return enrichedHistory;
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération de l\'historique des épisodes: $e');
    }
    return [];
  }

  /// Enregistre ou met à jour la progression de visionnage d'un film
  static Future<bool> saveMovieWatchHistory({
    required String userId,
    required dynamic movieId,
    required int lastWatchedPosition, // en secondes
    required String lastWatchedDate,
    required bool isCompleted,
  }) async {
    try {
      final endpoint = '/api/history/movies';
      final body = {
        'userID': userId,
        'movieID': movieId,
        'lastWatchedPosition': lastWatchedPosition,
        'lastWatchedDate': lastWatchedDate,
        'isCompleted': isCompleted,
      };

      final response = await ApiClient.post<dynamic>(endpoint, body: body);
      return response.isSuccess;
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde de l\'historique du film: $e');
      return false;
    }
  }

  /// Enregistre ou met à jour la progression de visionnage d'un épisode
  static Future<bool> saveEpisodeWatchHistory({
    required String userId,
    required int episodeId,
    required int lastWatchedPosition, // en secondes
    required String lastWatchedDate,
    required bool isCompleted,
  }) async {
    try {
      final endpoint = '/api/history/episodes';
      final body = {
        'userID': userId,
        'episodeID': episodeId,
        'lastWatchedPosition': lastWatchedPosition,
        'lastWatchedDate': lastWatchedDate,
        'isCompleted': isCompleted,
      };

      final response = await ApiClient.post<dynamic>(endpoint, body: body);
      return response.isSuccess;
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde de l\'historique de l\'épisode: $e');
      return false;
    }
  }
}
