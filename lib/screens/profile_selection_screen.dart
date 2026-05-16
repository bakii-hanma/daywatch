import 'package:flutter/material.dart';
import 'dart:ui';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/daywatch_logo.dart';
import '../widgets/common/animated_poster_background.dart';
import '../utils/alert_utils.dart';
import '../services/api_client.dart';
import '../services/user_storage_service.dart';
import 'home_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  String? _selectedProfile;
  bool _isLoading = false;
  bool _isLoadingProfiles = true;

  // Profils chargés depuis l'API
  List<Map<String, dynamic>> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfiles();
  }

  /// Charger les profils de l'utilisateur depuis l'API
  Future<void> _loadUserProfiles() async {
    try {
      setState(() => _isLoadingProfiles = true);

      // Récupérer les données utilisateur stockées
      final userData = await UserStorageService.getUserData();
      if (userData == null) {
        throw Exception('Aucune donnée utilisateur trouvée');
      }

      // Extraire l'ID utilisateur (adapter selon la structure de vos données)
      final userId =
          userData['id']?.toString() ??
          userData['user_id']?.toString() ??
          userData['userId']?.toString();

      if (userId == null) {
        throw Exception('ID utilisateur non trouvé dans les données stockées');
      }

      print('🔍 Chargement des profils pour l\'utilisateur: $userId');

      // Appeler l'API pour récupérer les profils
      final response = await ApiClient.getUserProfiles(userId: userId);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _profiles = response.data!;
          _isLoadingProfiles = false;
        });
        print('✅ ${_profiles.length} profil(s) chargé(s) avec succès');
      } else {
        // En cas d'erreur API, utiliser des profils par défaut
        print(
          '⚠️ Erreur API, utilisation des profils par défaut: ${response.error}',
        );
        _loadDefaultProfiles();
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des profils: $e');
      // En cas d'erreur, utiliser des profils par défaut
      _loadDefaultProfiles();
    }
  }

  /// Charger les profils par défaut en cas d'erreur API
  void _loadDefaultProfiles() {
    setState(() {
      _profiles = [
        {
          'id': 'user1',
          'name': 'Vous',
          'avatar':
              'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
          'isMain': true,
        },
        {
          'id': 'user2',
          'name': 'Aurora Sardes',
          'subtitle': 'Enfant',
          'avatar':
              'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
          'isMain': false,
        },
      ];
      _isLoadingProfiles = false;
    });
  }

  Future<void> _handleProfileSelection(String profileId) async {
    setState(() {
      _selectedProfile = profileId;
      _isLoading = true;
    });

    try {
      // Simuler une sélection de profil avec délai
      await Future.delayed(const Duration(milliseconds: 800));

      // Naviguer vers l'écran d'accueil
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      AlertUtils.showError(
        context: context,
        message: 'Erreur lors de la sélection du profil.',
        debugDetails: 'Erreur sélection profil $profileId: $e',
      );
    }
  }

  Future<void> _handleAddProfile() async {
    AlertUtils.showSuccess(
      context: context,
      message: 'Fonctionnalité d\'ajout de profil à venir !',
      debugDetails: 'Tentative d\'ajout d\'un nouveau profil',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(isDarkMode);
    final subtleTextColor = textColor.withOpacity(0.7);
    final overlayColors = AppColors.getAuthOverlayColors(isDarkMode);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Arrière-plan avec widget animé
          const Positioned.fill(child: AnimatedPosterBackground()),

          // Overlay avec dégradé
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: overlayColors,
                  stops: const [0.0, 0.15, 0.2, 0.3, 1.0],
                ),
              ),
            ),
          ),

          // Logo DAYWATCH
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: DaywatchLogo(
                  size: LogoSize.xlarge,
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
          ),

          // Contenu principal
          Positioned(
            left: 20,
            right: 20,
            bottom: 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre principal
                Text(
                  'Qui regarde ?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // Profils disponibles
                _isLoadingProfiles
                    ? _buildLoadingProfiles(textColor)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Profils existants
                          ..._profiles.map(
                            (profile) => _buildProfileCard(
                              profile: profile,
                              textColor: textColor,
                              subtleTextColor: subtleTextColor,
                              isSelected: _selectedProfile == profile['id'],
                            ),
                          ),

                          // Bouton Ajouter un profil
                          _buildAddProfileButton(textColor, subtleTextColor),
                        ],
                      ),

                const SizedBox(height: 60),
              ],
            ),
          ),

          // Indicateur de chargement
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required Map<String, dynamic> profile,
    required Color textColor,
    required Color subtleTextColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _handleProfileSelection(profile['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 3)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar circulaire
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.grey[300],
                  child: profile['avatar'] != null
                      ? Image.asset(
                          profile['avatar'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[400],
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        )
                      : Icon(Icons.person, size: 40, color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nom du profil
            Text(
              profile['name'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Sous-titre (avec espace réservé même si vide)
            const SizedBox(height: 4),
            SizedBox(
              height: 16, // Hauteur fixe pour le sous-titre
              child: profile['subtitle'] != null
                  ? Text(
                      profile['subtitle'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox.shrink(), // Widget vide mais la hauteur est maintenue
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProfileButton(Color textColor, Color subtleTextColor) {
    return GestureDetector(
      onTap: _handleAddProfile,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton circulaire avec icône +
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.6),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
            ),
            child: Icon(Icons.add, size: 40, color: textColor),
          ),
          const SizedBox(height: 12),

          // Texte "Ajouter"
          Text(
            'Ajouter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget de chargement pour les profils
  Widget _buildLoadingProfiles(Color textColor) {
    return SizedBox(
      height: 140, // Même hauteur qu'un profil complet
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            const SizedBox(height: 16),
            Text(
              'Chargement des profils...',
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
