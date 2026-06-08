import '../models/plan_model.dart';
import '../models/subscription_status_model.dart';
import 'api_client.dart';

class PlanService {
  /// Récupérer les plans d'abonnement disponibles
  static Future<List<PlanApiModel>> getPlans() async {
    try {
      final response = await ApiClient.get<dynamic>('/api/plans');
      if (response.isSuccess && response.data != null) {
        List<dynamic> plansData = [];
        if (response.data is List) {
          plansData = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          plansData = responseMap['data'] as List<dynamic>? ?? [];
        }

        return plansData
            .map((json) => PlanApiModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des plans d\'abonnement: $e');
    }
    return [];
  }

  /// Récupérer le statut d'abonnement de l'utilisateur
  static Future<UserSubscriptionStatusModel?> getSubscriptionStatus() async {
    try {
      final response = await ApiClient.get<Map<String, dynamic>>(
        '/api/users/subscription-status',
      );
      if (response.isSuccess && response.data != null) {
        return UserSubscriptionStatusModel.fromJson(response.data!);
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération du statut d\'abonnement: $e');
    }
    return null;
  }

  /// Initialiser un paiement
  static Future<ApiResponse<Map<String, dynamic>>> initPayment({
    required int planId,
    required int months,
    required String paymentMethod,
    String? phoneNumber,
    String? paypalEmail,
  }) async {
    try {
      final body = {
        'planId': planId,
        'months': months,
        'paymentMethod': paymentMethod,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (paypalEmail != null) 'paypalEmail': paypalEmail,
      };

      return await ApiClient.post<Map<String, dynamic>>(
        '/api/payments/init',
        body: body,
      );
    } catch (e) {
      return ApiResponse.error('Erreur d\'initialisation du paiement: $e');
    }
  }

  /// Simuler un paiement d'abonnement
  static Future<ApiResponse<Map<String, dynamic>>> simulatePlan({
    required int planId,
    required int months,
  }) async {
    try {
      final body = {
        'planId': planId,
        'months': months,
      };

      return await ApiClient.post<Map<String, dynamic>>(
        '/api/payments/simulate-plan',
        body: body,
      );
    } catch (e) {
      return ApiResponse.error('Erreur de simulation du paiement: $e');
    }
  }
}
