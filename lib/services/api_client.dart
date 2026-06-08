import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';
import 'user_storage_service.dart';

/// Client API centralisé pour toutes les requêtes vers le serveur
class ApiClient {
  /// URL de base du serveur API (depuis ServerConfig)
  static String get baseUrl => ServerConfig.apiBaseUrl;

  /// Endpoints de l'API
  static const String _moviesPrefix = '/api/movies';
  static const String _seriesPrefix = '/api/series';

  // ====== ENDPOINTS FILMS (Nouvelle API) ======
  static const String _moviesBase = _moviesPrefix;
  static const String _moviesRecent = '$_moviesPrefix/recent';
  static const String _moviesPopular = '$_moviesPrefix/popular';
  static const String _moviesComingSoon = '$_moviesPrefix/coming-soon';
  static const String _moviesRecentAdditions = '$_moviesPrefix/recent-additions';
  static const String _moviesRecentAdditionsEssentials = '$_moviesPrefix/recent-additions/essentials';
  static const String _moviesTopRecommendations = '$_moviesPrefix/top-recommendations';
  static const String _moviesTopRecommendationsEssentials = '$_moviesPrefix/top-recommendations/essentials';
  static const String _moviesBoxOffice = '$_moviesPrefix/popular'; // Fallback / alias pour compatibilité

  // ====== ENDPOINTS SÉRIES (Nouvelle API) ======
  static const String _seriesBase = _seriesPrefix;
  static const String _seriesPopular = '$_seriesPrefix/popular';
  static const String _seriesRecent = '$_seriesPrefix/recent';
  static const String _seriesRecommended = '$_seriesPrefix/recommended';
  static const String _seriesUpcoming = '$_seriesPrefix/upcoming';
  static const String _seriesAnime = '$_seriesPrefix/anime';
  static const String _seriesAnimeUpcoming = '$_seriesPrefix/anime/upcoming';
  static const String _seriesKDrama = '$_seriesPrefix/k-drama';
  static const String _seriesStats = '$_seriesPrefix/stats';

  // ====== ENDPOINTS TRAILERS ======
  static const String _trailersPrefix = '/api/trailers';
  static const String _trailersRecent = '$_trailersPrefix/recent';
  static const String _trailersUpcoming = '$_trailersPrefix/upcoming';

  // ====== ENDPOINTS CHAÎNES TV ======
  static const String _tvChannelsPrefix = '/api/iptv-org';
  static const String _tvChannelsAll = '$_tvChannelsPrefix/channels/french/only-with-streams';
  static const String _tvChannelsBase = '$_tvChannelsPrefix/channels/french';

  // ====== ENDPOINTS UTILISATEURS (AUTH) ======
  static const String _usersPrefix = '/api/users';
  static const String _authPrefix = '/api/auth';
  static const String _registerEndpoint = '$_authPrefix/register';
  static const String _loginEndpoint = '$_authPrefix/login';
  static const String _verifyEmailEndpoint = '$_authPrefix/verify-otp';
  static const String _resendVerificationEndpoint = '$_authPrefix/resend-otp';
  static const String _forgotPasswordEndpoint = '$_usersPrefix/forgot-password';
  static const String _updateProfileEndpoint = '$_usersPrefix/profile';
  static const String _updatePasswordEndpoint = '$_usersPrefix/password';
  static const String _updatePhoneEndpoint = '$_usersPrefix/phone';

  /// URL de base pour l'API utilisateurs
  static String get usersBaseUrl => ServerConfig.usersApiBaseUrl;

  /// URL complète pour l'inscription
  static String get registerUrl => '$usersBaseUrl$_registerEndpoint';

  /// URL complète pour la connexion
  static String get loginUrl => '$usersBaseUrl$_loginEndpoint';

  /// URL complète pour la vérification de l'email
  static String get verifyEmailUrl => '$usersBaseUrl$_verifyEmailEndpoint';

  /// URL complète pour le renvoi du code de vérification
  static String get resendVerificationUrl => '$usersBaseUrl$_resendVerificationEndpoint';

