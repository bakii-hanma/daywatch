import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../widgets/common/movies_grid.dart';
import '../widgets/common/series_grid.dart';
import '../widgets/common/history_item_card.dart';
import '../widgets/common/download_item_card.dart';
import '../widgets/common/marquee_text.dart';
import '../models/movie_model.dart';
import '../data/sample_data.dart';
import 'movie_detail_screen.dart';
import 'downloads_screen.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({Key? key}) : super(key: key);

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
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
      child: Column(
        children: [
          // Sub Tab Bar (Films, Séries) comme dans search_results_screen.dart
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
                                  animation: DefaultTabController.of(context)!,
                                  builder: (context, child) {
                                    final tabController =
                                        DefaultTabController.of(context)!;
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
                                  animation: DefaultTabController.of(context)!,
                                  builder: (context, child) {
                                    final tabController =
                                        DefaultTabController.of(context)!;
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
            child: TabBarView(
              children: [
                // Films favoris
                MoviesGrid(
                  movies: SampleData.popularMovies.take(8).toList(),
                  isDarkMode: isDarkMode,
                  countText:
                      '${SampleData.popularMovies.take(8).length} films favoris',
                  onMovieTap: (movie) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                ),
                // Séries favorites
                SeriesGrid(
                  series: SampleData.popularSeries.take(8).toList(),
                  isDarkMode: isDarkMode,
                  countText:
                      '${SampleData.popularSeries.take(8).length} séries favorites',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsTab(bool isDarkMode) {
    return DefaultTabController(
      length: 2,
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
                _buildStorageInfo('Films', '1.9 GB', '6 éléments', isDarkMode),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.getTextSecondaryColor(
                    isDarkMode,
                  ).withOpacity(0.3),
                ),
                _buildStorageInfo('Séries', '0.9 GB', '4 éléments', isDarkMode),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.getTextSecondaryColor(
                    isDarkMode,
                  ).withOpacity(0.3),
                ),
                _buildStorageInfo('Total', '2.8 GB', '10 éléments', isDarkMode),
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
                                  animation: DefaultTabController.of(context)!,
                                  builder: (context, child) {
                                    final tabController =
                                        DefaultTabController.of(context)!;
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
                                  animation: DefaultTabController.of(context)!,
                                  builder: (context, child) {
                                    final tabController =
                                        DefaultTabController.of(context)!;
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
            child: TabBarView(
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
    final items = isMovies
        ? SampleData.popularMovies.take(6).toList()
        : SampleData.popularSeries.take(4).toList();

    if (items.isEmpty) {
      return _buildDownloadsEmptyState(isDarkMode, isMovies);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return DownloadItemCard(
            item: item,
            isDarkMode: isDarkMode,
            isMovies: isMovies,
            onTap: () {
              if (isMovies) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MovieDetailScreen(movie: item as MovieModel),
                  ),
                );
              }
            },
            onDeleteTap: () =>
                _showDeleteDownloadDialog((item as dynamic).title),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DownloadsScreen(),
                ),
              );
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

  void _showDeleteDownloadDialog(String title) {
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
            onPressed: () {
              Navigator.pop(context);
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
                                  animation: DefaultTabController.of(context)!,
                                  builder: (context, child) {
                                    final tabController =
                                        DefaultTabController.of(context)!;
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
                                  animation: DefaultTabController.of(context)!,
                                  builder: (context, child) {
                                    final tabController =
                                        DefaultTabController.of(context)!;
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

          // Contenu Historique Films/Séries - Liste verticale comme dans l'image
          Expanded(
            child: TabBarView(
              children: [
                // Historique Films - Vue liste verticale
                _buildHistoryListView(isDarkMode, true),
                // Historique Séries - Vue liste verticale
                _buildHistoryListView(isDarkMode, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryListView(bool isDarkMode, bool isMovies) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          // Section Aujourd'hui
          _buildHistorySection(
            'Aujourd\'hui',
            isMovies
                ? SampleData.popularMovies.take(2).toList()
                : SampleData.popularSeries.take(2).toList(),
            isDarkMode,
            isMovies,
          ),
          const SizedBox(height: 24),

          // Section Hier
          _buildHistorySection(
            'Hier',
            isMovies
                ? SampleData.popularMovies.skip(2).take(2).toList()
                : SampleData.popularSeries.skip(2).take(2).toList(),
            isDarkMode,
            isMovies,
          ),
          const SizedBox(height: 24),

          // Section Il y a 2 jours
          _buildHistorySection(
            'Il y a 2 jours',
            isMovies
                ? SampleData.popularMovies.skip(4).take(2).toList()
                : SampleData.popularSeries.skip(4).take(2).toList(),
            isDarkMode,
            isMovies,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    String title,
    List<dynamic> items,
    bool isDarkMode,
    bool isMovies,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de la section
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
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
        ...items
            .map((item) => _buildHistoryItem(item, isDarkMode, isMovies))
            .toList(),
      ],
    );
  }

  Widget _buildHistoryItem(dynamic item, bool isDarkMode, bool isMovies) {
    return HistoryItemCard(
      item: item,
      isDarkMode: isDarkMode,
      isMovies: isMovies,
    );
  }
}
