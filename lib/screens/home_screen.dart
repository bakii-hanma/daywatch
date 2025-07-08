import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'live_tv_screen.dart';
import 'my_list_screen.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/common/horizontal_section.dart';
import '../widgets/common/movie_card.dart';
import '../widgets/common/actor_card.dart';
import '../widgets/common/trailer_card.dart';
import '../widgets/common/box_office_card.dart';
import '../widgets/common/movies_grid.dart';
import '../widgets/common/series_grid.dart';
import '../widgets/common/actors_grid.dart';
import '../widgets/common/home_shimmer.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../data/sample_data.dart';
import '../screens/search_screen.dart';
import '../screens/movies_screen.dart';
import '../screens/series_screen.dart';
import '../screens/trailers_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/series_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/platform_results_screen.dart';
import '../services/movie_service.dart';
import '../services/series_service.dart';
import '../services/trailer_service.dart';
import '../services/actor_service.dart';
import '../services/api_client.dart';
import '../config/server_config.dart';
import '../screens/actor_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _currentSliderIndex = 0;
  Timer? _autoSlideTimer;
  PageController _pageController = PageController();

  // État pour la recherche
  bool _isSearchActive = false;
  String _searchQuery = '';

  // État général de chargement
  bool _isLoading = true;
  String _loadingStatus = 'Chargement...';

  // États pour les films de l'API
  List<MovieApiModel> _recentMovies = [];
  List<MovieApiModel> _popularMovies = [];

  // États pour les séries de l'API
  List<SeriesApiModel> _latestSeries = [];
  List<SeriesApiModel> _popularSeries = [];

  // États pour les trailers de l'API
  List<TrailerApiModel> _recentTrailers = [];

  // États pour les acteurs de l'API
  List<ActorApiModel> _actors = [];

  // États pour les films du box office de l'API
  List<MovieApiModel> _boxOfficeMovies = [];

  final List<String> posterImages = [
    'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
    'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
    'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
    'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
    'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
    'assets/poster/a540bacb454d0bcc68204ff72c60210d17f9679f.jpg',
    'assets/poster/d88c27338531793104f79107f3fdf1722a0e9fdc.jpg',
    'assets/poster/ee95c8d574be76182adb5fd79675435e550090e2.jpg',
  ];

  final List<Map<String, String>> platforms = [
    {'name': 'Netflix', 'image': 'assets/plateformes/netflix.png'},
    {'name': 'Prime Video', 'image': 'assets/plateformes/prime video.png'},
    {'name': 'Disney+', 'image': 'assets/plateformes/dysney plus.png'},
    {'name': 'Apple TV', 'image': 'assets/plateformes/apple tv.png'},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _loadAllDataSequentially();
  }

  // Méthode pour charger toutes les données séquentiellement
  Future<void> _loadAllDataSequentially() async {
    try {
      // 1. Charger les films
      setState(() {
        _loadingStatus = 'Chargement des films...';
      });
      await _loadMovies();

      // 2. Charger les séries (avec plus de temps)
      setState(() {
        _loadingStatus = 'Chargement des séries...';
      });
      await _loadSeries();

      // 3. Charger les acteurs
      setState(() {
        _loadingStatus = 'Chargement des acteurs...';
      });
      await _loadActors();

      // 4. Charger les trailers
      setState(() {
        _loadingStatus = 'Chargement des trailers...';
      });
      await _loadTrailers();

      // 5. Charger les films du box office
      setState(() {
        _loadingStatus = 'Chargement du box office...';
      });
      await _loadBoxOfficeMovies();

      // 6. Attendre un peu pour assurer la cohérence
      await Future.delayed(const Duration(milliseconds: 500));

      // 7. Terminer le chargement
      setState(() {
        _isLoading = false;
        _loadingStatus = 'Chargement terminé';
      });

      print('✅ Toutes les données ont été chargées avec succès');
    } catch (e) {
      print('❌ Erreur lors du chargement séquentiel: $e');
      setState(() {
        _isLoading = false;
        _loadingStatus = 'Erreur de chargement';
      });
    }
  }

  // Méthode pour charger les films depuis l'API
  Future<void> _loadMovies() async {
    try {
      // Diagnostic réseau complet
      await MovieService.diagnoseNetwork();

      // Test de connectivité d'abord
      print('🔍 Test de connectivité API...');
      final isConnected = await MovieService.testConnection();

      if (!isConnected) {
        print('❌ Impossible de se connecter à l\'API');
        print('🌐 VÉRIFICATION RÉSEAU:');
        print(
          '   - Êtes-vous sur le même réseau WiFi que ${ServerConfig.apiBaseUrl} ?',
        );
        print('   - Le serveur est-il démarré ?');
        print('   - Y a-t-il un firewall qui bloque la connexion ?');
        return;
      }

      print('✅ Connectivité API confirmée');

      // Charger les films récents et populaires en parallèle
      print('📥 Chargement des films en cours...');
      final recentMoviesFuture = MovieService.getRecentMovies(limit: 5);
      final popularMoviesFuture = MovieService.getPopularMovies(limit: 10);

      final recentMovies = await recentMoviesFuture;
      final popularMovies = await popularMoviesFuture;

      setState(() {
        _recentMovies = recentMovies;
        _popularMovies = popularMovies;
      });

      print('📊 Résultats finaux:');
      print('   - Films récents chargés: ${_recentMovies.length}');
      print('   - Films populaires chargés: ${_popularMovies.length}');

      // Afficher les titres des films récents pour debug
      if (_recentMovies.isNotEmpty) {
        print('🎬 Films récents récupérés:');
        for (var movie in _recentMovies) {
          print('   - ${movie.title} (${movie.year}) - Note: ${movie.rating}');
        }
      } else {
        print('⚠️ Aucun film récent trouvé');
      }

      if (_popularMovies.isNotEmpty) {
        print('🔥 Films populaires récupérés:');
        for (var movie in _popularMovies.take(3)) {
          print('   - ${movie.title} (${movie.year}) - Note: ${movie.rating}');
        }
        if (_popularMovies.length > 3) {
          print('   ... et ${_popularMovies.length - 3} autres');
        }
      } else {
        print('⚠️ Aucun film populaire trouvé');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des films: $e');
      print('🔧 Suggestions de dépannage:');
      print('   1. Vérifiez votre connexion WiFi');
      print(
        '   2. Assurez-vous d\'être sur le même réseau que ${ServerConfig.apiBaseUrl}',
      );
      print('   3. Vérifiez que le serveur API est démarré');
      print(
        '   4. Testez l\'URL dans un navigateur: ${ServerConfig.apiBaseUrl}/api/radarr/movies/recent',
      );
    }
  }

  // Méthode pour charger les séries depuis l'API
  Future<void> _loadSeries() async {
    try {
      // Test de connectivité d'abord
      print('🔍 Test de connectivité API Sonarr...');
      final isConnected = await SeriesService.testConnection();

      if (!isConnected) {
        print('❌ Impossible de se connecter à l\'API Sonarr');
        return;
      }

      print('✅ Connectivité API Sonarr confirmée');

      // Charger les séries récentes et populaires en parallèle
      print('📥 Chargement des séries en cours...');

      // Donner plus de temps aux séries pour charger
      final recentSeriesFuture = SeriesService.getRecentSeries(limit: 10);
      final popularSeriesFuture = SeriesService.getPopularSeries(limit: 10);

      // Attendre les deux en parallèle avec un timeout plus long
      final results = await Future.wait([
        recentSeriesFuture,
        popularSeriesFuture,
      ], eagerError: false);

      final recentSeries = results[0] as List<SeriesApiModel>;
      final popularSeries = results[1] as List<SeriesApiModel>;

      setState(() {
        _latestSeries = recentSeries;
        _popularSeries = popularSeries;
      });

      print('📊 Résultats finaux séries:');
      print('   - Dernières séries chargées: ${_latestSeries.length}');
      print('   - Séries populaires chargées: ${_popularSeries.length}');

      // Afficher les titres des séries pour debug
      if (_latestSeries.isNotEmpty) {
        print('📺 Dernières séries récupérées:');
        for (var series in _latestSeries) {
          print(
            '   - ${series.title} (${series.year}) - Note: ${series.rating}',
          );
        }
      } else {
        print('⚠️ Aucune série trouvée');
      }

      if (_popularSeries.isNotEmpty) {
        print('🔥 Séries populaires récupérées:');
        for (var series in _popularSeries.take(3)) {
          print(
            '   - ${series.title} (${series.year}) - Note: ${series.rating}',
          );
        }
        if (_popularSeries.length > 3) {
          print('   ... et ${_popularSeries.length - 3} autres');
        }
      } else {
        print('⚠️ Aucune série populaire trouvée');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des séries: $e');
    }
  }

  // Méthode pour charger les trailers depuis l'API
  Future<void> _loadTrailers() async {
    print('🎬 === DÉBUT CHARGEMENT TRAILERS ===');

    try {
      // Test de connectivité d'abord
      print('🔍 Test de connectivité API Trailers...');
      final isConnected = await TrailerService.testConnection();

      if (!isConnected) {
        print('❌ Impossible de se connecter à l\'API Trailers');
        print('🔄 UTILISATION DES DONNÉES STATIQUES EN FALLBACK...');

        // Utiliser les données statiques en fallback
        final fallbackTrailers = _getFallbackTrailers();
        setState(() {
          _recentTrailers = fallbackTrailers;
        });
        print('✅ FALLBACK TRAILERS CHARGÉS: ${fallbackTrailers.length}');
        return;
      }

      // Charger les trailers récents
      print('📥 Chargement des trailers en cours...');
      final trailers = await TrailerService.getRecentTrailers(limit: 8);

      print('📊 Trailers récupérés depuis l\'API: ${trailers.length}');

      if (trailers.isNotEmpty) {
        setState(() {
          _recentTrailers = trailers;
        });

        print('📊 État final:');
        print('   - _recentTrailers.length: ${_recentTrailers.length}');

        // Afficher les titres des trailers pour debug
        print('🎬 Trailers récents récupérés:');
        for (var trailer in _recentTrailers.take(3)) {
          print('   - ${trailer.title} (${trailer.year})');
          print('     URL poster: ${trailer.fullPosterUrl}');
        }
        if (_recentTrailers.length > 3) {
          print('   ... et ${_recentTrailers.length - 3} autres');
        }
        print('✅ TRAILERS API CHARGÉS AVEC SUCCÈS');
      } else {
        print('⚠️ Aucun trailer API disponible - utilisation du fallback');
        final fallbackTrailers = _getFallbackTrailers();
        setState(() {
          _recentTrailers = fallbackTrailers;
        });
        print('✅ FALLBACK TRAILERS CHARGÉS: ${fallbackTrailers.length}');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des trailers: $e');
      print('📚 Stack trace: ${StackTrace.current}');
      print('🔄 UTILISATION DES DONNÉES STATIQUES EN FALLBACK...');

      // Utiliser les données statiques en fallback
      final fallbackTrailers = _getFallbackTrailers();
      setState(() {
        _recentTrailers = fallbackTrailers;
      });
      print('✅ FALLBACK TRAILERS CHARGÉS: ${fallbackTrailers.length}');
    }
    print('🎬 === FIN CHARGEMENT TRAILERS ===');
  }

  // Méthode pour charger les acteurs depuis l'API
  Future<void> _loadActors() async {
    try {
      print('🎭 === DÉBUT CHARGEMENT ACTEURS ===');
      print('🔗 URL API: ${ServerConfig.apiBaseUrl}/api/actors');

      final response = await ActorService.getActors(limit: 10);

      if (response.success && response.data.isNotEmpty) {
        setState(() {
          _actors = response.data;
        });

        print('✅ Acteurs chargés avec succès: ${_actors.length}');

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
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des acteurs: $e');
      print('🔄 Utilisation des données statiques en fallback');
    }
    print('🎭 === FIN CHARGEMENT ACTEURS ===');
  }

  // Méthode pour charger les films du box office depuis l'API
  Future<void> _loadBoxOfficeMovies() async {
    try {
      // Test de connectivité d'abord
      print('🔍 Test de connectivité API Box Office...');
      final isConnected = await MovieService.testConnection();

      if (!isConnected) {
        print('❌ Impossible de se connecter à l\'API Box Office');
        return;
      }

      print('✅ Connectivité API Box Office confirmée');

      // Charger les films du box office
      print('📥 Chargement des films du box office en cours...');
      final boxOfficeMovies = await MovieService.getBoxOfficeMovies(limit: 10);

      setState(() {
        _boxOfficeMovies = boxOfficeMovies;
      });

      print('📊 Résultats finaux box office:');
      print('   - Films du box office chargés: ${_boxOfficeMovies.length}');

      if (_boxOfficeMovies.isNotEmpty) {
        print('💰 Films du box office récupérés:');
        for (var movie in _boxOfficeMovies.take(3)) {
          final earnings = movie.boxOffice != null
              ? MovieService.formatEarnings(movie.boxOffice!.revenue)
              : 'N/A';
          print('   - ${movie.title} (${movie.year}) - Earnings: $earnings');
        }
        if (_boxOfficeMovies.length > 3) {
          print('   ... et ${_boxOfficeMovies.length - 3} autres');
        }
      } else {
        print('⚠️ Aucun film du box office trouvé');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des films du box office: $e');
    }
  }

  // Méthode pour obtenir des trailers de fallback
  List<TrailerApiModel> _getFallbackTrailers() {
    return [
      TrailerApiModel(
        title: 'The Marvels',
        overview:
            'Captain Marvel, Ms. Marvel, and Monica Rambeau team up to save the universe.',
        releaseDate: '2023-11-10',
        trailerUrl: 'https://www.youtube.com/watch?v=example1',
        posterPath:
            'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      ),
      TrailerApiModel(
        title: 'The Mandalorian',
        overview:
            'The travels of a lone bounty hunter in the outer reaches of the galaxy.',
        releaseDate: '2023-03-01',
        trailerUrl: 'https://www.youtube.com/watch?v=example2',
        posterPath:
            'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
      ),
      TrailerApiModel(
        title: 'House of the Dragon',
        overview:
            'The story of House Targaryen set 200 years before the events of Game of Thrones.',
        releaseDate: '2024-01-01',
        trailerUrl: 'https://www.youtube.com/watch?v=example3',
        posterPath:
            'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
      ),
      TrailerApiModel(
        title: 'Stranger Things',
        overview:
            'When a young boy disappears, his mother must confront terrifying forces.',
        releaseDate: '2022-05-27',
        trailerUrl: 'https://www.youtube.com/watch?v=example4',
        posterPath:
            'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
      ),
      TrailerApiModel(
        title: 'The Witcher',
        overview:
            'Geralt of Rivia, a solitary monster hunter, struggles to find his place.',
        releaseDate: '2023-06-29',
        trailerUrl: 'https://www.youtube.com/watch?v=example5',
        posterPath:
            'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
      ),
    ];
  }

  @override
  void dispose() {
    // S'assurer que le wakelock est désactivé en quittant l'écran
    WakelockPlus.disable();
    print('🔋 Wakelock désactivé - Sortie de l\'écran d\'accueil');
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_recentMovies.isNotEmpty) {
        if (_currentSliderIndex < _recentMovies.length - 1) {
          _currentSliderIndex++;
        } else {
          _currentSliderIndex = 0;
        }

        _pageController.animateToPage(
          _currentSliderIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _resetAutoSlide() {
    _autoSlideTimer?.cancel();
    _startAutoSlide();
  }

  void _activateSearch(String query) {
    setState(() {
      _isSearchActive = true;
      _searchQuery = query;
    });
  }

  void _deactivateSearch() {
    setState(() {
      _isSearchActive = false;
      _searchQuery = '';
    });
  }

  // Méthode pour convertir le nom d'affichage de la plateforme en nom API
  String _getPlatformApiName(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'netflix':
        return 'netflix';
      case 'prime video':
        return 'prime';
      case 'disney+':
        return 'disney';
      case 'apple tv+':
        return 'apple';
      default:
        return displayName
            .toLowerCase()
            .replaceAll(' ', '')
            .replaceAll('+', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);
    final cardColor = AppColors.getCardColor(isDarkMode);

    Widget currentPage;
    switch (_selectedIndex) {
      case 0:
        currentPage = _buildHomePage(
          backgroundColor,
          textColor,
          cardColor,
          isDarkMode,
        );
        break;
      case 1:
        currentPage = _buildSearchPage(backgroundColor, textColor);
        break;
      case 2:
        currentPage = const LiveTvScreen();
        break;
      case 3:
        currentPage = const MyListScreen();
        break;
      case 4:
        currentPage = const ProfileScreen();
        break;
      default:
        currentPage = _buildHomePage(
          backgroundColor,
          textColor,
          cardColor,
          isDarkMode,
        );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor,
        selectedItemColor: Colors.red,
        unselectedItemColor: textColor.withOpacity(0.6),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv_rounded),
            label: 'Direct',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border_rounded),
            label: 'Ma liste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage(
    Color backgroundColor,
    Color textColor,
    Color cardColor,
    bool isDarkMode,
  ) {
    // Afficher le shimmer si le chargement est en cours
    if (_isLoading) {
      return SafeArea(
        child: Column(
          children: [
            // Indicateur de statut de chargement
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _loadingStatus,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextColor(isDarkMode),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Shimmer réduit
            Expanded(child: HomeShimmer(isDarkMode: isDarkMode)),
          ],
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.red,
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        strokeWidth: 2.5,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section slider films récents de l'API - Pleine largeur
              _recentMovies.isEmpty
                  ? Container(
                      height: 250,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: 64,
                              color: AppColors.getTextSecondaryColor(
                                isDarkMode,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun film récent disponible',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextColor(isDarkMode),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vérifiez votre connexion WiFi',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.getTextSecondaryColor(
                                  isDarkMode,
                                ),
                              ),
                            ),
                            Text(
                              'IP serveur: ${ServerConfig.apiBaseUrl}',
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
                  : Column(
                      children: [
                        Container(
                          height: 250,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _recentMovies.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentSliderIndex = index;
                              });
                              // Réinitialiser le timer quand l'utilisateur swipe manuellement
                              _resetAutoSlide();
                            },
                            itemBuilder: (context, index) {
                              final movie = _recentMovies[index];
                              return Stack(
                                children: [
                                  // Image de fond pleine largeur depuis l'API
                                  movie.images.backdrop != null &&
                                          movie.images.backdrop!.isNotEmpty
                                      ? Image.network(
                                          movie.images.backdrop!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return movie.images.poster !=
                                                            null &&
                                                        movie
                                                            .images
                                                            .poster!
                                                            .isNotEmpty
                                                    ? Image.network(
                                                        movie.images.poster!,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        color: AppColors
                                                            .textSecondaryLight,
                                                        child: const Icon(
                                                          Icons.movie,
                                                          color:
                                                              AppColors.white,
                                                          size: 100,
                                                        ),
                                                      );
                                              },
                                        )
                                      : Container(
                                          color: AppColors.textSecondaryLight,
                                          child: const Icon(
                                            Icons.movie,
                                            color: AppColors.white,
                                            size: 100,
                                          ),
                                        ),
                                  // Overlay dégradé seulement en bas (plus sombre)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 90,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            isDarkMode
                                                ? AppColors.darkModeOverlay(0.7)
                                                : AppColors.blackOverlay(0.7),
                                            isDarkMode
                                                ? AppColors.darkModeOverlay(
                                                    0.95,
                                                  )
                                                : AppColors.blackOverlay(0.95),
                                          ],
                                          stops: const [0.0, 0.2, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Bouton play en face des informations
                                  Positioned(
                                    bottom: 25,
                                    right: 16,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.red
                                            : Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.red,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  // Informations du film en bas à gauche
                                  Positioned(
                                    bottom: 30,
                                    left: 16,
                                    right: 90,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            // Durée dans cadre gris
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(
                                                  0.8,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${movie.runtime}min',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Date dans cadre gris
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(
                                                  0.8,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                movie.year.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Note dans cadre blanc
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    movie.rating
                                                        .toStringAsFixed(1),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // Indicateurs de progression À L'EXTÉRIEUR (à gauche, plus gros et plus proches)
                        Container(
                          padding: const EdgeInsets.only(
                            left: 12,
                            top: 4,
                            bottom: 8,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(_recentMovies.length, (
                              dotIndex,
                            ) {
                              return Container(
                                width: dotIndex == _currentSliderIndex
                                    ? 40
                                    : 14,
                                height: 12,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: dotIndex == _currentSliderIndex
                                      ? Colors.red
                                      : Colors.grey.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),

              // Contenu sans padding global
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Section Films populaires de l'API
                  _buildPopularMoviesSection(isDarkMode),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Séries populaires (API)
                  _buildPopularSeriesSection(isDarkMode),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Recommandations
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
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
                        Text(
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

                  // Liste horizontale de recommandations
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final recommendations = [
                          {
                            'image':
                                'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
                            'title': 'Loki',
                            'seasons': '2 seasons',
                            'years': '2021 - 2023',
                            'rating': '8.4',
                            'genre': 'Drama • Sci-Fi & Fantasy',
                          },
                          {
                            'image':
                                'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
                            'title': 'The Mandalorian',
                            'seasons': '3 seasons',
                            'years': '2019 - 2023',
                            'rating': '8.7',
                            'genre': 'Action • Adventure • Sci-Fi',
                          },
                          {
                            'image':
                                'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
                            'title': 'House of the Dragon',
                            'seasons': '2 seasons',
                            'years': '2022 - 2024',
                            'rating': '8.5',
                            'genre': 'Drama • Fantasy • Action',
                          },
                          {
                            'image':
                                'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
                            'title': 'Stranger Things',
                            'seasons': '4 seasons',
                            'years': '2016 - 2022',
                            'rating': '8.7',
                            'genre': 'Drama • Fantasy • Horror',
                          },
                          {
                            'image':
                                'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
                            'title': 'The Witcher',
                            'seasons': '3 seasons',
                            'years': '2019 - 2023',
                            'rating': '8.2',
                            'genre': 'Action • Adventure • Fantasy',
                          },
                        ];

                        final item = recommendations[index];
                        return Container(
                          width: 350,
                          margin: const EdgeInsets.only(right: AppSpacing.md),
                          child: _buildRecommendationCard(
                            item['image']!,
                            item['title']!,
                            item['seasons']!,
                            item['years']!,
                            item['rating']!,
                            item['genre']!,
                            textColor,
                            isDarkMode,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Section Bandes annonces (API + fallback)
                  _buildTrailersSection(isDarkMode),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Derniers films
                  HorizontalSection<MovieApiModel>(
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
                  _buildLatestSeriesSection(isDarkMode),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Acteurs (API)
                  _buildActorsSection(isDarkMode),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Box office
                  _buildBoxOfficeSection(isDarkMode),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Plateformes
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plateformes',
                              style: AppTypography.header(
                                AppColors.getTextColor(isDarkMode),
                              ),
                            ),
                            Text(
                              'Voir +',
                              style: AppTypography.linkText(AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Grille des plateformes (3x2)
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                              ),
                          itemCount: SampleData.platforms.length,
                          itemBuilder: (context, index) {
                            final platform = SampleData.platforms[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigation vers la page de résultats par plateforme
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlatformResultsScreen(
                                      platformName: _getPlatformApiName(
                                        platform.name,
                                      ),
                                      platformDisplayName: platform.name,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.getWidgetBackgroundColor(
                                    isDarkMode,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMedium,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.blackOverlay(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMedium,
                                  ),
                                  child: Image.asset(
                                    platform.imagePath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Espace pour la bottom nav
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPage(Color backgroundColor, Color textColor) {
    if (_isSearchActive) {
      return _buildSearchResultsPage(backgroundColor, textColor);
    } else {
      return SearchScreen(onSearchActivated: _activateSearch);
    }
  }

  Widget _buildSearchResultsPage(Color backgroundColor, Color textColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header avec bouton retour et titre
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _deactivateSearch,
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
                      'Résultats de la recherche',
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton de filtre avec terme de recherche
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.getButtonColor(isDarkMode),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu,
                              color: AppColors.getTextColor(isDarkMode),
                              size: 23,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _searchQuery,
                              style: TextStyle(
                                color: AppColors.getTextColor(isDarkMode),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: _deactivateSearch,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.getTextColor(isDarkMode),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar avec design personnalisé
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.getButtonColor(isDarkMode),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          tabs: const [
                            Tab(text: 'Films'),
                            Tab(text: 'Séries'),
                            Tab(text: 'Acteurs'),
                          ],
                          labelColor: AppColors.getTextColor(isDarkMode),
                          unselectedLabelColor: AppColors.getTextSecondaryColor(
                            isDarkMode,
                          ),
                          indicator: BoxDecoration(
                            color: AppColors.getBackgroundColor(isDarkMode),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding: const EdgeInsets.all(3),
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          dividerColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu des onglets
              Expanded(
                child: TabBarView(
                  children: [
                    // Onglet Films
                    MoviesGrid(
                      movies: SampleData.popularMovies.take(6).toList(),
                      isDarkMode: isDarkMode,
                      countText:
                          '${SampleData.popularMovies.take(6).length} films trouvés',
                      onMovieTap: (movie) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                    ),
                    // Onglet Séries
                    SeriesGrid.api(
                      apiSeries: _latestSeries.take(6).toList(),
                      isDarkMode: isDarkMode,
                      countText:
                          '${_latestSeries.take(6).length} séries trouvées',
                    ),
                    // Onglet Acteurs
                    ActorsGrid(
                      actors: SampleData.actors.take(8).toList(),
                      isDarkMode: isDarkMode,
                      countText:
                          '${SampleData.actors.take(8).length} acteurs trouvés',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularMoviesSection(bool isDarkMode) {
    if (_popularMovies.isEmpty) {
      return Container(
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
        Container(
          height: AppSpacing.sectionHeightXLarge,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _popularMovies.length,
            itemBuilder: (context, index) {
              final movie = _popularMovies[index];
              return Container(
                width: AppSpacing.cardWidthLarge,
                margin: EdgeInsets.only(
                  right: index < _popularMovies.length - 1 ? AppSpacing.md : 0,
                ),
                child: MovieCard.fromApiModel(
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
                    // TODO: Ajouter aux favoris
                    print('Ajouté aux favoris: ${movie.title}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    String imagePath,
    String title,
    String seasons,
    String years,
    String rating,
    String genre,
    Color textColor,
    bool isDarkMode,
  ) {
    return Container(
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
            child: Image.asset(
              imagePath,
              width: 100,
              height: 180,
              fit: BoxFit.cover,
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
                        title,
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
                            seasons,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            years,
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
                                  rating,
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
                        genre,
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
                        Icons.bookmark_border,
                        'Sauvegarder',
                        textColor,
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
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color textColor) {
    return Column(
      children: [
        Icon(icon, size: 20, color: textColor.withOpacity(0.7)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
        ),
      ],
    );
  }

  // Section Séries populaires depuis l'API
  Widget _buildPopularSeriesSection(bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.white : AppColors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Séries populaires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeriesScreen(),
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
        _popularSeries.isEmpty
            ? Container(
                height: AppSpacing.sectionHeightXLarge,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.tv_off,
                        size: 48,
                        color: textColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune série populaire disponible',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                height: AppSpacing.sectionHeightXLarge,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _popularSeries.length,
                  itemBuilder: (context, index) {
                    final series = _popularSeries[index];
                    return Container(
                      width: AppSpacing.cardWidthLarge,
                      margin: EdgeInsets.only(
                        right: index < _popularSeries.length - 1
                            ? AppSpacing.md
                            : 0,
                      ),
                      child: MovieCard(
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
                          print(
                            '🎬 Navigation vers série populaire: ${series.title}',
                          );
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
                            print('❌ Erreur navigation série populaire: $e');
                          }
                        },
                        onFavoriteTap: () {
                          print('Ajouté aux favoris: ${series.title}');
                        },
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // Section Dernières séries depuis l'API
  Widget _buildLatestSeriesSection(bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.white : AppColors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dernières séries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeriesScreen(),
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
        _latestSeries.isEmpty
            ? Container(
                height: AppSpacing.sectionHeightXLarge,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.tv_off,
                        size: 48,
                        color: textColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune série disponible',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                height: AppSpacing.sectionHeightXLarge,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _latestSeries.length,
                  itemBuilder: (context, index) {
                    final series = _latestSeries[index];
                    return Container(
                      width: AppSpacing.cardWidthLarge,
                      margin: EdgeInsets.only(
                        right: index < _latestSeries.length - 1
                            ? AppSpacing.md
                            : 0,
                      ),
                      child: MovieCard(
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
                          print(
                            '🎬 Navigation vers dernière série: ${series.title}',
                          );
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
                            print('❌ Erreur navigation dernière série: $e');
                          }
                        },
                        onFavoriteTap: () {
                          print('Ajouté aux favoris: ${series.title}');
                        },
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // Section Acteurs depuis l'API avec fallback vers données statiques
  Widget _buildActorsSection(bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.white : AppColors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Acteurs',
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
        _actors.isEmpty
            ? Container(
                height: 200.0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: textColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun acteur disponible',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Utilisation des données statiques',
                        style: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                height: 200.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _actors.length,
                  itemBuilder: (context, index) {
                    final actor = _actors[index];
                    return Container(
                      width: 130.0,
                      margin: EdgeInsets.only(
                        right: index < _actors.length - 1 ? AppSpacing.md : 0,
                      ),
                      child: ActorCard(
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
                    );
                  },
                ),
              ),
      ],
    );

    // Si aucun acteur API, utiliser les données statiques
    if (_actors.isEmpty) {
      return HorizontalSection<ActorModel>(
        title: 'Acteurs',
        items: SampleData.actors,
        itemWidth: 130.0,
        sectionHeight: 200.0,
        isDarkMode: isDarkMode,
        itemBuilder: (actor, index) {
          return ActorCard(
            imagePath: actor.imagePath,
            name: actor.name,
            isDarkMode: isDarkMode,
            onTap: () {
              print('🎭 Navigation vers acteur statique: ${actor.name}');
              // Pour les acteurs statiques, on peut créer une page de détail simple
              // ou rediriger vers la recherche
            },
          );
        },
      );
    }

    return Container(); // Ne devrait jamais être atteint
  }

  // Section Box Office depuis l'API avec fallback vers données statiques
  Widget _buildBoxOfficeSection(bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.white : AppColors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Box office',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigation vers page box office complète
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

        _boxOfficeMovies.isEmpty
            ? _buildNoBoxOfficeSection(isDarkMode)
            : Container(
                height: 300.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _boxOfficeMovies.length > 5
                      ? 5
                      : _boxOfficeMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _boxOfficeMovies[index];
                    final boxOfficeModel = movie.toBoxOfficeModel();
                    return Container(
                      width: 300.0,
                      margin: EdgeInsets.only(
                        right: index < _boxOfficeMovies.length - 1
                            ? AppSpacing.md
                            : 0,
                      ),
                      child: BoxOfficeCard(
                        imagePath: boxOfficeModel.imagePath,
                        title: boxOfficeModel.title,
                        earnings: boxOfficeModel.earnings,
                        duration: boxOfficeModel.duration,
                        releaseDate: boxOfficeModel.releaseDate,
                        rating: boxOfficeModel.rating,
                        rank: boxOfficeModel.rank,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          print(
                            '💰 Navigation vers film box office: ${movie.title}',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen.fromApiMovie(movie),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // Section message quand aucun film box office disponible
  Widget _buildNoBoxOfficeSection(bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.white : AppColors.black;

    return Container(
      height: 300.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money_outlined,
              size: 64,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun film du box office disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez la connexion au serveur',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Trailers depuis l'API avec fallback vers données statiques
  Widget _buildTrailersSection(bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.white : AppColors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bandes annonces',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrailersScreen(),
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

        _recentTrailers.isEmpty
            ? _buildNoTrailersSection(isDarkMode)
            : Container(
                height: AppSpacing.sectionHeightMedium,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _recentTrailers.length > 5
                      ? 5
                      : _recentTrailers.length,
                  itemBuilder: (context, index) {
                    final trailer = _recentTrailers[index];
                    return Container(
                      width: 320.0,
                      margin: EdgeInsets.only(
                        right: index < _recentTrailers.length - 1
                            ? AppSpacing.md
                            : 0,
                      ),
                      child: TrailerCard(
                        imagePath: trailer.fullPosterUrl.isNotEmpty
                            ? trailer.fullPosterUrl
                            : 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
                        title: trailer.title,
                        duration: trailer.duration,
                        isDarkMode: isDarkMode,
                        trailerUrl: trailer.trailerUrl,
                        onPlayTap: () {
                          print('🎬 Lecture trailer: ${trailer.title}');
                          print('🔗 URL: ${trailer.trailerUrl}');
                        },
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // Section message quand aucun trailer disponible
  Widget _buildNoTrailersSection(bool isDarkMode) {
    final textColor = isDarkMode ? AppColors.white : AppColors.black;

    return Container(
      height: AppSpacing.sectionHeightMedium,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune bande-annonce disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez la connexion au serveur',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'IP: ${ApiClient.baseUrl}',
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

  // Méthode pour recharger tous les éléments lors du pull to refresh
  Future<void> _onRefresh() async {
    print('🔄 PULL TO REFRESH - Rechargement de tous les éléments...');

    // Remettre l'état de chargement à true
    setState(() {
      _isLoading = true;
      _loadingStatus = 'Rechargement...';
    });

    // Vider les listes actuelles
    _recentMovies.clear();
    _popularMovies.clear();
    _latestSeries.clear();
    _popularSeries.clear();
    _recentTrailers.clear();
    _actors.clear();
    _boxOfficeMovies.clear(); // Clear box office movies

    // Recharger toutes les données séquentiellement
    await _loadAllDataSequentially();

    print('✅ PULL TO REFRESH - Rechargement terminé !');
  }
}
