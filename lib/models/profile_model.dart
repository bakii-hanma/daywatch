class ProfileApiModel {
  final int id;
  final String userID;
  final String profileName;
  final String? profileAvatarUrl;
  final String profileType; // 'adult' ou 'kids'
  final Map<String, dynamic>? preferences;
  final bool isDefault;
  final bool hasPin;

  const ProfileApiModel({
    required this.id,
    required this.userID,
    required this.profileName,
    this.profileAvatarUrl,
    required this.profileType,
    this.preferences,
    required this.isDefault,
    required this.hasPin,
  });

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      id: json['id'] is int 
          ? json['id'] as int 
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userID: json['userID']?.toString() ?? '',
      profileName: json['profileName']?.toString() ?? '',
      profileAvatarUrl: json['profileAvatarUrl']?.toString(),
      profileType: json['profileType']?.toString() ?? 'adult',
      preferences: json['preferences'] is Map<String, dynamic> 
          ? json['preferences'] as Map<String, dynamic> 
          : null,
      isDefault: json['isDefault'] == true || 
          json['isDefault'] == 1 || 
          json['isDefault']?.toString().toLowerCase() == 'true',
      hasPin: json['hasPin'] == true || 
          json['hasPin'] == 1 || 
          json['hasPin']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userID': userID,
      'profileName': profileName,
      'profileAvatarUrl': profileAvatarUrl,
      'profileType': profileType,
      'preferences': preferences,
      'isDefault': isDefault,
      'hasPin': hasPin,
    };
  }
}
