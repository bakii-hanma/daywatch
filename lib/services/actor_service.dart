import '../models/movie_model.dart';
import 'api_client.dart';

class ActorApiModel {
  final int id;
  final String name;
  final String profilePath;
  final String character;
  final int order;
  final List<ActorMovieModel> movies;
  final List<ActorSeriesModel> series;
  final ActorStats stats;

  ActorApiModel({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.character,
    required this.order,
    required this.movies,
    required this.series,
    required this.stats,
  });

  factory ActorApiModel.fromJson(Map<String, dynamic> json) {
    return ActorApiModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Acteur inconnu',
      profilePath: json['profilePath'] ?? '',
      character: json['character'] ?? '',
      order: json['order'] ?? 0,
      movies:
          (json['movies'] as List<dynamic>?)
              ?.map((movie) => ActorMovieModel.fromJson(movie))
              .toList() ??
          [],
      series:
          (json['series'] as List<dynamic>?)
              ?.map((series) => ActorSeriesModel.fromJson(series))
              .toList() ??
          [],
      stats: ActorStats.fromJson(json['stats'] ?? {}),
    );
  }

  // Méthode pour convertir en ActorModel (pour compatibilité avec les widgets existants)
  ActorModel toActorModel() {
    return ActorModel(
      id: id.toString(),
      name: name,
      imagePath: _getActorImageUrl(),
    );
  }

  String _getActorImageUrl() {
    // Utiliser la vraie image de l'acteur si disponible
    if (profilePath.isNotEmpty) {
      return profilePath;
    }
    // Fallback vers une image par défaut si pas d'image
    return 'https://via.placeholder.com/500x750/4A5568/FFFFFF?text=${Uri.encodeComponent(name)}';
  }
}

class ActorMovieModel {
  final int id;
  final int tmdbId;
  final String title;
  final String originalTitle;
  final String overview;
  final int year;
  final double rating;
  final double? imdbRating;
  final double? tmdbRating;
  final double popularity;
  final int runtime;
  final String? certification;
  final bool isAvailable;
  final bool downloaded;
  final bool monitored;
  final ActorMovieImages images;
  final String character;
  final int order;
  final Map<String, dynamic>? roleInfo;

  ActorMovieModel({
    required this.id,
    required this.tmdbId,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.year,
    required this.rating,
    this.imdbRating,
    this.tmdbRating,
    required this.popularity,
    required this.runtime,
    this.certification,
    required this.isAvailable,
    required this.downloaded,
    required this.monitored,
    required this.images,
    required this.character,
    required this.order,
    this.roleInfo,
  });

  factory ActorMovieModel.fromJson(Map<String, dynamic> json) {
    return ActorMovieModel(
      id: json['id'] ?? 0,
      tmdbId: json['tmdbId'] ?? 0,
      title: json['title'] ?? 'Film inconnu',
      originalTitle: json['originalTitle'] ?? '',
      overview: json['overview'] ?? '',
      year: json['year'] ?? 0,
      rating: _toDouble(json['rating']) ?? 0.0,
      imdbRating: _toDouble(json['imdbRating']),
      tmdbRating: _toDouble(json['tmdbRating']),
      popularity: _toDouble(json['popularity']) ?? 0.0,
      runtime: json['runtime'] ?? 0,
      certification: json['certification'],
      isAvailable: json['isAvailable'] ?? false,
      downloaded: json['downloaded'] ?? false,
      monitored: json['monitored'] ?? false,
      images: ActorMovieImages.fromJson(json['images'] ?? {}),
      character: json['character'] ?? '',
      order: json['order'] ?? 0,
      roleInfo: json['roleInfo'],
    );
  }

  // Méthode utilitaire pour convertir en double de manière sûre
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Conversion simple vers MovieModel pour affichage
  MovieModel toMovieModel() {
    return MovieModel(
      id: id.toString(),
      title: title,
      imagePath: images.poster ?? '',
      genre: '', // À extraire des genres si disponible
      duration: runtime > 0 ? '${runtime}min' : '',
      releaseDate: year.toString(),
      rating: rating,
      description: overview,
    );
  }
}

class ActorMovieImages {
  final String? poster;
  final String? backdrop;
  final String? banner;

  const ActorMovieImages({this.poster, this.backdrop, this.banner});

  factory ActorMovieImages.fromJson(Map<String, dynamic> json) {
    return ActorMovieImages(
      poster: json['poster'],
      backdrop: json['backdrop'],
      banner: json['banner'],
    );
  }
}

class ActorSeriesModel {
  final int id;
  final int tmdbId;
  final String title;
  final String originalTitle;
  final String overview;
  final int year;
  final double rating;
  final double? imdbRating;
  final double? tmdbRating;
  final double popularity;
  final int runtime;
  final String? certification;
  final bool isAvailable;
  final bool downloaded;
  final bool monitored;
  final ActorSeriesImages images;
  final String character;
  final int order;
  final Map<String, dynamic>? roleInfo;

