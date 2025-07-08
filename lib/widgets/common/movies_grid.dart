import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../models/movie_model.dart';
import '../../screens/movie_detail_screen.dart';
import 'movie_card.dart';

class MoviesGrid extends StatelessWidget {
  final List<MovieModel>? movies;
  final List<MovieApiModel>? apiMovies;
  final bool isDarkMode;
  final String countText;
  final Function(MovieModel)? onMovieTap;
  final Function(MovieApiModel)? onApiMovieTap;

  const MoviesGrid({
    Key? key,
    this.movies,
    this.apiMovies,
    required this.isDarkMode,
    required this.countText,
    this.onMovieTap,
    this.onApiMovieTap,
  }) : assert(
         movies != null || apiMovies != null,
         'Either movies or apiMovies must be provided',
       ),
       super(key: key);

  // Constructor pour les films classiques
  const MoviesGrid.classic({
    Key? key,
    required List<MovieModel> movies,
    required bool isDarkMode,
    required String countText,
    Function(MovieModel)? onMovieTap,
  }) : this(
         key: key,
         movies: movies,
         apiMovies: null,
         isDarkMode: isDarkMode,
         countText: countText,
         onMovieTap: onMovieTap,
         onApiMovieTap: null,
       );

  // Constructor pour les films de l'API
  const MoviesGrid.api({
    Key? key,
    required List<MovieApiModel> apiMovies,
    required bool isDarkMode,
    required String countText,
    Function(MovieApiModel)? onApiMovieTap,
  }) : this(
         key: key,
         movies: null,
         apiMovies: apiMovies,
         isDarkMode: isDarkMode,
         countText: countText,
         onMovieTap: null,
         onApiMovieTap: onApiMovieTap,
       );

  // Getters pour unifier l'accès aux données
  List<dynamic> get _currentMovies => movies ?? apiMovies ?? [];
  int get _moviesCount => movies?.length ?? apiMovies?.length ?? 0;
  bool get _isApiMode => apiMovies != null;

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
                  text: '$_moviesCount',
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
            itemCount: _moviesCount,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 150,
                height: 350,
                child: _isApiMode
                    ? _buildApiMovieCard(context, index)
                    : _buildClassicMovieCard(context, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApiMovieCard(BuildContext context, int index) {
    final movie = apiMovies![index];
    return MovieCard.fromApiModel(
      movie: movie,
      isDarkMode: isDarkMode,
      onTap: () {
        if (onApiMovieTap != null) {
          onApiMovieTap!(movie);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen.fromApiMovie(movie),
            ),
          );
        }
      },
      onFavoriteTap: () {
        // Ajouter aux favoris
        print('Ajouté aux favoris: ${movie.title}');
      },
    );
  }

  Widget _buildClassicMovieCard(BuildContext context, int index) {
    final movie = movies![index];
    return MovieCard(
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
              builder: (context) => MovieDetailScreen.fromMovie(movie),
            ),
          );
        }
      },
      onFavoriteTap: () {
        // Ajouter aux favoris
      },
    );
  }
}
