import '../config/server_config.dart';

String _resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  if (url.startsWith('/')) {
    return '${ServerConfig.apiBaseUrl}$url';
  }
  return url;
}

// Fonction utilitaire pour convertir en double de manière sûre
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

// Extrait poster/backdrop/banner quel que soit le format (tableau Radarr ou objet normalisé)
MovieImages _parseImages(dynamic raw) {
  if (raw == null) return const MovieImages();

  // Format normalisé : {"poster":"...", "backdrop":"...", "banner":"..."}
  if (raw is Map) {
    if (!raw.containsKey('coverType')) {
      return MovieImages(
        poster: _resolveImageUrl(raw['poster'] as String?),
        backdrop: _resolveImageUrl(raw['backdrop'] as String?),
        banner: _resolveImageUrl(raw['banner'] as String?),
      );
    }
  }

  // Format Radarr natif : [{"coverType":"poster","remoteUrl":"..."}, ...]
  if (raw is List) {
    String? poster, backdrop, banner;
    for (final img in raw) {
      if (img is! Map) continue;
      final type = img['coverType']?.toString() ?? '';
      final url = img['remoteUrl']?.toString() ?? img['url']?.toString();
      if (url == null || url.isEmpty) continue;
      if (type == 'poster') {
        poster = url;
      } else if (type == 'fanart' || type == 'backdrop') {
        backdrop = url;
      } else if (type == 'banner') {
        banner = url;
      }
    }
    return MovieImages(
      poster: _resolveImageUrl(poster),
      backdrop: _resolveImageUrl(backdrop),
      banner: _resolveImageUrl(banner),
    );
  }

  return const MovieImages();
}

// Extrait rating/imdbRating/tmdbRating depuis ratings Radarr ou champs directs
(double rating, double? imdbRating, double? tmdbRating) _parseRatings(Map<String, dynamic> json) {
  double rating = 0.0;
  double? imdbRating;
  double? tmdbRating;

  // Format Radarr : ratings.tmdb.value / ratings.imdb.value
  final ratingsMap = json['ratings'];
  if (ratingsMap is Map) {
    final tmdbR = ratingsMap['tmdb'];
    final imdbR = ratingsMap['imdb'];
    if (tmdbR is Map) {
      tmdbRating = _toDouble(tmdbR['value']);
      rating = tmdbRating ?? 0.0;
    }
    if (imdbR is Map) {
      imdbRating = _toDouble(imdbR['value']);
      if (rating == 0.0) rating = imdbRating ?? 0.0;
    }
  }

  // Format normalisé : champs directs
  if (rating == 0.0) rating = _toDouble(json['rating']) ?? 0.0;
  imdbRating ??= _toDouble(json['imdbRating']);
  tmdbRating ??= _toDouble(json['tmdbRating']);

  return (rating, imdbRating, tmdbRating);
}

class MovieModel {
  final String id;
  final String title;
  final String imagePath;
  final String genre;
  final String duration;
  final String releaseDate;
  final double rating;
  final String description;

  const MovieModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.genre,
    required this.duration,
    required this.releaseDate,
    required this.rating,
    this.description = '',
  });
}

class SeriesModel {
  final String id;
  final String title;
  final String imagePath;
  final String genre;
  final String seasons;
  final String years;
  final double rating;
  final String description;

  const SeriesModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.genre,
    required this.seasons,
    required this.years,
    required this.rating,
    this.description = '',
  });
}

class ActorModel {
  final String id;
  final String name;
  final String imagePath;
  final String bio;

  const ActorModel({
    required this.id,
    required this.name,
    required this.imagePath,
    this.bio = '',
  });
}

class TrailerModel {
  final String id;
  final String title;
  final String imagePath;
  final String duration;
  final String videoUrl;

  const TrailerModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.duration,
    this.videoUrl = '',
  });
}

class BoxOfficeModel {
  final String id;
  final String title;
  final String imagePath;
  final String earnings;
  final String duration;
  final String releaseDate;
  final double rating;
  final int rank;

  const BoxOfficeModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.earnings,
    required this.duration,
    required this.releaseDate,
    required this.rating,
    required this.rank,
  });
}

class PlatformModel {
  final String id;
  final String name;
  final String imagePath;

