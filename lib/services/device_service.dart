import 'dart:async';
import 'dart:io' show Platform;
import '../models/device_model.dart';
import 'api_client.dart';
import 'user_storage_service.dart';

class DeviceService {
  static Timer? _heartbeatTimer;

  /// Récupérer tous les appareils associés à l'utilisateur
  static Future<List<DeviceApiModel>> listDevices() async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>('/api/devices');
      if (response.isSuccess && response.data != null) {
        final List<dynamic> devicesList = response.data!['data'] ?? [];
        return devicesList
            .map((json) => DeviceApiModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des appareils: $e');
    }
    return [];
  }

  /// Déconnecter un appareil spécifique
  static Future<bool> disconnectDevice(String deviceId) async {
    try {
      final response = await ApiClient.delete<Map<String, dynamic>>('/api/devices/$deviceId');
      return response.isSuccess;
    } catch (e) {
      print('❌ Erreur lors de la déconnexion de l\'appareil $deviceId: $e');
      return false;
    }
  }

  /// Déconnecter tous les autres appareils sauf l'actuel
  static Future<bool> disconnectOthers(String currentDeviceId) async {
    try {
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/api/devices/disconnect-others',
        body: {'currentDeviceId': currentDeviceId},
      );
      return response.isSuccess;
    } catch (e) {
      print('❌ Erreur lors de la déconnexion des autres appareils: $e');
      return false;
    }
  }

  /// Envoyer le heartbeat de l'appareil courant au serveur
  static Future<bool> sendHeartbeat() async {
    try {
      // Vérifier si l'utilisateur est connecté avant d'envoyer le heartbeat
      final isLoggedIn = await UserStorageService.isLoggedIn();
      if (!isLoggedIn) return false;

      final deviceId = await UserStorageService.getOrCreateDeviceId();
      
      String deviceName = 'Appareil Mobile';
      try {
        deviceName = Platform.localHostname;
      } catch (_) {}

      String deviceType = 'Mobile';
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        deviceType = 'Desktop';
      }

      final body = {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
        'operatingSystem': Platform.operatingSystemVersion,
        'appVersion': '1.0.0'
      };

      final response = await ApiClient.post<Map<String, dynamic>>(
        '/api/devices/heartbeat',
        body: body,
      );

      return response.isSuccess;
    } catch (e) {
      print('❌ Erreur lors de l\'envoi du heartbeat: $e');
      return false;
    }
  }

  /// Démarrer l'envoi périodique du heartbeat
  static void startHeartbeat() {
    // Éviter de lancer plusieurs timers
    _heartbeatTimer?.cancel();
    
    // Envoyer un premier heartbeat immédiatement
    sendHeartbeat();
    
    // Configurer le timer périodique (toutes les 60 secondes)
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      sendHeartbeat();
    });
    
    print('🔄 Heartbeat d\'appareil démarré (période: 60s)');
  }

  /// Arrêter l'envoi périodique du heartbeat
  static void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    print('⏹️ Heartbeat d\'appareil arrêté');
  }
}
