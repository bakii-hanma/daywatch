import 'package:flutter/material.dart';

/// Utilitaire pour gérer les alertes et les messages de débogage
class AlertUtils {
  /// Affiche un message à l'utilisateur via un SnackBar
  /// 
  /// [context] Le contexte de l'application
  /// [message] Le message à afficher à l'utilisateur
  /// [isError] Indique si c'est un message d'erreur (rouge) ou de succès (vert)
  /// [debugDetails] Détails supplémentaires pour les développeurs (affichés uniquement en console)
  static void showAlert({
    required BuildContext context,
    required String message,
    bool isError = false,
    String? debugDetails,
  }) {
    // Afficher le message utilisateur via SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
    
    // Afficher les détails de débogage en console pour les développeurs
    if (debugDetails != null) {
      print('DEBUG: $debugDetails');
    }
  }
  
  /// Affiche un message d'erreur à l'utilisateur
  static void showError({
    required BuildContext context,
    required String message,
    String? debugDetails,
  }) {
    showAlert(
      context: context,
      message: message,
      isError: true,
      debugDetails: debugDetails,
    );
  }
  
  /// Affiche un message de succès à l'utilisateur
  static void showSuccess({
    required BuildContext context,
    required String message,
    String? debugDetails,
  }) {
    showAlert(
      context: context,
      message: message,
      isError: false,
      debugDetails: debugDetails,
    );
  }
}