  /// URL complète pour mot de passe oublié
  static String get forgotPasswordUrl => '$usersBaseUrl$_forgotPasswordEndpoint';

  /// URL complète pour la mise à jour du profil
  static String get updateProfileUrl => '$usersBaseUrl$_updateProfileEndpoint';

  /// URL complète pour la mise à jour du mot de passe
  static String get updatePasswordUrl =>
      '$usersBaseUrl$_updatePasswordEndpoint';

  /// URL complète pour la mise à jour du téléphone
  static String get updatePhoneUrl => '$usersBaseUrl$_updatePhoneEndpoint';

  /// URLs complètes des endpoints - Films - Pour compatibilité externe
  static String get recentMoviesUrl => '$baseUrl$_moviesRecent';
  static String get popularMoviesUrl => '$baseUrl$_moviesPopular';
  static String get allMoviesUrl => '$baseUrl$_moviesBase';
  static String get comingSoonMoviesUrl => '$baseUrl$_moviesComingSoon';
  static String get recentAdditionsMoviesUrl => '$baseUrl$_moviesRecentAdditions';
  static String get recentAdditionsEssentialsMoviesUrl => '$baseUrl$_moviesRecentAdditionsEssentials';
  static String get topRecommendationsMoviesUrl => '$baseUrl$_moviesTopRecommendations';
  static String get topRecommendationsEssentialsMoviesUrl => '$baseUrl$_moviesTopRecommendationsEssentials';
  static String get boxOfficeMoviesUrl => '$baseUrl$_moviesBoxOffice';

  /// URLs complètes des endpoints - Séries - Pour compatibilité externe
  static String get recentSeriesUrl => '$baseUrl$_seriesRecent';
  static String get popularSeriesUrl => '$baseUrl$_seriesPopular';
  static String get allSeriesUrl => '$baseUrl$_seriesBase';
  static String get recommendedSeriesUrl => '$baseUrl$_seriesRecommended';
  static String get upcomingSeriesUrl => '$baseUrl$_seriesUpcoming';
  static String get animeSeriesUrl => '$baseUrl$_seriesAnime';
  static String get animeUpcomingSeriesUrl => '$baseUrl$_seriesAnimeUpcoming';
  static String get kDramaSeriesUrl => '$baseUrl$_seriesKDrama';
  static String get statsSeriesUrl => '$baseUrl$_seriesStats';

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



  // Variable pour stocker la promesse du refresh en cours (pour éviter les conflits si plusieurs requêtes font 401 en même temps)
  static Future<bool>? _refreshFuture;