  const PlatformModel({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}

class EpisodeModel {
  final String id;
  final String title;
  final String imagePath;
  final String duration;
  final String description;
  final int episodeNumber;
  final double rating;

  const EpisodeModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.duration,
    required this.description,
    required this.episodeNumber,
    required this.rating,
  });
}

class SeasonModel {
  final String id;
  final String title;
  final String imagePath; // Image principale (poster par défaut)
  final String? poster; // Poster spécifique de la saison
  final String? fanart; // Fanart de la saison
  final String? banner; // Banner de la saison
  final String episodes;
  final String year;
  final double rating;
  final String description;
  final List<EpisodeModel> episodesList;

  const SeasonModel({
    required this.id,
    required this.title,
    required this.imagePath,
    this.poster,
    this.fanart,
    this.banner,
    required this.episodes,
    required this.year,
    required this.rating,
    required this.description,
    required this.episodesList,
  });

  // Méthode pour obtenir l'image de fond (fanart en priorité, puis banner, puis imagePath)
  String getBackgroundImage() {
    if (fanart != null && fanart!.isNotEmpty) {
      return fanart!;
    }
    if (banner != null && banner!.isNotEmpty) {
      return banner!;
    }
    return imagePath;
  }

  // Méthode pour obtenir l'image du poster (poster en priorité, puis imagePath)
  String getPosterImage() {
    if (poster != null && poster!.isNotEmpty) {
      return poster!;
    }
    return imagePath;
  }
}

// Nouveau modèle pour l'API Radarr
class MovieApiModel {
  final String id;
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
  final MovieImages images;
  final ExtendedMovieMediaInfo mediaInfo;
  final MovieReleaseInfo releaseInfo;
  final List<String> genres;
  final String? studio;
  final String? website;
  final String? youTubeTrailerId;
  final MovieCollection? collection;
  final List<String> tags;
  final List<SimilarMovie> similarMovies;
  final MovieCast? cast;
  final MovieGallery? gallery;
  final MovieBoxOffice? boxOffice;
  final int? boxOfficeRank;
  final String? tagline;

  const MovieApiModel({
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
    required this.mediaInfo,
    required this.releaseInfo,
    required this.genres,
    this.studio,
    this.website,
    this.youTubeTrailerId,
    this.collection,
    required this.tags,
    this.similarMovies = const [],
    this.cast,
    this.gallery,
    this.boxOffice,
    this.boxOfficeRank,
    this.tagline,
  });

