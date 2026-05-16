import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';

/// Client API centralisé pour toutes les requêtes vers le serveur
class ApiClient {
  /// URL de base du serveur API (depuis ServerConfig)
  static String get baseUrl => ServerConfig.apiBaseUrl;

  /// Endpoints de l'API
  static const String _radarrPrefix = '/api/radarr';
  static const String _sonarrPrefix = '/api/sonarr';

  // ====== ENDPOINTS RADARR (FILMS) ======
  static const String _moviesRecent = '$_radarrPrefix/movies/recent';
  static const String _moviesPopular = '$_radarrPrefix/movies/popular';
  static const String _moviesBase = '$_radarrPrefix/movies';
  static const String _moviesBoxOffice = '$_radarrPrefix/movies/boxoffice';

  // ====== ENDPOINTS SONARR (SÉRIES) ======
  static const String _seriesRecent = '$_sonarrPrefix/series/recent';
  static const String _seriesPopular = '$_sonarrPrefix/series/popular';
  static const String _seriesBase = '$_sonarrPrefix/series';

  // ====== ENDPOINTS TRAILERS ======
  static const String _trailersPrefix = '/api/trailers';
  static const String _trailersRecent = '$_trailersPrefix/recent';

  // ====== ENDPOINTS CHAÎNES TV ======
  static const String _tvChannelsPrefix = '/api/iptv-org';
  static const String _tvChannelsAll = '$_tvChannelsPrefix/channels/all';
  static const String _tvChannelsBase = '$_tvChannelsPrefix/channels';

  // ====== ENDPOINTS UTILISATEURS (AUTH) ======
  static const String _usersPrefix = '/api/users';
  static const String _registerEndpoint = '$_usersPrefix/register';
  static const String _loginEndpoint = '$_usersPrefix/login';
  static const String _updateProfileEndpoint = '$_usersPrefix/profile';
  static const String _updatePasswordEndpoint = '$_usersPrefix/password';
  static const String _updatePhoneEndpoint = '$_usersPrefix/phone';
  static const String _getProfilesEndpoint = '/api/profiles/user/:userId';

  /// URL de base pour l'API utilisateurs
  static String get usersBaseUrl => ServerConfig.usersApiBaseUrl;

  /// URL complète pour l'inscription
  static String get registerUrl => '$usersBaseUrl$_registerEndpoint';

  /// URL complète pour la connexion
  static String get loginUrl => '$usersBaseUrl$_loginEndpoint';

  /// URL complète pour la mise à jour du profil
  static String get updateProfileUrl => '$usersBaseUrl$_updateProfileEndpoint';

  /// URL complète pour la mise à jour du mot de passe
  static String get updatePasswordUrl =>
      '$usersBaseUrl$_updatePasswordEndpoint';

  /// URL complète pour la mise à jour du téléphone
  static String get updatePhoneUrl => '$usersBaseUrl$_updatePhoneEndpoint';

  /// URLs complètes des endpoints - Films (Radarr) - Pour compatibilité externe
  static String get recentMoviesUrl => '$baseUrl$_moviesRecent';
  static String get popularMoviesUrl => '$baseUrl$_moviesPopular';
  static String get allMoviesUrl => '$baseUrl$_moviesBase';
  static String get boxOfficeMoviesUrl => '$baseUrl$_moviesBoxOffice';

  /// URLs complètes des endpoints - Séries (Sonarr) - Pour compatibilité externe
  static String get recentSeriesUrl => '$baseUrl$_seriesRecent';
  static String get popularSeriesUrl => '$baseUrl$_seriesPopular';
  static String get allSeriesUrl => '$baseUrl$_seriesBase';

  /// URLs complètes des endpoints - Trailers - Pour compatibilité externe
  static String get recentTrailersUrl => '$baseUrl$_trailersRecent';

  /// URLs complètes des endpoints - Chaînes TV - Pour compatibilité externe
  static String get allTvChannelsUrl => '$baseUrl$_tvChannelsAll';
  static String get tvChannelsBaseUrl => '$baseUrl$_tvChannelsBase';

