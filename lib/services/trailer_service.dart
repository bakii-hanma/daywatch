import '../models/movie_model.dart';
import 'api_client.dart';

class TrailerService {
  /// Test de connectivité à l'API Trailers via ApiClient
  static Future<bool> testConnection() async {
    try {
      print('🔍 Test de connexion Trailer API via ApiClient...');
      print('🌐 URL: ${ApiClient.recentTrailersUrl}');

      // Test simple de récupération de trailers
      final trailers = await ApiClient.getRecentTrailers<TrailerApiModel>(
        limit: 1,
        fromJson: TrailerApiModel.fromJson,
      );

      print('📡 Test de connexion résultat: ${trailers.isNotEmpty}');

      if (trailers.isNotEmpty) {
        print('✅ Test de connexion réussi - Trailers disponibles');
        return true;
      } else {
        print('⚠️ Connexion OK mais aucun trailer disponible');
        return false;
      }
    } catch (e) {
      print('❌ Erreur de connexion Trailer API: $e');
      print('🔧 Type d\'erreur: ${e.runtimeType}');
      return false;
    }
  }

  /// Récupérer les trailers récents via ApiClient
  static Future<List<TrailerApiModel>> getRecentTrailers({
    int limit = 10,
  }) async {
    try {
      print('📥 Récupération des trailers récents via ApiClient...');
      print('🌐 Endpoint: ${ApiClient.recentTrailersUrl}');

      final trailers = await ApiClient.getRecentTrailers<TrailerApiModel>(
        limit: limit,
        fromJson: TrailerApiModel.fromJson,
      );

      print('📊 Trailers récupérés: ${trailers.length}');

      // Debug: afficher les premiers trailers
      if (trailers.isNotEmpty) {
        print('🎬 Premiers trailers récupérés:');
        for (var trailer in trailers.take(3)) {
          print('   - ${trailer.title} (${trailer.year})');
          print('     Poster: ${trailer.fullPosterUrl}');
        }
        if (trailers.length > 3) {
          print('   ... et ${trailers.length - 3} autres');
        }
      }

      return trailers;
    } catch (e) {
      print('❌ Erreur lors de la récupération des trailers: $e');
      return [];
    }
  }

  /// Diagnostic réseau pour les trailers via ApiClient
  static Future<void> diagnoseNetwork() async {
    print('🔧 DIAGNOSTIC RÉSEAU TRAILERS VIA APICLIENT');
    print('════════════════════════════════════════════');
    print('🌐 Base URL: ${ApiClient.baseUrl}');
    print('🔗 Endpoint trailers: ${ApiClient.recentTrailersUrl}');

    try {
      // Test de connectivité générale
      final generalConnectivity = await ApiClient.testConnection();
      print('📡 Connectivité générale ApiClient: $generalConnectivity');

      // Test spécifique trailers
      final trailersConnectivity = await testConnection();
      print('📺 Connectivité trailers: $trailersConnectivity');

      // Essai de récupération
      final trailers = await getRecentTrailers(limit: 5);
      print('📊 Trailers récupérés lors du diagnostic: ${trailers.length}');

      if (trailers.isNotEmpty) {
        print('✅ DIAGNOSTIC SUCCÈS - API fonctionnelle');
        print('🎬 Exemple de trailer: ${trailers.first.title}');
      } else {
        print('⚠️ DIAGNOSTIC - Aucun trailer disponible');
      }
    } catch (e) {
      print('❌ Erreur diagnostic: $e');
      print('🌐 Vérifications suggérées:');
      print('   - IP du serveur: ${ApiClient.baseUrl}');
      print('   - Endpoint: /api/trailers/recent');
      print('   - Connectivité réseau');
    }

    print('════════════════════════════════════════════');
  }
}
