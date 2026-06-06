import '../models/tv_channel_model.dart';
import 'api_client.dart';

class TvChannelService {
  // Récupérer toutes les chaînes TV avec pagination
  static Future<List<TvChannelModel>> getAllChannels({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final channels = await ApiClient.getAllTvChannels<TvChannelModel>(
        page: page,
        limit: limit,
        fromJson: TvChannelModel.fromJson,
      );

      // Filtrer le contenu NSFW
      final filteredChannels = channels
          .where((channel) => !channel.isNsfw)
          .toList();

      return filteredChannels;
    } catch (e) {
      return [];
    }
  }

  // Récupérer un nombre limité de chaînes pour la page d'accueil
  static Future<List<TvChannelModel>> getHomeChannels({int limit = 8}) async {
    try {
      final channels = await ApiClient.getHomeTvChannels<TvChannelModel>(
        limit: limit,
        fromJson: TvChannelModel.fromJson,
      );

      // Filtrer le contenu NSFW
      final filteredChannels = channels
          .where((channel) => !channel.isNsfw)
          .toList();

      return filteredChannels;
    } catch (e) {
      return [];
    }
  }

  // Récupérer les chaînes filtrées par catégorie
  static Future<List<TvChannelModel>> getChannelsByCategory(
    String category,
  ) async {
    try {
      final channels = await ApiClient.getTvChannelsByCategory<TvChannelModel>(
        category,
        limit: 100,
        fromJson: TvChannelModel.fromJson,
      );

      // Filtrer le contenu NSFW
      final filteredChannels = channels
          .where((channel) => !channel.isNsfw)
          .toList();

      return filteredChannels;
    } catch (e) {
      return [];
    }
  }

  // Récupérer toutes les chaînes (multi-pages)
  static Future<List<TvChannelModel>> getAllChannelsMultiPage({
    int maxPages = 5,
    int limitPerPage = 50,
  }) async {
    try {
      final channels =
          await ApiClient.getAllTvChannelsMultiPage<TvChannelModel>(
            maxPages: maxPages,
            limitPerPage: limitPerPage,
            fromJson: TvChannelModel.fromJson,
          );

      // Filtrer le contenu NSFW
      final filteredChannels = channels
          .where((channel) => !channel.isNsfw)
          .toList();

      return filteredChannels;
    } catch (e) {
      return [];
    }
  }

  // Récupérer une chaîne par ID
  static Future<TvChannelModel?> getChannelById(String channelId) async {
    try {
      final response = await ApiClient.getTvChannelById<TvChannelModel>(
        channelId,
        fromJson: TvChannelModel.fromJson,
      );

      if (response.isSuccess && response.data != null) {
        final channel = response.data!;
        if (!channel.isNsfw) {
          return channel;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Obtenir la liste des catégories disponibles
  static Future<List<String>> getAvailableCategories() async {
    try {
      final categories = await ApiClient.getTvChannelCategories<TvChannelModel>(
        sampleSize: 100,
        fromJson: TvChannelModel.fromJson,
        getCategory: (channel) => channel.category,
      );

      return categories;
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

  // Tester la connectivité avec le serveur
  static Future<bool> testConnection() async {
    try {
      final isConnected = await ApiClient.testConnection();
      return isConnected;
    } catch (e) {
      return false;
    }
  }

  // Méthode utilitaire pour mapper les catégories (pour compatibilité)
  static bool _mapCategoryToFilter(String apiCategory, String filterCategory) {
    final apiCat = apiCategory.toLowerCase();
    final filterCat = filterCategory.toLowerCase();

    switch (filterCat) {
      case 'généralistes':
        return apiCat.contains('general') ||
            apiCat.contains('entertainment') ||
            apiCat.contains('variety');
      case 'sport':
        return apiCat.contains('sport');
      case 'info':
        return apiCat.contains('news') || apiCat.contains('info');
      case 'divertissement':
        return apiCat.contains('entertainment') ||
            apiCat.contains('reality') ||
            apiCat.contains('variety');
      case 'cinéma':
        return apiCat.contains('movie') ||
            apiCat.contains('cinema') ||
            apiCat.contains('film');
      case 'documentaires':
        return apiCat.contains('documentary') ||
            apiCat.contains('education') ||
            apiCat.contains('culture');
      default:
        return false;
    }
  }
}
