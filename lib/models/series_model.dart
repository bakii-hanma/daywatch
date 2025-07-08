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
      print('🖼️ Images trouvées pour ${json['title']}: ${images.length}');

      for (var image in images) {
        final String coverType = image['coverType'] ?? '';
        final String remoteUrl = image['remoteUrl'] ?? '';

        print('   - $coverType: $remoteUrl');

        // Prendre uniquement les remoteUrl (comme pour les films)
        if (remoteUrl.isNotEmpty) {
          switch (coverType) {
            case 'poster':
              if (poster.isEmpty) poster = remoteUrl;
              print('   ✅ Poster assigné: $poster');
              break;
            case 'banner':
              if (banner.isEmpty) banner = remoteUrl;
              print('   ✅ Banner assigné: $banner');
              break;
            case 'fanart':
              if (fanart.isEmpty) fanart = remoteUrl;
              print('   ✅ Fanart assigné: $fanart');
              break;
          }
        }
      }
    } else {
      print(
        '🖼️ Images récupérées directement depuis la réponse JSON pour ${json['title']}',
      );
      print('   📸 Poster: ${poster.isNotEmpty ? "✅" : "❌"} $poster');
      print('   🎭 Banner: ${banner.isNotEmpty ? "✅" : "❌"} $banner');
      print('   🖼️ Fanart: ${fanart.isNotEmpty ? "✅" : "❌"} $fanart');
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

    // Log final pour vérifier les images récupérées
    print('🎬 Série créée: ${json['title']}');
    print('   📸 Poster final: ${poster.isEmpty ? "❌ VIDE" : "✅ " + poster}');
    print('   🎭 Banner final: ${banner.isEmpty ? "❌ VIDE" : "✅ " + banner}');
    print('   🖼️ Fanart final: ${fanart.isEmpty ? "❌ VIDE" : "✅ " + fanart}');
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

    print('🎬 SeasonModel créé pour la saison $seasonNumber:');
    print('   📸 Poster: ${seasonModel.poster ?? "Non disponible"}');
    print('   🖼️ Fanart: ${seasonModel.fanart ?? "Non disponible"}');
    print('   🎭 Banner: ${seasonModel.banner ?? "Non disponible"}');
    print('   📺 Épisodes: ${episodeModels.length}');

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

  factory EpisodeStats.fromJson(Map<String, dynamic> json) {
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

  factory SeasonInfo.fromJson(Map<String, dynamic> json) {
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

  factory Season.fromJson(Map<String, dynamic> json) {
    // Extraire les images depuis la structure season
    String poster = json['poster'] ?? '';
    String banner = json['banner'] ?? '';
    String fanart = json['fanart'] ?? '';

    print('🖼️ Processing saison ${json['number']} - ${json['title']}');

    // Si les champs directs sont vides, essayer de les extraire depuis l'objet images
    if (poster.isEmpty || banner.isEmpty || fanart.isEmpty) {
      final Map<String, dynamic>? imagesMap = json['images'];

      if (imagesMap != null) {
        print('   📸 Images map trouvée avec clés: ${imagesMap.keys.toList()}');

        // Extraire les posters
        if (imagesMap['posters'] is List && poster.isEmpty) {
          final List<dynamic> posters = imagesMap['posters'] as List<dynamic>;
          if (posters.isNotEmpty) {
            poster = posters.first['url'] ?? posters.first['filePath'] ?? '';
            print('   ✅ Poster de saison depuis images: $poster');
          }
        }

        // Extraire les banners
        if (imagesMap['banners'] is List && banner.isEmpty) {
          final List<dynamic> banners = imagesMap['banners'] as List<dynamic>;
          if (banners.isNotEmpty) {
            banner = banners.first['url'] ?? banners.first['filePath'] ?? '';
            print('   ✅ Banner de saison depuis images: $banner');
          }
        }

        // Extraire les fanarts
        if (imagesMap['fanart'] is List && fanart.isEmpty) {
          final List<dynamic> fanarts = imagesMap['fanart'] as List<dynamic>;
          if (fanarts.isNotEmpty) {
            fanart = fanarts.first['url'] ?? fanarts.first['filePath'] ?? '';
            print('   ✅ Fanart de saison depuis images: $fanart');
          }
        }
      } else {
        // Fallback : essayer l'ancien format (tableau images)
        final List<dynamic> images = json['images'] ?? [];
        print(
          '   📋 Fallback: Images trouvées pour la saison ${json['number']}: ${images.length}',
        );

        for (var image in images) {
          final String coverType = image['coverType'] ?? '';
          final String remoteUrl = image['remoteUrl'] ?? '';

          print('     - $coverType: $remoteUrl');

          if (remoteUrl.isNotEmpty) {
            switch (coverType) {
              case 'poster':
                if (poster.isEmpty) poster = remoteUrl;
                print('     ✅ Poster de saison assigné: $poster');
                break;
              case 'banner':
                if (banner.isEmpty) banner = remoteUrl;
                print('     ✅ Banner de saison assigné: $banner');
                break;
              case 'fanart':
                if (fanart.isEmpty) fanart = remoteUrl;
                print('     ✅ Fanart de saison assigné: $fanart');
                break;
            }
          }
        }
      }
    } else {
      print(
        '   📸 Images récupérées directement depuis les champs poster/banner/fanart',
      );
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

  factory EpisodeTmdbData.fromJson(Map<String, dynamic> json) {
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

  EpisodeFileInfo({
    required this.id,
    required this.fileName,
    required this.fullPath,
    required this.relativePath,
    required this.size,
    required this.sizeGB,
    required this.quality,
    required this.mediaInfo,
  });

  factory EpisodeFileInfo.fromJson(Map<String, dynamic> json) {
    return EpisodeFileInfo(
      id: json['id'] ?? 0,
      fileName: json['fileName'] ?? '',
      fullPath: json['fullPath'] ?? '',
      relativePath: json['relativePath'] ?? '',
      size: json['size'] ?? 0,
      sizeGB: (json['sizeGB'] ?? 0.0).toDouble(),
      quality: EpisodeQuality.fromJson(json['quality'] ?? {}),
      mediaInfo: EpisodeMediaInfo.fromJson(json['mediaInfo'] ?? {}),
    );
  }
}

class EpisodeQuality {
  final String name;
  final String resolution;

  EpisodeQuality({required this.name, required this.resolution});

  factory EpisodeQuality.fromJson(Map<String, dynamic> json) {
    return EpisodeQuality(
      name: json['name'] ?? '',
      resolution: json['resolution'] ?? '',
    );
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

  factory EpisodeMediaInfo.fromJson(Map<String, dynamic> json) {
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
  final String? absoluteEpisodeNumber;
  final String? unverifiedSceneNumbering;
  final EpisodeFile? episodeFile;
  final List<EpisodeImage> images;
  final String? stillPath; // Nouveau champ pour la nouvelle structure
  final EpisodeTmdbData? tmdbData; // Données TMDB avec informations en français
  final EpisodeFileInfo? file; // Informations du fichier d'épisode

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
    this.absoluteEpisodeNumber,
    this.unverifiedSceneNumbering,
    this.episodeFile,
    required this.images,
    this.stillPath,
    this.tmdbData,
    this.file,
  });

  factory EpisodeApiModel.fromJson(Map<String, dynamic> json) {
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

    // Debug: afficher la structure des données de l'épisode
    print('🔍 Structure des données de l\'épisode:');
    print('   hasFile: ${json['hasFile']}');
    print('   episodeFile: ${json['episodeFile']}');
    print('   file: ${json['file']}');
    print('   data: ${json['data']}');

    // Debug: afficher toutes les clés disponibles
    print('🔑 Toutes les clés disponibles:');
    json.keys.forEach((key) {
      print('   - $key: ${json[key]}');
    });

    // Extraire les informations du fichier d'épisode
    EpisodeFileInfo? episodeFile;

    // Essayer différents chemins pour trouver les données du fichier
    Map<String, dynamic>? fileData;

    if (json['file'] != null) {
      fileData = json['file'] as Map<String, dynamic>;
      print('📁 Données trouvées dans "file"');
    } else if (json['data'] != null && json['data']['file'] != null) {
      fileData = json['data']['file'] as Map<String, dynamic>;
      print('📁 Données trouvées dans "data.file"');
    } else if (json['episodeFile'] != null) {
      fileData = json['episodeFile'] as Map<String, dynamic>;
      print('📁 Données trouvées dans "episodeFile"');
    }

    if (fileData != null) {
      episodeFile = EpisodeFileInfo.fromJson(fileData);
      print('📁 Fichier d\'épisode trouvé: ${episodeFile.fileName}');
      print('   📊 Taille: ${episodeFile.sizeGB}GB');
      print(
        '   🎬 Qualité: ${episodeFile.quality.name} (${episodeFile.quality.resolution}p)',
      );
      print('   📂 Chemin complet: ${episodeFile.fullPath}');
      print('   📂 Chemin relatif: ${episodeFile.relativePath}');
    } else {
      print('❌ Aucune donnée de fichier trouvée');
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
    if (json['gallery'] != null && json['gallery']['stills'] != null) {
      final List<dynamic> galleryStills =
          json['gallery']['stills'] as List<dynamic>;

      for (var still in galleryStills) {
        final String filePath = still['filePath'] ?? still['url'] ?? '';
        final String thumbUrl = still['thumbUrl'] ?? '';

        if (filePath.isNotEmpty) {
          episodeImages.add(
            EpisodeImage(
              coverType: 'still',
              remoteUrl: filePath,
              localUrl: thumbUrl.isNotEmpty ? thumbUrl : null,
            ),
          );
        }
      }

      // Si stillPath n'est pas défini, prendre la première image de la galerie
      if (stillPath == null || stillPath.isEmpty) {
        if (galleryStills.isNotEmpty) {
          stillPath =
              galleryStills.first['filePath'] ??
              galleryStills.first['url'] ??
              '';
        }
      }
    }

    print(
      '📺 Épisode ${json['episodeNumber']}: ${episodeImages.length} images trouvées',
    );
    if (stillPath != null && stillPath.isNotEmpty) {
      print('   🖼️ StillPath final: $stillPath');
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
      absoluteEpisodeNumber: json['absoluteEpisodeNumber']?.toString(),
      unverifiedSceneNumbering: json['unverifiedSceneNumbering']?.toString(),
      episodeFile: json['episodeFile'] != null
          ? EpisodeFile.fromJson(json['episodeFile'])
          : null,
      images: episodeImages,
      stillPath: stillPath,
      tmdbData: tmdbData,
      file: episodeFile,
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
      'absoluteEpisodeNumber': absoluteEpisodeNumber,
      'unverifiedSceneNumbering': unverifiedSceneNumbering,
      'episodeFile': episodeFile?.toJson(),
      'images': images.map((image) => image.toJson()).toList(),
      'stillPath': stillPath,
      'tmdbData': tmdbData != null
          ? {
              'tmdbId': tmdbData!.tmdbId,
              'name': tmdbData!.name,
              'overview': tmdbData!.overview,
              'airDate': tmdbData!.airDate,
              'episodeNumber': tmdbData!.episodeNumber,
              'seasonNumber': tmdbData!.seasonNumber,
              'stillPath': tmdbData!.stillPath,
              'voteAverage': tmdbData!.voteAverage,
              'voteCount': tmdbData!.voteCount,
              'runtime': tmdbData!.runtime,
              'crew': tmdbData!.crew,
              'guestStars': tmdbData!.guestStars,
            }
          : null,
      'file': file != null
          ? {
              'id': file!.id,
              'fileName': file!.fileName,
              'sizeGB': file!.sizeGB,
              'quality': {
                'name': file!.quality.name,
                'resolution': file!.quality.resolution,
              },
              'mediaInfo': {
                'videoCodec': file!.mediaInfo.videoCodec,
                'audioCodec': file!.mediaInfo.audioCodec,
                'resolution': file!.mediaInfo.resolution,
                'videoFps': file!.mediaInfo.videoFps,
                'audioChannels': file!.mediaInfo.audioChannels,
                'audioLanguages': file!.mediaInfo.audioLanguages,
                'subtitles': file!.mediaInfo.subtitles,
              },
              'fullPath': file!.fullPath,
              'relativePath': file!.relativePath,
              'size': file!.size,
            }
          : null,
    };
  }

  // Méthode pour convertir vers EpisodeModel
  EpisodeModel toEpisodeModel() {
    String imagePath = '';

    // Priorité 1: stillPath (nouvelle structure)
    if (stillPath != null && stillPath!.isNotEmpty) {
      imagePath = stillPath!;
      print('📸 Épisode $episodeNumber: Utilisation du stillPath: $imagePath');
    }
    // Priorité 2: images du modèle (chercher une image de type still ou screenshot)
    else if (images.isNotEmpty) {
      // Chercher une image de type still en priorité
      final still = images.where((img) => img.coverType == 'still').firstOrNull;
      if (still != null && still.remoteUrl.isNotEmpty) {
        imagePath = still.remoteUrl;
        print(
          '📸 Épisode $episodeNumber: Utilisation d\'une image still: $imagePath',
        );
      } else {
        // Fallback sur screenshot
        final screenshot = images
            .where((img) => img.coverType == 'screenshot')
            .firstOrNull;
        if (screenshot != null && screenshot.remoteUrl.isNotEmpty) {
          imagePath = screenshot.remoteUrl;
          print(
            '📸 Épisode $episodeNumber: Utilisation d\'une image screenshot: $imagePath',
          );
        } else {
          // Prendre la première image disponible
          final firstImage = images.firstWhere(
            (img) => img.remoteUrl.isNotEmpty,
            orElse: () => EpisodeImage(coverType: '', remoteUrl: ''),
          );
          if (firstImage.remoteUrl.isNotEmpty) {
            imagePath = firstImage.remoteUrl;
            print(
              '📸 Épisode $episodeNumber: Utilisation de la première image disponible: $imagePath',
            );
          }
        }
      }
    }

    if (imagePath.isEmpty) {
      print('⚠️ Épisode $episodeNumber: Aucune image trouvée');
    }

    return EpisodeModel(
      id: id.toString(),
      title: title,
      imagePath: imagePath,
      duration: '${runtime} min',
      description: overview,
      episodeNumber: episodeNumber,
      rating: rating,
    );
  }

  // Méthode pour récupérer l'image principale de l'épisode
  String getMainImage() {
    // Priorité 1: stillPath
    if (stillPath != null && stillPath!.isNotEmpty) {
      return stillPath!;
    }

    // Priorité 2: image de type still
    final still = images.where((img) => img.coverType == 'still').firstOrNull;
    if (still != null && still.remoteUrl.isNotEmpty) {
      return still.remoteUrl;
    }

    // Priorité 3: image de type screenshot
    final screenshot = images
        .where((img) => img.coverType == 'screenshot')
        .firstOrNull;
    if (screenshot != null && screenshot.remoteUrl.isNotEmpty) {
      return screenshot.remoteUrl;
    }

    // Priorité 4: première image disponible
    final firstImage = images.firstWhere(
      (img) => img.remoteUrl.isNotEmpty,
      orElse: () => EpisodeImage(coverType: '', remoteUrl: ''),
    );

    return firstImage.remoteUrl;
  }

  // Méthode pour récupérer toutes les images de l'épisode
  List<String> getAllImages() {
    List<String> allImages = [];

    // Ajouter stillPath s'il existe
    if (stillPath != null && stillPath!.isNotEmpty) {
      allImages.add(stillPath!);
    }

    // Ajouter toutes les images du tableau images
    for (var image in images) {
      if (image.remoteUrl.isNotEmpty && !allImages.contains(image.remoteUrl)) {
        allImages.add(image.remoteUrl);
      }
    }

    return allImages;
  }
}

class EpisodeFile {
  final int id;
  final int seriesId;
  final int seasonNumber;
  final int episodeNumber;
  final String path;
  final String relativePath;
  final String fileName;
  final int size;
  final String dateAdded;
  final String quality;
  final String qualityVersion;
  final String releaseGroup;
  final String sceneName;

  EpisodeFile({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.path,
    required this.relativePath,
    required this.fileName,
    required this.size,
    required this.dateAdded,
    required this.quality,
    required this.qualityVersion,
    required this.releaseGroup,
    required this.sceneName,
  });

  factory EpisodeFile.fromJson(Map<String, dynamic> json) {
    return EpisodeFile(
      id: json['id'] ?? 0,
      seriesId: json['seriesId'] ?? 0,
      seasonNumber: json['seasonNumber'] ?? 0,
      episodeNumber: json['episodeNumber'] ?? 0,
      path: json['path'] ?? '',
      relativePath: json['relativePath'] ?? '',
      fileName: json['fileName'] ?? '',
      size: json['size'] ?? 0,
      dateAdded: json['dateAdded'] ?? '',
      quality: json['quality']?['quality']?['name'] ?? '',
      qualityVersion:
          json['quality']?['revision']?['version']?.toString() ?? '',
      releaseGroup: json['releaseGroup'] ?? '',
      sceneName: json['sceneName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seriesId': seriesId,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'path': path,
      'relativePath': relativePath,
      'fileName': fileName,
      'size': size,
      'dateAdded': dateAdded,
      'quality': quality,
      'qualityVersion': qualityVersion,
      'releaseGroup': releaseGroup,
      'sceneName': sceneName,
    };
  }
}

class EpisodeImage {
  final String coverType;
  final String remoteUrl;
  final String? localUrl;

  EpisodeImage({
    required this.coverType,
    required this.remoteUrl,
    this.localUrl,
  });

  factory EpisodeImage.fromJson(Map<String, dynamic> json) {
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
