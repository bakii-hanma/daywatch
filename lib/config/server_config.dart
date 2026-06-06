/// Configuration centralisée des serveurs
/// Modifiez ces URLs pour changer les adresses des serveurs dans toute l'application
class ServerConfig {
  // ====== SERVEUR API (Radarr, Sonarr, Trailers) ======
  /// URL de base pour l'API (Radarr, Sonarr, Trailers)
  static const String apiBaseUrl = 'https://api.daywatch.online';

  // ====== SERVEUR DE FILMS/STREAMING ======
  /// URL de base pour le serveur de streaming/films
  static const String streamingBaseUrl = 'https://api.daywatch.online';

  // ====== SERVEUR UTILISATEURS (AUTH) ======
  /// URL de base pour l'API utilisateurs (inscription, connexion)
  static const String usersApiBaseUrl = 'https://api.daywatch.online';

  // ====== MÉTHODES UTILITAIRES ======

  /// Obtenir l'URL complète pour un fichier sur le serveur de streaming
  static String getStreamingUrl(String filePath) {
    // Assurer que le chemin commence par "/"
    final cleanPath = filePath.startsWith('/') ? filePath : '/$filePath';
    return '$streamingBaseUrl$cleanPath';
  }

  /// Obtenir l'URL complète pour un endpoint API
  static String getApiUrl(String endpoint) {
    // Assurer que l'endpoint commence par "/"
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$apiBaseUrl$cleanEndpoint';
  }

  /// Tester la connectivité au serveur de streaming
  static String get streamingTestUrl => '$streamingBaseUrl/ping';

  /// Tester la connectivité au serveur API
  static String get apiTestUrl => '$apiBaseUrl/ping';

  // ====== INFORMATIONS DE DEBUG ======

  /// Afficher la configuration actuelle
  static void printConfig() {
    print('🌐 === CONFIGURATION SERVEURS ===');
    print('📡 API Base URL: $apiBaseUrl');
    print('🎬 Streaming Base URL: $streamingBaseUrl');
    print('🔗 API Test URL: $apiTestUrl');
    print('🔗 Streaming Test URL: $streamingTestUrl');
    print('================================');
  }

  /// Vérifier si les URLs sont valides
  static bool get isConfigValid {
    return apiBaseUrl.isNotEmpty &&
        streamingBaseUrl.isNotEmpty &&
        apiBaseUrl.startsWith('http') &&
        streamingBaseUrl.startsWith('http');
  }
}
