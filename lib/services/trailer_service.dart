import '../models/movie_model.dart';
import 'api_client.dart';

class TrailerService {
  /// Test de connectivité à l'API Trailers via ApiClient
  static Future<bool> testConnection() async {
    try {
      // Test simple de récupération de trailers
      final trailers = await ApiClient.getRecentTrailers<TrailerApiModel>(
        limit: 1,
        fromJson: TrailerApiModel.fromJson,
      );

      if (trailers.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Récupérer les trailers récents via ApiClient
  static Future<List<TrailerApiModel>> getRecentTrailers({
    int limit = 10,
  }) async {
    try {
      final trailers = await ApiClient.getRecentTrailers<TrailerApiModel>(
        limit: limit,
        fromJson: TrailerApiModel.fromJson,
      );

      return trailers;
    } catch (e) {
      return [];
    }
  }

  /// Récupérer les trailers à venir via ApiClient
  static Future<List<TrailerApiModel>> getUpcomingTrailers({
    int limit = 10,
  }) async {
    try {
      final trailers = await ApiClient.getUpcomingTrailers<TrailerApiModel>(
        limit: limit,
        fromJson: TrailerApiModel.fromJson,
      );

      return trailers;
    } catch (e) {
      return [];
    }
  }

  /// Diagnostic réseau pour les trailers via ApiClient
  static Future<void> diagnoseNetwork() async {
    try {
      await ApiClient.testConnection();
      await testConnection();
      await getRecentTrailers(limit: 5);
      await getUpcomingTrailers(limit: 5);
    } catch (e) {
      // Ignoré
    }
  }
}
