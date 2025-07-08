import '../models/tv_channel_model.dart';
import 'api_client.dart';

class TvChannelService {
  // Récupérer toutes les chaînes TV avec pagination
  static Future<List<TvChannelModel>> getAllChannels({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      print('📺 Récupération des chaînes TV - Page $page, Limite $limit');

      final channels = await ApiClient.getAllTvChannels<TvChannelModel>(
        page: page,
        limit: limit,
        fromJson: TvChannelModel.fromJson,
      );

      // Filtrer le contenu NSFW
      final filteredChannels = channels
          .where((channel) => !channel.isNsfw)
          .toList();

      print(
        '✅ Chaînes TV récupérées: ${channels.length} (${filteredChannels.length} après filtrage NSFW)',
      );
      return filteredChannels;
    } catch (e) {
      print('❌ Erreur getAllChannels: $e');
      return [];
    }
  }

  // Récupérer un nombre limité de chaînes pour la page d'accueil
  static Future<List<TvChannelModel>> getHomeChannels({int limit = 8}) async {
    try {
      print('📺 Récupération des chaînes TV d\'accueil - Limite $limit');

      final channels = await ApiClient.getHomeTvChannels<TvChannelModel>(
        limit: limit,
        fromJson: TvChannelModel.fromJson,
      );

      // Filtrer le contenu NSFW
      final filteredChannels = channels
          .where((channel) => !channel.isNsfw)
          .toList();

      print('✅ Chaînes TV d\'accueil récupérées: ${filteredChannels.length}');
      return filteredChannels;
    } catch (e) {
      print('❌ Erreur getHomeChannels: $e');
      return [];
    }
  }

  // Récupérer les chaînes filtrées par catégorie
  static Future<List<TvChannelModel>> getChannelsByCategory(
    String category,
  ) async {
    try {
      print('📺 Récupération des chaînes TV par catégorie: $category');

      final channels = await ApiClient.getTvChannelsByCategory<TvChannelModel>(
        category,
        limit: 100,
        fromJson: TvChannelModel.fromJson,
      );

      // Filtrer le contenu NSFW
      final filteredChannels = channels
          .where((channel) => !channel.isNsfw)
          .toList();

      print(
        '✅ Chaînes TV par catégorie "$category": ${filteredChannels.length}',
      );
      return filteredChannels;
    } catch (e) {
      print('❌ Erreur getChannelsByCategory: $e');
      return [];
    }
  }

  // Récupérer toutes les chaînes (multi-pages)
  static Future<List<TvChannelModel>> getAllChannelsMultiPage({
    int maxPages = 5,
    int limitPerPage = 50,
  }) async {
    try {
      print(
        '📺 Récupération multi-pages des chaînes TV - Max $maxPages pages, $limitPerPage par page',
      );

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

      print('✅ Total chaînes TV multi-pages: ${filteredChannels.length}');
      return filteredChannels;
    } catch (e) {
      print('❌ Erreur getAllChannelsMultiPage: $e');
      return [];
    }
  }

  // Récupérer une chaîne par ID
  static Future<TvChannelModel?> getChannelById(String channelId) async {
    try {
      print('📺 Récupération de la chaîne TV par ID: $channelId');

      final response = await ApiClient.getTvChannelById<TvChannelModel>(
        channelId,
        fromJson: TvChannelModel.fromJson,
      );

      if (response.isSuccess && response.data != null) {
        final channel = response.data!;
        if (!channel.isNsfw) {
          print('✅ Chaîne TV récupérée: ${channel.name}');
          return channel;
        } else {
          print('⚠️ Chaîne TV NSFW filtrée: ${channel.name}');
          return null;
        }
      } else {
        print('❌ Chaîne TV non trouvée: $channelId');
        return null;
      }
    } catch (e) {
      print('❌ Erreur getChannelById: $e');
      return null;
    }
  }

  // Obtenir la liste des catégories disponibles
  static Future<List<String>> getAvailableCategories() async {
    try {
      print('📺 Récupération des catégories de chaînes TV disponibles');

      final categories = await ApiClient.getTvChannelCategories<TvChannelModel>(
        sampleSize: 100,
        fromJson: TvChannelModel.fromJson,
        getCategory: (channel) => channel.category,
      );

      print('✅ Catégories disponibles: ${categories.length}');
      return categories;
    } catch (e) {
      print('❌ Erreur getAvailableCategories: $e');
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
      print('🧪 Test de connectivité des chaînes TV');

      final isConnected = await ApiClient.testConnection();

      print(
        isConnected
            ? '✅ Connectivité chaînes TV confirmée'
            : '❌ Test de connexion chaînes TV échoué',
      );
      return isConnected;
    } catch (e) {
      print('❌ Test de connexion chaînes TV échoué: $e');
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