  factory MovieApiModel.fromJson(Map<String, dynamic> json) {
    // Fonctionne pour les deux formats : normalisé ET Radarr natif
    final images = _parseImages(json['images']);
    final (rating, imdbRating, tmdbRating) = _parseRatings(json);

    // mediaInfo : format normalisé (objet direct) ou Radarr (via movieFile)
    ExtendedMovieMediaInfo mediaInfo;
    if (json['mediaInfo'] is Map<String, dynamic>) {
      mediaInfo = ExtendedMovieMediaInfo.fromJson(json['mediaInfo'] as Map<String, dynamic>);
    } else {
      // Format Radarr : extraire depuis movieFile
      final movieFile = json['movieFile'];
      if (movieFile is Map) {
        final qualityField = movieFile['quality'];
        String? quality;
        if (qualityField is Map) {
          final qi = qualityField['quality'];
          quality = qi is Map ? qi['name']?.toString() : null;
        } else {
          quality = qualityField?.toString();
        }
        final mInfo = movieFile['mediaInfo'];
        String? resolution, videoCodec, audioCodec;
        if (mInfo is Map) {
          resolution = '${mInfo['width'] ?? 0}x${mInfo['height'] ?? 0}';
          videoCodec = mInfo['videoCodec']?.toString();
          audioCodec = mInfo['audioCodecID']?.toString() ?? mInfo['audioCodec']?.toString();
        }
        final path = movieFile['path']?.toString() ?? json['path']?.toString();
        mediaInfo = ExtendedMovieMediaInfo(
          path: path,
          folderName: json['folderName']?.toString(),
          quality: quality,
          sizeOnDisk: _toDouble(movieFile['size']) ?? 0.0,
          resolution: resolution,
          isStreamable: json['hasFile'] ?? false,
          videoCodec: videoCodec,
          audioCodec: audioCodec,
          fullPath: path,
        );
      } else {
        mediaInfo = ExtendedMovieMediaInfo.empty();
      }
    }

    // releaseInfo : format normalisé (objet) ou Radarr (champs directs)
    final MovieReleaseInfo releaseInfo;
    if (json['releaseInfo'] is Map<String, dynamic>) {
      releaseInfo = MovieReleaseInfo.fromJson(json['releaseInfo'] as Map<String, dynamic>);
    } else {
      releaseInfo = MovieReleaseInfo(
        inCinemas: json['inCinemas']?.toString(),
        digitalRelease: json['digitalRelease']?.toString(),
        physicalRelease: json['physicalRelease']?.toString(),
        status: json['status']?.toString(),
      );
    }

    // genres : liste de strings (les deux formats)
    final genresList = json['genres'];
    final genres = genresList is List
        ? genresList.map((g) => g.toString()).toList()
        : <String>[];

    // tags : chaine dans format normalisé, entiers dans Radarr (ignorés)
    final tagsList = json['tags'];
    final tags = (tagsList is List && tagsList.isNotEmpty && tagsList.first is String)
        ? List<String>.from(tagsList)
        : <String>[];

    return MovieApiModel(
      id: json['id']?.toString() ?? '0',
      tmdbId: _toInt(json['tmdbId']),
      title: json['title'] ?? '',
      originalTitle: json['originalTitle'] ?? '',
      overview: json['overview'] ?? '',
      year: _toInt(json['year']),
      rating: rating,
      imdbRating: imdbRating,
      tmdbRating: tmdbRating,
      popularity: _toDouble(json['popularity']) ?? 0.0,
      runtime: _toInt(json['runtime']),
      certification: json['certification']?.toString(),
      isAvailable: json['isAvailable'] ?? json['hasFile'] ?? false,
      downloaded: json['downloaded'] ?? json['hasFile'] ?? false,
      monitored: json['monitored'] ?? false,
      images: images,
      mediaInfo: mediaInfo,
      releaseInfo: releaseInfo,
      genres: genres,
      studio: json['studio']?.toString(),
      website: json['website']?.toString(),
      youTubeTrailerId: json['youTubeTrailerId']?.toString(),
      collection: json['collection'] is Map
          ? MovieCollection.fromJson(json['collection'] as Map<String, dynamic>)
          : null,
      tags: tags,
      similarMovies: (json['similarMovies'] as List? ?? [])
          .map((item) => SimilarMovie.fromJson(item as Map<String, dynamic>))
          .toList(),
      cast: json['cast'] != null && json['cast'] is Map
          ? MovieCast.fromJson(json['cast'] as Map<String, dynamic>)
          : null,
      gallery: json['gallery'] != null && json['gallery'] is Map
          ? MovieGallery.fromJson(json['gallery'] as Map<String, dynamic>)
          : null,
      boxOffice: json['boxOffice'] != null && json['boxOffice'] is Map
          ? MovieBoxOffice.fromJson(json['boxOffice'] as Map<String, dynamic>)
          : null,
      boxOfficeRank: json['boxOfficeRank'] != null ? _toInt(json['boxOfficeRank']) : null,
      tagline: json['tagline']?.toString(),
    );
  }

