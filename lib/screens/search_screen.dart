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
import '../models/series_model.dart';
import '../data/sample_data.dart';
import '../services/movie_service.dart';
import '../services/series_service.dart';
import '../services/actor_service.dart';
import '../config/server_config.dart';
import 'genres_screen.dart';
import 'movies_screen.dart';
import 'series_screen.dart';
import 'series_detail_screen.dart';
import 'movie_detail_screen.dart';
import 'actor_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final Function(String)? onSearchActivated;

  const SearchScreen({Key? key, this.onSearchActivated}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // États pour les films de l'API
  List<MovieApiModel> _recentMovies = [];
  List<MovieApiModel> _popularMovies = [];
  bool _isLoadingRecentMovies = true;
  bool _isLoadingPopularMovies = true;

  // États pour les séries de l'API
  List<SeriesApiModel> _latestSeries = [];
  List<SeriesApiModel> _popularSeries = [];
  bool _isLoadingLatestSeries = true;
  bool _isLoadingPopularSeries = true;

  // États pour les acteurs de l'API
  List<ActorApiModel> _actors = [];
  bool _isLoadingActors = true;

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
  void initState() {
    super.initState();
    _loadMovies();
    _loadSeries();
    _loadActors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Méthode pour charger les films depuis l'API
  Future<void> _loadMovies() async {
    try {
      print('🔍 Chargement des films pour la page de recherche...');

      // Test de connectivité d'abord
      final isConnected = await MovieService.testConnection();

      if (!isConnected) {
        print('❌ Impossible de se connecter à l\'API');
        setState(() {
          _isLoadingRecentMovies = false;
          _isLoadingPopularMovies = false;
        });
        return;
      }

      print('✅ Connectivité API confirmée');

      // Charger les films récents et populaires en parallèle
      final recentMoviesFuture = MovieService.getRecentMovies(limit: 10);
      final popularMoviesFuture = MovieService.getPopularMovies(limit: 10);

      final recentMovies = await recentMoviesFuture;
      final popularMovies = await popularMoviesFuture;

      setState(() {
        _recentMovies = recentMovies;
        _popularMovies = popularMovies;
        _isLoadingRecentMovies = false;
        _isLoadingPopularMovies = false;
      });

      print('📊 Films chargés pour la recherche:');
      print('   - Films récents: ${_recentMovies.length}');
      print('   - Films populaires: ${_popularMovies.length}');
    } catch (e) {
      print('❌ Erreur lors du chargement des films: $e');
      setState(() {
        _isLoadingRecentMovies = false;
        _isLoadingPopularMovies = false;
      });
    }
  }

  // Méthode pour charger les séries depuis l'API
  Future<void> _loadSeries() async {
    try {
      print('🔍 Chargement des séries pour la page de recherche...');

      // Test de connectivité d'abord
      final isConnected = await SeriesService.testConnection();

      if (!isConnected) {
        print('❌ Impossible de se connecter à l\'API Sonarr');
        setState(() {
          _isLoadingLatestSeries = false;
          _isLoadingPopularSeries = false;
        });
        return;
      }

      print('✅ Connectivité API Sonarr confirmée');

      // Charger les séries récentes et populaires en parallèle
      final recentSeriesFuture = SeriesService.getRecentSeries(limit: 10);
      final popularSeriesFuture = SeriesService.getPopularSeries(limit: 10);

      final recentSeries = await recentSeriesFuture;
      final popularSeries = await popularSeriesFuture;

      setState(() {
        _latestSeries = recentSeries;
        _popularSeries = popularSeries;
        _isLoadingLatestSeries = false;
        _isLoadingPopularSeries = false;
      });

      print('📊 Séries chargées pour la recherche:');
      print('   - Dernières séries: ${_latestSeries.length}');
      print('   - Séries populaires: ${_popularSeries.length}');
    } catch (e) {
      print('❌ Erreur lors du chargement des séries: $e');
      setState(() {
        _isLoadingLatestSeries = false;
        _isLoadingPopularSeries = false;
      });
    }
  }

  // Méthode pour charger les acteurs depuis l'API
  Future<void> _loadActors() async {
    try {
      print('🎭 === DÉBUT CHARGEMENT ACTEURS POUR RECHERCHE ===');
      print('🔗 URL API: ${ServerConfig.apiBaseUrl}/api/actors');

      final response = await ActorService.getActors(limit: 10);

      if (response.success && response.data.isNotEmpty) {
        setState(() {
          _actors = response.data;
          _isLoadingActors = false;
        });

        print(
          '✅ Acteurs chargés avec succès pour la recherche: ${_actors.length}',
        );

        // Afficher les premiers acteurs pour debug
        print('🎭 Acteurs récupérés:');
        for (var actor in _actors.take(3)) {
          print('   - ${actor.name} (${actor.stats.totalContent} contenus)');
        }
        if (_actors.length > 3) {
          print('   ... et ${_actors.length - 3} autres');
        }
      } else {
        print(
          '⚠️ Aucun acteur trouvé dans l\'API - utilisation des données statiques',
        );
        setState(() {
          _isLoadingActors = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des acteurs: $e');
      print('🔄 Utilisation des données statiques en fallback');
      setState(() {
        _isLoadingActors = false;
      });
    }
    print('🎭 === FIN CHARGEMENT ACTEURS POUR RECHERCHE ===');
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

              // Section Acteurs (API avec fallback)
              _isLoadingActors
                  ? Container(
                      height: 200,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                    )
                  : _actors.isEmpty
                  ? HorizontalSection<ActorModel>(
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
                    )
                  : HorizontalSection<ActorApiModel>(
                      title: 'Acteurs',
                      items: _actors,
                      itemBuilder: (actor, index) => ActorCard(
                        imagePath: actor.profilePath.isNotEmpty
                            ? actor.profilePath
                            : 'https://via.placeholder.com/500x750/4A5568/FFFFFF?text=${Uri.encodeComponent(actor.name)}',
                        name: actor.name,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          print('🎭 Navigation vers acteur: ${actor.name}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActorDetailScreen(
                                actorId: actor.id,
                                actorName: actor.name,
                              ),
                            ),
                          );
                        },
                      ),
                      itemWidth: 130,
                      sectionHeight: 200,
                      isDarkMode: isDarkMode,
                      onSeeMoreTap: () {
                        // Navigation vers tous les acteurs
                      },
                    ),

              const SizedBox(height: AppSpacing.xl),

              // Section Derniers films (API)
              _isLoadingRecentMovies
                  ? Container(
                      height: AppSpacing.sectionHeightXLarge,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                    )
                  : _recentMovies.isEmpty
                  ? Container(
                      height: AppSpacing.sectionHeightXLarge,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_outlined,
                              size: 48,
                              color: AppColors.getTextSecondaryColor(
                                isDarkMode,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun film récent disponible',
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
                                color: AppColors.getTextSecondaryColor(
                                  isDarkMode,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : HorizontalSection<MovieApiModel>(
                      title: 'Derniers films',
                      items: _recentMovies,
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
                        return MovieCard.fromApiModel(
                          movie: movie,
                          isDarkMode: isDarkMode,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailScreen.fromApiMovie(movie),
                              ),
                            );
                          },
                          onFavoriteTap: () {
                            // Ajouter aux favoris
                            print('Ajouté aux favoris: ${movie.title}');
                          },
                        );
                      },
                    ),
              const SizedBox(height: AppSpacing.sectionSpacing),

              // Section Dernières séries (API)
              _isLoadingLatestSeries
                  ? Container(
                      height: AppSpacing.sectionHeightXLarge,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                    )
                  : _latestSeries.isEmpty
                  ? Container(
                      height: AppSpacing.sectionHeightXLarge,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.tv_off,
                              size: 48,
                              color: AppColors.getTextSecondaryColor(
                                isDarkMode,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune série disponible',
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
                                color: AppColors.getTextSecondaryColor(
                                  isDarkMode,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : HorizontalSection<SeriesApiModel>(
                      title: 'Dernières séries',
                      items: _latestSeries,
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
                          imagePath: series.poster.isNotEmpty
                              ? series.poster
                              : 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
                          title: series.title,
                          genre: series.genres.isNotEmpty
                              ? series.genres.first
                              : 'Série',
                          duration:
                              '${series.seasonInfo.totalSeasons} saison${series.seasonInfo.totalSeasons > 1 ? 's' : ''}',
                          releaseDate: series.year.toString(),
                          rating: series.rating,
                          isDarkMode: isDarkMode,
                          onTap: () {
                            print('🎬 Navigation vers série: ${series.title}');
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SeriesDetailScreen.fromApiSeries(
                                        apiSeries: series,
                                      ),
                                ),
                              );
                            } catch (e) {
                              print('❌ Erreur navigation série: $e');
                            }
                          },
                          onFavoriteTap: () {
                            print('Ajouté aux favoris: ${series.title}');
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
