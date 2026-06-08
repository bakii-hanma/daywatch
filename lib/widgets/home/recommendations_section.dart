import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../screens/movie_detail_screen.dart';

class RecommendationsSection extends StatelessWidget {
  final List<MovieApiModel> recommendations;
  final bool isDarkMode;
  final Set<String> favoriteMovieIds;
  final Function(MovieApiModel movie)? onFavoriteTap;

  static String _formatDuration(int runtime) {
    if (runtime <= 0) return 'Non défini';
    if (runtime < 60) return '${runtime}min';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return minutes > 0 ? '${hours}h${minutes}min' : '${hours}h';
  }

  const RecommendationsSection({
    super.key,
    required this.recommendations,
    required this.isDarkMode,
    required this.favoriteMovieIds,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final textColor = AppColors.getTextColor(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommandé pour vous',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Text(
                'Voir +',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final movie = recommendations[index];
              return Container(
                width: 350,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                child: _buildRecommendationCard(context, movie, textColor),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    MovieApiModel movie,
    Color textColor,
  ) {
    final isFav = favoriteMovieIds.contains(movie.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen.fromApiMovie(movie),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image du côté gauche
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: movie.images.poster != null && movie.images.poster!.isNotEmpty
                  ? Image.network(
                      movie.images.poster!,
                      width: 100,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 180,
                          color: AppColors.textSecondaryLight,
                          child: const Icon(
                            Icons.movie,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 100,
                      height: 180,
                      color: AppColors.textSecondaryLight,
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ),
            // Informations du côté droit
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _formatDuration(movie.runtime),
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              movie.year.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.genres.isNotEmpty
                              ? movie.genres.join(' • ')
                              : 'Film',
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Boutons d'action
                    Row(
                      children: [
                        _buildActionButton(Icons.share, 'Partager', textColor),
                        const SizedBox(width: 24),
                        _buildActionButton(
                          isFav ? Icons.bookmark : Icons.bookmark_border,
                          'Sauvegarder',
                          textColor,
                          color: isFav ? Colors.red : null,
                          onTap: onFavoriteTap != null ? () => onFavoriteTap!(movie) : null,
                        ),
                        const SizedBox(width: 24),
                        _buildActionButton(
                          Icons.download,
                          'Télécharger',
                          textColor,
                        ),
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

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color textColor, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, size: 20, color: color ?? textColor.withOpacity(0.7)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}
