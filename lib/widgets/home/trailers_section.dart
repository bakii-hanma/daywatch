import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../widgets/common/trailer_card.dart';
import '../../screens/trailers_screen.dart';
import '../../services/api_client.dart';

class TrailersSection extends StatelessWidget {
  final List<TrailerApiModel> recentTrailers;
  final bool isDarkMode;

  const TrailersSection({
    super.key,
    required this.recentTrailers,
    required this.isDarkMode,
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
                'Bandes annonces',
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
                      builder: (context) => const TrailersScreen(),
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

        recentTrailers.isEmpty
            ? _buildNoTrailersSection(textColor)
            : SizedBox(
                height: AppSpacing.sectionHeightMedium,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: recentTrailers.length > 5 ? 5 : recentTrailers.length,
                  itemBuilder: (context, index) {
                    final trailer = recentTrailers[index];
                    return Container(
                      width: 320.0,
                      margin: EdgeInsets.only(
                        right: index < recentTrailers.length - 1 ? AppSpacing.md : 0,
                      ),
                      child: TrailerCard(
                        imagePath: trailer.fullPosterUrl.isNotEmpty
                            ? trailer.fullPosterUrl
                            : 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
                        title: trailer.title,
                        duration: trailer.duration,
                        isDarkMode: isDarkMode,
                        trailerUrl: trailer.trailerUrl,
                        onPlayTap: () {
                          print('🎬 Lecture trailer: ${trailer.title}');
                          print('🔗 URL: ${trailer.trailerUrl}');
                        },
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildNoTrailersSection(Color textColor) {
    return SizedBox(
      height: AppSpacing.sectionHeightMedium,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune bande-annonce disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez la connexion au serveur',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'IP: ${ApiClient.baseUrl}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
