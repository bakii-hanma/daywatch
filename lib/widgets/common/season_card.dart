import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../models/movie_model.dart';
import '../../screens/season_detail_screen.dart';
import '../../data/sample_data.dart';

class SeasonCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String episodes;
  final String year;
  final double rating;
  final String description;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const SeasonCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.episodes,
    required this.year,
    required this.rating,
    required this.description,
    required this.isDarkMode,
    this.onTap,
  }) : super(key: key);

  Widget _buildImage() {
    // Toujours utiliser Image.network car les images viennent maintenant de l'API
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.tv, size: 40, color: Colors.grey),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          onTap ??
          () {
            // Navigation automatique vers la page de détails de saison
            final seasonModel = SeasonModel(
              id: '1',
              title: title,
              imagePath: imagePath,
              episodes: episodes,
              year: year,
              rating: rating,
              description: description,
              episodesList: SampleData.lokiSeason1Episodes,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeasonDetailScreen(season: seasonModel),
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2E2828) : const Color(0xFFE0D9D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la saison
            Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(),
              ),
            ),

            const SizedBox(width: 8),

            // Informations de la saison
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de la saison
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.getTextColor(isDarkMode),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Informations (épisodes, année, note)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          episodes,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          year,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toString(),
                              style: TextStyle(
                                color: isDarkMode ? Colors.black : Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