  /// Alias de fromJson — le format est détecté automatiquement.
  factory MovieApiModel.fromRadarrJson(Map<String, dynamic> json) =>
      MovieApiModel.fromJson(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tmdbId': tmdbId,
      'title': title,
      'originalTitle': originalTitle,
      'overview': overview,
      'year': year,
      'rating': rating,
      'imdbRating': imdbRating,
      'tmdbRating': tmdbRating,
      'popularity': popularity,
      'runtime': runtime,
      'certification': certification,
      'isAvailable': isAvailable,
      'downloaded': downloaded,
      'monitored': monitored,
      'images': images.toJson(),
      'mediaInfo': mediaInfo.toJson(),
      'releaseInfo': releaseInfo.toJson(),
      'genres': genres,
      'studio': studio,
      'website': website,
      'youTubeTrailerId': youTubeTrailerId,
      'collection': collection?.toJson(),
      'tags': tags,
      'similarMovies': similarMovies.map((m) => m.toJson()).toList(),
      'cast': cast?.toJson(),
      'gallery': gallery?.toJson(),
      'boxOffice': boxOffice?.toJson(),
      'boxOfficeRank': boxOfficeRank,
      'tagline': tagline,
    };
  }

  MovieApiModel copyWith({
    String? id,
    int? tmdbId,
    String? title,
    String? originalTitle,
    String? overview,
    int? year,
    double? rating,
    double? imdbRating,
    double? tmdbRating,
    double? popularity,
    int? runtime,
    String? certification,
    bool? isAvailable,
    bool? downloaded,
    bool? monitored,
    MovieImages? images,
    ExtendedMovieMediaInfo? mediaInfo,
    MovieReleaseInfo? releaseInfo,
    List<String>? genres,
    String? studio,
    String? website,
    String? youTubeTrailerId,
    MovieCollection? collection,
    List<String>? tags,
    List<SimilarMovie>? similarMovies,
    MovieCast? cast,
    MovieGallery? gallery,
    MovieBoxOffice? boxOffice,
    int? boxOfficeRank,
    String? tagline,
  }) {
    return MovieApiModel(
      id: id ?? this.id,
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      overview: overview ?? this.overview,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      imdbRating: imdbRating ?? this.imdbRating,
      tmdbRating: tmdbRating ?? this.tmdbRating,
      popularity: popularity ?? this.popularity,
      runtime: runtime ?? this.runtime,
      certification: certification ?? this.certification,
      isAvailable: isAvailable ?? this.isAvailable,
      downloaded: downloaded ?? this.downloaded,
      monitored: monitored ?? this.monitored,
      images: images ?? this.images,
      mediaInfo: mediaInfo ?? this.mediaInfo,
      releaseInfo: releaseInfo ?? this.releaseInfo,
      genres: genres ?? this.genres,
      studio: studio ?? this.studio,
      website: website ?? this.website,
      youTubeTrailerId: youTubeTrailerId ?? this.youTubeTrailerId,
      collection: collection ?? this.collection,
      tags: tags ?? this.tags,
      similarMovies: similarMovies ?? this.similarMovies,
      cast: cast ?? this.cast,
      gallery: gallery ?? this.gallery,
      boxOffice: boxOffice ?? this.boxOffice,
      boxOfficeRank: boxOfficeRank ?? this.boxOfficeRank,
      tagline: tagline ?? this.tagline,
    );
  }

  // Méthode pour parser les données essentielles (nouvelle structure)
  factory MovieApiModel.fromEssentialJson(Map<String, dynamic> json) {
    // Extraire l'année depuis releaseDate
    int year = 0;
    if (json['releaseDate'] != null) {
      final releaseDate = json['releaseDate'] as String;
      // Essayer d'extraire l'année depuis "25 avril 2012" ou "2012-04-25"
      final yearMatch = RegExp(r'(\d{4})').firstMatch(releaseDate);
      if (yearMatch != null) {
        year = int.tryParse(yearMatch.group(1)!) ?? 0;
      }
    }

    // Extraire la durée en minutes depuis "2h 23" ou "1h 57"
    int runtime = 0;
    if (json['runtime'] != null) {
      final runtimeStr = json['runtime'] as String;
      final hoursMatch = RegExp(r'(\d+)h').firstMatch(runtimeStr);
      final minutesMatch = RegExp(r'(\d+)').allMatches(runtimeStr);

      int hours = 0;
      int minutes = 0;

      if (hoursMatch != null) {
        hours = int.tryParse(hoursMatch.group(1)!) ?? 0;
      }

      if (minutesMatch.length > 1) {
        minutes = int.tryParse(minutesMatch.last.group(1)!) ?? 0;
      }

      runtime = hours * 60 + minutes;
    }

    // Convertir les genres de List<String> vers List<String>
    List<String> genres = [];
    if (json['genres'] != null) {
      genres = List<String>.from(json['genres']);
    }

    return MovieApiModel(
      id: json['id']?.toString() ?? '0',
      tmdbId: _toInt(json['tmdbId']),
      title: json['title'] ?? '',
      originalTitle: json['originalTitle'] ?? '',
      overview: '', // Pas d'overview dans les données essentielles
      year: year,
      rating: _toDouble(json['rating']) ?? 0.0,
      imdbRating: null,
      tmdbRating: null,
      popularity: 0.0, // Pas de popularité dans les données essentielles
      runtime: runtime,
      certification: null,
      isAvailable: json['isAvailable'] ?? false,
      downloaded:
          false, // Pas d'info de téléchargement dans les données essentielles
      monitored:
          false, // Pas d'info de monitoring dans les données essentielles
      images: MovieImages(poster: json['poster'], backdrop: null, banner: null),
      mediaInfo: ExtendedMovieMediaInfo.empty(),
      releaseInfo: MovieReleaseInfo.empty(),
      genres: genres,
      studio: null,
      website: null,
      youTubeTrailerId: null,
      collection: null,
      tags: [], // Pas de tags dans les données essentielles
      similarMovies: [],
      cast: null,
      gallery: null,
      boxOffice: null,
      boxOfficeRank: null,
      tagline: json['tagline']?.toString(),
    );
  }



  // Méthode pour convertir vers l'ancien modèle pour compatibilité
  MovieModel toMovieModel() {
    return MovieModel(
      id: id.toString(),
      title: title,
      imagePath: images.poster ?? '',
      genre: genres.isNotEmpty ? genres.first : '',
      duration: '${runtime}min',
      releaseDate: year.toString(),
      rating: rating,
      description: overview,
    );
  }

  // Méthode pour convertir vers BoxOfficeModel pour compatibilité
  BoxOfficeModel toBoxOfficeModel() {
    // Utiliser uniquement les fanarts (backdrops) pour le box office
    String imagePath = '';
    if (images.backdrop != null && images.backdrop!.isNotEmpty) {
      imagePath = images.backdrop!;
    } else if (gallery != null && gallery!.backdrops.isNotEmpty) {
      // Utiliser le premier backdrop de la galerie
      imagePath = gallery!.backdrops.first.filePath;
    }
    // Si aucun fanart n'est disponible, on laisse imagePath vide
    // Le widget BoxOfficeCard gérera l'affichage d'un placeholder

    return BoxOfficeModel(
      id: id.toString(),
      title: title,
      imagePath: imagePath,
      earnings: boxOffice != null ? _formatEarnings(boxOffice!.revenue) : '',
      duration: '${runtime}min',
      releaseDate: year.toString(),
      rating: rating,
      rank: boxOfficeRank ?? 0,
    );
  }

  // Méthode utilitaire pour formater les gains
  String _formatEarnings(int revenue) {
    if (revenue >= 1000000000) {
      return '\$${(revenue / 1000000000).toStringAsFixed(1)}B';
    } else if (revenue >= 1000000) {
      return '\$${(revenue / 1000000).toStringAsFixed(1)}M';
    } else if (revenue >= 1000) {
      return '\$${(revenue / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$$revenue';
    }
  }
}

