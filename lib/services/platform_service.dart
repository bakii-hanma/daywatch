import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';

class PlatformService {
  static const String baseUrl = ServerConfig.apiBaseUrl;

  // Test de connectivité
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Récupérer les contenus d'une plateforme
  static Future<PlatformContentResponse> getPlatformContent(
    String platform, {
    int limit = 50,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/platforms/$platform?limit=$limit'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PlatformContentResponse.fromJson(jsonData);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Impossible de récupérer les contenus: $e');
    }
  }

  // Méthode de diagnostic réseau
  static Future<void> diagnoseNetwork() async {
    try {
      await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // Ignoré
    }
  }
}

// Modèle de réponse pour les contenus de plateforme
class PlatformContentResponse {
  final bool success;
  final String message;
  final int count;
  final PlatformData data;
  final PlatformSource source;
  final PlatformStats stats;
  final String timestamp;
  final PlatformMeta meta;

  PlatformContentResponse({
    required this.success,
    required this.message,
    required this.count,
    required this.data,
    required this.source,
    required this.stats,
    required this.timestamp,
    required this.meta,
  });

  factory PlatformContentResponse.fromJson(Map<String, dynamic> json) {
    return PlatformContentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: PlatformData.fromJson(json['data'] ?? {}),
      source: PlatformSource.fromJson(json['source'] ?? {}),
      stats: PlatformStats.fromJson(json['stats'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      meta: PlatformMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class PlatformData {
  final List<MovieApiModel> movies;
  final List<SeriesApiModel> series;

  PlatformData({required this.movies, required this.series});

  factory PlatformData.fromJson(Map<String, dynamic> json) {
    return PlatformData(
      movies: (json['movies'] as List? ?? [])
          .map((item) => MovieApiModel.fromJson(item))
          .toList(),
      series: (json['series'] as List? ?? [])
          .map((item) => SeriesApiModel.fromJson(item))
          .toList(),
    );
  }
}

class PlatformSource {
  final String movies;
  final String series;

  PlatformSource({required this.movies, required this.series});

  factory PlatformSource.fromJson(Map<String, dynamic> json) {
    return PlatformSource(
      movies: json['movies'] ?? '',
      series: json['series'] ?? '',
    );
  }
}

class PlatformStats {
  final int totalContent;
  final int movies;
  final int series;
  final int totalSize;

  PlatformStats({
    required this.totalContent,
    required this.movies,
    required this.series,
    required this.totalSize,
  });

  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      totalContent: json['totalContent'] ?? 0,
      movies: json['movies'] ?? 0,
      series: json['series'] ?? 0,
      totalSize: json['totalSize'] ?? 0,
    );
  }
}

class PlatformMeta {
  final String endpoint;
  final String version;
  final int requestedLimit;
  final bool enrichmentEnabled;
  final String dataStructure;

  PlatformMeta({
    required this.endpoint,
    required this.version,
    required this.requestedLimit,
    required this.enrichmentEnabled,
    required this.dataStructure,
  });

  factory PlatformMeta.fromJson(Map<String, dynamic> json) {
    return PlatformMeta(
      endpoint: json['endpoint'] ?? '',
      version: json['version'] ?? '',
      requestedLimit: json['requestedLimit'] ?? 0,
      enrichmentEnabled: json['enrichmentEnabled'] ?? false,
      dataStructure: json['dataStructure'] ?? '',
    );
  }
}
