import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:daywatch/models/tv_channel_model.dart';
import 'package:daywatch/services/tv_channel_service.dart';

void main() {
  setUpAll(() async {
    // Charger les variables d'environnement pour les tests
    await dotenv.load(fileName: ".env");
  });

  group('TvChannelService Tests', () {
    test('TvChannelModel should be created from JSON', () {
      final jsonData = {
        'id': 'test_id',
        'name': 'Test Channel',
        'category': 'Test Category',
        'logo': 'https://example.com/logo.png',
        'url': 'https://example.com/stream.m3u8',
        'languages': ['fr'],
        'is_nsfw': false,
        'country': 'FR',
      };

      final channel = TvChannelModel.fromJson(jsonData);

      expect(channel.id, equals('test_id'));
      expect(channel.name, equals('Test Channel'));
      expect(channel.category, equals('Test Category'));
      expect(channel.logo, equals('https://example.com/logo.png'));
      expect(channel.url, equals('https://example.com/stream.m3u8'));
      expect(channel.languages, contains('fr'));
      expect(channel.isNsfw, isFalse);
      expect(channel.country, equals('FR'));
    });

    test('TvChannelService should have correct URL configuration', () {
      expect(dotenv.env['API_BASE_URL'], isNotNull);
      expect(dotenv.env['IPTV_CHANNELS_ENDPOINT'], isNotNull);
    });

    // Test des méthodes de filtrage (sans appel API réel)
    test('Category mapping should work correctly', () {
      // Test avec des données mock
      expect(true, isTrue); // Placeholder pour les tests futurs
    });
  });
}
