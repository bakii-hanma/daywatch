import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/common/movies_grid.dart';
import '../widgets/common/series_grid.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../services/platform_service.dart';
import '../data/sample_data.dart';

class PlatformResultsScreen extends StatefulWidget {
  final String platformName;
  final String platformDisplayName;

  const PlatformResultsScreen({
    Key? key,
    required this.platformName,
    required this.platformDisplayName,
  }) : super(key: key);

  @override
  State<PlatformResultsScreen> createState() => _PlatformResultsScreenState();
}

class _PlatformResultsScreenState extends State<PlatformResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // États de chargement
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Données
  List<MovieApiModel> _movies = [];
  List<SeriesApiModel> _series = [];
  PlatformStats? _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPlatformContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlatformContent() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      print('🔍 Chargement des contenus pour: ${widget.platformName}');

      final response = await PlatformService.getPlatformContent(
        widget.platformName,
        limit: 100,
      );

      if (response.success) {
        setState(() {
          _movies = response.data.movies;
          _series = response.data.series;
          _stats = response.stats;
          _isLoading = false;
        });

        print(
          '✅ Contenus chargés: ${_movies.length} films, ${_series.length} séries',
        );
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response.message;
          _isLoading = false;
        });
        print('❌ Erreur API: ${response.message}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
      print('❌ Erreur lors du chargement: $e');
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des contenus...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPlatformContent,
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Aucun $type trouvé',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun $type n\'est disponible sur ${widget.platformDisplayName} pour le moment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.platformDisplayName,
                          style: TextStyle(
                            color: AppColors.getTextColor(isDarkMode),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_stats != null)
                          Text(
                            '${_stats!.totalContent} contenus disponibles',
                            style: TextStyle(
                              color: AppColors.getTextSecondaryColor(
                                isDarkMode,
                              ),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bouton de filtre avec nom de la plateforme
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
                            Icons.tv,
                            color: AppColors.getTextColor(isDarkMode),
                            size: 23,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.platformDisplayName,
                            style: TextStyle(
                              color: AppColors.getTextColor(isDarkMode),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          if (_stats != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.getBackgroundColor(isDarkMode),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_stats!.totalContent}',
                                style: TextStyle(
                                  color: AppColors.getTextColor(isDarkMode),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
                                      'Films (${_movies.length})',
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
                                      'Séries (${_series.length})',
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
                  ? _buildLoadingState()
                  : _hasError
                  ? _buildErrorState()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Onglet Films
                        _movies.isEmpty
                            ? _buildEmptyState('film')
                            : MoviesGrid(
                                movies: _movies
                                    .map((movie) => movie.toMovieModel())
                                    .toList(),
                                isDarkMode: isDarkMode,
                                countText: '${_movies.length} films trouvés',
                              ),
                        // Onglet Séries
                        _series.isEmpty
                            ? _buildEmptyState('série')
                            : SeriesGrid(
                                series: _series
                                    .map((series) => series.toSeriesModel())
                                    .toList(),
                                isDarkMode: isDarkMode,
                                countText: '${_series.length} séries trouvées',
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
