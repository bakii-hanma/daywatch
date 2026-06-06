import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../widgets/common/movie_card.dart';
import '../../screens/movies_screen.dart';
import '../../screens/movie_detail_screen.dart';

class PopularMoviesSection extends StatelessWidget {
  final List<MovieApiModel> popularMovies;
  final bool isDarkMode;
  final Set<int> favoriteMovieIds;
  final Function(MovieApiModel movie)? onFavoriteTap;

  const PopularMoviesSection({
    super.key,
    required this.popularMovies,
    required this.isDarkMode,
    required this.favoriteMovieIds,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (popularMovies.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_outlined,
                size: 48,
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun film populaire disponible',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vérifiez la connexion au serveur',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Films populaires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoviesScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Voir +',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Liste horizontale des films
        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: popularMovies.length,
            itemBuilder: (context, index) {
              final movie = popularMovies[index];
              final isFav = favoriteMovieIds.contains(movie.id);
              return Container(
                width: AppSpacing.cardWidthLarge,
                margin: EdgeInsets.only(
                  right: index < popularMovies.length - 1 ? AppSpacing.md : 0,
                ),
                child: MovieCard.fromApiModel(
                  movie: movie,
                  isDarkMode: isDarkMode,
                  isFavorite: isFav,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailScreen.fromApiMovie(movie),
                      ),
                    );
                  },
                  onFavoriteTap: onFavoriteTap != null ? () => onFavoriteTap!(movie) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