  /// Headers par défaut pour toutes les requêtes
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        'Origin, Content-Type, Accept, Authorization, X-Request-With',
    'User-Agent':
        'Mozilla/5.0 (Android; Mobile) AppleWebKit/537.36 KHTML/Gecko Chrome/91.0 Mobile Safari/537.36',
    'Accept-Encoding': 'gzip, deflate',
    'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.8',
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache',
  };

  /// Timeout par défaut pour les requêtes
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Timeout spécifique pour les séries (plus long car plus de données)
  static const Duration seriesTimeout = Duration(seconds: 60);

  /// Instance singleton du client HTTP
  static final http.Client _httpClient = http.Client();

  /// Effectuer une requête GET
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final url = endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint';

      print('🌐 GET: $url');

      final response = await _httpClient
          .get(Uri.parse(url), headers: {..._defaultHeaders, ...?headers})
          .timeout(timeout ?? defaultTimeout);

      print('📡 Statut: ${response.statusCode}');

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      print('❌ Erreur GET: $e');
      return ApiResponse.error('Erreur de connexion: $e');
    }
  }

  /// Effectuer une requête POST
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final url = endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint';

      print('🌐 POST: $url');

      final response = await _httpClient
          .post(
            Uri.parse(url),
            headers: {..._defaultHeaders, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? defaultTimeout);

      print('📡 Statut: ${response.statusCode}');

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      print('❌ Erreur POST: $e');
      return ApiResponse.error('Erreur de connexion: $e');
    }
  }

  /// Traiter la réponse HTTP
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic jsonData = jsonDecode(response.body);

        print('🔍 Type de réponse JSON: ${jsonData.runtimeType}');
        if (jsonData is Map<String, dynamic>) {
          print('🔍 Clés disponibles: ${jsonData.keys.toList()}');
        }

        // Si c'est une Map avec success/data (format API standard)
        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('success')) {
          if (jsonData['success'] == true) {
            if (fromJson != null && jsonData['data'] != null) {
              final result = fromJson(jsonData['data']);
              return ApiResponse.success(result);
            } else {
              return ApiResponse.success(jsonData['data'] as T);
            }
          } else {
            return ApiResponse.error(jsonData['message'] ?? 'Erreur inconnue');
          }
        }
        // Si c'est une Map avec data (nouveau format Sonarr)
        else if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('data')) {
          // Retourner directement la Map complète pour que les méthodes spécialisées puissent la traiter
          return ApiResponse.success(jsonData as T);
        }
        // Si c'est directement une liste
        else if (jsonData is List) {
          if (fromJson != null) {
            // Pour les listes, on prend le premier élément comme exemple
            if (jsonData.isNotEmpty && jsonData.first is Map<String, dynamic>) {
              final result = fromJson(jsonData.first as Map<String, dynamic>);
              return ApiResponse.success(result);
            }
          }
          return ApiResponse.success(jsonData as T);
        }
        // Si c'est directement un objet Map
        else if (jsonData is Map<String, dynamic>) {
          if (fromJson != null) {
            final result = fromJson(jsonData);
            return ApiResponse.success(result);
          }
          return ApiResponse.success(jsonData as T);
        }
        // Format inattendu
        else {
          print('⚠️ Format de réponse inattendu: ${jsonData.runtimeType}');
          return ApiResponse.success(jsonData as T);
        }
      } else {
        return ApiResponse.error(
          'Erreur HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Erreur parsing JSON: $e');
      print('📄 Contenu de la réponse: ${response.body}');
      return ApiResponse.error('Erreur de format de réponse: $e');
    }
  }

  // ====== MÉTHODES SPÉCIALISÉES RADARR (FILMS) ======

  /// Récupérer les films récents
  static Future<List<T>> getRecentMovies<T>({
    int limit = 10,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final endpoint = '$_moviesRecent?limit=$limit';
      final response = await get(endpoint);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        final List<T> result = items.map((item) => fromJson(item)).toList();
        return result;
      } else {
        print('❌ Erreur API films récents: ${response.error}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getRecentMovies: $e');
      return [];
    }
  }

  /// Récupérer les films populaires
  static Future<List<T>> getPopularMovies<T>({
    int limit = 10,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final endpoint = '$_moviesPopular?limit=$limit';
      final response = await get(endpoint);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        final List<T> result = items.map((item) => fromJson(item)).toList();
        return result;
      } else {
        print('❌ Erreur API films populaires: ${response.error}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getPopularMovies: $e');
      return [];
    }
  }

  /// Récupérer tous les films
  static Future<List<T>> getAllMovies<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final endpoint = _moviesBase;
      final response = await get(endpoint);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        final List<T> result = items.map((item) => fromJson(item)).toList();
        return result;
      } else {
        print('❌ Erreur API tous les films: ${response.error}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getAllMovies: $e');
      return [];
    }
  }

  /// Récupérer un film par ID
  static Future<ApiResponse<T?>> getMovieById<T>(
    int movieId, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final endpoint = '$_moviesBase/$movieId';
    final response = await get<Map<String, dynamic>>(endpoint);

    if (response.isSuccess && response.data != null) {
      final Map<String, dynamic> itemData = response.data!;
      if (fromJson != null && itemData.isNotEmpty) {
        final T result = fromJson(itemData);
        return ApiResponse.success(result);
      } else if (itemData.isNotEmpty) {
        return ApiResponse.success(itemData as T);
      }
    }
    return ApiResponse.error(response.error ?? 'Film non trouvé');
  }

  /// Récupérer les films du box office
  static Future<List<T>> getBoxOfficeMovies<T>({
    int limit = 10,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final endpoint = '$_moviesBoxOffice?limit=$limit';
      final response = await get(endpoint);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        final List<T> result = items.map((item) => fromJson(item)).toList();
        print('💰 Films box office récupérés via ApiClient: ${result.length}');
        return result;
      } else {
        print('❌ Erreur API films box office: ${response.error}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getBoxOfficeMovies: $e');
      return [];
    }
  }

  // ====== MÉTHODES SPÉCIALISÉES SONARR (SÉRIES) ======

  /// Récupérer les séries récentes
  static Future<List<T>> getRecentSeries<T>({
    int limit = 10,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final endpoint = '$_seriesRecent?limit=$limit';
      final response = await get<dynamic>(endpoint, timeout: seriesTimeout);

      if (response.isSuccess && response.data != null) {
        List<dynamic> items;

        // Gérer différents formats de réponse
        if (response.data is List) {
          // Format direct : liste de séries
          items = response.data as List<dynamic>;
          print('📋 Format de réponse: Liste directe (${items.length} séries)');
        } else if (response.data is Map<String, dynamic>) {
          // Format avec wrapper : { success: true, data: [...], message: "..." }
          final responseMap = response.data as Map<String, dynamic>;

          if (responseMap['data'] is List) {
            items = responseMap['data'] as List<dynamic>;
            print(
              '📋 Format de réponse: Wrapper avec success/data (${items.length} séries)',
            );
            print('📊 Message: ${responseMap['message'] ?? 'Non spécifié'}');
            print('📈 Count: ${responseMap['count'] ?? 'Non spécifié'}');
          } else if (responseMap['source'] != null) {
            // Format avec wrapper : { data: [...], source: "...", meta: {...} }
            items = responseMap['data'] as List<dynamic>;
            print(
              '📋 Format de réponse: Wrapper avec source/meta (${items.length} séries)',
            );
            print('📊 Source: ${responseMap['source'] ?? 'Non spécifié'}');
            print(
              '📅 Timestamp: ${responseMap['timestamp'] ?? 'Non spécifié'}',
            );
          } else {
            print('⚠️ Format de réponse inattendu: Map sans champ data');
            print('🔍 Clés disponibles: ${responseMap.keys.toList()}');
            return [];
          }
        } else {
          print('⚠️ Format de réponse inattendu pour séries récentes');
          print('🔍 Type reçu: ${response.data.runtimeType}');
          return [];
        }

        final List<T> result = items.map((item) => fromJson(item)).toList();
        print('✅ ${result.length} séries récentes récupérées via ApiClient');
        return result;
      } else {
        print('❌ Erreur API séries récentes: ${response.error}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getRecentSeries: $e');
      print('🔍 Type d\'erreur: ${e.runtimeType}');
      return [];
    }
  }

  /// Récupérer les séries populaires
  static Future<List<T>> getPopularSeries<T>({
    int limit = 10,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final endpoint = '$_seriesPopular?limit=$limit';
      final response = await get<dynamic>(endpoint, timeout: seriesTimeout);

      if (response.isSuccess && response.data != null) {
        List<dynamic> items;

        // Gérer différents formats de réponse
        if (response.data is List) {
          // Format direct : liste de séries
          items = response.data as List<dynamic>;
          print('📋 Format de réponse: Liste directe (${items.length} séries)');
        } else if (response.data is Map<String, dynamic>) {
          // Format avec wrapper : { success: true, data: [...], message: "..." }
          final responseMap = response.data as Map<String, dynamic>;

          if (responseMap['data'] is List) {
            items = responseMap['data'] as List<dynamic>;
            print(
              '📋 Format de réponse: Wrapper avec success/data (${items.length} séries)',
            );
            print('📊 Message: ${responseMap['message'] ?? 'Non spécifié'}');
            print('📈 Count: ${responseMap['count'] ?? 'Non spécifié'}');
          } else if (responseMap['source'] != null) {
            // Format avec wrapper : { data: [...], source: "...", meta: {...} }
            items = responseMap['data'] as List<dynamic>;
            print(
              '📋 Format de réponse: Wrapper avec source/meta (${items.length} séries)',
            );
            print('📊 Source: ${responseMap['source'] ?? 'Non spécifié'}');
            print(
              '📅 Timestamp: ${responseMap['timestamp'] ?? 'Non spécifié'}',
            );
          } else {
            print('⚠️ Format de réponse inattendu: Map sans champ data');
            print('🔍 Clés disponibles: ${responseMap.keys.toList()}');
            return [];
          }
        } else {
          print('⚠️ Format de réponse inattendu pour séries populaires');
          print('🔍 Type reçu: ${response.data.runtimeType}');
          return [];
        }

        final List<T> result = items.map((item) => fromJson(item)).toList();
        print('✅ ${result.length} séries populaires récupérées via ApiClient');
        return result;
      } else {
        print('❌ Erreur API séries populaires: ${response.error}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getPopularSeries: $e');
      print('🔍 Type d\'erreur: ${e.runtimeType}');
      return [];
    }
  }

  /// Récupérer une série par ID
  static Future<ApiResponse<T?>> getSeriesById<T>(
    String seriesId, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final endpoint = '$_seriesBase/$seriesId';
    final response = await get<Map<String, dynamic>>(
      endpoint,
      timeout: seriesTimeout,
    );

    if (response.isSuccess && response.data != null) {
      final Map<String, dynamic> itemData = response.data!;
      if (fromJson != null && itemData.isNotEmpty) {
        final T result = fromJson(itemData);
        return ApiResponse.success(result);
      } else if (itemData.isNotEmpty) {
        return ApiResponse.success(itemData as T);
      }
    }
    return ApiResponse.error(response.error ?? 'Série non trouvée');
  }

  // ====== MÉTHODES SPÉCIALISÉES TRAILERS ======

  /// Récupérer les trailers récents
  static Future<List<T>> getRecentTrailers<T>({
    int limit = 10,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final endpoint = '$_trailersRecent?limit=$limit';
      final response = await get(endpoint);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        final List<T> result = items.map((item) => fromJson(item)).toList();
        print('✅ Trailers récupérés via ApiClient: ${result.length}');
        return result;
      } else {
        print('❌ Erreur API trailers récents: ${response.error}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getRecentTrailers: $e');
      return [];
    }
  }

  // ====== MÉTHODES SPÉCIALISÉES CHAÎNES TV ======

  /// Récupérer toutes les chaînes TV avec pagination
  static Future<List<T>> getAllTvChannels<T>({
    int page = 1,
    int limit = 50,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final endpoint = '$_tvChannelsAll?page=$page&limit=$limit';
      final response = await get(endpoint);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        final List<T> result = items.map((item) => fromJson(item)).toList();
        print(
          '✅ Chaînes TV récupérées via ApiClient: ${result.length} (page $page)',
        );
        return result;
      } else {
        print('❌ Erreur API chaînes TV: ${response.error}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getAllTvChannels: $e');
      return [];
    }
  }

  /// Récupérer un nombre limité de chaînes pour la page d'accueil
  static Future<List<T>> getHomeTvChannels<T>({
    int limit = 8,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final channels = await getAllTvChannels(
        page: 1,
        limit: limit,
        fromJson: fromJson,
      );
      print('✅ Chaînes TV d\'accueil récupérées: ${channels.length}');
      return channels;
    } catch (e) {
      print('❌ Exception getHomeTvChannels: $e');
      return [];
    }
  }

  /// Récupérer les chaînes TV par catégorie
  static Future<List<T>> getTvChannelsByCategory<T>(
    String category, {
    int limit = 100,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      // Récupérer toutes les chaînes puis filtrer par catégorie
      final allChannels = await getAllTvChannels(
        page: 1,
        limit: limit,
        fromJson: fromJson,
      );

      if (category == 'Toutes' || category.isEmpty) {
        return allChannels;
      }

      final filteredChannels = allChannels.where((channel) {
        // Utiliser la réflexion pour accéder à la propriété category
        // ou implémenter une méthode de filtrage spécifique
        return _filterChannelByCategory(channel, category);
      }).toList();

      print(
        '✅ Chaînes TV filtrées par catégorie "$category": ${filteredChannels.length}',
      );
      return filteredChannels;
    } catch (e) {
      print('❌ Exception getTvChannelsByCategory: $e');
      return [];
    }
  }

  /// Récupérer toutes les chaînes TV (multi-pages)
  static Future<List<T>> getAllTvChannelsMultiPage<T>({
    int maxPages = 5,
    int limitPerPage = 50,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      List<T> allChannels = [];

      for (int page = 1; page <= maxPages; page++) {
        final channels = await getAllTvChannels(
          page: page,
          limit: limitPerPage,
          fromJson: fromJson,
        );

        if (channels.isEmpty) {
          // Plus de chaînes disponibles
          break;
        }

        allChannels.addAll(channels);
        print('📊 Page $page: ${channels.length} chaînes récupérées');
      }

      print('✅ Total chaînes TV récupérées: ${allChannels.length}');
      return allChannels;
    } catch (e) {
      print('❌ Exception getAllTvChannelsMultiPage: $e');
      return [];
    }
  }

  /// Récupérer une chaîne TV par ID
  static Future<ApiResponse<T?>> getTvChannelById<T>(
    String channelId, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final endpoint = '$_tvChannelsBase/$channelId';
    final response = await get<Map<String, dynamic>>(endpoint);

    if (response.isSuccess && response.data != null) {
      final Map<String, dynamic> itemData = response.data!;
      if (fromJson != null && itemData.isNotEmpty) {
        final T result = fromJson(itemData);
        return ApiResponse.success(result);
      } else if (itemData.isNotEmpty) {
        return ApiResponse.success(itemData as T);
      }
    }
    return ApiResponse.error(response.error ?? 'Chaîne TV non trouvée');
  }

  /// Obtenir la liste des catégories de chaînes disponibles
  static Future<List<String>> getTvChannelCategories<T>({
    int sampleSize = 100,
    required T Function(Map<String, dynamic>) fromJson,
    required String Function(T) getCategory,
  }) async {
    try {
      // Récupérer un échantillon pour obtenir les catégories
      final sampleChannels = await getAllTvChannels(
        page: 1,
        limit: sampleSize,
        fromJson: fromJson,
      );

      final categories = sampleChannels
          .map((channel) => getCategory(channel))
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();

      categories.sort();
      final result = ['Toutes', ...categories];
      print('✅ Catégories de chaînes TV disponibles: ${result.length}');
      return result;
    } catch (e) {
      print('❌ Exception getTvChannelCategories: $e');
      return [
        'Toutes',
        'Généralistes',
        'Sport',
        'Info',
        'Divertissement',
        'Cinéma',
        'Documentaires',
      ];
    }
  }

  /// Méthode utilitaire pour filtrer les chaînes par catégorie
  static bool _filterChannelByCategory<T>(T channel, String category) {
    // Cette méthode doit être implémentée selon le modèle de données spécifique
    // Pour l'instant, on retourne true pour éviter les erreurs
    // L'implémentation réelle dépendra de la structure de TvChannelModel
    return true;
  }

  /// Inscription utilisateur
  static Future<ApiResponse<T>> registerUser<T>({
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await post<T>(
        registerUrl,
        body: body,
        fromJson: fromJson,
      );
      return response;
    } catch (e) {
      print('❌ Erreur inscription: $e');
      return ApiResponse.error('Erreur inscription: $e');
    }
  }

  /// Connexion utilisateur
  static Future<ApiResponse<T>> loginUser<T>({
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await post<T>(loginUrl, body: body, fromJson: fromJson);
      return response;
    } catch (e) {
      print('❌ Erreur connexion: $e');
      return ApiResponse.error('Erreur connexion: $e');
    }
  }

  /// Tester la connectivité avec le serveur
  static Future<bool> testConnection() async {
    try {
      print('🧪 Test de connectivité vers: $baseUrl');

      final response = await get(
        _moviesRecent,
        timeout: const Duration(seconds: 10),
      );

      final isConnected = response.isSuccess;
      print(
        isConnected ? '✅ Connectivité confirmée' : '❌ Test de connexion échoué',
      );

      return isConnected;
    } catch (e) {
      print('❌ Test de connexion échoué: $e');
      return false;
    }
  }

  /// Obtenir l'URL complète d'un endpoint
  static String getFullUrl(String endpoint) {
    return endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint';
  }

  /// Récupérer les profils d'un utilisateur
  static Future<ApiResponse<List<Map<String, dynamic>>>> getUserProfiles({
    required String userId,
  }) async {
    try {
      print('🔍 Récupération des profils pour l\'utilisateur: $userId');

      // Construire l'URL avec l'ID utilisateur
      final endpoint = _getProfilesEndpoint.replaceAll(':userId', userId);
      final url = '$usersBaseUrl$endpoint';

      print('📡 Requête vers: $url');

      final response = await http
          .get(Uri.parse(url), headers: _defaultHeaders)
          .timeout(defaultTimeout);

      print('📡 Statut de la réponse: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);

        // Vérifier si la réponse contient une liste de profils
        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('profiles')) {
          final profilesList = jsonData['profiles'] as List<dynamic>;
          final profiles = profilesList
              .map((profile) => profile as Map<String, dynamic>)
              .toList();

          print('✅ ${profiles.length} profil(s) récupéré(s) avec succès');
          return ApiResponse.success(profiles);
        } else if (jsonData is List) {
          // Si la réponse est directement une liste
          final profiles = jsonData
              .map((profile) => profile as Map<String, dynamic>)
              .toList();

          print('✅ ${profiles.length} profil(s) récupéré(s) avec succès');
          return ApiResponse.success(profiles);
        } else {
          print('❌ Format de réponse inattendu pour les profils');
          return ApiResponse.error('Format de réponse inattendu');
        }
      } else {
        final errorMessage =
            'Erreur HTTP ${response.statusCode}: ${response.reasonPhrase}';
        print('❌ $errorMessage');
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      print('❌ Erreur récupération profils: $e');
      return ApiResponse.error('Erreur récupération profils: $e');
    }
  }

  /// Nettoyer les ressources
  static void dispose() {
    _httpClient.close();
  }
}

/// Classe pour encapsuler les réponses API
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ApiResponse.success(this.data) : isSuccess = true, error = null;
  ApiResponse.error(this.error) : isSuccess = false, data = null;

  /// Obtenir les données ou lancer une exception
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception(error ?? 'Données non disponibles');
  }

  /// Vérifier si la réponse contient des données
  bool get hasData => isSuccess && data != null;
}
