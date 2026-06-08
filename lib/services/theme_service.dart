import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _keyThemeMode = 'theme_mode';
  
  // ValueNotifier global pour le mode de thème actuel
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  // Charger le thème depuis SharedPreferences au démarrage
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_keyThemeMode);
      if (savedTheme != null) {
        if (savedTheme == 'dark') {
          themeModeNotifier.value = ThemeMode.dark;
        } else if (savedTheme == 'light') {
          themeModeNotifier.value = ThemeMode.light;
        } else {
          themeModeNotifier.value = ThemeMode.system;
        }
      } else {
        // Mode sombre par défaut
        themeModeNotifier.value = ThemeMode.dark;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation du thème: $e');
      themeModeNotifier.value = ThemeMode.dark;
    }
  }

  // Changer et sauvegarder le mode de thème
  static Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      String modeStr = 'dark';
      if (mode == ThemeMode.light) {
        modeStr = 'light';
      } else if (mode == ThemeMode.system) {
        modeStr = 'system';
      }
      await prefs.setString(_keyThemeMode, modeStr);
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde du thème: $e');
    }
  }

  // Permet de savoir si le mode sombre est actuellement actif
  static bool get isDark {
    return themeModeNotifier.value == ThemeMode.dark;
  }
}
