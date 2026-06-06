class DeviceApiModel {
  final int id;
  final String userId;
  final String deviceId;
  final String? deviceName;
  final String? deviceType;
  final String? operatingSystem;
  final String? ipAddress;
  final String? appVersion;
  final DateTime lastActive;
  final bool isConnected;

  DeviceApiModel({
    required this.id,
    required this.userId,
    required this.deviceId,
    this.deviceName,
    this.deviceType,
    this.operatingSystem,
    this.ipAddress,
    this.appVersion,
    required this.lastActive,
    required this.isConnected,
  });

  factory DeviceApiModel.fromJson(Map<String, dynamic> json) {
    return DeviceApiModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['userId'] ?? '',
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
      operatingSystem: json['operatingSystem'],
      ipAddress: json['ipAddress'],
      appVersion: json['appVersion'],
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : DateTime.now(),
      isConnected: json['isConnected'] == true || json['isConnected'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'operatingSystem': operatingSystem,
      'ipAddress': ipAddress,
      'appVersion': appVersion,
      'lastActive': lastActive.toIso8601String(),
      'isConnected': isConnected,
    };
  }
}
