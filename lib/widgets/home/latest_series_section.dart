import 'package:flutter/material.dart';
import '../../models/series_model.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../widgets/common/series_card.dart';
import '../../screens/series_screen.dart';
import '../../screens/series_detail_screen.dart';

class LatestSeriesSection extends StatelessWidget {
  final List<SeriesApiModel> latestSeries;
  final bool isDarkMode;
  final Set<String> favoriteSeriesIds;
  final Function(SeriesApiModel series)? onFavoriteTap;

  const LatestSeriesSection({
    super.key,
    required this.latestSeries,
    required this.isDarkMode,
    required this.favoriteSeriesIds,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppColors.white : AppColors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dernières séries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeriesScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Voir +',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        latestSeries.isEmpty
            ? SizedBox(
                height: 290,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.tv_off,
                        size: 48,
                        color: textColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune série disponible',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 290,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: latestSeries.length,
                  itemBuilder: (context, index) {
                    final series = latestSeries[index];
                    final isFav = favoriteSeriesIds.contains(series.id);
                    return Container(
                      width: AppSpacing.cardWidthLarge,
                      margin: EdgeInsets.only(
                        right: index < latestSeries.length - 1
                            ? AppSpacing.md
                            : 0,
                      ),
                      child: SeriesCard.fromApiModel(
                        series: series,
                        isDarkMode: isDarkMode,
                        isFavorite: isFav,
                        onTap: () {
                          print(
                            '🎬 Navigation vers dernière série: ${series.title}',
                          );
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SeriesDetailScreen.fromApiSeries(
                                      apiSeries: series,
                                    ),
                              ),
                            );
                          } catch (e) {
                            print('❌ Erreur navigation dernière série: $e');
                          }
                        },
                        onFavoriteTap: onFavoriteTap != null ? () => onFavoriteTap!(series) : null,
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