class MovieImages {
  final String? poster;
  final String? backdrop;
  final String? banner;

  const MovieImages({this.poster, this.backdrop, this.banner});

  factory MovieImages.fromJson(Map<String, dynamic> json) {
    return MovieImages(
      poster: json['poster'],
      backdrop: json['backdrop'],
      banner: json['banner'],
    );
  }

  Map<String, dynamic> toJson() => {
    'poster': poster,
    'backdrop': backdrop,
    'banner': banner,
  };
}

class MovieMediaInfo {
  final String? path;
  final String? folderName;
  final String? quality;
  final double sizeOnDisk;
  final String? format;
  final String? resolution;
  final bool isStreamable;
  final String? videoCodec;
  final String? audioCodec;

  const MovieMediaInfo({
    this.path,
    this.folderName,
    this.quality,
    this.sizeOnDisk = 0,
    this.format,
    this.resolution,
    this.isStreamable = false,
    this.videoCodec,
    this.audioCodec,
  });

  factory MovieMediaInfo.fromJson(Map<String, dynamic> json) {
    return MovieMediaInfo(
      path: json['path'],
      folderName: json['folderName'],
      quality: json['quality'],
      sizeOnDisk: _toDouble(json['sizeOnDisk']) ?? 0.0,
      format: json['format'],
      resolution: json['resolution'],
      isStreamable: json['isStreamable'] ?? false,
      videoCodec: json['videoCodec'],
      audioCodec: json['audioCodec'],
    );
  }

