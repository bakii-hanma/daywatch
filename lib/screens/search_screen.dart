import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/common/search_header.dart';
import '../widgets/common/genre_grid.dart';
import '../widgets/common/horizontal_section.dart';
import '../widgets/common/movie_card.dart';
import '../widgets/common/actor_card.dart';
import '../models/movie_model.dart';
import '../data/sample_data.dart';
import 'genres_screen.dart';
import 'movies_screen.dart';
import 'series_screen.dart';
import 'series_detail_screen.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final Function(String)? onSearchActivated;

  const SearchScreen({Key? key, this.onSearchActivated}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Données des genres avec images
  final List<GenreItem> _genres = [
    GenreItem(
      name: 'Action',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
    ),
    GenreItem(
      name: 'Aventure',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
    ),
    GenreItem(
      name: 'Animation',
      imagePath: 'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
    ),
    GenreItem(
      name: 'Comédie',
      imagePath: 'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getSearchBackgroundColor(isDarkMode),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: SearchHeader(
                  searchController: _searchController,
                  isDarkMode: isDarkMode,
                  onSearchActivated: widget.onSearchActivated,
                  onSearchChanged: () {
                    // Logique de recherche
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GenreGrid(
                  genres: _genres,
                  isDarkMode: isDarkMode,
                  title: 'Genres',
                  onSeeAllTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenresScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Section Acteurs
              HorizontalSection<ActorModel>(
                title: 'Acteurs',
                items: SampleData.actors,
                itemBuilder: (actor, index) => ActorCard(
                  imagePath: actor.imagePath,
                  name: actor.name,
                  isDarkMode: isDarkMode,
                ),
                itemWidth: 130,
                sectionHeight: 200,
                isDarkMode: isDarkMode,
                onSeeMoreTap: () {
                  // Navigation vers tous les acteurs
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Section Derniers films
              HorizontalSection<MovieModel>(
                title: 'Derniers films',
                items: SampleData.popularMovies,
                itemWidth: AppSpacing.cardWidthLarge,
                sectionHeight: AppSpacing.sectionHeightXLarge,
                isDarkMode: isDarkMode,
                onSeeMoreTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoviesScreen(),
                    ),
                  );
                },
                itemBuilder: (movie, index) {
                  return MovieCard(
                    imagePath: movie.imagePath,
                    title: movie.title,
                    genre: movie.genre,
                    duration: movie.duration,
                    releaseDate: movie.releaseDate,
                    rating: movie.rating,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(movie: movie),
                        ),
                      );
                    },
                    onFavoriteTap: () {
                      // Ajouter aux favoris
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),

              // Section Dernières séries
              HorizontalSection<SeriesModel>(
                title: 'Dernières séries',
                items: SampleData.popularSeries,
                itemWidth: AppSpacing.cardWidthLarge,
                sectionHeight: AppSpacing.sectionHeightXLarge,
                isDarkMode: isDarkMode,
                onSeeMoreTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeriesScreen(),
                    ),
                  );
                },
                itemBuilder: (series, index) {
                  return MovieCard(
                    imagePath: series.imagePath,
                    title: series.title,
                    genre: series.genre,
                    duration: series.seasons,
                    releaseDate: series.years,
                    rating: series.rating,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SeriesDetailScreen(series: series),
                        ),
                      );
                    },
                    onFavoriteTap: () {
                      // Logique favoris
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
