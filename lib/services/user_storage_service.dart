import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorageService {
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keySelectedProfile = 'selected_profile';

  // Stockage en mémoire comme fallback
  static Map<String, dynamic>? _memoryUserData;
  static bool _memoryIsLoggedIn = false;
  static Map<String, dynamic>? _memorySelectedProfile;
  static bool _useMemoryFallback = false;

  // Sauvegarder les données utilisateur
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    // Mettre à jour systématiquement le cache mémoire pour un accès immédiat sans asynchronie
    _memoryUserData = userData;
    _memoryIsLoggedIn = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Sauvegarder les données utilisateur complètes
      await prefs.setString(_keyUserData, jsonEncode(userData));

      // Marquer comme connecté
      await prefs.setBool(_keyIsLoggedIn, true);
    } catch (e) {
      // Fallback vers le stockage en mémoire uniquement si SharedPreferences échoue
      _useMemoryFallback = true;
    }
  }

  // Récupérer les données utilisateur (toujours désenveloppées — sans la couche 'data' englobante)
  static Future<Map<String, dynamic>?> getUserData() async {
    Map<String, dynamic>? raw;

    if (_memoryUserData != null) {
      raw = _memoryUserData;
    } else if (_useMemoryFallback) {
      raw = _memoryUserData;
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString(_keyUserData);
        if (userDataString != null) {
          _memoryUserData = jsonDecode(userDataString) as Map<String, dynamic>;
          _memoryIsLoggedIn = true;
          raw = _memoryUserData;
        }
      } catch (e) {
        _useMemoryFallback = true;
        raw = _memoryUserData;
      }
    }

    if (raw == null) return null;

    // Désenvelopper automatiquement si les données sont sous la clé 'data'
    // Ex: { "success": true, "data": { "userId": "...", ... } }
    if (raw.containsKey('data') && raw['data'] is Map) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw;
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    if (_memoryIsLoggedIn) {
      return true;
    }

    if (_useMemoryFallback) {
      return _memoryIsLoggedIn;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _memoryIsLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      return _memoryIsLoggedIn;
    } catch (e) {
      _useMemoryFallback = true;
      return _memoryIsLoggedIn;
    }
  }

  // Extraire les données utilisateur réelles si elles sont enveloppées
  static Map<String, dynamic>? _getActualUserData(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    if (userData.containsKey('data') && userData['data'] is Map) {
      return userData['data'] as Map<String, dynamic>;
    }
    return userData;
  }

  // Récupérer le nom d'utilisateur
  static Future<String?> getUsername() async {
    final rawData = await getUserData();
    final userData = _getActualUserData(rawData);
    return userData?['username'] as String?;
  }

  // Récupérer l'email
  static Future<String?> getEmail() async {
    final rawData = await getUserData();
    final userData = _getActualUserData(rawData);
    return userData?['email'] as String?;
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final rawData = await getUserData();
    final userData = _getActualUserData(rawData);
    if (userData == null) return null;
    
    // Essayer de récupérer le token depuis l'objet session de Supabase
    if (userData.containsKey('session') && userData['session'] is Map) {
      return userData['session']['accessToken'] as String?;
    }
    
    // Fallback sur l'ancien format de clé 'token'
    return userData['token'] as String?;
  }

  // Récupérer les informations du profil principal
  static Future<Map<String, dynamic>?> getMainProfile() async {
    final selectedProfile = await getSelectedProfile();
    if (selectedProfile != null) {
      return selectedProfile;
    }

    final rawData = await getUserData();
    final userData = _getActualUserData(rawData);
    final profiles = userData?['profiles'];

    if (profiles != null &&
        profiles['data'] != null &&
        profiles['data'].isNotEmpty) {
      // Retourner le premier profil ou celui marqué comme défaut
      final profilesList = profiles['data'] as List;

      // Chercher le profil par défaut (gère booléen ou entier)
      final defaultProfile = profilesList.firstWhere(
        (profile) => profile['isDefault'] == true || profile['isDefault'] == 1,
        orElse: () => profilesList.first,
      );

      return defaultProfile as Map<String, dynamic>;
    }

    return null;
  }

  // Sauvegarder le profil sélectionné
  static Future<void> saveSelectedProfile(Map<String, dynamic> profile) async {
    // Mettre à jour systématiquement le cache mémoire pour un accès immédiat
    _memorySelectedProfile = profile;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedProfile, jsonEncode(profile));
    } catch (e) {
      _useMemoryFallback = true;
    }
  }

  // Récupérer le profil sélectionné
  static Future<Map<String, dynamic>?> getSelectedProfile() async {
    if (_memorySelectedProfile != null) {
      return _memorySelectedProfile;
    }

    if (_useMemoryFallback) {
      return _memorySelectedProfile;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString(_keySelectedProfile);

      if (profileString != null) {
        _memorySelectedProfile = jsonDecode(profileString) as Map<String, dynamic>;
        return _memorySelectedProfile;
      }
    } catch (e) {
      _useMemoryFallback = true;
      return _memorySelectedProfile;
    }

    return null;
  }

  // Vérifier si un profil a été sélectionné
  static Future<bool> hasSelectedProfile() async {
    final profile = await getSelectedProfile();
    return profile != null;
  }

  // Supprimer le profil sélectionné
  static Future<void> clearSelectedProfile() async {
    _memorySelectedProfile = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySelectedProfile);
    } catch (e) {
      // Ignoré
    }
  }


  // Obtenir ou générer un device ID unique
  static Future<String> getOrCreateDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_id');
      if (deviceId == null) {
        final random = DateTime.now().millisecondsSinceEpoch.hashCode;
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}_$random';
        await prefs.setString('device_id', deviceId);
      }
      return deviceId;
    } catch (_) {
      return 'device_fallback_memory';
    }
  }

  // Obtenir le device ID actuel si existant
  static Future<String?> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('device_id');
    } catch (_) {
      return null;
    }
  }

  // Déconnexion - supprimer toutes les données
  static Future<void> logout() async {
    _memoryUserData = null;
    _memoryIsLoggedIn = false;
    _memorySelectedProfile = null;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Supprimer toutes les données utilisateur et profil sélectionné
      await prefs.remove(_keyUserData);
      await prefs.remove(_keySelectedProfile);
      await prefs.setBool(_keyIsLoggedIn, false);
    } catch (e) {
      _useMemoryFallback = true;
    }
  }

  // Effacer complètement toutes les données
  static Future<void> clearAll() async {
    // Nettoyer la mémoire
    _memoryUserData = null;
    _memoryIsLoggedIn = false;
    _memorySelectedProfile = null;
    _useMemoryFallback = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // Ignoré
    }
  }


  // Méthode pour vérifier quel système de stockage est utilisé
  static bool isUsingMemoryFallback() {
    return _useMemoryFallback;
  }

  // Méthode pour forcer l'utilisation de SharedPreferences (pour les tests)
  static void resetToSharedPreferences() {
    _useMemoryFallback = false;
    _memoryUserData = null;
    _memoryIsLoggedIn = false;
  }
}
