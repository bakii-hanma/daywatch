import '../models/series_model.dart';
import 'api_client.dart';

class SeriesService {
  /// Test de connectivité avec l'API Sonarr
  static Future<bool> testConnection() async {
    try {
      print('🔗 Test de connexion Sonarr vers ${ApiClient.baseUrl}...');
      final series = await ApiClient.getRecentSeries<SeriesApiModel>(
        limit: 1,
        fromJson: (json) => SeriesApiModel.fromJson(json),
      );
      return series.isNotEmpty;
    } catch (e) {
      print('❌ Erreur de connexion Sonarr: $e');
      return false;
    }
  }

  /// Diagnostic réseau pour l'API Sonarr
  static Future<void> diagnoseNetwork() async {
    print('\n🔍 === DIAGNOSTIC RÉSEAU SONARR ===');
    print('📍 URL de base: ${ApiClient.baseUrl}');
    print('🎯 Endpoint: /api/sonarr/series/popular');

    try {
      final isConnected = await testConnection();
      print(
        isConnected ? '✅ Connectivité confirmée' : '❌ Test de connexion échoué',
      );
    } catch (e) {
      print('❌ Erreur lors du diagnostic: $e');
    }
    print('=== FIN DIAGNOSTIC ===\n');
  }

  /// Récupération des séries populaires
  static Future<List<SeriesApiModel>> getPopularSeries({int limit = 10}) async {
    return _getSeriesWithRetry(
      () => ApiClient.getPopularSeries<SeriesApiModel>(
        limit: limit,
        fromJson: (json) => SeriesApiModel.fromJson(json),
      ),
      'séries populaires',
      limit,
    );
  }

  /// Récupération des séries récentes
  static Future<List<SeriesApiModel>> getRecentSeries({int limit = 10}) async {
    return _getSeriesWithRetry(
      () => ApiClient.getRecentSeries<SeriesApiModel>(
        limit: limit,
        fromJson: (json) => SeriesApiModel.fromJson(json),
      ),
      'séries récentes',
      limit,
    );
  }

