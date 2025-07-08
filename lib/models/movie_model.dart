// Fonction utilitaire pour convertir en double de manière sûre
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
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
  });

  factory MovieApiModel.fromJson(Map<String, dynamic> json) {
    return MovieApiModel(
      id: json['id'] ?? 0,
      tmdbId: json['tmdbId'] ?? 0,
      title: json['title'] ?? '',
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
      images: MovieImages.fromJson(json['images'] ?? {}),
      mediaInfo: ExtendedMovieMediaInfo.fromJson(json['mediaInfo'] ?? {}),
      releaseInfo: MovieReleaseInfo.fromJson(json['releaseInfo'] ?? {}),
      genres: List<String>.from(json['genres'] ?? []),
      studio: json['studio'],
      website: json['website'],
      youTubeTrailerId: json['youTubeTrailerId'],
      collection: json['collection'] != null
          ? MovieCollection.fromJson(json['collection'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      similarMovies: (json['similarMovies'] as List? ?? [])
          .map((item) => SimilarMovie.fromJson(item))
          .toList(),
      cast: json['cast'] != null ? MovieCast.fromJson(json['cast']) : null,
      gallery: json['gallery'] != null
          ? MovieGallery.fromJson(json['gallery'])
          : null,
      boxOffice: json['boxOffice'] != null
          ? MovieBoxOffice.fromJson(json['boxOffice'])
          : null,
      boxOfficeRank: json['boxOfficeRank'],
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
}

class MovieCollection {
  final String title;
  final int tmdbId;

  const MovieCollection({required this.title, required this.tmdbId});

  factory MovieCollection.fromJson(Map<String, dynamic> json) {
    return MovieCollection(
      title: json['title'] ?? '',
      tmdbId: json['tmdbId'] ?? 0,
    );
  }
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      order: json['order'] ?? 0,
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
      id: json['id'] ?? 0,
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
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      originalTitle: json['originalTitle'] ?? '',
      overview: json['overview'] ?? '',
      year: json['year'] ?? 0,
      rating: _toDouble(json['rating']) ?? 0.0,
      popularity: _toDouble(json['popularity']) ?? 0.0,
      poster: json['poster'],
      backdrop: json['backdrop'],
    );
  }
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
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      profit: json['profit'] ?? 0,
      roi: _toDouble(json['roi']) ?? 0.0,
      profitMargin: json['profitMargin'] ?? 0,
    );
  }
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
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
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
      resolution: json['resolution'] ?? 0,
      source: json['source'] ?? '',
    );
  }
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
}

class Language {
  final int id;
  final String name;

  const Language({required this.id, required this.name});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

// Modèle pour les bandes-annonces depuis l'API
class TrailerApiModel {
  final String title;
  final String overview;
  final String releaseDate;
  final String trailerUrl;
  final String posterPath;

  TrailerApiModel({
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.trailerUrl,
    required this.posterPath,
  });

  factory TrailerApiModel.fromJson(Map<String, dynamic> json) {
    return TrailerApiModel(
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      trailerUrl: json['trailerUrl'] ?? '',
      posterPath: json['posterPath'] ?? '',
    );
  }

  // Getter pour obtenir l'URL complète de l'image
  String get fullPosterUrl {
    if (posterPath.isEmpty) return '';
    if (posterPath.startsWith('http')) return posterPath;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  // Getter pour la durée formatée (approximative pour les trailers)
  String get duration => '2-3 min'; // Durée standard des trailers

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
