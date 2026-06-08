import 'movie_model.dart';

class SeriesApiModel {
  final String
  id; // Changé de int à String pour gérer les IDs comme "tmdb_93405"
  final int tmdbId;
  final String title;
  final String sortTitle;
  final int year;
  final String status;
  final String overview;
  final String network;
  final String airTime;
  final String poster;
  final String banner;
  final String fanart;
  final double rating;
  final String certification;
  final List<String> genres;
  final int runtime;
  final String premiered;
  final bool ended;
  final bool isAvailable;
  final bool monitored;
  final String path;
  final EpisodeStats episodeStats;
  final SeasonInfo seasonInfo;
  final String? imdbId;
  final int? tvdbId;
  final int? tvMazeId;
  final MovieCast? cast;
  final MovieGallery? gallery;
  // Cache des épisodes par saison
  final Map<int, List<EpisodeApiModel>> episodesBySeason;

  SeriesApiModel({
    required this.id, // Maintenant un String
    required this.tmdbId,
    required this.title,
    required this.sortTitle,
    required this.year,
    required this.status,
    required this.overview,
    required this.network,
    required this.airTime,
    required this.poster,
    required this.banner,
    required this.fanart,
    required this.rating,
    required this.certification,
    required this.genres,
    required this.runtime,
    required this.premiered,
    required this.ended,
    required this.isAvailable,
    required this.monitored,
    required this.path,
    required this.episodeStats,
    required this.seasonInfo,
    this.imdbId,
    this.tvdbId,
    this.tvMazeId,
    this.cast,
    this.gallery,
    this.episodesBySeason = const {},
  });

