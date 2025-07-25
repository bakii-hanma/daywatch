import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../design_system/spacing.dart';
import '../screens/home_screen.dart';

class DeviceSelectionScreen extends StatelessWidget {
  const DeviceSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(isDarkMode);
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);

    // Liste des appareils disponibles
    final List<Map<String, dynamic>> devices = [
      {
        'name': 'Mobile',
        'icon': Icons.smartphone,
        'description': 'Profitez de DayWatch sur votre smartphone',
        'imagePath': 'assets/devices/mobile.png',
      },
      {
        'name': 'Ordinateur',
        'icon': Icons.computer,
        'description': 'Regardez sur un écran plus grand',
        'imagePath': 'assets/devices/computer.png',
      },
      {
        'name': 'TV',
        'icon': Icons.tv,
        'description': 'Expérience cinéma à la maison',
        'imagePath': 'assets/devices/tv.png',
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Fond avec dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  backgroundColor,
                ],
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec barre d'état simulée
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo ou titre
                      Text(
                        'DAYWATCH',
                        style: AppTypography.title(AppColors.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Titre de la page
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'Choisissez votre appareil',
                    style: AppTypography.header(textColor),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Sous-titre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'Sélectionnez l\'appareil sur lequel vous souhaitez utiliser DayWatch',
                    style: AppTypography.body(
                      AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Liste des appareils
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return _buildDeviceCard(
                        context,
                        device['name'],
                        device['icon'],
                        device['description'],
                        device['imagePath'],
                        isDarkMode,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    String name,
    IconData icon,
    String description,
    String imagePath,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigation vers l'écran d'accueil ou l'écran spécifique à l'appareil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.getWidgetBackgroundColor(isDarkMode),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOverlay(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image de l'appareil
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusMedium),
                topRight: Radius.circular(AppSpacing.radiusMedium),
              ),
              child: Container(
                height: 180,
                width: double.infinity,
                color: AppColors.primary.withOpacity(0.05),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Fallback si l'image n'existe pas
                    Icon(
                      icon,
                      size: 80,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    // Tentative de charger l'image
                    Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) {
                        // L'image n'a pas pu être chargée, l'icône est déjà affichée
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Informations sur l'appareil
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        name,
                        style: AppTypography.subtitle(
                          AppColors.getTextColor(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    description,
                    style: AppTypography.body(
                      AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Bouton de sélection
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: Center(
                      child: Text(
                        'Sélectionner',
                        style: AppTypography.bodySemiBold(AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}