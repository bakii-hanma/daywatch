import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorageService {
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Stockage en mémoire comme fallback
  static Map<String, dynamic>? _memoryUserData;
  static bool _memoryIsLoggedIn = false;
  static bool _useMemoryFallback = false;

  // Sauvegarder les données utilisateur
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Sauvegarder les données utilisateur complètes
      await prefs.setString(_keyUserData, jsonEncode(userData));

      // Marquer comme connecté
      await prefs.setBool(_keyIsLoggedIn, true);

      print('✅ Données utilisateur sauvegardées avec SharedPreferences');
    } catch (e) {
      print('⚠️ Erreur SharedPreferences, utilisation du stockage mémoire: $e');
      // Fallback vers le stockage en mémoire
      _useMemoryFallback = true;
      _memoryUserData = userData;
      _memoryIsLoggedIn = true;
      print('✅ Données utilisateur sauvegardées en mémoire');
    }
  }

  // Récupérer les données utilisateur
  static Future<Map<String, dynamic>?> getUserData() async {
    if (_useMemoryFallback) {
      return _memoryUserData;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_keyUserData);

      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('⚠️ Erreur SharedPreferences, basculement vers mémoire: $e');
      _useMemoryFallback = true;
      return _memoryUserData;
    }

    return null;
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    if (_useMemoryFallback) {
      return _memoryIsLoggedIn;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      print('⚠️ Erreur SharedPreferences, basculement vers mémoire: $e');
      _useMemoryFallback = true;
      return _memoryIsLoggedIn;
    }
  }

  // Récupérer le nom d'utilisateur
  static Future<String?> getUsername() async {
    final userData = await getUserData();
    return userData?['username'] as String?;
  }

  // Récupérer l'email
  static Future<String?> getEmail() async {
    final userData = await getUserData();
    return userData?['email'] as String?;
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final userData = await getUserData();
    return userData?['token'] as String?;
  }

  // Récupérer les informations du profil principal
  static Future<Map<String, dynamic>?> getMainProfile() async {
    final userData = await getUserData();
    final profiles = userData?['profiles'];

    if (profiles != null &&
        profiles['data'] != null &&
        profiles['data'].isNotEmpty) {
      // Retourner le premier profil ou celui marqué comme défaut
      final profilesList = profiles['data'] as List;

      // Chercher le profil par défaut
      final defaultProfile = profilesList.firstWhere(
        (profile) => profile['isDefault'] == 1,
        orElse: () => profilesList.first,
      );

      return defaultProfile as Map<String, dynamic>;
    }

    return null;
  }

  // Déconnexion - supprimer toutes les données
  static Future<void> logout() async {
    if (_useMemoryFallback) {
      _memoryUserData = null;
      _memoryIsLoggedIn = false;
      print('✅ Utilisateur déconnecté - données mémoire supprimées');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Supprimer toutes les données utilisateur
      await prefs.remove(_keyUserData);
      await prefs.setBool(_keyIsLoggedIn, false);

      print('✅ Utilisateur déconnecté - données SharedPreferences supprimées');
    } catch (e) {
      print('⚠️ Erreur lors de la déconnexion SharedPreferences: $e');
      // Nettoyer la mémoire quand même
      _memoryUserData = null;
      _memoryIsLoggedIn = false;
      _useMemoryFallback = true;
      print('✅ Utilisateur déconnecté - données mémoire supprimées');
    }
  }

  // Effacer complètement toutes les données
  static Future<void> clearAll() async {
    // Nettoyer la mémoire
    _memoryUserData = null;
    _memoryIsLoggedIn = false;
    _useMemoryFallback = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Toutes les données SharedPreferences effacées');
    } catch (e) {
      print('⚠️ Erreur lors du nettoyage SharedPreferences: $e');
      print('✅ Données mémoire effacées');
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
