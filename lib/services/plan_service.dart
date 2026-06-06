import '../models/plan_model.dart';
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
}
