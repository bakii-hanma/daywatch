import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'live_tv_screen.dart';
import 'my_list_screen.dart';
import 'series_screen.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../services/favorite_service.dart';
import '../services/user_storage_service.dart';
import '../widgets/common/horizontal_section.dart';
import '../widgets/common/movie_card.dart';
import '../widgets/common/movies_grid.dart';
import '../widgets/common/series_grid.dart';
import '../widgets/common/actors_grid.dart';
import '../widgets/home/header_slider.dart';
import '../widgets/home/popular_movies_section.dart';
import '../widgets/home/recommendations_section.dart';
import '../widgets/home/trailers_section.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../screens/search_screen.dart';
import '../screens/movies_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/series_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../services/movie_service.dart';
import '../services/series_service.dart';
import '../services/tv_channel_service.dart';
import '../services/watch_history_service.dart';
import '../models/tv_channel_model.dart';
import '../widgets/common/series_card.dart';
import '../widgets/home/tv_channels_section.dart';
import '../screens/actor_detail_screen.dart';
import '../services/search_service.dart';
import '../services/device_service.dart';
import '../services/trailer_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _currentSliderIndex = 0;
  Timer? _autoSlideTimer;
  final PageController _pageController = PageController();

  // État pour la recherche
  bool _isSearchActive = false;
  String _searchQuery = '';

  // Résultats de la recherche API
  List<MovieApiModel> _searchResultsMovies = [];
  List<SeriesApiModel> _searchResultsSeries = [];
  List<ActorModel> _searchResultsActors = [];
  bool _isLoadingSearchResults = false;

  // États de chargement individuels
  bool _isLoadingMovies = true;
  bool _isLoadingRecommendations = true;
  bool _isLoadingTrailers = true;

  // États pour les films de l'API
  List<MovieApiModel> _recentMovies = [];
  List<MovieApiModel> _popularMovies = [];
  List<MovieApiModel> _headerMovies = [];

  // États pour les recommandations de l'API
  List<MovieApiModel> _recommendations = [];

  // États pour les trailers de l'API
  List<TrailerApiModel> _recentTrailers = [];

  // États de chargement additionnels pour alignement web
  bool _isLoadingSeries = true;
  bool _isLoadingTvChannels = true;
  bool _isLoadingHistory = true;

  // États pour les séries de l'API
  List<SeriesApiModel> _popularSeries = [];
  List<SeriesApiModel> _recentSeries = [];
  List<SeriesApiModel> _animeSeries = [];
  List<SeriesApiModel> _kdramaSeries = [];

  // États pour les chaînes de l'API
  List<TvChannelModel> _tvChannels = [];

  // États pour la reprise de lecture
  List<Map<String, dynamic>> _watchHistory = [];

  // États pour les favoris de l'utilisateur
  Set<String> _favoriteMovieIds = {};
  String? _userId;

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
    _loadAllData();
    DeviceService.startHeartbeat();
  }

  // Charger toutes les données
  Future<void> _loadAllData() async {
    await _loadFavorites();
    await Future.wait([
      _loadMovies(),
      _loadRecommendations(),
      _loadTrailers(),
      _loadSeries(),
      _loadTvChannels(),
      _loadWatchHistory(),
    ]);
  }

  // Charger les séries
  Future<void> _loadSeries() async {
    if (mounted) setState(() => _isLoadingSeries = true);
    try {
      final popular = await SeriesService.getPopularSeries(limit: 15);
      final recent = await SeriesService.getRecentSeries(limit: 15);
      final anime = await SeriesService.getAnimeSeries(limit: 15);
      final kdrama = await SeriesService.getKDramaSeries(limit: 15);
      if (mounted) {
        setState(() {
          _popularSeries = popular;
          _recentSeries = recent;
          _animeSeries = anime;
          _kdramaSeries = kdrama;
          _isLoadingSeries = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSeries = false);
    }
  }

  // Charger les chaînes TV en direct
  Future<void> _loadTvChannels() async {
    if (mounted) setState(() => _isLoadingTvChannels = true);
    try {
      final channels = await TvChannelService.getHomeChannels(limit: 15);
      if (mounted) {
        setState(() {
          _tvChannels = channels;
          _isLoadingTvChannels = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTvChannels = false);
    }
  }

  // Charger l'historique pour reprendre la lecture
  Future<void> _loadWatchHistory() async {
    if (_userId == null) {
      if (mounted) setState(() => _isLoadingHistory = false);
      return;
    }
    if (mounted) setState(() => _isLoadingHistory = true);
    try {
      final history = await WatchHistoryService.getMovieWatchHistory(_userId!);
      final ongoing = history.where((h) => h['isCompleted'] != true).toList();
      if (mounted) {
        setState(() {
          _watchHistory = ongoing;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  // Charger les trailers
  Future<void> _loadTrailers() async {
    if (mounted) setState(() => _isLoadingTrailers = true);
    try {
      final trailers = await TrailerService.getRecentTrailers(limit: 8);
      if (mounted) {
        setState(() {
          _recentTrailers = trailers;
          _isLoadingTrailers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTrailers = false);
    }
  }



  // Charger les favoris
  Future<void> _loadFavorites() async {
    try {
      final userData = await UserStorageService.getUserData();
      if (userData != null) {
        _userId = userData['userId']?.toString();
        if (_userId != null) {
          final favMovies = await FavoriteService.getFavoriteMovies(_userId!);
          if (mounted) {
            setState(() {
              _favoriteMovieIds = favMovies.map((m) => m.id).toSet();
            });
          }
        }
      }
    } catch (_) {}
  }

  // Ajouter/retirer un film des favoris
  Future<void> _toggleMovieFavorite(MovieApiModel movie) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour gérer vos favoris.'),
        ),
      );
      return;
    }
    final isFav = _favoriteMovieIds.contains(movie.id);
    bool success = false;
    if (isFav) {
      success = await FavoriteService.removeMovieFromFavorites(
        _userId!,
        movie.id,
      );
      if (success) {
        if (mounted) setState(() => _favoriteMovieIds.remove(movie.id));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Retiré de vos favoris')));
      }
    } else {
      success = await FavoriteService.addMovieToFavorites(_userId!, movie.id);
      if (success) {
        if (mounted) setState(() => _favoriteMovieIds.add(movie.id));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ajouté à vos favoris')));
      }
    }
  }

  // Charger les recommandations
  Future<void> _loadRecommendations() async {
    setState(() => _isLoadingRecommendations = true);
    try {
      final recommendations = await MovieService.getTopRecommendations(
        limit: 5,
      );
      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRecommendations = false);
    }
  }

  // Charger les films
  Future<void> _loadMovies() async {
    setState(() => _isLoadingMovies = true);
    try {
      // Récupérer tous les films (cette route fonctionne, mise en cache)
      final allMovies = await MovieService.getOrFetchAllMovies();

      // 1. Extraire les films populaires (triés par popularité décroissante)
      final popularList = List<MovieApiModel>.from(allMovies);
      popularList.sort((a, b) => b.popularity.compareTo(a.popularity));
      final popularMovies = popularList.take(15).toList();

      // 2. Extraire les derniers films (triés par année décroissante, puis par ID décroissant)
      final recentList = List<MovieApiModel>.from(allMovies);
      recentList.sort((a, b) {
        final yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) return yearCompare;
        return b.id.compareTo(a.id);
      });
      final recentMovies = recentList.take(15).toList();

      // 3. Extraire les 5 films populaires les mieux notés (par ordre de note)
      final headerList = List<MovieApiModel>.from(popularList.take(30));
      headerList.sort((a, b) => b.rating.compareTo(a.rating));
      final headerMovies = headerList.take(5).toList();

      if (mounted) {
        setState(() {
          _recentMovies = recentMovies;
          _popularMovies = popularMovies;
          _headerMovies = headerMovies;
          _isLoadingMovies = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMovies = false);
    }
  }

  Widget _buildSliderShimmer(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalListShimmer(
    bool isDarkMode, {
    required String title,
    double height = 200,
    double cardWidth = 140,
    bool isActor = false,
  }) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de section simulé
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 18,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(right: index < 3 ? AppSpacing.lg : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: isActor
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: isActor
                                ? null
                                : BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      if (!isActor) ...[
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    DeviceService.stopHeartbeat();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_headerMovies.isNotEmpty && _pageController.hasClients) {
        if (_currentSliderIndex < _headerMovies.length - 1) {
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
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoadingSearchResults = true);
    try {
      final results = await SearchService.search(query.trim());
      if (mounted) {
        setState(() {
          _searchResultsMovies = results.movies;
          _searchResultsSeries = [...results.series, ...results.animes];
          _searchResultsActors = results.actors
              .map((a) => a.toActorModel())
              .toList();
          _isLoadingSearchResults = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResultsMovies = [];
          _searchResultsSeries = [];
          _searchResultsActors = [];
          _isLoadingSearchResults = false;
        });
      }
    }
  }

  void _deactivateSearch() {
    setState(() {
      _isSearchActive = false;
      _searchQuery = '';
    });
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
              // Slider d'en-tête (5 nouveaux films les mieux notés)
              _isLoadingMovies
                  ? _buildSliderShimmer(isDarkMode)
                  : HeaderSlider(
                      recentMovies: _headerMovies,
                      pageController: _pageController,
                      currentSliderIndex: _currentSliderIndex,
                      onPageChanged: (index) {
                        setState(() {
                          _currentSliderIndex = index;
                        });
                        _resetAutoSlide();
                      },
                      isDarkMode: isDarkMode,
                    ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Section Reprendre la lecture
                  if (!_isLoadingHistory && _watchHistory.isNotEmpty) ...[
                    HorizontalSection<Map<String, dynamic>>(
                      title: 'Reprendre la lecture',
                      items: _watchHistory,
                      itemWidth: 200,
                      sectionHeight: 180,
                      isDarkMode: isDarkMode,
                      showSeeMore: false,
                      itemBuilder: (entry, index) {
                        final movie = entry['movie'] as MovieApiModel;
                        final pos = entry['lastWatchedPosition'] as int? ?? 0;
                        final duration = movie.runtime * 60;
                        final progress = duration > 0 ? (pos / duration) : 0.0;
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
                            width: 200,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.getWidgetBackgroundColor(isDarkMode),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  if (movie.images.backdrop != null)
                                    Image.network(
                                      movie.images.backdrop!,
                                      width: 200,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    )
                                  else if (movie.images.poster != null)
                                    Image.network(
                                      movie.images.poster!,
                                      width: 200,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    )
                                  else
                                    Container(
                                      width: 200,
                                      height: 180,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.movie, color: Colors.white),
                                    ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          movie.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor: Colors.grey[700],
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Section Films populaires (API)
                  _isLoadingMovies
                      ? _buildHorizontalListShimmer(
                          isDarkMode,
                          title: 'Films populaires',
                        )
                      : PopularMoviesSection(
                          popularMovies: _popularMovies,
                          isDarkMode: isDarkMode,
                          favoriteMovieIds: _favoriteMovieIds,
                          onFavoriteTap: _toggleMovieFavorite,
                        ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Séries populaires (API)
                  _isLoadingSeries
                      ? _buildHorizontalListShimmer(
                          isDarkMode,
                          title: 'Séries populaires',
                        )
                      : HorizontalSection<SeriesApiModel>(
                          title: 'Séries populaires',
                          items: _popularSeries,
                          itemWidth: 150,
                          sectionHeight: 290,
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
                            return SeriesCard.fromApiModel(
                              series: series,
                              isDarkMode: isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeriesDetailScreen.fromApiSeries(
                                      apiSeries: series,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Recommandé pour vous (API)
                  _isLoadingRecommendations
                      ? _buildHorizontalListShimmer(
                          isDarkMode,
                          title: 'Recommandé pour vous',
                        )
                      : RecommendationsSection(
                          recommendations: _recommendations,
                          isDarkMode: isDarkMode,
                          favoriteMovieIds: _favoriteMovieIds,
                          onFavoriteTap: _toggleMovieFavorite,
                        ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Animés populaires
                  if (!_isLoadingSeries && _animeSeries.isNotEmpty) ...[
                    HorizontalSection<SeriesApiModel>(
                      title: 'Animés populaires',
                      items: _animeSeries,
                      itemWidth: 150,
                      sectionHeight: 290,
                      isDarkMode: isDarkMode,
                      itemBuilder: (series, index) {
                        return SeriesCard.fromApiModel(
                          series: series,
                          isDarkMode: isDarkMode,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SeriesDetailScreen.fromApiSeries(
                                  apiSeries: series,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Section K-Dramas
                  if (!_isLoadingSeries && _kdramaSeries.isNotEmpty) ...[
                    HorizontalSection<SeriesApiModel>(
                      title: 'K-Dramas',
                      items: _kdramaSeries,
                      itemWidth: 150,
                      sectionHeight: 290,
                      isDarkMode: isDarkMode,
                      itemBuilder: (series, index) {
                        return SeriesCard.fromApiModel(
                          series: series,
                          isDarkMode: isDarkMode,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SeriesDetailScreen.fromApiSeries(
                                  apiSeries: series,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Section IPTV En direct
                  TvChannelsSection(
                    title: 'Chaînes en direct',
                    channels: _tvChannels,
                    isLoading: _isLoadingTvChannels,
                    onSeeMoreTap: () {
                      setState(() {
                        _selectedIndex = 2; // Onglet direct
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Bandes-annonces (API)
                  _isLoadingTrailers
                      ? _buildHorizontalListShimmer(
                          isDarkMode,
                          title: 'Bandes-annonces',
                          height: 180,
                          cardWidth: 280,
                        )
                      : TrailersSection(
                          recentTrailers: _recentTrailers,
                          isDarkMode: isDarkMode,
                        ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Derniers films (API)
                  _isLoadingMovies
                      ? _buildHorizontalListShimmer(
                          isDarkMode,
                          title: 'Derniers films',
                        )
                      : HorizontalSection<MovieApiModel>(
                          title: 'Derniers films',
                          items: _recentMovies,
                          itemWidth: AppSpacing.cardWidthLarge,
                          sectionHeight: 290,
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
                            final isFav = _favoriteMovieIds.contains(movie.id);
                            return MovieCard.fromApiModel(
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
                              onFavoriteTap: () => _toggleMovieFavorite(movie),
                            );
                          },
                        ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Section Dernières séries (API)
                  _isLoadingSeries
                      ? _buildHorizontalListShimmer(
                          isDarkMode,
                          title: 'Dernières séries',
                        )
                      : HorizontalSection<SeriesApiModel>(
                          title: 'Dernières séries',
                          items: _recentSeries,
                          itemWidth: 150,
                          sectionHeight: 290,
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
                            return SeriesCard.fromApiModel(
                              series: series,
                              isDarkMode: isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeriesDetailScreen.fromApiSeries(
                                      apiSeries: series,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
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
                          overlayColor: WidgetStateProperty.all(
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
                child: _isLoadingSearchResults
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      )
                    : TabBarView(
                        children: [
                          // Onglet Films
                          MoviesGrid.api(
                            apiMovies: _searchResultsMovies,
                            isDarkMode: isDarkMode,
                            countText:
                                '${_searchResultsMovies.length} films trouvés',
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
                          // Onglet Séries
                          SeriesGrid.api(
                            apiSeries: _searchResultsSeries,
                            isDarkMode: isDarkMode,
                            countText:
                                '${_searchResultsSeries.length} séries trouvées',
                            onApiSeriesTap: (series) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SeriesDetailScreen.fromApiSeries(
                                        apiSeries: series,
                                      ),
                                ),
                              );
                            },
                          ),
                          // Onglet Acteurs
                          ActorsGrid(
                            actors: _searchResultsActors,
                            isDarkMode: isDarkMode,
                            countText:
                                '${_searchResultsActors.length} acteurs trouvés',
                            onActorTap: (actor) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActorDetailScreen(
                                    actorId: int.parse(actor.id),
                                    actorName: actor.name,
                                  ),
                                ),
                              );
                            },
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

  // Méthode pour recharger tous les éléments lors du pull to refresh
  Future<void> _onRefresh() async {
    // Remettre l'état de chargement à true
    setState(() {
      _isLoadingMovies = true;
      _isLoadingRecommendations = true;
      _isLoadingTrailers = true;
      _isLoadingSeries = true;
      _isLoadingTvChannels = true;
      _isLoadingHistory = true;
    });

    // Vider les listes actuelles
    MovieService.clearCache();
    _recentMovies.clear();
    _popularMovies.clear();
    _recommendations.clear();
    _headerMovies.clear();
    _recentTrailers.clear();
    _popularSeries.clear();
    _recentSeries.clear();
    _animeSeries.clear();
    _kdramaSeries.clear();
    _tvChannels.clear();
    _watchHistory.clear();

    // Recharger toutes les données
    await _loadAllData();
  }
}
