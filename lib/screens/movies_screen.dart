import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/movies_grid.dart';
import '../widgets/common/genre_filter_bar.dart';
import '../models/movie_model.dart';
import '../data/sample_data.dart';
import 'movie_detail_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({Key? key}) : super(key: key);

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  String selectedGenre = 'Tout';

  final List<String> genres = [
    'Tout',
    'Action',
    'Aventure',
    'Animation',
    'Comédie',
    'Drame',
    'Horreur',
    'Romance',
  ];

  List<MovieModel> get filteredMovies {
    if (selectedGenre == 'Tout') {
      return SampleData.popularMovies;
    }
    return SampleData.popularMovies
        .where(
          (movie) =>
              movie.genre.toLowerCase().contains(selectedGenre.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getSearchBackgroundColor(isDarkMode),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec bouton retour et titre
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.getTextColor(isDarkMode),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Films',
                    style: TextStyle(
                      color: AppColors.getTextColor(isDarkMode),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Filtres par genre
            GenreFilterBar(
              genres: genres,
              selectedGenre: selectedGenre,
              onGenreSelected: (genre) {
                setState(() {
                  selectedGenre = genre;
                });
              },
            ),

            // Grille des films
            Expanded(
              child: MoviesGrid(
                movies: filteredMovies,
                isDarkMode: isDarkMode,
                countText: '${filteredMovies.length} films trouvés',
                onMovieTap: (movie) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(movie: movie),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
