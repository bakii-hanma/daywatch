import 'package:flutter/material.dart';
import 'dart:async';
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
import '../models/movie_model.dart';
import '../data/sample_data.dart';
import '../screens/search_screen.dart';
import '../screens/movies_screen.dart';
import '../screens/series_screen.dart';
import '../screens/trailers_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/series_detail_screen.dart';
import '../screens/profile_screen.dart';

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
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentSliderIndex < 2) {
        _currentSliderIndex++;
      } else {
        _currentSliderIndex = 0;
      }

      _pageController.animateToPage(
        _currentSliderIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section slider films récemment ajoutés - Pleine largeur
            Column(
              children: [
                Container(
                  height: 250,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 3,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSliderIndex = index;
                      });
                      // Réinitialiser le timer quand l'utilisateur swipe manuellement
                      _resetAutoSlide();
                    },
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          // Image de fond pleine largeur
                          Image.asset(
                            posterImages[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
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
                                        ? AppColors.darkModeOverlay(0.95)
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
                                color: isDarkMode ? Colors.red : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: isDarkMode ? Colors.white : Colors.red,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Spider-Man: Across the Spider-Verse',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // Durée dans cadre gris
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '2h14',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Date dans cadre gris
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '15 avril 2020',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Note dans cadre blanc
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
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
                                          const SizedBox(width: 2),
                                          const Text(
                                            '8.4',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
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
                  padding: const EdgeInsets.only(left: 12, top: 4, bottom: 8),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (dotIndex) {
                      return Container(
                        width: dotIndex == _currentSliderIndex ? 40 : 14,
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
                const SizedBox(height: 8),

                // Section Films populaires
                HorizontalSection<MovieModel>(
                  title: 'Films populaires',
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
                            builder: (context) =>
                                MovieDetailScreen(movie: movie),
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

                // Section Séries populaires
                HorizontalSection<SeriesModel>(
                  title: 'Séries populaires',
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
                        // Ajouter aux favoris
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),

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
                        margin: const EdgeInsets.only(right: AppSpacing.lg),
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

                // Section Bandes annonces
                HorizontalSection<TrailerModel>(
                  title: 'Bandes annonces',
                  items: SampleData.trailers,
                  itemWidth: 320.0,
                  sectionHeight: AppSpacing.sectionHeightMedium,
                  isDarkMode: isDarkMode,
                  onSeeMoreTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrailersScreen(),
                      ),
                    );
                  },
                  itemBuilder: (trailer, index) {
                    return TrailerCard(
                      imagePath: trailer.imagePath,
                      title: trailer.title,
                      duration: trailer.duration,
                      isDarkMode: isDarkMode,
                      onPlayTap: () {
                        // Lecture de la bande-annonce
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),

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
                            builder: (context) =>
                                MovieDetailScreen(movie: movie),
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
                        // Ajouter aux favoris
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // Section Acteurs
                HorizontalSection<ActorModel>(
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
                        // Navigation vers profil acteur
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // Section Box office
                HorizontalSection<BoxOfficeModel>(
                  title: 'Box office',
                  items: SampleData.boxOfficeMovies,
                  itemWidth: 300.0,
                  sectionHeight: 300.0,
                  isDarkMode: isDarkMode,
                  itemBuilder: (boxOffice, index) {
                    return BoxOfficeCard(
                      imagePath: boxOffice.imagePath,
                      title: boxOffice.title,
                      earnings: boxOffice.earnings,
                      duration: boxOffice.duration,
                      releaseDate: boxOffice.releaseDate,
                      rating: boxOffice.rating,
                      rank: boxOffice.rank,
                      isDarkMode: isDarkMode,
                      onTap: () {
                        // Navigation vers détail du film
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),

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
                          return Container(
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
                    SeriesGrid(
                      series: SampleData.popularSeries.take(6).toList(),
                      isDarkMode: isDarkMode,
                      countText:
                          '${SampleData.popularSeries.take(6).length} séries trouvées',
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
}
