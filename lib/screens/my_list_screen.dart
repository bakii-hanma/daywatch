import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../widgets/common/movies_grid.dart';
import '../widgets/common/series_grid.dart';
import '../widgets/common/history_item_card.dart';
import '../widgets/common/download_item_card.dart';
import '../widgets/common/marquee_text.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import 'movie_detail_screen.dart';
import 'series_detail_screen.dart';
import 'downloads_screen.dart';

import '../services/favorite_service.dart';
import '../services/watch_history_service.dart';
import '../services/download_service.dart';
import '../services/user_storage_service.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  String? _userId;
  List<MovieApiModel> _favoriteMovies = [];
  List<SeriesApiModel> _favoriteSeries = [];
  List<MovieApiModel> _downloadedMovies = [];
  List<SeriesApiModel> _downloadedSeries = [];
  List<Map<String, dynamic>> _movieHistory = [];
  List<Map<String, dynamic>> _episodeHistory = [];

  bool _isLoadingFavorites = true;
  bool _isLoadingDownloads = true;
  bool _isLoadingHistory = true;

  String _storageUsedString = '0.0 GB';
  String _moviesSizeString = '0.0 GB';
  String _seriesSizeString = '0.0 GB';

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final userData = await UserStorageService.getUserData();
    if (userData != null) {
      setState(() {
        _userId = userData['userId']?.toString();
      });
      if (_userId != null) {
        _loadData();
      }
    } else {
      setState(() {
        _isLoadingFavorites = false;
        _isLoadingDownloads = false;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _loadData() async {
    _loadFavorites();
    _loadDownloads();
    _loadHistory();
  }

  Future<void> _loadFavorites() async {
    if (_userId == null) return;
    setState(() => _isLoadingFavorites = true);
    final movies = await FavoriteService.getFavoriteMovies(_userId!);
    final shows = await FavoriteService.getFavoriteShows(_userId!);
    if (mounted) {
      setState(() {
        _favoriteMovies = movies;
        _favoriteSeries = shows;
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> _loadDownloads() async {
    setState(() => _isLoadingDownloads = true);
    final movies = await DownloadService.getDownloadedMovies();
    final series = await DownloadService.getDownloadedSeries();
    final storageStr = await DownloadService.getStorageUsedString();
    if (mounted) {
      setState(() {
        _downloadedMovies = movies;
        _downloadedSeries = series;
        _storageUsedString = storageStr;
        _moviesSizeString = '${(movies.length * 1.2).toStringAsFixed(1)} GB';
        _seriesSizeString = '${(series.length * 0.6).toStringAsFixed(1)} GB';
        _isLoadingDownloads = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    if (_userId == null) return;
    setState(() => _isLoadingHistory = true);
    final movieHistory = await WatchHistoryService.getMovieWatchHistory(_userId!);
    final episodeHistory = await WatchHistoryService.getEpisodeWatchHistory(_userId!);
    if (mounted) {
      setState(() {
        _movieHistory = movieHistory;
        _episodeHistory = episodeHistory;
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Text(
                  'Bibliothèque',
                  style: AppTypography.header(textColor),
                  textAlign: TextAlign.center,
                ),
              ),

              // Tab Bar principale en bas
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.getTextSecondaryColor(
                        isDarkMode,
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  tabs: [
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: MarqueeText(
                          text: 'Favoris',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          animationDuration: const Duration(milliseconds: 3000),
                          pauseDuration: const Duration(milliseconds: 1000),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: MarqueeText(
                          text: 'Téléchargements',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          animationDuration: const Duration(milliseconds: 3000),
                          pauseDuration: const Duration(milliseconds: 1000),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: MarqueeText(
                          text: 'Historique',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          animationDuration: const Duration(milliseconds: 3000),
                          pauseDuration: const Duration(milliseconds: 1000),
                        ),
                      ),
                    ),
                  ],
                  labelColor: AppColors.getTextColor(isDarkMode),
                  unselectedLabelColor: AppColors.getTextSecondaryColor(
                    isDarkMode,
                  ),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  dividerColor: Colors.transparent,
                ),
              ),

              const SizedBox(height: 16),

              // Contenu des onglets
              Expanded(
                child: TabBarView(
                  children: [
                    // Onglet Favoris
                    _buildFavoritesTab(isDarkMode),
                    // Onglet Téléchargements
                    _buildDownloadsTab(isDarkMode),
                    // Onglet Historique
                    _buildHistoryTab(isDarkMode),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesTab(bool isDarkMode) {
    return DefaultTabController(
      length: 2,
      child: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: Column(
          children: [
            // Sub Tab Bar (Films, Séries)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.getButtonColor(isDarkMode),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          // Onglet Films
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => DefaultTabController.of(
                                    context,
                                  ).animateTo(0),
                                  child: AnimatedBuilder(
                                    animation: DefaultTabController.of(context),
                                    builder: (context, child) {
                                      final tabController =
                                          DefaultTabController.of(context);
                                      final isSelected = tabController.index == 0;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.getBackgroundColor(
                                                  isDarkMode,
                                                )
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          'Films',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.getTextColor(
                                                    isDarkMode,
                                                  )
                                                : AppColors.getTextSecondaryColor(
                                                    isDarkMode,
                                                  ),
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          // Onglet Séries
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => DefaultTabController.of(
                                    context,
                                  ).animateTo(1),
                                  child: AnimatedBuilder(
                                    animation: DefaultTabController.of(context),
                                    builder: (context, child) {
                                      final tabController =
                                          DefaultTabController.of(context);
                                      final isSelected = tabController.index == 1;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.getBackgroundColor(
                                                  isDarkMode,
                                                )
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          'Séries',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.getTextColor(
                                                    isDarkMode,
                                                  )
                                                : AppColors.getTextSecondaryColor(
                                                    isDarkMode,
                                                  ),
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu Films/Séries
            Expanded(
              child: _isLoadingFavorites
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        // Films favoris
                        MoviesGrid(
                          apiMovies: _favoriteMovies,
                          isDarkMode: isDarkMode,
                          countText: '${_favoriteMovies.length} films favoris',
                          onApiMovieTap: (movie) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailScreen.fromApiMovie(movie),
                              ),
                            );
                          },
                        ),
                        // Séries favorites
                        SeriesGrid.api(
                          apiSeries: _favoriteSeries,
                          isDarkMode: isDarkMode,
                          countText: '${_favoriteSeries.length} séries favorites',
                          onApiSeriesTap: (series) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SeriesDetailScreen.fromApiSeries(apiSeries: series),
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
    );
  }

  Widget _buildDownloadsTab(bool isDarkMode) {
    return DefaultTabController(
      length: 2,
      child: RefreshIndicator(
        onRefresh: _loadDownloads,
        child: Column(
          children: [
            // Informations de stockage en haut
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getWidgetBackgroundColor(isDarkMode),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.getTextSecondaryColor(
                    isDarkMode,
                  ).withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStorageInfo('Films', _moviesSizeString, '${_downloadedMovies.length} éléments', isDarkMode),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.getTextSecondaryColor(
                      isDarkMode,
                    ).withOpacity(0.3),
                  ),
                  _buildStorageInfo('Séries', _seriesSizeString, '${_downloadedSeries.length} éléments', isDarkMode),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.getTextSecondaryColor(
                      isDarkMode,
                    ).withOpacity(0.3),
                  ),
                  _buildStorageInfo('Total', _storageUsedString, '${_downloadedMovies.length + _downloadedSeries.length} éléments', isDarkMode),
                ],
              ),
            ),

            // Sub Tab Bar (Films, Séries)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.getButtonColor(isDarkMode),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          // Onglet Films
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => DefaultTabController.of(
                                    context,
                                  ).animateTo(0),
                                  child: AnimatedBuilder(
                                    animation: DefaultTabController.of(context),
                                    builder: (context, child) {
                                      final tabController =
                                          DefaultTabController.of(context);
                                      final isSelected = tabController.index == 0;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.getBackgroundColor(
                                                  isDarkMode,
                                                )
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          'Films',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.getTextColor(
                                                    isDarkMode,
                                                  )
                                                : AppColors.getTextSecondaryColor(
                                                    isDarkMode,
                                                  ),
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          // Onglet Séries
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => DefaultTabController.of(
                                    context,
                                  ).animateTo(1),
                                  child: AnimatedBuilder(
                                    animation: DefaultTabController.of(context),
                                    builder: (context, child) {
                                      final tabController =
                                          DefaultTabController.of(context);
                                      final isSelected = tabController.index == 1;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.getBackgroundColor(
                                                  isDarkMode,
                                                )
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          'Séries',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.getTextColor(
                                                    isDarkMode,
                                                  )
                                                : AppColors.getTextSecondaryColor(
                                                    isDarkMode,
                                                  ),
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu Films/Séries téléchargés
            Expanded(
              child: _isLoadingDownloads
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        // Films téléchargés
                        _buildDownloadsListView(isDarkMode, true),
                        // Séries téléchargées
                        _buildDownloadsListView(isDarkMode, false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfo(
    String type,
    String size,
    String count,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Text(
          type,
          style: TextStyle(
            color: AppColors.getTextColor(isDarkMode),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          size,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          count,
          style: TextStyle(
            color: AppColors.getTextSecondaryColor(isDarkMode),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadsListView(bool isDarkMode, bool isMovies) {
    final items = isMovies ? _downloadedMovies : _downloadedSeries;

    if (items.isEmpty) {
      return _buildDownloadsEmptyState(isDarkMode, isMovies);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Utiliser les extensions toMovieModel() et toSeriesModel() pour le widget DownloadItemCard
          final classicItem = isMovies 
              ? (item as MovieApiModel).toMovieModel() 
              : (item as SeriesApiModel).toSeriesModel();
              
          return DownloadItemCard(
            item: classicItem,
            isDarkMode: isDarkMode,
            isMovies: isMovies,
            onTap: () {
              if (isMovies) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen.fromApiMovie(item as MovieApiModel),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeriesDetailScreen.fromApiSeries(apiSeries: item as SeriesApiModel),
                  ),
                );
              }
            },
            onDeleteTap: () =>
                _showDeleteDownloadDialog(isMovies, item),
          );
        },
      ),
    );
  }

  Widget _buildDownloadsEmptyState(bool isDarkMode, bool isMovies) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMovies ? Icons.movie_outlined : Icons.tv_outlined,
            size: 80,
            color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun ${isMovies ? 'film' : 'série'} téléchargé',
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les ${isMovies ? 'films' : 'séries'} que vous téléchargez\napparaîtront ici',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DownloadsScreen(),
                ),
              );
              _loadDownloads();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Gérer les téléchargements'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDownloadDialog(bool isMovie, dynamic item) {
    final title = isMovie ? (item as MovieApiModel).title : (item as SeriesApiModel).title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le téléchargement'),
        content: Text(
          'Voulez-vous supprimer "$title" de vos téléchargements ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (isMovie) {
                await DownloadService.removeDownloadedMovie((item as MovieApiModel).id);
              } else {
                await DownloadService.removeDownloadedSeries((item as SeriesApiModel).id);
              }
              _loadDownloads();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$title supprimé')));
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(bool isDarkMode) {
    return DefaultTabController(
      length: 2,
      child: RefreshIndicator(
        onRefresh: _loadHistory,
        child: Column(
          children: [
            // Sub Tab Bar (Films, Séries)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.getButtonColor(isDarkMode),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          // Onglet Films
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => DefaultTabController.of(
                                    context,
                                  ).animateTo(0),
                                  child: AnimatedBuilder(
                                    animation: DefaultTabController.of(context),
                                    builder: (context, child) {
                                      final tabController =
                                          DefaultTabController.of(context);
                                      final isSelected = tabController.index == 0;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.getBackgroundColor(
                                                  isDarkMode,
                                                )
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          'Films',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.getTextColor(
                                                    isDarkMode,
                                                  )
                                                : AppColors.getTextSecondaryColor(
                                                    isDarkMode,
                                                  ),
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          // Onglet Séries
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => DefaultTabController.of(
                                    context,
                                  ).animateTo(1),
                                  child: AnimatedBuilder(
                                    animation: DefaultTabController.of(context),
                                    builder: (context, child) {
                                      final tabController =
                                          DefaultTabController.of(context);
                                      final isSelected = tabController.index == 1;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.getBackgroundColor(
                                                  isDarkMode,
                                                )
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          'Séries',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.getTextColor(
                                                    isDarkMode,
                                                  )
                                                : AppColors.getTextSecondaryColor(
                                                    isDarkMode,
                                                  ),
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu Historique
            Expanded(
              child: _isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        // Historique Films
                        _buildHistoryListView(isDarkMode, true),
                        // Historique Séries
                        _buildHistoryListView(isDarkMode, false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryListView(bool isDarkMode, bool isMovies) {
    final historyList = isMovies ? _movieHistory : _episodeHistory;

    if (historyList.isEmpty) {
      return Center(
        child: Text(
          'Aucun élément dans l\'historique',
          style: TextStyle(
            color: AppColors.getTextSecondaryColor(isDarkMode),
            fontSize: 16,
          ),
        ),
      );
    }

    // Grouper les éléments par date (Aujourd'hui, Hier, Plus ancien)
    final List<Map<String, dynamic>> todayItems = [];
    final List<Map<String, dynamic>> yesterdayItems = [];
    final List<Map<String, dynamic>> olderItems = [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var item in historyList) {
      DateTime? watchedDate;
      if (item['lastWatchedDate'] != null) {
        watchedDate = DateTime.tryParse(item['lastWatchedDate']);
      } else if (item['lastWatchedAt'] != null) {
        watchedDate = DateTime.tryParse(item['lastWatchedAt']);
      }

      if (watchedDate == null) {
        olderItems.add(item);
        continue;
      }

      final compareDate = DateTime(watchedDate.year, watchedDate.month, watchedDate.day);
      if (compareDate == today) {
        todayItems.add(item);
      } else if (compareDate == yesterday) {
        yesterdayItems.add(item);
      } else {
        olderItems.add(item);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          if (todayItems.isNotEmpty)
            _buildHistorySection('Aujourd\'hui', todayItems, isDarkMode, isMovies),
          if (yesterdayItems.isNotEmpty)
            _buildHistorySection('Hier', yesterdayItems, isDarkMode, isMovies),
          if (olderItems.isNotEmpty)
            _buildHistorySection('Plus ancien', olderItems, isDarkMode, isMovies),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    String title,
    List<Map<String, dynamic>> items,
    bool isDarkMode,
    bool isMovies,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de la section
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 12),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Liste des éléments
        ...items.map((item) => _buildHistoryItem(item, isDarkMode, isMovies)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, bool isDarkMode, bool isMovies) {
    dynamic classicModel;
    if (isMovies) {
      final movieApi = item['movie'] as MovieApiModel?;
      if (movieApi != null) {
        classicModel = movieApi.toMovieModel();
      }
    } else {
      // Pour les épisodes, si on n'a pas enrichi, on fabrique un modèle minimal
      final episodeId = item['episodeID'] ?? item['episodeId'];
      classicModel = MovieModel(
        id: episodeId.toString(),
        title: 'Épisode $episodeId',
        imagePath: '', // fallback
        genre: 'Série',
        duration: '${item['lastWatchedPosition'] ?? 0}s',
        releaseDate: '',
        rating: 0.0,
      );
    }

    if (classicModel == null) return const SizedBox.shrink();

    return HistoryItemCard(
      item: classicModel,
      isDarkMode: isDarkMode,
      isMovies: isMovies,
      onTap: () {
        if (isMovies) {
          final movieApi = item['movie'] as MovieApiModel?;
          if (movieApi != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen.fromApiMovie(movieApi),
              ),
            );
          }
        }
      },
    );
  }
}
