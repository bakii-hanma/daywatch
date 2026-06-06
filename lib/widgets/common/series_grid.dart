import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../models/movie_model.dart';
import '../../models/series_model.dart';
import '../../screens/series_detail_screen.dart';
import 'series_card.dart';

class SeriesGrid extends StatelessWidget {
  final List<SeriesModel>? series;
  final List<SeriesApiModel>? apiSeries;
  final bool isDarkMode;
  final String countText;
  final Function(SeriesModel)? onSeriesTap;
  final Function(SeriesApiModel)? onApiSeriesTap;

  const SeriesGrid({
    super.key,
    required this.series,
    required this.isDarkMode,
    required this.countText,
    this.onSeriesTap,
  }) : apiSeries = null,
       onApiSeriesTap = null;

  const SeriesGrid.api({
    super.key,
    required this.apiSeries,
    required this.isDarkMode,
    required this.countText,
    this.onApiSeriesTap,
  }) : series = null,
       onSeriesTap = null;

  @override
  Widget build(BuildContext context) {
    final int itemCount = series?.length ?? apiSeries?.length ?? 0;
    final bool isApiMode = apiSeries != null;

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
                  text: '$itemCount',
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
              childAspectRatio: 150 / 290, // 150px width / 290px height
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (isApiMode) {
                // Mode API - utiliser SeriesApiModel
                final SeriesApiModel apiSerie = apiSeries![index];

                // Debug série API
                print('🎬 Affichage série API: ${apiSerie.title}');

                return SizedBox(
                  width: 150,
                  height: 290,
                  child: SeriesCard.fromApiModel(
                    series: apiSerie,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      print('🎬 Clic sur série: ${apiSerie.title}');
                      if (onApiSeriesTap != null) {
                        print('   ↗️ Appel de onApiSeriesTap callback');
                        onApiSeriesTap!(apiSerie);
                      } else {
                        print(
                          '   🚀 Navigation automatique vers page détails série',
                        );
                        try {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SeriesDetailScreen.fromApiSeries(
                                    apiSeries: apiSerie,
                                  ),
                            ),
                          );
                        } catch (e) {
                          print('❌ Erreur navigation: $e');
                        }
                      }
                    },
                    onFavoriteTap: () {
                      print('⭐ Ajouté aux favoris: ${apiSerie.title}');
                    },
                  ),
                );
              } else {
                // Mode normal - utiliser SeriesModel
                final SeriesModel singleSeries = series![index];
                return SizedBox(
                  width: 150,
                  height: 290,
                  child: SeriesCard.fromModel(
                    series: singleSeries,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      print(
                        '🎬 Clic sur série classique: ${singleSeries.title}',
                      );
                      if (onSeriesTap != null) {
                        print('   ↗️ Appel de onSeriesTap callback');
                        onSeriesTap!(singleSeries);
                      } else {
                        print('   🚀 Navigation vers SeriesDetailScreen');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SeriesDetailScreen(series: singleSeries),
                          ),
                        );
                      }
                    },
                    onFavoriteTap: () {
                      print('⭐ Ajouté aux favoris: ${singleSeries.title}');
                    },
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
