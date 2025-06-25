import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/series_grid.dart';
import '../widgets/common/genre_filter_bar.dart';
import '../models/movie_model.dart';
import '../data/sample_data.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({Key? key}) : super(key: key);

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  String selectedGenre = 'Tout';

  final List<String> genres = [
    'Tout',
    'Action',
    'Aventure',
    'Animation',
    'Comédie',
    'Drame',
    'Horreur',
    'Romance',
  ];

  List<SeriesModel> get filteredSeries {
    if (selectedGenre == 'Tout') {
      return SampleData.popularSeries;
    }
    return SampleData.popularSeries
        .where(
          (series) =>
              series.genre.toLowerCase().contains(selectedGenre.toLowerCase()),
        )
        .toList();
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
                ],
              ),
            ),

            // Filtres par genre
            GenreFilterBar(
              genres: genres,
              selectedGenre: selectedGenre,
              onGenreSelected: (genre) {
                setState(() {
                  selectedGenre = genre;
                });
              },
            ),

            // Grille des séries
            Expanded(
              child: SeriesGrid(
                series: filteredSeries,
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
