import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/movies_grid.dart';
import '../widgets/common/genre_filter_bar.dart';
import '../models/movie_model.dart';
import '../data/sample_data.dart';
import '../services/movie_service.dart';
import 'movie_detail_screen.dart';
import '../config/server_config.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({Key? key}) : super(key: key);

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  String selectedGenre = 'Tout';
  bool _isLoading = true;
  List<MovieApiModel> _allMovies = [];
  List<String> _availableGenres = ['Tout'];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      print('📋 Chargement de tous les films...');

      // Tester la connectivité d'abord
      final isConnected = await MovieService.testConnection();

      if (!isConnected) {
        print('❌ Impossible de se connecter à l\'API');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Charger tous les films
      final movies = await MovieService.getAllMovies();

      if (movies.isNotEmpty) {
        // Extraire les genres uniques
        final allGenres = <String>{};
        for (var movie in movies) {
          allGenres.addAll(movie.genres);
        }

        setState(() {
          _allMovies = movies;
          // Trier les genres et ajouter "Tout" au début
          final sortedGenres = allGenres.toList()..sort();
          _availableGenres = ['Tout', ...sortedGenres];
          _isLoading = false;
        });

        print('✅ Films chargés: ${movies.length}');
        print('🎭 Genres disponibles: $_availableGenres');
      } else {
        print('⚠️ Aucun film récupéré de l\'API');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des films: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<MovieApiModel> get filteredMovies {
    if (selectedGenre == 'Tout') {
      return _allMovies;
    }
    return _allMovies
        .where(
          (movie) => movie.genres.any(
            (genre) =>
                genre.toLowerCase().contains(selectedGenre.toLowerCase()),
          ),
        )
        .toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun film disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(
                Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vérifiez la connexion au serveur',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(
                Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'IP: ${ServerConfig.apiBaseUrl}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadMovies();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
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
              genres: _availableGenres,
              selectedGenre: selectedGenre,
              onGenreSelected: (genre) {
                setState(() {
                  selectedGenre = genre;
                });
              },
            ),

            // Contenu principal
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Chargement des films...',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Récupération depuis l\'API',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : _allMovies.isEmpty
                  ? _buildEmptyState()
                  : MoviesGrid.api(
                      apiMovies: filteredMovies,
                      isDarkMode: isDarkMode,
                      countText: '${filteredMovies.length} films trouvés',
                      onApiMovieTap: (movie) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen.fromApiMovie(movie),
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