  /// Rafraîchir la session de manière thread-safe
  static Future<bool> _refreshSession() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    _refreshFuture = () async {
      try {
        final userData = await UserStorageService.getUserData();
        if (userData == null) return false;

        final session = userData['session'] as Map<String, dynamic>?;
        if (session == null) return false;

        final refreshToken = session['refresh_token'] ?? session['refreshToken'];
        if (refreshToken == null) return false;

        final response = await _httpClient.post(
          Uri.parse('$usersBaseUrl/api/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': refreshToken}),
        ).timeout(defaultTimeout);

        if (response.statusCode == 401) {
          // Token expiré ou révoqué -> déconnexion de l'utilisateur
          await UserStorageService.logout();
          return false;
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['success'] == true && body['data'] != null) {
            final data = body['data'] as Map<String, dynamic>;
            final newSession = data['session'] as Map<String, dynamic>;

            // Mettre à jour la session dans les SharedPreferences tout en conservant les autres données (plans, profils)
            final current = await UserStorageService.getUserData();
            if (current != null) {
              final Map<String, dynamic> currentSession = Map<String, dynamic>.from(current['session'] as Map? ?? {});

              // Mettre à jour à la fois camelCase et snake_case pour la compatibilité descendante
              currentSession['access_token'] = newSession['access_token'];
              currentSession['accessToken'] = newSession['access_token'];
              currentSession['refresh_token'] = newSession['refresh_token'];
              currentSession['refreshToken'] = newSession['refresh_token'];
              currentSession['expires_at'] = newSession['expires_at'];
              currentSession['expiresAt'] = newSession['expires_at'];
              currentSession['expires_in'] = newSession['expires_in'];
              currentSession['expiresIn'] = newSession['expires_in'];

              current['session'] = currentSession;
              if (data['user'] != null) {
                current['user'] = data['user'];
              }

              // saveUserData ré-enveloppe ou non selon le format, mais on lui passe le format enveloppé
              await UserStorageService.saveUserData({'success': true, 'data': current});
            }
            return true;
          }
        }
        return false;
      } catch (e) {
        print('Erreur lors du rafraîchissement de la session: $e');
        return false;
      } finally {
        _refreshFuture = null;
      }
    }();

    return _refreshFuture!;
  }

  /// Méthode centrale privée pour envoyer toutes les requêtes HTTP avec gestion de l'auth et du retry
  static Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
    bool isRetry = false,
  }) async {
    try {
      final url = endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint';
      final token = await UserStorageService.getToken();
      
      final finalHeaders = {
        ..._defaultHeaders,
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final requestTimeout = timeout ?? defaultTimeout;
      final uri = Uri.parse(url);
      http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _httpClient
              .post(uri, headers: finalHeaders, body: body != null ? jsonEncode(body) : null)
              .timeout(requestTimeout);
          break;
        case 'PUT':
          response = await _httpClient
              .put(uri, headers: finalHeaders, body: body != null ? jsonEncode(body) : null)
              .timeout(requestTimeout);
          break;
        case 'PATCH':
          response = await _httpClient
              .patch(uri, headers: finalHeaders, body: body != null ? jsonEncode(body) : null)
              .timeout(requestTimeout);
          break;
        case 'DELETE':
          response = await _httpClient
              .delete(uri, headers: finalHeaders, body: body != null ? jsonEncode(body) : null)
              .timeout(requestTimeout);
          break;
        case 'GET':
        default:
          response = await _httpClient
              .get(uri, headers: finalHeaders)
              .timeout(requestTimeout);
          break;
      }

      // Si erreur 401 et qu'un token était présent et qu'on n'a pas déjà retry
      if (response.statusCode == 401 && !isRetry && token != null) {
        final success = await _refreshSession();
        if (success) {
          // Rejouer la requête d'origine
          return _request<T>(
            method,
            endpoint,
            body: body,
            headers: headers,
            timeout: timeout,
            fromJson: fromJson,
            isRetry: true,
          );
        }
      }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Erreur de connexion: $e');
    }
  }

  /// Traiter la réponse HTTP
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      'GET',
      endpoint,
      headers: headers,
      timeout: timeout,
      fromJson: fromJson,
    );
  }

  /// Effectuer une requête POST
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      'POST',
      endpoint,
      body: body,
      headers: headers,
      timeout: timeout,
      fromJson: fromJson,
    );
  }

  /// Effectuer une requête PUT
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      'PUT',
      endpoint,
      body: body,
      headers: headers,
      timeout: timeout,
      fromJson: fromJson,
    );
  }

  /// Effectuer une requête PATCH
  static Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      'PATCH',
      endpoint,
      body: body,
      headers: headers,
      timeout: timeout,
      fromJson: fromJson,
    );
  }

  /// Effectuer une requête DELETE
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      'DELETE',
      endpoint,
      body: body,
      headers: headers,
      timeout: timeout,
      fromJson: fromJson,
    );
  }


  /// Traiter la réponse HTTP
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic jsonData = jsonDecode(response.body);

        // Si c'est une Map avec success/data (format API standard)
        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('success')) {
          if (jsonData['success'] == true) {
            if (fromJson != null && jsonData['data'] != null) {
              final result = fromJson(jsonData['data']);
              return ApiResponse.success(result);
            } else {
              if (T == Map<String, dynamic>) {
                return ApiResponse.success(jsonData as T);
              }
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
          return ApiResponse.success(jsonData as T);
        }
      } else {
        String errorMsg = 'Erreur HTTP ${response.statusCode}';
        try {
          final dynamic jsonData = jsonDecode(response.body);
          if (jsonData is Map<String, dynamic> &&
              jsonData.containsKey('message')) {
            errorMsg = jsonData['message'].toString();
          } else if (response.body.isNotEmpty && response.body.length < 150) {
            errorMsg = response.body;
          }
        } catch (_) {
          if (response.body.isNotEmpty && response.body.length < 150) {
            errorMsg = response.body;
          }
        }
        return ApiResponse.error(errorMsg);
      }
    } catch (e) {
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
        return [];
      }
    } catch (e) {
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
        return [];
      }
    } catch (e) {
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
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Récupérer un film par ID
  static Future<ApiResponse<T?>> getMovieById<T>(
    dynamic movieId, {
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
        return result;
      } else {
        return [];
      }
    } catch (e) {
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
          items = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;

          if (responseMap['data'] is List) {
            items = responseMap['data'] as List<dynamic>;
          } else if (responseMap['source'] != null) {
            items = responseMap['data'] as List<dynamic>;
          } else {
            return [];
          }
        } else {
          return [];
        }

        final List<T> result = items.map((item) => fromJson(item)).toList();
        return result;
      } else {
        return [];
      }
    } catch (e) {
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
          items = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;

          if (responseMap['data'] is List) {
            items = responseMap['data'] as List<dynamic>;
          } else if (responseMap['source'] != null) {
            items = responseMap['data'] as List<dynamic>;
          } else {
            return [];
          }
        } else {
          return [];
        }

        final List<T> result = items.map((item) => fromJson(item)).toList();
        return result;
      } else {
        return [];
      }
    } catch (e) {
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
      print('📺 [DEBUG STREAM] Réponse brute pour les détails de la série ($seriesId) :');
      print(jsonEncode(itemData));
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
        return result;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Récupérer les trailers à venir
  static Future<List<T>> getUpcomingTrailers<T>({
    int limit = 10,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final endpoint = '$_trailersUpcoming?limit=$limit';
      final response = await get(endpoint);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data as List<dynamic>;
        final List<T> result = items.map((item) => fromJson(item)).toList();
        return result;
      } else {
        return [];
      }
    } catch (e) {
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
        return result;
      } else {
        return [];
      }
    } catch (e) {
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
      return channels;
    } catch (e) {
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

      return filteredChannels;
    } catch (e) {
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
      }

      return allChannels;
    } catch (e) {
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
      return result;
    } catch (e) {
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
      return ApiResponse.error('Erreur inscription: $e');
    }
  }

  /// Vérification de l'email par OTP
  static Future<ApiResponse<T>> verifyEmail<T>({
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await post<T>(
        verifyEmailUrl,
        body: body,
        fromJson: fromJson,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur vérification email: $e');
    }
  }

  /// Renvoyer le code de vérification email
  static Future<ApiResponse<T>> resendVerification<T>({
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await post<T>(
        resendVerificationUrl,
        body: body,
        fromJson: fromJson,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur renvoi email: $e');
    }
  }

  /// Demande de réinitialisation de mot de passe (mot de passe oublié)
  static Future<ApiResponse<T>> forgotPassword<T>({
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await post<T>(
        forgotPasswordUrl,
        body: body,
        fromJson: fromJson,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur demande réinitialisation: $e');
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
      return ApiResponse.error('Erreur connexion: $e');
    }
  }

  /// Tester la connectivité avec le serveur
  static Future<bool> testConnection() async {
    try {
      final response = await get(
        _moviesRecent,
        timeout: const Duration(seconds: 10),
      );

      final isConnected = response.isSuccess;
      return isConnected;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir l'URL complète d'un endpoint
  static String getFullUrl(String endpoint) {
    return endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint';
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