  /// Méthode helper avec retry pour récupérer les séries
  static Future<List<SeriesApiModel>> _getSeriesWithRetry(
    Future<List<SeriesApiModel>> Function() apiCall,
    String seriesType,
    int limit,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        print(
          '📥 Récupération des $seriesType (tentative ${retryCount + 1}/$maxRetries, limite: $limit)...',
        );

        final series = await apiCall();

        print('✅ ${series.length} $seriesType récupérées avec succès');

        // Debug : afficher les titres
        if (series.isNotEmpty) {
          print('📺 $seriesType récupérées:');
          for (var serie in series.take(3)) {
            print(
              '   - ${serie.title} (${serie.year}) - Note: ${serie.rating}',
            );
          }
          if (series.length > 3) {
            print('   ... et ${series.length - 3} autres');
          }
        }

        return series;
      } catch (e) {
        retryCount++;
        print(
          '❌ Tentative ${retryCount}/$maxRetries échouée pour $seriesType: $e',
        );

        if (retryCount < maxRetries) {
          print(
            '⏳ Nouvelle tentative dans ${retryDelay.inSeconds} secondes...',
          );
          await Future.delayed(retryDelay);
        } else {
          print('❌ Toutes les tentatives échouées pour $seriesType');
          return [];
        }
      }
    }
    return [];
  }

  /// Récupération d'une série par son ID
  static Future<SeriesApiModel?> getSeriesById(String seriesId) async {
    try {
      print('📥 Récupération de la série ID: $seriesId...');

      final response = await ApiClient.getSeriesById<SeriesApiModel>(
        seriesId,
        fromJson: (json) => SeriesApiModel.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        final series = response.data!;
        print('✅ Série récupérée: ${series.title}');
        return series;
      } else {
        print(
          '❌ Erreur lors de la récupération de la série: ${response.error}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception lors de la récupération de la série: $e');
      return null;
    }
  }

  /// Récupération d'une série par son ID avec tous ses épisodes inclus
  static Future<SeriesApiModel?> getSeriesWithEpisodes(String seriesId) async {
    try {
      print(
        '📥 Récupération de la série ID: $seriesId avec tous ses épisodes...',
      );

      final response = await ApiClient.getSeriesById<SeriesApiModel>(
        seriesId,
        fromJson: (json) => SeriesApiModel.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        final series = response.data!;
        print('✅ Série récupérée: ${series.title}');

        // Vérifier si les épisodes sont déjà inclus dans la réponse
        if (series.episodesBySeason.isNotEmpty) {
          print(
            '📺 Épisodes déjà inclus dans la réponse: ${series.episodesBySeason.length} saisons',
          );
          return series;
        }

        // Si les épisodes ne sont pas inclus, les récupérer séparément
        print('📥 Récupération des épisodes séparément...');
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

          print(
            '✅ Série enrichie avec ${allEpisodes.length} épisodes répartis sur ${episodesBySeason.length} saisons',
          );
          return enrichedSeries;
        } else {
          print('⚠️ Aucun épisode trouvé pour la série "${series.title}"');
          return series;
        }
      } else {
        print(
          '❌ Erreur lors de la récupération de la série: ${response.error}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception lors de la récupération de la série: $e');
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
      print(
        '📥 Récupération de l\'épisode S${seasonNumber}E${episodeNumber} de la série $seriesId...',
      );

      // D'abord récupérer la série avec tous ses épisodes
      final series = await getSeriesWithEpisodes(seriesId);
      if (series == null) {
        print('❌ Série non trouvée');
        return null;
      }

      // Chercher l'épisode dans les épisodes de la saison
      final seasonEpisodes = series.getEpisodesForSeason(seasonNumber);
      final episode = seasonEpisodes
          .where((e) => e.episodeNumber == episodeNumber)
          .firstOrNull;

      if (episode != null) {
        print('✅ Épisode trouvé: ${episode.title}');
        print('   📁 Fichier: ${episode.file?.fileName ?? 'Non disponible'}');
        print('   🎬 Qualité: ${episode.getQuality()}');
        print('   📊 Taille: ${episode.getFileSize()}');
        print(
          '   🔗 URL de streaming: ${episode.getStreamUrl() ?? 'Non disponible'}',
        );
        return episode;
      } else {
        print('❌ Épisode S${seasonNumber}E${episodeNumber} non trouvé');
        return null;
      }
    } catch (e) {
      print('❌ Exception lors de la récupération de l\'épisode: $e');
      return null;
    }
  }

  /// Récupération des épisodes d'une saison
  static Future<List<EpisodeApiModel>> getSeasonEpisodes({
    required String seriesId,
    required int seasonNumber,
  }) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        print(
          '📥 Récupération des épisodes de la série $seriesId, saison $seasonNumber (tentative ${retryCount + 1}/$maxRetries)...',
        );

        final endpoint =
            '/api/sonarr/series/$seriesId/episodes?seasonNumber=$seasonNumber';
        final response = await ApiClient.get<dynamic>(
          endpoint,
          timeout: const Duration(
            seconds: 45,
          ), // Timeout plus long pour les épisodes
        );

        if (response.isSuccess && response.data != null) {
          List<dynamic> episodesData;

          // Gérer différents formats de réponse
          if (response.data is List) {
            // Format direct : liste d'épisodes
            episodesData = response.data as List<dynamic>;
            print(
              '📋 Format de réponse: Liste directe (${episodesData.length} épisodes)',
            );
          } else if (response.data is Map<String, dynamic>) {
            // Format avec wrapper : { success: true, data: [...], message: "..." }
            final responseMap = response.data as Map<String, dynamic>;

            if (responseMap['data'] is List) {
              episodesData = responseMap['data'] as List<dynamic>;
              print(
                '📋 Format de réponse: Wrapper avec success/data (${episodesData.length} épisodes)',
              );
              print('📊 Message: ${responseMap['message'] ?? 'Non spécifié'}');
              print('📈 Count: ${responseMap['count'] ?? 'Non spécifié'}');
            } else {
              print('⚠️ Format de réponse inattendu: Map sans champ data');
              print('🔍 Clés disponibles: ${responseMap.keys.toList()}');
              retryCount++;
              if (retryCount < maxRetries) {
                await Future.delayed(retryDelay);
                continue;
              } else {
                return [];
              }
            }
          } else {
            print('⚠️ Format de réponse inattendu pour les épisodes');
            print('🔍 Type reçu: ${response.data.runtimeType}');
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(retryDelay);
              continue;
            } else {
              return [];
            }
          }

          // Debug : afficher les données brutes du premier épisode
          if (episodesData.isNotEmpty) {
            print('🔍 Données brutes du premier épisode:');
            final firstEpisodeData = episodesData.first;
            print('   - Type: ${firstEpisodeData.runtimeType}');
            print(
              '   - Clés: ${firstEpisodeData is Map ? firstEpisodeData.keys.toList() : 'Non-Map'}',
            );
            if (firstEpisodeData is Map) {
              print('   - hasFile: ${firstEpisodeData['hasFile']}');
              print('   - file: ${firstEpisodeData['file']}');
              print('   - episodeFile: ${firstEpisodeData['episodeFile']}');
            }
          }

          final List<EpisodeApiModel> episodes = episodesData
              .map((episode) => EpisodeApiModel.fromJson(episode))
              .toList();

          print(
            '✅ ${episodes.length} épisodes récupérés pour la saison $seasonNumber',
          );

          // Debug : afficher les premiers épisodes
          if (episodes.isNotEmpty) {
            print('📺 Épisodes récupérés:');
            for (var episode in episodes.take(3)) {
              print('   - Épisode ${episode.episodeNumber}: ${episode.title}');
              print('     hasFile: ${episode.hasFile}');
              print('     file: ${episode.file?.fullPath ?? 'null'}');
              print('     quality: ${episode.getQuality()}');
              print('     size: ${episode.getFileSize()}');
            }
            if (episodes.length > 3) {
              print('   ... et ${episodes.length - 3} autres');
            }
          }

          return episodes;
        } else {
          print(
            '❌ Erreur lors de la récupération des épisodes: ${response.error}',
          );
          retryCount++;

          if (retryCount < maxRetries) {
            print(
              '⏳ Nouvelle tentative dans ${retryDelay.inSeconds} secondes...',
            );
            await Future.delayed(retryDelay);
          } else {
            return [];
          }
        }
      } catch (e) {
        retryCount++;
        print(
          '❌ Tentative ${retryCount}/$maxRetries échouée pour les épisodes: $e',
        );

        if (retryCount < maxRetries) {
          print(
            '⏳ Nouvelle tentative dans ${retryDelay.inSeconds} secondes...',
          );
          await Future.delayed(retryDelay);
        } else {
          print('❌ Toutes les tentatives échouées pour les épisodes');
          return [];
        }
      }
    }
    return [];
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
        print(
          '📥 Récupération de tous les épisodes de la série $seriesId (tentative ${retryCount + 1}/$maxRetries)...',
        );

        final endpoint = '/api/sonarr/series/$seriesId/episodes';
        final response = await ApiClient.get<dynamic>(
          endpoint,
          timeout: const Duration(
            seconds: 90,
          ), // Timeout très long pour tous les épisodes
        );

        if (response.isSuccess && response.data != null) {
          List<dynamic> episodesData;

          // Gérer différents formats de réponse
          if (response.data is List) {
            // Format direct : liste d'épisodes
            episodesData = response.data as List<dynamic>;
            print(
              '📋 Format de réponse: Liste directe (${episodesData.length} épisodes)',
            );
          } else if (response.data is Map<String, dynamic>) {
            // Format avec wrapper : { success: true, data: [...], message: "..." }
            final responseMap = response.data as Map<String, dynamic>;

            if (responseMap['data'] is List) {
              episodesData = responseMap['data'] as List<dynamic>;
              print(
                '📋 Format de réponse: Wrapper avec success/data (${episodesData.length} épisodes)',
              );
              print('📊 Message: ${responseMap['message'] ?? 'Non spécifié'}');
              print('📈 Count: ${responseMap['count'] ?? 'Non spécifié'}');
            } else {
              print('⚠️ Format de réponse inattendu: Map sans champ data');
              print('🔍 Clés disponibles: ${responseMap.keys.toList()}');
              retryCount++;
              if (retryCount < maxRetries) {
                await Future.delayed(retryDelay);
                continue;
              } else {
                return [];
              }
            }
          } else {
            print('⚠️ Format de réponse inattendu pour tous les épisodes');
            print('🔍 Type reçu: ${response.data.runtimeType}');
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

          print(
            '✅ ${episodes.length} épisodes récupérés pour la série $seriesId',
          );

          // Debug : afficher les statistiques par saison
          final Map<int, int> episodesBySeason = {};
          for (var episode in episodes) {
            episodesBySeason[episode.seasonNumber] =
                (episodesBySeason[episode.seasonNumber] ?? 0) + 1;
          }

          print('📊 Répartition par saison:');
          for (var entry in episodesBySeason.entries) {
            print('   - Saison ${entry.key}: ${entry.value} épisodes');
          }

          return episodes;
        } else {
          print(
            '❌ Erreur lors de la récupération de tous les épisodes: ${response.error}',
          );
          retryCount++;

          if (retryCount < maxRetries) {
            print(
              '⏳ Nouvelle tentative dans ${retryDelay.inSeconds} secondes...',
            );
            await Future.delayed(retryDelay);
          } else {
            return [];
          }
        }
      } catch (e) {
        retryCount++;
        print(
          '❌ Tentative ${retryCount}/$maxRetries échouée pour tous les épisodes: $e',
        );

        if (retryCount < maxRetries) {
          print(
            '⏳ Nouvelle tentative dans ${retryDelay.inSeconds} secondes...',
          );
          await Future.delayed(retryDelay);
        } else {
          print('❌ Toutes les tentatives échouées pour tous les épisodes');
          return [];
        }
      }
    }
    return [];
  }

  /// Enrichir une série avec tous ses épisodes
  static Future<SeriesApiModel?> enrichSeriesWithEpisodes({
    required SeriesApiModel series,
  }) async {
    try {
      print(
        '🔄 Enrichissement de la série "${series.title}" avec ses épisodes...',
      );

      final allEpisodes = await getAllSeriesEpisodes(seriesId: series.id);

      if (allEpisodes.isEmpty) {
        print('⚠️ Aucun épisode trouvé pour la série "${series.title}"');
        return series;
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

      print(
        '✅ Série "${series.title}" enrichie avec ${allEpisodes.length} épisodes répartis sur ${episodesBySeason.length} saisons',
      );
      return enrichedSeries;
    } catch (e) {
      print('❌ Erreur lors de l\'enrichissement de la série: $e');
      return series; // Retourner la série originale en cas d'erreur
    }
  }

  /// Diagnostic pour un épisode spécifique
  static Future<void> diagnoseEpisode(String seriesId, int episodeId) async {
    try {
      print('🔍 === DIAGNOSTIC ÉPISODE $episodeId ===');

      // Récupérer la série avec tous ses épisodes
      final series = await getSeriesWithEpisodes(seriesId);
      if (series == null) {
        print('❌ Série non trouvée');
        return;
      }

      // Chercher l'épisode spécifique
      EpisodeApiModel? targetEpisode;
      for (var seasonEpisodes in series.episodesBySeason.values) {
        targetEpisode = seasonEpisodes
            .where((e) => e.id == episodeId)
            .firstOrNull;
        if (targetEpisode != null) break;
      }

      if (targetEpisode != null) {
        print('✅ Épisode $episodeId trouvé: ${targetEpisode.title}');
        print('   - hasFile: ${targetEpisode.hasFile}');
        print('   - file: ${targetEpisode.file}');
        print('   - file?.fullPath: ${targetEpisode.file?.fullPath}');
        print('   - file?.fileName: ${targetEpisode.file?.fileName}');
        print('   - getStreamUrl(): ${targetEpisode.getStreamUrl()}');
        print('   - getFilePath(): ${targetEpisode.getFilePath()}');
      } else {
        print('❌ Épisode $episodeId non trouvé');
      }

      print('=== FIN DIAGNOSTIC ===');
    } catch (e) {
      print('❌ Erreur lors du diagnostic: $e');
    }
  }
}