  ActorSeriesModel({
    required this.id,
    required this.tmdbId,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.year,
    required this.rating,
    this.imdbRating,
    this.tmdbRating,
    required this.popularity,
    required this.runtime,
    this.certification,
    required this.isAvailable,
    required this.downloaded,
    required this.monitored,
    required this.images,
    required this.character,
    required this.order,
    this.roleInfo,
  });

  factory ActorSeriesModel.fromJson(Map<String, dynamic> json) {
    return ActorSeriesModel(
      id: json['id'] ?? 0,
      tmdbId: json['tmdbId'] ?? 0,
      title: json['title'] ?? 'Série inconnue',
      originalTitle: json['originalTitle'] ?? '',
      overview: json['overview'] ?? '',
      year: json['year'] ?? 0,
      rating: _toDouble(json['rating']) ?? 0.0,
      imdbRating: _toDouble(json['imdbRating']),
      tmdbRating: _toDouble(json['tmdbRating']),
      popularity: _toDouble(json['popularity']) ?? 0.0,
      runtime: json['runtime'] ?? 0,
      certification: json['certification'],
      isAvailable: json['isAvailable'] ?? false,
      downloaded: json['downloaded'] ?? false,
      monitored: json['monitored'] ?? false,
      images: ActorSeriesImages.fromJson(json['images'] ?? {}),
      character: json['character'] ?? '',
      order: json['order'] ?? 0,
      roleInfo: json['roleInfo'],
    );
  }

  // Méthode utilitaire pour convertir en double de manière sûre
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Conversion simple vers SeriesModel pour affichage
  SeriesModel toSeriesModel() {
    return SeriesModel(
      id: id.toString(),
      title: title,
      imagePath: images.poster ?? '',
      genre: '', // À extraire des genres si disponible
      seasons: '', // À extraire des saisons si disponible
      years: year.toString(),
      rating: rating,
      description: overview,
    );
  }
}

class ActorSeriesImages {
  final String? poster;
  final String? backdrop;
  final String? banner;

  const ActorSeriesImages({this.poster, this.backdrop, this.banner});

  factory ActorSeriesImages.fromJson(Map<String, dynamic> json) {
    return ActorSeriesImages(
      poster: json['poster'],
      backdrop: json['backdrop'],
      banner: json['banner'],
    );
  }
}

class ActorStats {
  final int totalContent;
  final int movies;
  final int series;

  ActorStats({
    required this.totalContent,
    required this.movies,
    required this.series,
  });

  factory ActorStats.fromJson(Map<String, dynamic> json) {
    return ActorStats(
      totalContent: json['totalContent'] ?? 0,
      movies: json['movies'] ?? 0,
      series: json['series'] ?? 0,
    );
  }
}

class ActorResponse {
  final bool success;
  final String message;
  final int count;
  final List<ActorApiModel> data;
  final ActorGlobalStats stats;

  ActorResponse({
    required this.success,
    required this.message,
    required this.count,
    required this.data,
    required this.stats,
  });

  factory ActorResponse.fromJson(Map<String, dynamic> json) {
    return ActorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Aucun message',
      count: json['count'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((actor) => ActorApiModel.fromJson(actor))
              .toList() ??
          [],
      stats: ActorGlobalStats.fromJson(json['stats'] ?? {}),
    );
  }
}

class ActorGlobalStats {
  final int totalActors;
  final int totalContent;
  final int totalMovies;
  final int totalSeries;

  ActorGlobalStats({
    required this.totalActors,
    required this.totalContent,
    required this.totalMovies,
    required this.totalSeries,
  });

  factory ActorGlobalStats.fromJson(Map<String, dynamic> json) {
    return ActorGlobalStats(
      totalActors: json['totalActors'] ?? 0,
      totalContent: json['totalContent'] ?? 0,
      totalMovies: json['totalMovies'] ?? 0,
      totalSeries: json['totalSeries'] ?? 0,
    );
  }
}

class ActorDetailResponse {
  final bool success;
  final String message;
  final ActorApiModel data;

  ActorDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ActorDetailResponse.fromJson(Map<String, dynamic> json) {
    return ActorDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Aucun message',
      data: ActorApiModel.fromJson(json['data'] ?? {}),
    );
  }
}

class ActorService {
  static Future<ActorResponse> getActors({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final endpoint = '/api/actors?limit=$limit&offset=$offset';

      final response = await ApiClient.get<Map<String, dynamic>>(
        endpoint,
        timeout: const Duration(seconds: 45), // L'API d'acteurs est lourde
      );

      if (response.isSuccess && response.data != null) {
        final jsonData = response.data!;
        return ActorResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Erreur lors de la récupération des acteurs: ${response.error}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<ActorDetailResponse> getActorDetails(int actorId) async {
    try {
      final endpoint = '/api/actors/$actorId';

      final response = await ApiClient.get<Map<String, dynamic>>(
        endpoint,
        timeout: const Duration(seconds: 45), // L'API d'acteurs est lourde
      );

      if (response.isSuccess && response.data != null) {
        final jsonData = response.data!;
        return ActorDetailResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Erreur lors de la récupération des détails de l\'acteur: ${response.error}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
