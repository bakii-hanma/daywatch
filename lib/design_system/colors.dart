import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFFCC242C); // Rouge spécifique de l'app
  static const Color primaryDark = Color(0xFFB01E25);
  static const Color primaryLight = Color(0xFFE53E3E);

  // Couleurs neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Couleurs de fond
  static const Color backgroundLight = Color(
    0xFFF5EEEE,
  ); // Couleur norme F5EEEE
  static const Color backgroundDark = Color(
    0xFF191717,
  ); // Noir spécifique mode sombre

  // Couleurs de surface
  static const Color surfaceLight = Color(
    0xFFFFFFFF,
  ); // Blanc pour les cartes/surfaces
  static const Color surfaceDark = Color(
    0xFF2A2A2A,
  ); // Surface sombre pour les cartes

  // Couleurs pour boutons et tab bars
  static const Color buttonLight = Color(
    0xFFE0D9D9,
  ); // Couleur boutons mode jour
  static const Color buttonDark = Color(
    0xFF2A2A2A,
  ); // Couleur boutons mode nuit

  // Couleurs de carte
  static const Color cardLight = Color(0xFFF5F5F5);
  static const Color cardDark = Color(0xFF2A2A2A);

  // Couleurs pour boutons de recherche et filtre
  static const Color searchButtonLight = Color(0xFF2E2828);
  static const Color searchButtonDark = Color(0xFF2E2828);

  // Couleur de fond pour le mode clair dans les pages de recherche
  static const Color lightSearchBackground = Color(0xFFF5EEEE);

  // Couleurs de texte
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Couleurs d'accent
  static const Color accent = Color(0xFFFFC107); // Amber pour les étoiles
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // Couleurs avec opacité
  static Color greyOverlay(double opacity) => Colors.grey.withOpacity(opacity);
  static Color blackOverlay(double opacity) =>
      Colors.black.withOpacity(opacity);
  static Color whiteOverlay(double opacity) =>
      Colors.white.withOpacity(opacity);
  static Color darkModeOverlay(double opacity) => const Color(
    0xFF191717,
  ).withOpacity(opacity); // Overlay spécifique mode sombre

  // Couleurs d'overlay pour écrans d'authentification
  static List<Color> getAuthOverlayColors(bool isDarkMode) {
    if (isDarkMode) {
      return [
        Colors.transparent,
        Colors.black.withOpacity(0.1),
        Colors.black.withOpacity(0.3),
        Colors.black.withOpacity(0.6),
        Colors.black.withOpacity(0.9),
      ];
    } else {
      return [
        Colors.transparent,
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.6),
        Colors.white.withOpacity(0.9),
      ];
    }
  }

  // Couleur d'overlay pour container d'authentification
  static Color getAuthContainerColor(bool isDarkMode) {
    return isDarkMode
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.7);
  }

  // Bordure pour container d'authentification (mode clair uniquement)
  static Border? getAuthContainerBorder(bool isDarkMode) {
    return isDarkMode
        ? null
        : Border.all(color: Colors.white.withOpacity(0.3), width: 1);
  }

  // Couleurs pour les champs de formulaire d'authentification
  static Color getAuthFieldFillColor(bool isDarkMode) {
    return isDarkMode
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.05);
  }

  static Color getAuthFieldBorderColor(bool isDarkMode) {
    return isDarkMode
        ? Colors.white.withOpacity(0.8)
        : Colors.black.withOpacity(0.2);
  }

  static Color getAuthHintTextColor(bool isDarkMode) {
    return isDarkMode
        ? Colors.white.withOpacity(0.6)
        : Colors.black.withOpacity(0.5);
  }

  static Color getAuthStatusBarColor(bool isDarkMode) {
    return isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.white.withOpacity(0.8);
  }

  // Getters pour thème adaptatif
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? backgroundDark : backgroundLight;
  }

  static Color getSearchBackgroundColor(bool isDarkMode) {
    return isDarkMode ? backgroundDark : backgroundLight;
  }

  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? textPrimaryDark : textPrimaryLight;
  }

  static Color getTextSecondaryColor(bool isDarkMode) {
    return isDarkMode ? textSecondaryDark : textSecondaryLight;
  }

  static Color getCardColor(bool isDarkMode) {
    return isDarkMode ? cardDark : cardLight;
  }

  static Color getSearchButtonColor(bool isDarkMode) {
    return isDarkMode ? searchButtonDark : searchButtonLight;
  }

  static Color getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? surfaceDark : surfaceLight;
  }

  static Color getButtonColor(bool isDarkMode) {
    return isDarkMode ? buttonDark : buttonLight;
  }

  static Color getWidgetBackgroundColor(bool isDarkMode) {
    return isDarkMode
        ? backgroundDark
        : buttonLight; // #191717 pour dark, #E0D9D9 pour light
  }
}
