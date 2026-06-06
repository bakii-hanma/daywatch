import 'package:flutter/material.dart';
import 'dart:convert';
import '../widgets/common/custom_toast.dart';

/// Utilitaire pour gérer les alertes et les messages de débogage
class AlertUtils {
  /// Nettoie un message potentiellement brut (JSON ou HTTP) provenant de l'API
  static String _cleanRawMessage(String rawMessage) {
    // Si le message contient un JSON
    if (rawMessage.contains('{"') && rawMessage.contains('}')) {
      try {
        final startIndex = rawMessage.indexOf('{');
        final endIndex = rawMessage.lastIndexOf('}') + 1;
        final jsonString = rawMessage.substring(startIndex, endIndex);
        
        final decoded = json.decode(jsonString);
        if (decoded is Map && decoded.containsKey('message')) {
          return decoded['message'].toString();
        }
      } catch (_) {
        // Ignorer l'erreur et tenter le nettoyage regex
      }
    }
    
    // Si le message est préfixé par "Erreur HTTP XXX: " ou "Erreur inscription: " etc.
    final httpErrorRegex = RegExp(r'Erreur HTTP \d+:\s*(.*)', caseSensitive: false);
    final match = httpErrorRegex.firstMatch(rawMessage);
    if (match != null && match.groupCount >= 1) {
      final body = match.group(1)!;
      if (body.isNotEmpty) return body;
    }

    return rawMessage;
  }

  /// Affiche un message à l'utilisateur via le CustomToast
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
    // Nettoyer les réponses brutes de l'API pour ne garder que le message utile
    final cleanMessage = _cleanRawMessage(message);

    // Afficher le message utilisateur via notre CustomToast
    CustomToast.show(
      context: context,
      message: cleanMessage,
      type: isError ? ToastType.error : ToastType.success,
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