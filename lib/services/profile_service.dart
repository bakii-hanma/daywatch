import '../models/profile_model.dart';
import 'api_client.dart';

class ProfileService {
  // 1. Créer un profil (POST /api/profiles)
  static Future<ApiResponse<ProfileApiModel>> createProfile({
    required String profileName,
    String? profileAvatarUrl,
    String profileType = 'adult',
    Map<String, dynamic>? preferences,
    bool isDefault = false,
  }) async {
    try {
      final body = {
        'profileName': profileName,
        if (profileAvatarUrl != null) 'profileAvatarUrl': profileAvatarUrl,
        'profileType': profileType,
        if (preferences != null) 'preferences': preferences,
        'isDefault': isDefault,
      };
      final response = await ApiClient.post<ProfileApiModel>(
        '/api/profiles',
        body: body,
        fromJson: (json) => ProfileApiModel.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur lors de la création du profil: $e');
    }
  }

  // 2. Supprimer un profil (DELETE /api/profiles/:profileId)
  static Future<ApiResponse<dynamic>> deleteProfile(int profileId) async {
    try {
      final response = await ApiClient.delete<dynamic>(
        '/api/profiles/$profileId',
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur lors de la suppression du profil: $e');
    }
  }

  // 3. Détail d'un profil (GET /api/profiles/:profileId)
  static Future<ApiResponse<ProfileApiModel>> getProfileById(int profileId) async {
    try {
      final response = await ApiClient.get<ProfileApiModel>(
        '/api/profiles/$profileId',
        fromJson: (json) => ProfileApiModel.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération du profil: $e');
    }
  }

  // 4. Mettre à jour un profil (PUT /api/profiles/:profileId)
  static Future<ApiResponse<ProfileApiModel>> updateProfile(
    int profileId, {
    required String profileName,
    String? profileAvatarUrl,
    String? profileType,
    Map<String, dynamic>? preferences,
    bool? isDefault,
  }) async {
    try {
      final body = {
        'profileName': profileName,
        if (profileAvatarUrl != null) 'profileAvatarUrl': profileAvatarUrl,
        if (profileType != null) 'profileType': profileType,
        if (preferences != null) 'preferences': preferences,
        if (isDefault != null) 'isDefault': isDefault,
      };
      final response = await ApiClient.put<ProfileApiModel>(
        '/api/profiles/$profileId',
        body: body,
        fromJson: (json) => ProfileApiModel.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // 5. Définir un profil par défaut (PATCH /api/profiles/:profileId/default)
  static Future<ApiResponse<ProfileApiModel>> setDefaultProfile(int profileId) async {
    try {
      final response = await ApiClient.patch<ProfileApiModel>(
        '/api/profiles/$profileId/default',
        fromJson: (json) => ProfileApiModel.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur lors de la définition du profil par défaut: $e');
    }
  }

  // 6. Supprimer le PIN (DELETE /api/profiles/:profileId/pin)
  static Future<ApiResponse<dynamic>> clearPin(int profileId) async {
    try {
      final response = await ApiClient.delete<dynamic>(
        '/api/profiles/$profileId/pin',
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur lors de la suppression du PIN: $e');
    }
  }

  // 7. Activer/changer le PIN (PUT /api/profiles/:profileId/pin)
  static Future<ApiResponse<dynamic>> setPin(int profileId, String pin) async {
    try {
      final body = {'pin': pin};
      final response = await ApiClient.put<dynamic>(
        '/api/profiles/$profileId/pin',
        body: body,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur lors de l\'activation du PIN: $e');
    }
  }

  // 8. Vérifier le PIN (POST /api/profiles/:profileId/verify-pin)
  static Future<ApiResponse<dynamic>> verifyPin(int profileId, String pin) async {
    try {
      final body = {'pin': pin};
      final response = await ApiClient.post<dynamic>(
        '/api/profiles/$profileId/verify-pin',
        body: body,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur lors de la vérification du PIN: $e');
    }
  }

  // 9. Profil actif courant (GET /api/profiles/me)
  static Future<ApiResponse<ProfileApiModel>> getCurrentProfile() async {
    try {
      final response = await ApiClient.get<ProfileApiModel>(
        '/api/profiles/me',
        fromJson: (json) => ProfileApiModel.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération du profil courant: $e');
    }
  }

  // 10. Tous les profils du user courant (GET /api/profiles/user)
  static Future<ApiResponse<List<ProfileApiModel>>> getUserProfiles() async {
    try {
      final response = await ApiClient.get<dynamic>(
        '/api/profiles/user',
      );

      if (response.isSuccess && response.data != null) {
        List<dynamic> profilesData = [];
        if (response.data is List) {
          profilesData = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          profilesData = responseMap['data'] as List<dynamic>? ?? [];
        }

        final profiles = profilesData
            .map((json) => ProfileApiModel.fromJson(json))
            .toList();
        return ApiResponse.success(profiles);
      }
      return ApiResponse.error(response.error ?? 'Erreur inconnue');
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des profils: $e');
    }
  }

  // 11. Profils d'un user spécifique (GET /api/profiles/user/:userId)
  static Future<ApiResponse<List<ProfileApiModel>>> getUserProfilesById(String userId) async {
    try {
      final response = await ApiClient.get<dynamic>(
        '/api/profiles/user/$userId',
      );

      if (response.isSuccess && response.data != null) {
        List<dynamic> profilesData = [];
        if (response.data is List) {
          profilesData = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          profilesData = responseMap['data'] as List<dynamic>? ?? [];
        }

        final profiles = profilesData
            .map((json) => ProfileApiModel.fromJson(json))
            .toList();
        return ApiResponse.success(profiles);
      }
      return ApiResponse.error(response.error ?? 'Erreur inconnue');
    } catch (e) {
      return ApiResponse.error('Erreur lors de la récupération des profils de l\'utilisateur: $e');
    }
  }
}
