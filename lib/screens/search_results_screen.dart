import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/movies_grid.dart';
import '../widgets/common/series_grid.dart';
import '../widgets/common/actors_grid.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../services/search_service.dart';
import 'actor_detail_screen.dart';
import 'movie_detail_screen.dart';
import 'series_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MovieApiModel> _searchResultsMovies = [];
  List<SeriesApiModel> _searchResultsSeries = [];
  List<ActorModel> _searchResultsActors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _performSearch();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await SearchService.search(widget.searchQuery);
      if (mounted) {
        setState(() {
          _searchResultsMovies = results.movies;
          _searchResultsSeries = [...results.series, ...results.animes];
          _searchResultsActors = results.actors.map((actor) => actor.toActorModel()).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResultsMovies = [];
          _searchResultsSeries = [];
          _searchResultsActors = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                            widget.searchQuery,
                            style: TextStyle(
                              color: AppColors.getTextColor(isDarkMode),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => Navigator.pop(context),
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
                            child: GestureDetector(
                              onTap: () => _tabController.animateTo(0),
                              child: AnimatedBuilder(
                                animation: _tabController,
                                builder: (context, child) {
                                  final isSelected = _tabController.index == 0;
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
                                            ? AppColors.getTextColor(isDarkMode)
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
                            ),
                          ),
                          // Onglet Séries
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _tabController.animateTo(1),
                              child: AnimatedBuilder(
                                animation: _tabController,
                                builder: (context, child) {
                                  final isSelected = _tabController.index == 1;
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
                                            ? AppColors.getTextColor(isDarkMode)
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
                            ),
                          ),
                          // Onglet Acteurs
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _tabController.animateTo(2),
                              child: AnimatedBuilder(
                                animation: _tabController,
                                builder: (context, child) {
                                  final isSelected = _tabController.index == 2;
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
                                      'Acteurs',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.getTextColor(isDarkMode)
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu des onglets
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Onglet Films
                        MoviesGrid.api(
                          apiMovies: _searchResultsMovies,
                          isDarkMode: isDarkMode,
                          countText: '${_searchResultsMovies.length} films trouvés',
                          onApiMovieTap: (movie) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailScreen.fromApiMovie(movie),
                              ),
                            );
                          },
                        ),
                        // Onglet Séries
                        SeriesGrid.api(
                          apiSeries: _searchResultsSeries,
                          isDarkMode: isDarkMode,
                          countText: '${_searchResultsSeries.length} séries trouvées',
                          onApiSeriesTap: (series) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SeriesDetailScreen.fromApiSeries(apiSeries: series),
                              ),
                            );
                          },
                        ),
                        // Onglet Acteurs
                        ActorsGrid(
                          actors: _searchResultsActors,
                          isDarkMode: isDarkMode,
                          countText: '${_searchResultsActors.length} acteurs trouvés',
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
    );
  }
}
