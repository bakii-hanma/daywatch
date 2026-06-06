import '../models/movie_model.dart';
import '../models/series_model.dart';
import 'api_client.dart';
import 'movie_service.dart';

class SearchActorModel {
  final int id;
  final String name;
  final String? profilePath;
  final double popularity;
  final List<String> knownFor;

  SearchActorModel({
    required this.id,
    required this.name,
    this.profilePath,
    required this.popularity,
    required this.knownFor,
  });

  factory SearchActorModel.fromJson(Map<String, dynamic> json) {
    return SearchActorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profilePath'],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      knownFor: List<String>.from(json['knownFor'] ?? []),
    );
  }

  ActorModel toActorModel() {
    return ActorModel(
      id: id.toString(),
      name: name,
      imagePath: profilePath ?? 'https://via.placeholder.com/500x750/4A5568/FFFFFF?text=${Uri.encodeComponent(name)}',
    );
  }
}

class SearchResultModel {
  final List<MovieApiModel> movies;
  final List<SeriesApiModel> series;
  final List<SeriesApiModel> animes;
  final List<SearchActorModel> actors;

  SearchResultModel({
    required this.movies,
    required this.series,
    required this.animes,
    required this.actors,
  });

  factory SearchResultModel.empty() {
    return SearchResultModel(
      movies: [],
      series: [],
      animes: [],
      actors: [],
    );
  }
}

class SearchService {
  static Future<SearchResultModel> search(String query, {int limit = 20}) async {
    try {
      final endpoint = '/api/search?q=${Uri.encodeComponent(query)}&limit=$limit';
      final response = await ApiClient.get<dynamic>(endpoint);

      if (response.isSuccess && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data as Map<dynamic, dynamic>).cast<String, dynamic>();

        final moviesJson = data['movies'] as List<dynamic>? ?? [];
        final seriesJson = data['series'] as List<dynamic>? ?? [];
        final animesJson = data['animes'] as List<dynamic>? ?? [];
        final actorsJson = data['actors'] as List<dynamic>? ?? [];

        // Recherche locale des films en cache à partir de /api/movies
        final allMovies = await MovieService.getOrFetchAllMovies();
        final queryLower = query.toLowerCase();
        final movies = allMovies.where((movie) {
          return movie.title.toLowerCase().contains(queryLower) ||
                 movie.originalTitle.toLowerCase().contains(queryLower);
        }).take(limit).toList();

        final series = seriesJson
            .map((json) => SeriesApiModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        final animes = animesJson
            .map((json) => SeriesApiModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        final actors = actorsJson
            .map((json) => SearchActorModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        return SearchResultModel(
          movies: movies,
          series: series,
          animes: animes,
          actors: actors,
        );
      }
      return SearchResultModel.empty();
    } catch (e) {
      return SearchResultModel.empty();
    }
  }
}
