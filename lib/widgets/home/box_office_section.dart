import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../widgets/common/box_office_card.dart';
import '../../screens/movie_detail_screen.dart';

class BoxOfficeSection extends StatelessWidget {
  final List<MovieApiModel> boxOfficeMovies;
  final bool isDarkMode;

  const BoxOfficeSection({
    super.key,
    required this.boxOfficeMovies,
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
                'Box office',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigation vers page box office complète si nécessaire
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

        boxOfficeMovies.isEmpty
            ? _buildNoBoxOfficeSection(textColor)
            : SizedBox(
                height: 300.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: boxOfficeMovies.length > 5 ? 5 : boxOfficeMovies.length,
                  itemBuilder: (context, index) {
                    final movie = boxOfficeMovies[index];
                    final boxOfficeModel = movie.toBoxOfficeModel();
                    return Container(
                      width: 300.0,
                      margin: EdgeInsets.only(
                        right: index < boxOfficeMovies.length - 1 ? AppSpacing.md : 0,
                      ),
                      child: BoxOfficeCard(
                        imagePath: boxOfficeModel.imagePath,
                        title: boxOfficeModel.title,
                        earnings: boxOfficeModel.earnings,
                        duration: boxOfficeModel.duration,
                        releaseDate: boxOfficeModel.releaseDate,
                        rating: boxOfficeModel.rating,
                        rank: boxOfficeModel.rank,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          print('💰 Navigation vers film box office: ${movie.title}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen.fromApiMovie(movie),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildNoBoxOfficeSection(Color textColor) {
    return SizedBox(
      height: 300.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money_outlined,
              size: 64,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun film du box office disponible',
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
          ],
        ),
      ),
    );
  }
}
