import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';

class TrailerCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String duration;
  final bool isDarkMode;
  final VoidCallback? onPlayTap;

  const TrailerCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.duration,
    required this.isDarkMode,
    this.onPlayTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container principal avec image et overlay
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackOverlay(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Stack(
                children: [
                  // Image de fond
                  Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Overlay noir avec dégradé
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.blackOverlay(0.3),
                          AppColors.blackOverlay(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Bouton play au centre
                  Center(
                    child: GestureDetector(
                      onTap: onPlayTap,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blackOverlay(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  // Texte "BANDE-ANNONCE" au centre
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Text(
                        'BANDE-ANNONCE',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppTypography.fontSizeLarge,
                          fontWeight: AppTypography.fontWeightBold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: AppColors.blackOverlay(0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Titre et durée
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.subtitle(
                  AppColors.getTextColor(isDarkMode),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              duration,
              style: AppTypography.body(
                AppColors.getTextSecondaryColor(isDarkMode),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
