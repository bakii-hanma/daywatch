import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';
import '../../models/series_model.dart';
import '../../models/movie_model.dart';
import '../../config/server_config.dart';

class SeriesCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String genre;
  final String seasons;
  final String year;
  final double rating;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isNetworkImage;
  final bool isFavorite;

  const SeriesCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.genre,
    required this.seasons,
    required this.year,
    required this.rating,
    required this.isDarkMode,
    this.onTap,
    this.onFavoriteTap,
    this.isNetworkImage = false,
    this.isFavorite = false,
  });

  // Constructeur pour les séries de l'API
  factory SeriesCard.fromApiModel({
    required SeriesApiModel series,
    required bool isDarkMode,
    bool isFavorite = false,
    VoidCallback? onTap,
    VoidCallback? onFavoriteTap,
  }) {
    return SeriesCard(
      imagePath: series.poster,
      title: series.title,
      genre: series.genres.isNotEmpty ? series.genres.first : 'Série',
      seasons: '${series.seasonInfo.totalSeasons} saisons',
      year: series.year.toString(),
      rating: series.rating,
      isDarkMode: isDarkMode,
      onTap: onTap,
      onFavoriteTap: onFavoriteTap,
      isNetworkImage: true,
      isFavorite: isFavorite,
    );
  }

  // Constructeur pour les séries classiques (données d'exemple)
  factory SeriesCard.fromModel({
    required SeriesModel series,
    required bool isDarkMode,
    bool isFavorite = false,
    VoidCallback? onTap,
    VoidCallback? onFavoriteTap,
  }) {
    return SeriesCard(
      imagePath: series.imagePath,
      title: series.title,
      genre: series.genre,
      seasons: series.seasons,
      year: series.years,
      rating: series.rating,
      isDarkMode: isDarkMode,
      onTap: onTap,
      onFavoriteTap: onFavoriteTap,
      isNetworkImage: false,
      isFavorite: isFavorite,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 280,
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
            // Image avec note et icône favoris
            SizedBox(
              width: 150,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: Stack(
                  children: [
                    _buildImage(),
                    // Note en haut à gauche
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSmall,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.accent,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: AppTypography.small(AppColors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Icône favoris en haut à droite
                    if (onFavoriteTap != null)
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: GestureDetector(
                          onTap: onFavoriteTap,
                          child: Icon(
                            isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            color: isFavorite ? AppColors.primary : Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Informations de la série
            Container(
              width: 150,
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
                    genre,
                    style: AppTypography.caption(
                      AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Saisons et année
                  Row(
                    children: [
                      _buildInfoBadge(seasons, isDarkMode),
                      const SizedBox(width: 6),
                      _buildInfoBadge(year, isDarkMode),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.textSecondaryLight,
        child: const Icon(Icons.live_tv, color: AppColors.white, size: 50),
      );
    }

    String resolvedImagePath = imagePath;
    if (imagePath.startsWith('/')) {
      resolvedImagePath = '${ServerConfig.apiBaseUrl}$imagePath';
    }

    final isNetwork = isNetworkImage ||
        resolvedImagePath.startsWith('http://') ||
        resolvedImagePath.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        resolvedImagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.textSecondaryLight.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.textSecondaryLight,
            child: const Icon(
              Icons.broken_image,
              color: AppColors.white,
              size: 50,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.textSecondaryLight,
            child: const Icon(
              Icons.broken_image,
              color: AppColors.white,
              size: 50,
            ),
          );
        },
      );
    }
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
}
