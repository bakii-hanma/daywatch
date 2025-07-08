import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';
import '../../models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String genre;
  final String duration;
  final String releaseDate;
  final double rating;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isNetworkImage;

  const MovieCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.genre,
    required this.duration,
    required this.releaseDate,
    required this.rating,
    required this.isDarkMode,
    this.onTap,
    this.onFavoriteTap,
    this.isNetworkImage = false,
  }) : super(key: key);

  // Constructeur pour les films de l'API
  factory MovieCard.fromApiModel({
    required MovieApiModel movie,
    required bool isDarkMode,
    VoidCallback? onTap,
    VoidCallback? onFavoriteTap,
  }) {
    return MovieCard(
      imagePath: movie.images.poster ?? '',
      title: movie.title,
      genre: movie.genres.isNotEmpty ? movie.genres.first : 'Non défini',
      duration: '${movie.runtime}min',
      releaseDate: movie.year.toString(),
      rating: movie.rating,
      isDarkMode: isDarkMode,
      onTap: onTap,
      onFavoriteTap: onFavoriteTap,
      isNetworkImage: true,
    );
  }

  // Constructeur pour les anciens modèles
  factory MovieCard.fromModel({
    required MovieModel movie,
    required bool isDarkMode,
    VoidCallback? onTap,
    VoidCallback? onFavoriteTap,
  }) {
    return MovieCard(
      imagePath: movie.imagePath,
      title: movie.title,
      genre: movie.genre,
      duration: movie.duration,
      releaseDate: movie.releaseDate,
      rating: movie.rating,
      isDarkMode: isDarkMode,
      onTap: onTap,
      onFavoriteTap: onFavoriteTap,
      isNetworkImage: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 250,
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
            Container(
              width: 150,
              height: 225,
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
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: const Icon(
                          Icons.bookmark,
                          color: AppColors.primary,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Informations du film
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
                  // Durée et date
                  Row(
                    children: [
                      _buildInfoBadge(duration, isDarkMode),
                      const SizedBox(width: 6),
                      _buildInfoBadge(releaseDate, isDarkMode),
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
        child: const Icon(Icons.movie, color: AppColors.white, size: 50),
      );
    }

    print('🖼️ Tentative de chargement image réseau: "$imagePath"');
    return Image.network(
      imagePath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('✅ Image chargée avec succès: "$imagePath"');
          return child;
        }
        print('⏳ Chargement en cours: "$imagePath"');
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
        print('❌ Erreur chargement image: "$imagePath"');
        print('   Error: $error');
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
