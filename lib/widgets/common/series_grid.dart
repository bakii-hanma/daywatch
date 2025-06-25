import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../models/movie_model.dart';
import '../../screens/series_detail_screen.dart';
import 'movie_card.dart';

class SeriesGrid extends StatelessWidget {
  final List<SeriesModel> series;
  final bool isDarkMode;
  final String countText;
  final Function(SeriesModel)? onSeriesTap;

  const SeriesGrid({
    Key? key,
    required this.series,
    required this.isDarkMode,
    required this.countText,
    this.onSeriesTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${series.length}',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' séries trouvées',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 150 / 350, // 150px width / 350px height
            ),
            itemCount: series.length,
            itemBuilder: (context, index) {
              final singleSeries = series[index];
              return SizedBox(
                width: 150,
                height: 350,
                child: MovieCard(
                  imagePath: singleSeries.imagePath,
                  title: singleSeries.title,
                  genre: singleSeries.genre,
                  duration: singleSeries.seasons,
                  releaseDate: singleSeries.years,
                  rating: singleSeries.rating,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    if (onSeriesTap != null) {
                      onSeriesTap!(singleSeries);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SeriesDetailScreen(series: singleSeries),
                        ),
                      );
                    }
                  },
                  onFavoriteTap: () {
                    // Ajouter aux favoris
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
