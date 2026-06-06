class PlanApiModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String duration;
  final int maxProfiles;
  final int maxDevices;
  final int maxConcurrentStreams;
  final bool hasMovies;
  final bool hasShows;
  final bool hasIPTV;
  final bool allowDownloads;
  final bool hasAds;

  PlanApiModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    required this.maxProfiles,
    required this.maxDevices,
    required this.maxConcurrentStreams,
    required this.hasMovies,
    required this.hasShows,
    required this.hasIPTV,
    required this.allowDownloads,
    required this.hasAds,
  });

  factory PlanApiModel.fromJson(Map<String, dynamic> json) {
    return PlanApiModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      duration: json['duration']?.toString() ?? '',
      maxProfiles: json['maxProfiles'] is int
          ? json['maxProfiles']
          : int.tryParse(json['maxProfiles']?.toString() ?? '') ?? 4,
      maxDevices: json['maxDevices'] is int
          ? json['maxDevices']
          : int.tryParse(json['maxDevices']?.toString() ?? '') ?? 2,
      maxConcurrentStreams: json['maxConcurrentStreams'] is int
          ? json['maxConcurrentStreams']
          : int.tryParse(json['maxConcurrentStreams']?.toString() ?? '') ?? 2,
      hasMovies: json['hasMovies'] == true || json['hasMovies'] == 1 || json['hasMovies']?.toString().toLowerCase() == 'true',
      hasShows: json['hasShows'] == true || json['hasShows'] == 1 || json['hasShows']?.toString().toLowerCase() == 'true',
      hasIPTV: json['hasIPTV'] == true || json['hasIPTV'] == 1 || json['hasIPTV']?.toString().toLowerCase() == 'true',
      allowDownloads: json['allowDownloads'] == true || json['allowDownloads'] == 1 || json['allowDownloads']?.toString().toLowerCase() == 'true',
      hasAds: json['hasAds'] == true || json['hasAds'] == 1 || json['hasAds']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'maxProfiles': maxProfiles,
      'maxDevices': maxDevices,
      'maxConcurrentStreams': maxConcurrentStreams,
      'hasMovies': hasMovies,
      'hasShows': hasShows,
      'hasIPTV': hasIPTV,
      'allowDownloads': allowDownloads,
      'hasAds': hasAds,
    };
  }
}