  factory SeriesApiModel.fromJson(Map<String, dynamic> json) {
    // Extraire les images directement depuis la réponse JSON
    // D'après la réponse de l'API, ces champs sont disponibles directement
    String poster = json['poster'] ?? '';
    String banner = json['banner'] ?? '';
    String fanart = json['fanart'] ?? '';

    // Si les champs directs sont vides, essayer de les extraire depuis le tableau images (fallback)
    if (poster.isEmpty || banner.isEmpty || fanart.isEmpty) {
      final List<dynamic> images = json['images'] ?? [];

      for (var image in images) {
        final String coverType = image['coverType'] ?? '';
        final String remoteUrl = image['remoteUrl'] ?? '';

        // Prendre uniquement les remoteUrl (comme pour les films)
        if (remoteUrl.isNotEmpty) {
          switch (coverType) {
            case 'poster':
              if (poster.isEmpty) poster = remoteUrl;
              break;
            case 'banner':
              if (banner.isEmpty) banner = remoteUrl;
              break;
            case 'fanart':
              if (fanart.isEmpty) fanart = remoteUrl;
              break;
          }
        }
      }
    }

    // Extraire les épisodes si disponibles dans la réponse
    Map<int, List<EpisodeApiModel>> episodesBySeason = {};
    if (json['episodes'] != null) {
      final List<dynamic> episodesData = json['episodes'] as List<dynamic>;
      for (var episodeData in episodesData) {
        final episode = EpisodeApiModel.fromJson(episodeData);
        final seasonNumber = episode.seasonNumber;
        if (!episodesBySeason.containsKey(seasonNumber)) {
          episodesBySeason[seasonNumber] = [];
        }
        episodesBySeason[seasonNumber]!.add(episode);
      }

      // Trier les épisodes par numéro d'épisode dans chaque saison
      for (var seasonNumber in episodesBySeason.keys) {
        episodesBySeason[seasonNumber]!.sort(
          (a, b) => a.episodeNumber.compareTo(b.episodeNumber),
        );
      }

      print(
        '📺 ${episodesBySeason.length} saisons avec épisodes trouvées dans la réponse API',
      );
    }

    // Extraire les épisodes depuis seasonInfo.seasons[].episodes (nouvelle structure)
    if (json['seasonInfo'] != null && json['seasonInfo']['seasons'] != null) {
      final List<dynamic> seasonsData =
          json['seasonInfo']['seasons'] as List<dynamic>;
      for (var seasonData in seasonsData) {
        if (seasonData['episodes'] != null) {
          final int seasonNumber = seasonData['number'] ?? 0;
          final List<dynamic> seasonEpisodesData =
              seasonData['episodes'] as List<dynamic>;

          if (!episodesBySeason.containsKey(seasonNumber)) {
            episodesBySeason[seasonNumber] = [];
          }

          for (var episodeData in seasonEpisodesData) {
            // Adapter la structure des épisodes pour correspondre à EpisodeApiModel
            final adaptedEpisodeData = {
              'id': episodeData['id'],
              'seriesId': json['id'],
              'seasonNumber': seasonNumber,
              'episodeNumber': episodeData['episodeNumber'],
              'title': episodeData['title'],
              'overview': episodeData['overview'] ?? '',
              'airDate': episodeData['airDate'] ?? '',
              'airDateUtc': episodeData['airDateUtc'] ?? '',
              'runtime': episodeData['runtime'] ?? 0,
              'rating': episodeData['ratings']?['value'] ?? 0.0,
              'hasFile': episodeData['hasFile'] ?? false,
              'monitored': episodeData['monitored'] ?? false,
              'unverifiedSceneNumbering':
                  episodeData['unverifiedSceneNumbering'] ?? false,
              'ratings': episodeData['ratings'] ?? {'value': 0.0},
              'file': episodeData['file'], // Inclure les données de fichier
              'metadata': episodeData['metadata'],
              'tmdbData': episodeData['tmdbData'],
              'gallery': episodeData['gallery'],
              'images':
                  episodeData['gallery']?['stills']
                      ?.map(
                        (still) => {
                          'coverType': 'still',
                          'remoteUrl': still['filePath'] ?? still['url'] ?? '',
                          'localUrl': still['thumbUrl'],
                        },
                      )
                      .toList() ??
                  [],
              'stillPath': episodeData['stillPath'],
            };

            try {
              final episode = EpisodeApiModel.fromJson(adaptedEpisodeData);
              episodesBySeason[seasonNumber]!.add(episode);
            } catch (e) {
              print('⚠️ Erreur lors de la création de l\'épisode: $e');
            }
          }

          // Trier les épisodes par numéro d'épisode
          episodesBySeason[seasonNumber]!.sort(
            (a, b) => a.episodeNumber.compareTo(b.episodeNumber),
          );
        }
      }

      print(
        '📺 ${episodesBySeason.length} saisons avec épisodes extraites depuis seasonInfo',
      );
    }

        // Log final pour vérifier les images récupérées
    print('🎬 Série créée: ${json['title']}');
    print('   Poster final: ${poster.isEmpty ? "VIDE" : poster}');
    print('   Banner final: ${banner.isEmpty ? "VIDE" : banner}');

    return SeriesApiModel(
      id: json['id']?.toString() ?? '0', // Convertir en String
      tmdbId: json['tmdbId'] ?? 0,
      title: json['title'] ?? '',
      sortTitle: json['sortTitle'] ?? '',
      year: json['year'] ?? 0,
      status: json['status'] ?? '',
      overview: json['overview'] ?? '',
      network: json['network'] ?? '',
      airTime: json['airTime'] ?? '',
      poster: poster,
      banner: banner,
      fanart: fanart,
      rating: (json['rating'] ?? 0.0).toDouble(),
      certification: json['certification'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      runtime: json['runtime'] ?? 0,
      premiered: json['premiered'] ?? '',
      ended: json['ended'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      monitored: json['monitored'] ?? false,
      path: json['path'] ?? '',
      episodeStats: EpisodeStats.fromJson(json['episodeStats'] ?? {}),
      seasonInfo: SeasonInfo.fromJson(json['seasonInfo'] ?? {}),
      imdbId: json['imdbId'],
      tvdbId: json['tvdbId'],
      tvMazeId: json['tvMazeId'],
      cast: json['cast'] != null ? MovieCast.fromJson(json['cast']) : null,
      gallery: json['gallery'] != null
          ? MovieGallery.fromJson(json['gallery'])
          : null,
      episodesBySeason: episodesBySeason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Déjà un String maintenant
      'tmdbId': tmdbId,
      'title': title,
      'sortTitle': sortTitle,
      'year': year,
      'status': status,
      'overview': overview,
      'network': network,
      'airTime': airTime,
      'poster': poster,
      'banner': banner,
      'fanart': fanart,
      'rating': rating,
      'certification': certification,
      'genres': genres,
      'runtime': runtime,
      'premiered': premiered,
      'ended': ended,
      'isAvailable': isAvailable,
      'monitored': monitored,
      'path': path,
      'episodeStats': episodeStats.toJson(),
      'seasonInfo': seasonInfo.toJson(),
      'imdbId': imdbId,
      'tvdbId': tvdbId,
      'tvMazeId': tvMazeId,
      'cast': cast?.toJson(),
      'gallery': gallery?.toJson(),
      'episodesBySeason': episodesBySeason.map(
        (key, value) =>
            MapEntry(key.toString(), value.map((e) => e.toJson()).toList()),
      ),
    };
  }
  SeriesApiModel copyWith({
    String? id,
    int? tmdbId,
    String? title,
    String? sortTitle,
    int? year,
    String? status,
    String? overview,
    String? network,
    String? airTime,
    String? poster,
    String? banner,
    String? fanart,
    double? rating,
    String? certification,
    List<String>? genres,
    int? runtime,
    String? premiered,
    bool? ended,
    bool? isAvailable,
    bool? monitored,
    String? path,
    EpisodeStats? episodeStats,
    SeasonInfo? seasonInfo,
    String? imdbId,
    int? tvdbId,
    int? tvMazeId,
    MovieCast? cast,
    MovieGallery? gallery,
    Map<int, List<EpisodeApiModel>>? episodesBySeason,
  }) {
    return SeriesApiModel(
      id: id ?? this.id,
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      sortTitle: sortTitle ?? this.sortTitle,
      year: year ?? this.year,
      status: status ?? this.status,
      overview: overview ?? this.overview,
      network: network ?? this.network,
      airTime: airTime ?? this.airTime,
      poster: poster ?? this.poster,
      banner: banner ?? this.banner,
      fanart: fanart ?? this.fanart,
      rating: rating ?? this.rating,
      certification: certification ?? this.certification,
      genres: genres ?? this.genres,
      runtime: runtime ?? this.runtime,
      premiered: premiered ?? this.premiered,
      ended: ended ?? this.ended,
      isAvailable: isAvailable ?? this.isAvailable,
      monitored: monitored ?? this.monitored,
      path: path ?? this.path,
      episodeStats: episodeStats ?? this.episodeStats,
      seasonInfo: seasonInfo ?? this.seasonInfo,
      imdbId: imdbId ?? this.imdbId,
      tvdbId: tvdbId ?? this.tvdbId,
      tvMazeId: tvMazeId ?? this.tvMazeId,
      cast: cast ?? this.cast,
      gallery: gallery ?? this.gallery,
      episodesBySeason: episodesBySeason ?? this.episodesBySeason,
    );
  }

  // Méthode pour obtenir les épisodes d'une saison spécifique
  List<EpisodeApiModel> getEpisodesForSeason(int seasonNumber) {
    return episodesBySeason[seasonNumber] ?? [];
  }

  // Méthode pour vérifier si une saison a des épisodes en cache
  bool hasEpisodesForSeason(int seasonNumber) {
    return episodesBySeason.containsKey(seasonNumber) &&
        episodesBySeason[seasonNumber]!.isNotEmpty;
  }

  // Méthode pour ajouter des épisodes à une saison
  SeriesApiModel withEpisodesForSeason(
    int seasonNumber,
    List<EpisodeApiModel> episodes,
  ) {
    final newEpisodesBySeason = Map<int, List<EpisodeApiModel>>.from(
      episodesBySeason,
    );
    newEpisodesBySeason[seasonNumber] = episodes;

    return SeriesApiModel(
      id: id,
      tmdbId: tmdbId,
      title: title,
      sortTitle: sortTitle,
      year: year,
      status: status,
      overview: overview,
      network: network,
      airTime: airTime,
      poster: poster,
      banner: banner,
      fanart: fanart,
      rating: rating,
      certification: certification,
      genres: genres,
      runtime: runtime,
      premiered: premiered,
      ended: ended,
      isAvailable: isAvailable,
      monitored: monitored,
      path: path,
      episodeStats: episodeStats,
      seasonInfo: seasonInfo,
      imdbId: imdbId,
      tvdbId: tvdbId,
      tvMazeId: tvMazeId,
      cast: cast,
      gallery: gallery,
      episodesBySeason: newEpisodesBySeason,
    );
  }

  // Méthode pour convertir SeriesApiModel en SeriesModel
  SeriesModel toSeriesModel() {
    return SeriesModel(
      id: id, // Déjà un String maintenant
      title: title,
      imagePath: poster.isNotEmpty
          ? poster
          : fanart.isNotEmpty
          ? fanart
          : banner,
      genre: genres.isNotEmpty ? genres.first : 'Action',
      seasons: '${seasonInfo.totalSeasons} saisons',
      years: year.toString(),
      rating: rating,
      description: overview,
    );
  }

  // Méthode pour créer un SeasonModel avec les images de la saison
  SeasonModel? getSeasonModel(int seasonNumber) {
    // Chercher la saison dans seasonInfo.seasons
    final season = seasonInfo.seasons
        .where((s) => s.number == seasonNumber)
        .firstOrNull;

    if (season == null) {
      print('⚠️ Saison $seasonNumber non trouvée dans la série $title');
      return null;
    }

    // Convertir les épisodes de cette saison en EpisodeModel
    final seasonEpisodes = getEpisodesForSeason(seasonNumber);
    final episodeModels = seasonEpisodes
        .map((episode) => episode.toEpisodeModel())
        .toList();

    // Créer le SeasonModel avec les images de la saison
    final seasonModel = season.toSeasonModel(
      seriesTitle: title,
      seriesYear: year,
      seriesRating: rating,
      seriesOverview: overview,
      episodesList: episodeModels,
    );

    return seasonModel;
  }
}

class EpisodeStats {
  final int total;
  final int available;
  final int monitored;
  final double percentageDownloaded;

  EpisodeStats({
    required this.total,
    required this.available,
    required this.monitored,
    required this.percentageDownloaded,
  });

  factory EpisodeStats.fromJson(dynamic json) {
    if (json is! Map) return EpisodeStats(total: 0, available: 0, monitored: 0, percentageDownloaded: 0.0);
    return EpisodeStats(
      total: json['total'] ?? 0,
      available: json['available'] ?? 0,
      monitored: json['monitored'] ?? 0,
      percentageDownloaded: (json['percentageDownloaded'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'available': available,
      'monitored': monitored,
      'percentageDownloaded': percentageDownloaded,
    };
  }
}

class SeasonInfo {
  final int totalSeasons;
  final int currentSeason;
  final List<Season> seasons;

  SeasonInfo({
    required this.totalSeasons,
    required this.currentSeason,
    required this.seasons,
  });

  factory SeasonInfo.fromJson(dynamic json) {
    if (json is! Map) return SeasonInfo(totalSeasons: 0, currentSeason: 0, seasons: []);
    return SeasonInfo(
      totalSeasons: json['totalSeasons'] ?? 0,
      currentSeason: json['currentSeason'] ?? 0,
      seasons:
          (json['seasons'] as List<dynamic>?)
              ?.map((season) => Season.fromJson(season))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSeasons': totalSeasons,
      'currentSeason': currentSeason,
      'seasons': seasons.map((season) => season.toJson()).toList(),
    };
  }
}

class Season {
  final int number;
  final String title;
  final bool monitored;
  final int episodeCount;
  final int episodeFileCount;
  final int monitoredCount;
  final double percentComplete;
  final int sizeOnDisk;
  final double sizeOnDiskGB;
  final String poster;
  final String banner;
  final String fanart;

  Season({
    required this.number,
    required this.title,
    required this.monitored,
    required this.episodeCount,
    required this.episodeFileCount,
    required this.monitoredCount,
    required this.percentComplete,
    required this.sizeOnDisk,
    required this.sizeOnDiskGB,
    required this.poster,
    required this.banner,
    required this.fanart,
  });

  factory Season.fromJson(dynamic json) {
    if (json is! Map) return Season(number: 0, title: '', monitored: false, episodeCount: 0, episodeFileCount: 0, monitoredCount: 0, percentComplete: 0.0, sizeOnDisk: 0, sizeOnDiskGB: 0.0, poster: '', banner: '', fanart: '');
    // Extraire les images depuis la structure season
    String poster = json['poster'] ?? '';
    String banner = json['banner'] ?? '';
    String fanart = json['fanart'] ?? '';

    // Si les champs directs sont vides, essayer de les extraire depuis l'objet images
    if (poster.isEmpty || banner.isEmpty || fanart.isEmpty) {
      final Map<String, dynamic>? imagesMap = json['images'];

      if (imagesMap != null) {
        // Extraire les posters
        if (imagesMap['posters'] is List && poster.isEmpty) {
          final List<dynamic> posters = imagesMap['posters'] as List<dynamic>;
          if (posters.isNotEmpty) {
            poster = posters.first['url'] ?? posters.first['filePath'] ?? '';
          }
        }

        // Extraire les banners
        if (imagesMap['banners'] is List && banner.isEmpty) {
          final List<dynamic> banners = imagesMap['banners'] as List<dynamic>;
          if (banners.isNotEmpty) {
            banner = banners.first['url'] ?? banners.first['filePath'] ?? '';
          }
        }

        // Extraire les fanarts
        if (imagesMap['fanart'] is List && fanart.isEmpty) {
          final List<dynamic> fanarts = imagesMap['fanart'] as List<dynamic>;
          if (fanarts.isNotEmpty) {
            fanart = fanarts.first['url'] ?? fanarts.first['filePath'] ?? '';
          }
        }
      } else {
        // Fallback : essayer l'ancien format (tableau images)
        final List<dynamic> images = json['images'] ?? [];

        for (var image in images) {
          final String coverType = image['coverType'] ?? '';
          final String remoteUrl = image['remoteUrl'] ?? '';

          if (remoteUrl.isNotEmpty) {
            switch (coverType) {
              case 'poster':
                if (poster.isEmpty) poster = remoteUrl;
                break;
              case 'banner':
                if (banner.isEmpty) banner = remoteUrl;
                break;
              case 'fanart':
                if (fanart.isEmpty) fanart = remoteUrl;
                break;
            }
          }
        }
      }
    }

    return Season(
      number: json['number'] ?? 0,
      title: json['title'] ?? '',
      monitored: json['monitored'] ?? false,
      episodeCount: json['episodeCount'] ?? 0,
      episodeFileCount: json['episodeFileCount'] ?? 0,
      monitoredCount: json['monitoredCount'] ?? 0,
      percentComplete: (json['percentComplete'] ?? 0.0).toDouble(),
      sizeOnDisk: json['sizeOnDisk'] ?? 0,
      sizeOnDiskGB: (json['sizeOnDiskGB'] ?? 0.0).toDouble(),
      poster: poster,
      banner: banner,
      fanart: fanart,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'monitored': monitored,
      'episodeCount': episodeCount,
      'episodeFileCount': episodeFileCount,
      'monitoredCount': monitoredCount,
      'percentComplete': percentComplete,
      'sizeOnDisk': sizeOnDisk,
      'sizeOnDiskGB': sizeOnDiskGB,
      'poster': poster,
      'banner': banner,
      'fanart': fanart,
    };
  }

  // Méthode pour convertir vers SeasonModel avec les images
  SeasonModel toSeasonModel({
    required String seriesTitle,
    required int seriesYear,
    required double seriesRating,
    required String seriesOverview,
    required List<EpisodeModel> episodesList,
  }) {
    return SeasonModel(
      id: number.toString(),
      title: title.isNotEmpty ? title : 'Saison $number',
      imagePath: poster.isNotEmpty ? poster : '', // Poster par défaut
      poster: poster.isNotEmpty ? poster : null,
      fanart: fanart.isNotEmpty ? fanart : null,
      banner: banner.isNotEmpty ? banner : null,
      episodes: '$episodeCount épisodes',
      year: seriesYear.toString(),
      rating: seriesRating,
      description: seriesOverview,
      episodesList: episodesList,
    );
  }
}

// Modèle pour les données TMDB d'un épisode
class EpisodeTmdbData {
  final int tmdbId;
  final String name;
  final String overview;
  final String airDate;
  final int episodeNumber;
  final int seasonNumber;
  final String stillPath;
  final double voteAverage;
  final int voteCount;
  final int runtime;
  final List<dynamic> crew;
  final List<dynamic> guestStars;

  EpisodeTmdbData({
    required this.tmdbId,
    required this.name,
    required this.overview,
    required this.airDate,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.stillPath,
    required this.voteAverage,
    required this.voteCount,
    required this.runtime,
    required this.crew,
    required this.guestStars,
  });

  factory EpisodeTmdbData.fromJson(dynamic json) {
    if (json is! Map) return EpisodeTmdbData(tmdbId: 0, name: '', overview: '', airDate: '', episodeNumber: 0, seasonNumber: 0, stillPath: '', voteAverage: 0.0, voteCount: 0, runtime: 0, crew: [], guestStars: []);
    return EpisodeTmdbData(
      tmdbId: json['tmdbId'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      airDate: json['airDate'] ?? '',
      episodeNumber: json['episodeNumber'] ?? 0,
      seasonNumber: json['seasonNumber'] ?? 0,
      stillPath: json['stillPath'] ?? '',
      voteAverage: (json['voteAverage'] ?? 0.0).toDouble(),
      voteCount: json['voteCount'] ?? 0,
      runtime: json['runtime'] ?? 0,
      crew: json['crew'] ?? [],
      guestStars: json['guestStars'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tmdbId': tmdbId,
      'name': name,
      'overview': overview,
      'airDate': airDate,
      'episodeNumber': episodeNumber,
      'seasonNumber': seasonNumber,
      'stillPath': stillPath,
      'voteAverage': voteAverage,
      'voteCount': voteCount,
      'runtime': runtime,
      'crew': crew,
      'guestStars': guestStars,
    };
  }
}

// Modèle pour les informations de fichier d'épisode
class EpisodeFileInfo {
  final int id;
  final String fileName;
  final String fullPath; // Chemin complet du fichier
  final String relativePath; // Chemin relatif
  final int size; // Taille en bytes
  final double sizeGB; // Taille en GB
  final EpisodeQuality quality;
  final EpisodeMediaInfo mediaInfo;
  final String? downloadUrl; // URL de téléchargement
  final String? streamUrl; // URL de streaming

  EpisodeFileInfo({
    required this.id,
    required this.fileName,
    required this.fullPath,
    required this.relativePath,
    required this.size,
    required this.sizeGB,
    required this.quality,
    required this.mediaInfo,
    this.downloadUrl,
    this.streamUrl,
  });

  factory EpisodeFileInfo.fromJson(dynamic json) {
    if (json is! Map) return EpisodeFileInfo(id: 0, fileName: '', fullPath: '', relativePath: '', size: 0, sizeGB: 0.0, quality: EpisodeQuality(name: '', resolution: ''), mediaInfo: EpisodeMediaInfo(videoCodec: '', audioCodec: '', resolution: '', videoFps: 0, audioChannels: 0, audioLanguages: [], subtitles: []));
    return EpisodeFileInfo(
      id: json['id'] ?? 0,
      fileName: json['fileName'] ?? '',
      fullPath: json['fullPath'] ?? '',
      relativePath: json['relativePath'] ?? '',
      size: json['size'] ?? 0,
      sizeGB: (json['sizeGB'] ?? 0.0).toDouble(),
      quality: EpisodeQuality.fromJson(json['quality'] ?? {}),
      mediaInfo: EpisodeMediaInfo.fromJson(json['mediaInfo'] ?? {}),
      downloadUrl: json['downloadUrl'],
      streamUrl: json['streamUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fullPath': fullPath,
      'relativePath': relativePath,
      'size': size,
      'sizeGB': sizeGB,
      'quality': quality.toJson(),
      'mediaInfo': mediaInfo.toJson(),
      'downloadUrl': downloadUrl,
      'streamUrl': streamUrl,
    };
  }
}

class EpisodeQuality {
  final String name;
  final String resolution;

  EpisodeQuality({required this.name, required this.resolution});

  factory EpisodeQuality.fromJson(dynamic json) {
    if (json is! Map) return EpisodeQuality(name: '', resolution: '');
    return EpisodeQuality(
      name: json['name'] ?? '',
      resolution: json['resolution'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'resolution': resolution};
  }
}

class EpisodeMediaInfo {
  final String videoCodec;
  final String audioCodec;
  final String resolution;
  final int videoFps;
  final int audioChannels;
  final List<String> audioLanguages;
  final List<String> subtitles;

  EpisodeMediaInfo({
    required this.videoCodec,
    required this.audioCodec,
    required this.resolution,
    required this.videoFps,
    required this.audioChannels,
    required this.audioLanguages,
    required this.subtitles,
  });

  factory EpisodeMediaInfo.fromJson(dynamic json) {
    if (json is! Map) return EpisodeMediaInfo(videoCodec: '', audioCodec: '', resolution: '', videoFps: 0, audioChannels: 0, audioLanguages: [], subtitles: []);
    return EpisodeMediaInfo(
      videoCodec: json['videoCodec'] ?? '',
      audioCodec: json['audioCodec'] ?? '',
      resolution: json['resolution'] ?? '',
      videoFps: json['videoFps'] ?? 0,
      audioChannels: json['audioChannels'] ?? 0,
      audioLanguages: List<String>.from(json['audioLanguages'] ?? []),
      subtitles: List<String>.from(json['subtitles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoCodec': videoCodec,
      'audioCodec': audioCodec,
      'resolution': resolution,
      'videoFps': videoFps,
      'audioChannels': audioChannels,
      'audioLanguages': audioLanguages,
      'subtitles': subtitles,
    };
  }
}

// Modèle pour les images d'épisode
class EpisodeImage {
  final String coverType;
  final String remoteUrl;
  final String? localUrl;

  EpisodeImage({
    required this.coverType,
    required this.remoteUrl,
    this.localUrl,
  });

  factory EpisodeImage.fromJson(dynamic json) {
    if (json is! Map) return EpisodeImage(coverType: '', remoteUrl: '');
    return EpisodeImage(
      coverType: json['coverType'] ?? '',
      remoteUrl: json['remoteUrl'] ?? '',
      localUrl: json['localUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coverType': coverType,
      'remoteUrl': remoteUrl,
      'localUrl': localUrl,
    };
  }
}

// Modèle pour les épisodes de l'API
class EpisodeApiModel {
  final int id;
  final int seriesId;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String overview;
  final String airDate;
  final String airDateUtc;
  final int runtime;
  final double rating;
  final bool hasFile;
  final bool monitored;
  final bool unverifiedSceneNumbering;
  final EpisodeRatings ratings;
  final List<EpisodeImage> images;
  final EpisodeFileInfo? file;
  final EpisodeMetadata? metadata;
  final EpisodeTmdbData? tmdbData;
  final EpisodeGallery? gallery;
  final String? stillPath;

  EpisodeApiModel({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.overview,
    required this.airDate,
    required this.airDateUtc,
    required this.runtime,
    required this.rating,
    required this.hasFile,
    required this.monitored,
    required this.unverifiedSceneNumbering,
    required this.ratings,
    required this.images,
    this.file,
    this.metadata,
    this.tmdbData,
    this.gallery,
    this.stillPath,
  });

  factory EpisodeApiModel.fromJson(Map<String, dynamic> json) {
    // Debug: afficher toutes les clés disponibles
    print('🔍 Données JSON de l\'épisode ${json['episodeNumber']}:');
    print('   - Clés disponibles: ${json.keys.toList()}');
    print('   - hasFile: ${json['hasFile']}');
    print('   - file: ${json['file']}');
    print('   - episodeFile: ${json['episodeFile']}');

    // Extraire les données TMDB si disponibles
    EpisodeTmdbData? tmdbData;
    if (json['tmdbData'] != null) {
      tmdbData = EpisodeTmdbData.fromJson(json['tmdbData']);
      print(
        '🇫🇷 Données TMDB trouvées pour l\'épisode ${json['episodeNumber']}',
      );
      print('   📝 Overview TMDB: ${tmdbData.overview}');
      print('   🎬 Titre TMDB: ${tmdbData.name}');
    }

    // Prioriser l'overview en français depuis TMDB
    String episodeTitle = json['title'] ?? '';
    String episodeOverview = json['overview'] ?? '';
    String episodeStillPath = json['stillPath'];
    int episodeRuntime = json['runtime'] ?? 0;
    double episodeRating = (json['rating'] ?? 0.0).toDouble();

    // Si les données TMDB sont disponibles, les utiliser en priorité
    if (tmdbData != null) {
      // Prioriser le titre TMDB s'il est disponible
      if (tmdbData.name.isNotEmpty) {
        episodeTitle = tmdbData.name;
        print('   ✅ Titre TMDB utilisé: $episodeTitle');
      }

      // Prioriser l'overview TMDB s'il est disponible
      if (tmdbData.overview.isNotEmpty) {
        episodeOverview = tmdbData.overview;
        print('   ✅ Overview TMDB utilisé: $episodeOverview');
      }

      // Prioriser le stillPath TMDB s'il est disponible
      if (tmdbData.stillPath.isNotEmpty) {
        episodeStillPath = tmdbData.stillPath;
        print('   ✅ StillPath TMDB utilisé: $episodeStillPath');
      }

      // Prioriser le runtime TMDB s'il est disponible
      if (tmdbData.runtime > 0) {
        episodeRuntime = tmdbData.runtime;
        print('   ✅ Runtime TMDB utilisé: $episodeRuntime');
      }

      // Prioriser le vote average TMDB s'il est disponible
      if (tmdbData.voteAverage > 0) {
        episodeRating = tmdbData.voteAverage;
        print('   ✅ Rating TMDB utilisé: $episodeRating');
      }
    }

    // Extraire les informations du fichier d'épisode
    EpisodeFileInfo? episodeFile;

    // Essayer différents chemins pour trouver les données du fichier
    Map<String, dynamic>? fileData;

    if (json['file'] != null) {
      fileData = json['file'] as Map<String, dynamic>;
      print('📁 Données trouvées dans "file"');
      print('   - Clés du fichier: ${fileData.keys.toList()}');
    } else if (json['episodeFile'] != null) {
      fileData = json['episodeFile'] as Map<String, dynamic>;
      print('📁 Données trouvées dans "episodeFile"');
      print('   - Clés du fichier: ${fileData.keys.toList()}');
    }

    if (fileData != null) {
      try {
        episodeFile = EpisodeFileInfo.fromJson(fileData);
        print('📁 Fichier d\'épisode trouvé: ${episodeFile.fileName}');
        print('   📊 Taille: ${episodeFile.sizeGB}GB');
        print(
          '   🎬 Qualité: ${episodeFile.quality.name} (${episodeFile.quality.resolution}p)',
        );
        print('   📂 Chemin complet: ${episodeFile.fullPath}');
      } catch (e) {
        print('❌ Erreur lors du parsing du fichier: $e');
        print('   - Données brutes: $fileData');
      }
    } else {
      print('❌ Aucune donnée de fichier trouvée');
    }

    // Extraire les métadonnées
    EpisodeMetadata? metadata;
    if (json['metadata'] != null) {
      metadata = EpisodeMetadata.fromJson(json['metadata']);
    }

    // Extraire la galerie
    EpisodeGallery? gallery;
    if (json['gallery'] != null) {
      gallery = EpisodeGallery.fromJson(json['gallery']);
    }

    // Extraire les images d'épisode
    List<EpisodeImage> episodeImages = [];
    String? stillPath = episodeStillPath;

    // Traiter les images depuis le tableau images standard
    if (json['images'] != null) {
      episodeImages = (json['images'] as List<dynamic>)
          .map((image) => EpisodeImage.fromJson(image))
          .toList();
    }

    // Traiter les images depuis la galerie (nouvelle structure)
    if (gallery != null && gallery.stills.isNotEmpty) {
      for (var still in gallery.stills) {
        episodeImages.add(
          EpisodeImage(
            coverType: 'still',
            remoteUrl: still.filePath,
            localUrl: still.thumbUrl.isNotEmpty ? still.thumbUrl : null,
          ),
        );
      }

      // Si stillPath n'est pas défini, prendre la première image de la galerie
      if (stillPath.isEmpty) {
        stillPath = gallery.stills.first.filePath;
      }
    }

    return EpisodeApiModel(
      id: json['id'] ?? 0,
      seriesId: json['seriesId'] ?? 0,
      seasonNumber: json['seasonNumber'] ?? 0,
      episodeNumber: json['episodeNumber'] ?? 0,
      title: episodeTitle,
      overview: episodeOverview,
      airDate: json['airDate'] ?? '',
      airDateUtc: json['airDateUtc'] ?? '',
      runtime: episodeRuntime,
      rating: episodeRating,
      hasFile: json['hasFile'] ?? false,
      monitored: json['monitored'] ?? false,
      unverifiedSceneNumbering: json['unverifiedSceneNumbering'] ?? false,
      ratings: EpisodeRatings.fromJson(json['ratings'] ?? {}),
      images: episodeImages,
      file: episodeFile,
      metadata: metadata,
      tmdbData: tmdbData,
      gallery: gallery,
      stillPath: stillPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seriesId': seriesId,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'title': title,
      'overview': overview,
      'airDate': airDate,
      'airDateUtc': airDateUtc,
      'runtime': runtime,
      'rating': rating,
      'hasFile': hasFile,
      'monitored': monitored,
      'unverifiedSceneNumbering': unverifiedSceneNumbering,
      'ratings': ratings.toJson(),
      'images': images.map((image) => image.toJson()).toList(),
      'file': file?.toJson(),
      'metadata': metadata?.toJson(),
      'tmdbData': tmdbData?.toJson(),
      'gallery': gallery?.toJson(),
      'stillPath': stillPath,
    };
  }

  // Méthode pour obtenir l'URL de streaming
  String? getStreamUrl() {
    return file?.downloadUrl ?? file?.streamUrl;
  }

  // Méthode pour obtenir le chemin du fichier
  String? getFilePath() {
    return file?.fullPath;
  }

  // Méthode pour vérifier si l'épisode est disponible
  bool isAvailable() {
    return hasFile && file != null;
  }

  // Méthode pour obtenir la qualité de l'épisode
  String getQuality() {
    return file?.quality.name ?? 'Inconnue';
  }

  // Méthode pour obtenir la taille du fichier
  String getFileSize() {
    if (file != null) {
      return '${file!.sizeGB.toStringAsFixed(2)} GB';
    }
    return 'Inconnue';
  }

  // Méthode pour convertir en EpisodeModel
  EpisodeModel toEpisodeModel() {
    return EpisodeModel(
      id: id.toString(),
      title: title,
      imagePath: stillPath ?? (images.isNotEmpty ? images.first.remoteUrl : ''),
      duration: runtime > 0 ? '$runtime min' : 'Inconnue',
      description: overview,
      episodeNumber: episodeNumber,
      rating: rating,
    );
  }
}

// Modèle pour les notes d'un épisode
class EpisodeRatings {
  final double value;

  EpisodeRatings({required this.value});

  factory EpisodeRatings.fromJson(dynamic json) {
    if (json is! Map) return EpisodeRatings(value: 0.0);
    return EpisodeRatings(value: (json['value'] ?? 0.0).toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'value': value};
  }
}

// Modèle pour les métadonnées d'un épisode
class EpisodeMetadata {
  final int episodeFileId;
  final String lastSearchTime;

  EpisodeMetadata({required this.episodeFileId, required this.lastSearchTime});

  factory EpisodeMetadata.fromJson(dynamic json) {
    if (json is! Map) return EpisodeMetadata(episodeFileId: 0, lastSearchTime: '');
    return EpisodeMetadata(
      episodeFileId: json['episodeFileId'] ?? 0,
      lastSearchTime: json['lastSearchTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'episodeFileId': episodeFileId, 'lastSearchTime': lastSearchTime};
  }
}

// Modèle pour la galerie d'un épisode
class EpisodeGallery {
  final List<EpisodeStill> stills;

  EpisodeGallery({required this.stills});

  factory EpisodeGallery.fromJson(dynamic json) {
    if (json is! Map) return EpisodeGallery(stills: []);
    final List<dynamic> stillsData = json['stills'] ?? [];
    return EpisodeGallery(
      stills: stillsData.map((still) => EpisodeStill.fromJson(still)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'stills': stills.map((still) => still.toJson()).toList()};
  }
}

// Modèle pour une image d'épisode
class EpisodeStill {
  final String filePath;
  final String url;
  final String thumbUrl;
  final int width;
  final int height;
  final double aspectRatio;
  final double voteAverage;

  EpisodeStill({
    required this.filePath,
    required this.url,
    required this.thumbUrl,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.voteAverage,
  });

  factory EpisodeStill.fromJson(dynamic json) {
    if (json is! Map) return EpisodeStill(filePath: '', url: '', thumbUrl: '', width: 0, height: 0, aspectRatio: 0.0, voteAverage: 0.0);
    return EpisodeStill(
      filePath: json['filePath'] ?? '',
      url: json['url'] ?? '',
      thumbUrl: json['thumbUrl'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      aspectRatio: (json['aspectRatio'] ?? 0.0).toDouble(),
      voteAverage: (json['voteAverage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'url': url,
      'thumbUrl': thumbUrl,
      'width': width,
      'height': height,
      'aspectRatio': aspectRatio,
      'voteAverage': voteAverage,
    };
  }
}
