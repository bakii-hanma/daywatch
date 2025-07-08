import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';

class BoxOfficeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String earnings;
  final String duration;
  final String releaseDate;
  final double rating;
  final int rank;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const BoxOfficeCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.earnings,
    required this.duration,
    required this.releaseDate,
    required this.rating,
    required this.rank,
    required this.isDarkMode,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge de rang
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: Stack(
                  children: [
                    // Utiliser Image.network pour les vraies images de l'API
                    Image.network(
                      imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.greyOverlay(0.3),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.greyOverlay(0.3),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.movie,
                                  size: 40,
                                  color: AppColors.getTextSecondaryColor(
                                    isDarkMode,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image non disponible',
                                  style: AppTypography.small(
                                    AppColors.getTextSecondaryColor(isDarkMode),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Badge de rang en haut à gauche
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            rank.toString(),
                            style: AppTypography.bodySemiBold(AppColors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Informations du film
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.getWidgetBackgroundColor(isDarkMode),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusMedium),
                    bottomRight: Radius.circular(AppSpacing.radiusMedium),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodySemiBold(
                        AppColors.getTextColor(isDarkMode),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      earnings,
                      style: AppTypography.subtitle(AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Badges durée, date et note
                    Row(
                      children: [
                        _buildInfoBadge(duration, isDarkMode),
                        const SizedBox(width: 6),
                        _buildInfoBadge(releaseDate, isDarkMode),
                        const SizedBox(width: 6),
                        _buildRatingBadge(rating, isDarkMode),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.greyOverlay(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.small(AppColors.getTextSecondaryColor(isDarkMode)),
      ),
    );
  }

  Widget _buildRatingBadge(double rating, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.accent, size: 12),
          const SizedBox(width: 2),
          Text(rating.toString(), style: AppTypography.small(AppColors.black)),
        ],
      ),
    );
  }
}