  Map<String, dynamic> toJson() => {
    'path': path,
    'folderName': folderName,
    'quality': quality,
    'sizeOnDisk': sizeOnDisk,
    'format': format,
    'resolution': resolution,
    'isStreamable': isStreamable,
    'videoCodec': videoCodec,
    'audioCodec': audioCodec,
  };
}

class MovieReleaseInfo {
  final String? inCinemas;
  final String? digitalRelease;
  final String? physicalRelease;
  final String? status;

  const MovieReleaseInfo({
    this.inCinemas,
    this.digitalRelease,
    this.physicalRelease,
    this.status,
  });

  factory MovieReleaseInfo.fromJson(Map<String, dynamic> json) {
    return MovieReleaseInfo(
      inCinemas: json['inCinemas'],
      digitalRelease: json['digitalRelease'],
      physicalRelease: json['physicalRelease'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'inCinemas': inCinemas,
    'digitalRelease': digitalRelease,
    'physicalRelease': physicalRelease,
    'status': status,
  };

  // Méthode pour créer une instance vide
  static MovieReleaseInfo empty() {
    return const MovieReleaseInfo(
      inCinemas: null,
      digitalRelease: null,
      physicalRelease: null,
      status: null,
    );
  }
}

class MovieCollection {
  final String title;
  final int tmdbId;

  const MovieCollection({required this.title, required this.tmdbId});

  factory MovieCollection.fromJson(Map<String, dynamic> json) {
    return MovieCollection(
      title: json['title'] ?? '',
      tmdbId: _toInt(json['tmdbId']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'tmdbId': tmdbId,
  };
}

class MovieCast {
  final List<CastMember> cast;
  final List<CrewMember> crew;

  const MovieCast({required this.cast, required this.crew});

  factory MovieCast.fromJson(Map<String, dynamic> json) {
    return MovieCast(
      cast: (json['cast'] as List? ?? [])
          .map((item) => CastMember.fromJson(item))
          .toList(),
      crew: (json['crew'] as List? ?? [])
          .map((item) => CrewMember.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'cast': cast.map((c) => c.toJson()).toList(),
    'crew': crew.map((c) => c.toJson()).toList(),
  };
}

class CastMember {
  final int id;
  final String name;
  final String character;
  final int order;
  final String? profilePath;
  final double popularity;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.order,
    this.profilePath,
    required this.popularity,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      order: _toInt(json['order']),
      profilePath: json['profilePath'],
      popularity: _toDouble(json['popularity']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'character': character,
    'order': order,
    'profilePath': profilePath,
    'popularity': popularity,
  };
}

class CrewMember {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  const CrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      job: json['job'] ?? '',
      department: json['department'] ?? '',
      profilePath: json['profilePath'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'job': job,
    'department': department,
    'profilePath': profilePath,
  };
}

// Nouveaux modèles pour supporter les données complètes de l'API
class SimilarMovie {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final int year;
  final double rating;
  final double popularity;
  final String? poster;
  final String? backdrop;

  const SimilarMovie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.year,
    required this.rating,
    required this.popularity,
    this.poster,
    this.backdrop,
  });

  factory SimilarMovie.fromJson(Map<String, dynamic> json) {
    return SimilarMovie(
      id: _toInt(json['id']),
      title: json['title'] ?? '',
      originalTitle: json['originalTitle'] ?? '',
      overview: json['overview'] ?? '',
      year: _toInt(json['year']),
      rating: _toDouble(json['rating']) ?? 0.0,
      popularity: _toDouble(json['popularity']) ?? 0.0,
      poster: json['poster'],
      backdrop: json['backdrop'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'originalTitle': originalTitle,
    'overview': overview,
    'year': year,
    'rating': rating,
    'popularity': popularity,
    'poster': poster,
    'backdrop': backdrop,
  };
}

class MovieGallery {
  final List<GalleryImage> backdrops;
  final List<GalleryImage> posters;

  const MovieGallery({required this.backdrops, required this.posters});

  factory MovieGallery.fromJson(Map<String, dynamic> json) {
    return MovieGallery(
      backdrops: (json['backdrops'] as List? ?? [])
          .map((item) => GalleryImage.fromJson(item))
          .toList(),
      posters: (json['posters'] as List? ?? [])
          .map((item) => GalleryImage.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'backdrops': backdrops.map((b) => b.toJson()).toList(),
    'posters': posters.map((p) => p.toJson()).toList(),
  };
}

class MovieBoxOffice {
  final int budget;
  final int revenue;
  final int profit;
  final double roi;
  final int profitMargin;

  const MovieBoxOffice({
    required this.budget,
    required this.revenue,
    required this.profit,
    required this.roi,
    required this.profitMargin,
  });

  factory MovieBoxOffice.fromJson(Map<String, dynamic> json) {
    return MovieBoxOffice(
      budget: _toInt(json['budget']),
      revenue: _toInt(json['revenue']),
      profit: _toInt(json['profit']),
      roi: _toDouble(json['roi']) ?? 0.0,
      profitMargin: _toInt(json['profitMargin']),
    );
  }

  Map<String, dynamic> toJson() => {
    'budget': budget,
    'revenue': revenue,
    'profit': profit,
    'roi': roi,
    'profitMargin': profitMargin,
  };
}

class GalleryImage {
  final String filePath;
  final int width;
  final int height;
  final double aspectRatio;
  final double voteAverage;
  final String? language;

  const GalleryImage({
    required this.filePath,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.voteAverage,
    this.language,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      filePath: json['filePath'] ?? '',
      width: _toInt(json['width']),
      height: _toInt(json['height']),
      aspectRatio: _toDouble(json['aspectRatio']) ?? 1.0,
      voteAverage: _toDouble(json['voteAverage']) ?? 0.0,
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'width': width,
    'height': height,
    'aspectRatio': aspectRatio,
    'voteAverage': voteAverage,
    'language': language,
  };
}

class ExtendedMovieMediaInfo extends MovieMediaInfo {
  final String? fileName;
  final String? fullPath;
  final String? relativePath;
  final double fileSize;
  final String? fileDateAdded;
  final String? streamUrl;
  final QualityDetails? qualityDetails;
  final TechnicalInfo? technicalInfo;
  final List<Language> languages;

  const ExtendedMovieMediaInfo({
    super.path,
    super.folderName,
    super.quality,
    super.sizeOnDisk,
    super.format,
    super.resolution,
    super.isStreamable,
    super.videoCodec,
    super.audioCodec,
    this.fileName,
    this.fullPath,
    this.relativePath,
    this.fileSize = 0,
    this.fileDateAdded,
    this.streamUrl,
    this.qualityDetails,
    this.technicalInfo,
    this.languages = const [],
  });

  factory ExtendedMovieMediaInfo.fromJson(Map<String, dynamic> json) {
    return ExtendedMovieMediaInfo(
      path: json['path'],
      folderName: json['folderName'],
      quality: json['quality'],
      sizeOnDisk: _toDouble(json['sizeOnDisk']) ?? 0.0,
      format: json['format'],
      resolution: json['resolution'],
      isStreamable: json['isStreamable'] ?? false,
      videoCodec: json['videoCodec'],
      audioCodec: json['audioCodec'],
      fileName: json['fileName'],
      fullPath: json['fullPath'],
      relativePath: json['relativePath'],
      fileSize: _toDouble(json['fileSize']) ?? 0.0,
      fileDateAdded: json['fileDateAdded'],
      streamUrl: json['streamUrl'],
      qualityDetails: json['qualityDetails'] != null
          ? QualityDetails.fromJson(json['qualityDetails'])
          : null,
      technicalInfo: json['technicalInfo'] != null
          ? TechnicalInfo.fromJson(json['technicalInfo'])
          : null,
      languages: (json['languages'] as List? ?? [])
          .map((item) => Language.fromJson(item))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'fileName': fileName,
      'fullPath': fullPath,
      'relativePath': relativePath,
      'fileSize': fileSize,
      'fileDateAdded': fileDateAdded,
      'streamUrl': streamUrl,
      'qualityDetails': qualityDetails?.toJson(),
      'technicalInfo': technicalInfo?.toJson(),
      'languages': languages.map((l) => l.toJson()).toList(),
    });
    return map;
  }

  // Méthode pour créer une instance vide
  static ExtendedMovieMediaInfo empty() {
    return ExtendedMovieMediaInfo(
      path: null,
      folderName: null,
      quality: null,
      sizeOnDisk: 0,
      format: null,
      resolution: null,
      isStreamable: false,
      videoCodec: null,
      audioCodec: null,
      fileName: null,
      fullPath: null,
      relativePath: null,
      fileSize: 0,
      fileDateAdded: null,
      streamUrl: null,
      qualityDetails: null,
      technicalInfo: null,
      languages: const [],
    );
  }
}

class QualityDetails {
  final String name;
  final int resolution;
  final String source;

  const QualityDetails({
    required this.name,
    required this.resolution,
    required this.source,
  });

  factory QualityDetails.fromJson(Map<String, dynamic> json) {
    return QualityDetails(
      name: json['name'] ?? '',
      resolution: _toInt(json['resolution']),
      source: json['source'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'resolution': resolution,
    'source': source,
  };
}

class TechnicalInfo {
  final String? videoCodec;
  final double? videoBitrate;
  final double? videoFps;
  final String? audioCodec;
  final double? audioBitrate;
  final dynamic audioChannels; // Peut être int, double ou String (comme "5.1")
  final String? audioLanguages;
  final String? subtitles;
  final String? resolution;
  final String? scanType;
  final String? runtime;

  const TechnicalInfo({
    this.videoCodec,
    this.videoBitrate,
    this.videoFps,
    this.audioCodec,
    this.audioBitrate,
    this.audioChannels,
    this.audioLanguages,
    this.subtitles,
    this.resolution,
    this.scanType,
    this.runtime,
  });

  factory TechnicalInfo.fromJson(Map<String, dynamic> json) {
    return TechnicalInfo(
      videoCodec: json['videoCodec'],
      videoBitrate: _toDouble(json['videoBitrate']),
      videoFps: _toDouble(json['videoFps']),
      audioCodec: json['audioCodec'],
      audioBitrate: _toDouble(json['audioBitrate']),
      audioChannels: json['audioChannels'],
      audioLanguages: json['audioLanguages'],
      subtitles: json['subtitles'],
      resolution: json['resolution'],
      scanType: json['scanType'],
      runtime: json['runtime'],
    );
  }

  Map<String, dynamic> toJson() => {
    'videoCodec': videoCodec,
    'videoBitrate': videoBitrate,
    'videoFps': videoFps,
    'audioCodec': audioCodec,
    'audioBitrate': audioBitrate,
    'audioChannels': audioChannels,
    'audioLanguages': audioLanguages,
    'subtitles': subtitles,
    'resolution': resolution,
    'scanType': scanType,
    'runtime': runtime,
  };
}

class Language {
  final int id;
  final String name;

  const Language({required this.id, required this.name});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(id: _toInt(json['id']), name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

// Modèle pour les bandes-annonces depuis l'API
class TrailerApiModel {
  final String title;
  final String overview;
  final String releaseDate;
  final String trailerUrl;
  final String posterPath;
  final String backdropPath;

  TrailerApiModel({
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.trailerUrl,
    required this.posterPath,
    required this.backdropPath,
  });

  factory TrailerApiModel.fromJson(Map<String, dynamic> json) {
    return TrailerApiModel(
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      trailerUrl: json['trailerUrl'] ?? '',
      posterPath: json['poster'] ?? json['posterPath'] ?? '',
      backdropPath: json['backdrop'] ?? json['backdropPath'] ?? '',
    );
  }

  // Getter pour obtenir l'URL complète de l'image (de préférence le backdrop pour le format paysage)
  String get fullPosterUrl {
    if (backdropPath.isNotEmpty) {
      if (backdropPath.startsWith('http')) return backdropPath;
      return 'https://image.tmdb.org/t/p/w780$backdropPath';
    }
    if (posterPath.isEmpty) return '';
    if (posterPath.startsWith('http')) return posterPath;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  // Getter pour la durée formatée (retirée pour les trailers)
  String get duration => '';

  // Getter pour l'année depuis releaseDate
  String get year {
    if (releaseDate.isEmpty) return '';
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (e) {
      return '';
    }
  }
}
