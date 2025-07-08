import 'dart:async';
import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/series_grid.dart';
import '../widgets/common/genre_filter_bar.dart';
import '../models/series_model.dart';
import '../services/series_service.dart';
import '../config/server_config.dart';
import 'series_detail_screen.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({Key? key}) : super(key: key);

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  String selectedGenre = 'Tout';
  bool _isLoading = true;
  List<SeriesApiModel> _allSeries = [];
  List<String> _availableGenres = ['Tout'];

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    try {
      print('📋 Chargement de toutes les séries...');

      // Tester la connectivité d'abord
      final isConnected = await SeriesService.testConnection();

      if (!isConnected) {
        print('❌ Impossible de se connecter à l\'API Sonarr');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Charger toutes les séries avec un timeout plus long
      final series = await SeriesService.getRecentSeries(limit: 100).timeout(
        const Duration(
          seconds: 90,
        ), // Timeout de 90 secondes pour le chargement
        onTimeout: () {
          print('⏰ Timeout lors du chargement des séries');
          throw TimeoutException('Chargement des séries trop long');
        },
      );

      if (series.isNotEmpty) {
        // Extraire les genres uniques
        final allGenres = <String>{};
        for (var serie in series) {
          allGenres.addAll(serie.genres);
        }

        setState(() {
          _allSeries = series;
          // Trier les genres et ajouter "Tout" au début
          final sortedGenres = allGenres.toList()..sort();
          _availableGenres = ['Tout', ...sortedGenres];
          _isLoading = false;
        });

        print('✅ Séries chargées: ${series.length}');
        print('🎭 Genres disponibles: $_availableGenres');
      } else {
        print('⚠️ Aucune série récupérée de l\'API');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des séries: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<SeriesApiModel> get filteredSeries {
    if (selectedGenre == 'Tout') {
      return _allSeries;
    }
    return _allSeries
        .where(
          (series) => series.genres.any(
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
          Icon(Icons.tv_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune série disponible',
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
              _loadSeries();
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

  // Méthode pour tester l'enrichissement d'une série
  Future<void> _testSeriesEnrichment() async {
    if (_allSeries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune série disponible pour le test')),
      );
      return;
    }

    final testSeries = _allSeries.first;
    print('🧪 Test d\'enrichissement pour la série: ${testSeries.title}');

    try {
      final enrichedSeries =
          await SeriesService.enrichSeriesWithEpisodes(
            series: testSeries,
          ).timeout(
            const Duration(seconds: 120), // Timeout de 2 minutes pour le test
            onTimeout: () {
              print('⏰ Timeout lors du test d\'enrichissement');
              throw TimeoutException('Test d\'enrichissement trop long');
            },
          );

      if (enrichedSeries != null) {
        final totalEpisodes = enrichedSeries.episodesBySeason.values.fold(
          0,
          (sum, episodes) => sum + episodes.length,
        );

        print('✅ Test réussi: ${totalEpisodes} épisodes récupérés');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Test réussi: ${totalEpisodes} épisodes récupérés pour ${enrichedSeries.title}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Test échoué: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test échoué: $e'), backgroundColor: Colors.red),
      );
    }
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
                    'Séries',
                    style: TextStyle(
                      color: AppColors.getTextColor(isDarkMode),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Bouton de test pour l'enrichissement
                  if (_allSeries.isNotEmpty)
                    IconButton(
                      onPressed: _testSeriesEnrichment,
                      icon: const Icon(Icons.science, color: Colors.red),
                      tooltip: 'Tester l\'enrichissement des épisodes',
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
                            'Chargement des séries...',
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
                  : _allSeries.isEmpty
                  ? _buildEmptyState()
                  : SeriesGrid.api(
                      apiSeries: filteredSeries,
                      isDarkMode: isDarkMode,
                      countText: '${filteredSeries.length} séries trouvées',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
