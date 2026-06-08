import '../config/server_config.dart';

String _resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  if (url.startsWith('/')) {
    return '${ServerConfig.apiBaseUrl}$url';
  }
  return url;
}

class TvChannelModel {
  final String id;
  final String name;
  final String category;
  final String logo;
  final String url;
  final List<String> languages;
  final bool isNsfw;
  final String country;

  TvChannelModel({
    required this.id,
    required this.name,
    required this.category,
    required this.logo,
    required this.url,
    required this.languages,
    required this.isNsfw,
    required this.country,
  });

  factory TvChannelModel.fromJson(Map<String, dynamic> json) {
    // Gérer les catégories (peut être une liste ou une chaîne simple)
    String categoryStr = 'Généraliste';
    if (json['categories'] != null &&
        json['categories'] is List &&
        (json['categories'] as List).isNotEmpty) {
      categoryStr = (json['categories'] as List).first.toString();
    } else if (json['category'] != null) {
      categoryStr = json['category'].toString();
    }

    return TvChannelModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: categoryStr,
      logo: _resolveImageUrl(json['logo'] as String?),
      url:
          json['primaryStream'] ??
          json['url'] ??
          '', // primaryStream est l'URL de diffusion
      languages: List<String>.from(json['languages'] ?? ['fr']),
      isNsfw: json['isNsfw'] ?? false, // Différent de is_nsfw
      country: json['country'] ?? 'FR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'logo': logo,
      'url': url,
      'languages': languages,
      'is_nsfw': isNsfw,
      'country': country,
    };
  }

  @override
  String toString() {
    return 'TvChannelModel{id: $id, name: $name, category: $category}';
  }
}
