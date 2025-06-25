import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../models/movie_model.dart';
import '../../screens/movie_detail_screen.dart';
import 'movie_card.dart';

class MoviesGrid extends StatelessWidget {
  final List<MovieModel> movies;
  final bool isDarkMode;
  final String countText;
  final Function(MovieModel)? onMovieTap;

  const MoviesGrid({
    Key? key,
    required this.movies,
    required this.isDarkMode,
    required this.countText,
    this.onMovieTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${movies.length}',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' films trouvés',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 150 / 350, // 150px width / 350px height
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return SizedBox(
                width: 150,
                height: 350,
                child: MovieCard(
                  imagePath: movie.imagePath,
                  title: movie.title,
                  genre: movie.genre,
                  duration: movie.duration,
                  releaseDate: movie.releaseDate,
                  rating: movie.rating,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    if (onMovieTap != null) {
                      onMovieTap!(movie);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(movie: movie),
                        ),
                      );
                    }
                  },
                  onFavoriteTap: () {
                    // Ajouter aux favoris
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
