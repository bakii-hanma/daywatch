import '../models/series_model.dart';
import '../models/movie_model.dart'; // Pour MovieCast et MovieGallery
import 'api_client.dart';
import 'dart:convert';

class SeriesService {
  /// Test de connectivité avec l'API Séries
  static Future<bool> testConnection() async {
    try {
      final response = await ApiClient.get<dynamic>('/api/series?limit=1');
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }



  /// Helper générique pour récupérer et parser une liste de séries avec retry
  static Future<List<SeriesApiModel>> _fetchSeriesList(
    String endpoint, {
    Duration? timeout,
  }) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final response = await ApiClient.get<dynamic>(
          endpoint,
          timeout: timeout ?? ApiClient.seriesTimeout,
        );

        if (response.isSuccess && response.data != null) {
          print('📺 [SeriesService DEBUG BRUT] Response for $endpoint: ${jsonEncode(response.data)}');
          List<dynamic> items;

          // Gérer les formats de réponse directs et enveloppés
          if (response.data is List) {
            items = response.data as List<dynamic>;
          } else if (response.data is Map<String, dynamic>) {
            final responseMap = response.data as Map<String, dynamic>;
            if (responseMap['data'] is List) {
              items = responseMap['data'] as List<dynamic>;
            } else {
              return [];
            }
          } else {
            return [];
          }

          return items.map((item) => SeriesApiModel.fromJson(item)).toList();
        } else {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
          }
        }
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }
    return [];
  }

  /// Récupération de toutes les séries (Liste paginée)
  /// GET /api/series
  static Future<List<SeriesApiModel>> getAllSeries({
    int limit = 2000,
    bool enrich = false,
  }) async {
    return _fetchSeriesList('/api/series?limit=$limit&enrich=$enrich');
  }

  /// Récupération des séries populaires
  /// GET /api/series/popular
  static Future<List<SeriesApiModel>> getPopularSeries({int limit = 20}) async {
    return _fetchSeriesList('/api/series/popular?limit=$limit');
  }

  /// Récupération des séries récentes
  /// GET /api/series/recent
  static Future<List<SeriesApiModel>> getRecentSeries({int limit = 20}) async {
    return _fetchSeriesList('/api/series/recent?limit=$limit');
  }

  /// Récupération des séries recommandées
  /// GET /api/series/recommended
  static Future<List<SeriesApiModel>> getRecommendedSeries({
    int limit = 20,
  }) async {
    return _fetchSeriesList('/api/series/recommended?limit=$limit');
  }

  /// Récupération des séries à venir
  /// GET /api/series/upcoming
  static Future<List<SeriesApiModel>> getUpcomingSeries({int limit = 30}) async {
    return _fetchSeriesList('/api/series/upcoming?limit=$limit');
  }

  /// Récupération des animés japonais
  /// GET /api/series/anime
  static Future<List<SeriesApiModel>> getAnimeSeries({int limit = 50}) async {
    return _fetchSeriesList('/api/series/anime?limit=$limit');
  }

  /// Récupération des animés à venir
  /// GET /api/series/anime/upcoming
  static Future<List<SeriesApiModel>> getUpcomingAnimes({int limit = 30}) async {
    return _fetchSeriesList('/api/series/anime/upcoming?limit=$limit');
  }

  /// Récupération des séries coréennes (K-Drama)
  /// GET /api/series/k-drama
  static Future<List<SeriesApiModel>> getKDramaSeries({int limit = 50}) async {
    return _fetchSeriesList('/api/series/k-drama?limit=$limit');
  }

  /// Récupération des séries par plateforme
  /// GET /api/series/platforms/:platform
  static Future<List<SeriesApiModel>> getSeriesByPlatform(
    String platform, {
    int limit = 100,
    bool includeUnavailable = false,
  }) async {
    return _fetchSeriesList(
      '/api/series/platforms/$platform?limit=$limit&includeUnavailable=$includeUnavailable',
    );
  }

  /// Récupération d'une série par son ID
  /// GET /api/series/:id
  static Future<SeriesApiModel?> getSeriesById(String seriesId) async {
    int attempt = 0;
    const maxRetries = 3;

    while (attempt < maxRetries) {
      attempt++;
      try {
        final response = await ApiClient.getSeriesById<SeriesApiModel>(
          seriesId,
          fromJson: (json) => SeriesApiModel.fromJson(json),
        );

        if (response.isSuccess && response.data != null) {
          return response.data!;
        }
        
        print('⚠️ Échec de chargement de la série $seriesId (tentative $attempt/$maxRetries)');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 1500 * attempt));
        }
      } catch (e) {
        print('⚠️ Erreur lors du chargement de la série $seriesId (tentative $attempt/$maxRetries) : $e');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 1500 * attempt));
        } else {
          return null;
        }
      }
    }
    return null;
  }

  /// Récupération du casting d'une série
  /// GET /api/series/:id/credits
  static Future<MovieCast?> getSeriesCredits(
    String seriesId, {
    int limit = 30,
  }) async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/api/series/$seriesId/credits?limit=$limit',
      );
      if (response.isSuccess && response.data != null) {
        final Map<String, dynamic> data = response.data!;
        final castList = data['data'] ?? data['cast'] ?? [];
        final crewList = data['crew'] ?? [];
        return MovieCast.fromJson({
          'cast': castList,
          'crew': crewList,
        });
      }
      return null;
    } catch (e) {
      return null;
    }
  }



  /// Récupération des épisodes avec leurs fichiers vidéo
  /// GET /api/series/:id/episodes-with-files
  static Future<List<EpisodeApiModel>> getSeriesEpisodesWithFiles(
    String seriesId, {
    bool enrich = true,
  }) async {
    try {
      final response = await ApiClient.get<dynamic>(
        '/api/series/$seriesId/episodes-with-files?enrich=$enrich',
        timeout: const Duration(seconds: 90),
      );

      if (response.isSuccess && response.data != null) {
        List<dynamic> episodesData;
        if (response.data is List) {
          episodesData = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          if (responseMap['data'] is List) {
            episodesData = responseMap['data'] as List<dynamic>;
          } else {
            return [];
          }
        } else {
          return [];
        }

        return episodesData.map((e) => EpisodeApiModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupération des affiches et images d'une série
  /// GET /api/series/:id/images
  static Future<MovieGallery?> getSeriesImages(String seriesId) async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/api/series/$seriesId/images',
      );
      if (response.isSuccess && response.data != null) {
        final Map<String, dynamic> data = response.data!;
        final galleryData = data['data'] ?? {};
        return MovieGallery.fromJson({
          'backdrops': galleryData['backdrops'] ?? [],
          'posters': galleryData['posters'] ?? [],
        });
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupération de la liste des saisons
  /// GET /api/series/:id/seasons
  static Future<List<Season>> getSeriesSeasons(String seriesId) async {
    try {
      final response = await ApiClient.get<dynamic>(
        '/api/series/$seriesId/seasons',
      );
      if (response.isSuccess && response.data != null) {
        List<dynamic> items;
        if (response.data is List) {
          items = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic> &&
            response.data['data'] is List) {
          items = response.data['data'] as List<dynamic>;
        } else {
          return [];
        }

        return items.map((item) {
          final int number = item['seasonNumber'] ?? 0;
          final String title = item['name'] ?? 'Saison $number';
          final bool monitored = item['monitored'] ?? false;
          final int episodeCount = item['episodeCount'] ?? 0;
          final int episodeFileCount =
              item['downloadedEpisodes'] ?? item['episodeFileCount'] ?? 0;
          final double percentComplete =
              episodeCount > 0 ? (episodeFileCount / episodeCount) * 100 : 0.0;
          final String poster = item['posterPath'] ?? item['poster'] ?? '';

          return Season(
            number: number,
            title: title,
            monitored: monitored,
            episodeCount: episodeCount,
            episodeFileCount: episodeFileCount,
            monitoredCount: monitored ? episodeCount : 0,
            percentComplete: percentComplete,
            sizeOnDisk: 0,
            sizeOnDiskGB: 0.0,
            poster: poster,
            banner: '',
            fanart: '',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupération des détails d'une saison
  /// GET /api/series/:id/seasons/:seasonNumber
  static Future<Map<String, dynamic>?> getSeasonDetail(
    String seriesId,
    int seasonNumber,
  ) async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/api/series/$seriesId/seasons/$seasonNumber',
      );
      if (response.isSuccess && response.data != null) {
        return response.data!['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupération des trailers/vidéos de la série
  /// GET /api/series/:id/videos
  static Future<List<dynamic>> getSeriesVideos(String seriesId) async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/api/series/$seriesId/videos',
      );
      if (response.isSuccess && response.data != null) {
        return response.data!['data'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupération des statistiques des séries
  /// GET /api/series/stats
  static Future<Map<String, dynamic>?> getSeriesStats() async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/api/series/stats',
      );
      if (response.isSuccess && response.data != null) {
        return response.data!['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupération d'une série par son ID avec tous ses épisodes inclus
  static Future<SeriesApiModel?> getSeriesWithEpisodes(String seriesId) async {
    try {
      final response = await ApiClient.getSeriesById<SeriesApiModel>(
        seriesId,
        fromJson: (json) => SeriesApiModel.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        final series = response.data!;

        // Vérifier si les épisodes sont déjà inclus dans la réponse
        if (series.episodesBySeason.isNotEmpty) {
          return series;
        }

        // Si les épisodes ne sont pas inclus, les récupérer séparément
        final allEpisodes = await getAllSeriesEpisodes(seriesId: seriesId);

        if (allEpisodes.isNotEmpty) {
          // Organiser les épisodes par saison
          final Map<int, List<EpisodeApiModel>> episodesBySeason = {};
          for (var episode in allEpisodes) {
            final seasonNumber = episode.seasonNumber;
            if (!episodesBySeason.containsKey(seasonNumber)) {
              episodesBySeason[seasonNumber] = [];
            }
            episodesBySeason[seasonNumber]!.add(episode);
          }

          // Trier les épisodes par numéro dans chaque saison
          for (var seasonNumber in episodesBySeason.keys) {
            episodesBySeason[seasonNumber]!.sort(
              (a, b) => a.episodeNumber.compareTo(b.episodeNumber),
            );
          }

          // Créer une nouvelle instance de la série avec les épisodes
          final enrichedSeries = SeriesApiModel(
            id: series.id,
            tmdbId: series.tmdbId,
            title: series.title,
            sortTitle: series.sortTitle,
            year: series.year,
            status: series.status,
            overview: series.overview,
            network: series.network,
            airTime: series.airTime,
            poster: series.poster,
            banner: series.banner,
            fanart: series.fanart,
            rating: series.rating,
            certification: series.certification,
            genres: series.genres,
            runtime: series.runtime,
            premiered: series.premiered,
            ended: series.ended,
            isAvailable: series.isAvailable,
            monitored: series.monitored,
            path: series.path,
            episodeStats: series.episodeStats,
            seasonInfo: series.seasonInfo,
            imdbId: series.imdbId,
            tvdbId: series.tvdbId,
            tvMazeId: series.tvMazeId,
            cast: series.cast,
            gallery: series.gallery,
            episodesBySeason: episodesBySeason,
          );

          return enrichedSeries;
        } else {
          return series;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Récupération d'un épisode spécifique avec toutes ses données
  static Future<EpisodeApiModel?> getEpisodeById({
    required String seriesId,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    try {
      // D'abord récupérer la série avec tous ses épisodes
      final series = await getSeriesWithEpisodes(seriesId);
      if (series == null) {
        return null;
      }

      // Chercher l'épisode dans les épisodes de la saison
      final seasonEpisodes = series.getEpisodesForSeason(seasonNumber);
      final episode = seasonEpisodes
          .where((e) => e.episodeNumber == episodeNumber)
          .firstOrNull;

      if (episode != null) {
        return episode;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Récupération des épisodes d'une saison
  static Future<List<EpisodeApiModel>> getSeasonEpisodes({
    required String seriesId,
    required int seasonNumber,
  }) async {
    try {
      final allEpisodes = await getAllSeriesEpisodes(seriesId: seriesId);
      return allEpisodes.where((e) => e.seasonNumber == seasonNumber).toList();
    } catch (e) {
      return [];
    }
  }

  /// Récupération de tous les épisodes d'une série
  static Future<List<EpisodeApiModel>> getAllSeriesEpisodes({
    required String seriesId,
  }) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final endpoint = '/api/series/$seriesId/episodes';
        final response = await ApiClient.get<dynamic>(
          endpoint,
          timeout: const Duration(
            seconds: 90,
          ), // Timeout très long pour tous les épisodes
        );

        if (response.isSuccess && response.data != null) {
          print('📺 [DEBUG STREAM] Réponse brute pour les épisodes de la série ($seriesId) :');
          print(jsonEncode(response.data));
          List<dynamic> episodesData;

          // Gérer différents formats de réponse
          if (response.data is List) {
            episodesData = response.data as List<dynamic>;
          } else if (response.data is Map<String, dynamic>) {
            final responseMap = response.data as Map<String, dynamic>;

            if (responseMap['data'] is List) {
              episodesData = responseMap['data'] as List<dynamic>;
            } else {
              retryCount++;
              if (retryCount < maxRetries) {
                await Future.delayed(retryDelay);
                continue;
              } else {
                return [];
              }
            }
          } else {
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(retryDelay);
              continue;
            } else {
              return [];
            }
          }

          final List<EpisodeApiModel> episodes = episodesData
              .map((episode) => EpisodeApiModel.fromJson(episode))
              .toList();

          return episodes;
        } else {
          retryCount++;

          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
          } else {
            return [];
          }
        }
      } catch (e) {
        retryCount++;

        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          return [];
        }
      }
    }
    return [];
  }

  /// Enrichir une série avec tous ses épisodes et détails complets
  static Future<SeriesApiModel?> enrichSeriesWithEpisodes({
    required SeriesApiModel series,
  }) async {
    try {
      // Charger d'abord les détails complets de la série (synopsis, cast, gallery)
      final fullSeries = await getSeriesById(series.id);
      final seriesToEnrich = fullSeries ?? series;

      final allEpisodes = await getAllSeriesEpisodes(
        seriesId: seriesToEnrich.id,
      );

      if (allEpisodes.isEmpty) {
        return seriesToEnrich;
      }

      // Organiser les épisodes par saison
      final Map<int, List<EpisodeApiModel>> episodesBySeason = {};
      for (var episode in allEpisodes) {
        final seasonNumber = episode.seasonNumber;
        if (!episodesBySeason.containsKey(seasonNumber)) {
          episodesBySeason[seasonNumber] = [];
        }
        episodesBySeason[seasonNumber]!.add(episode);
      }

      // Trier les épisodes par numéro dans chaque saison
      for (var seasonNumber in episodesBySeason.keys) {
        episodesBySeason[seasonNumber]!.sort(
          (a, b) => a.episodeNumber.compareTo(b.episodeNumber),
        );
      }

      // Créer une nouvelle instance de la série avec les épisodes et les métadonnées complètes
      final enrichedSeries = SeriesApiModel(
        id: seriesToEnrich.id,
        tmdbId: seriesToEnrich.tmdbId,
        title: seriesToEnrich.title,
        sortTitle: seriesToEnrich.sortTitle,
        year: seriesToEnrich.year,
        status: seriesToEnrich.status,
        overview: seriesToEnrich.overview,
        network: seriesToEnrich.network,
        airTime: seriesToEnrich.airTime,
        poster: seriesToEnrich.poster,
        banner: seriesToEnrich.banner,
        fanart: seriesToEnrich.fanart,
        rating: seriesToEnrich.rating,
        certification: seriesToEnrich.certification,
        genres: seriesToEnrich.genres,
        runtime: seriesToEnrich.runtime,
        premiered: seriesToEnrich.premiered,
        ended: seriesToEnrich.ended,
        isAvailable: seriesToEnrich.isAvailable,
        monitored: seriesToEnrich.monitored,
        path: seriesToEnrich.path,
        episodeStats: seriesToEnrich.episodeStats,
        seasonInfo: seriesToEnrich.seasonInfo,
        imdbId: seriesToEnrich.imdbId,
        tvdbId: seriesToEnrich.tvdbId,
        tvMazeId: seriesToEnrich.tvMazeId,
        cast: seriesToEnrich.cast,
        gallery: seriesToEnrich.gallery,
        episodesBySeason: episodesBySeason,
      );

      return enrichedSeries;
    } catch (e) {
      return series; // Retourner la série originale en cas d'erreur
    }
  }


}
