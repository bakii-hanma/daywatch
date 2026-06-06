import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../design_system/colors.dart';
import '../../screens/movie_detail_screen.dart';

class HeaderSlider extends StatelessWidget {
  final List<MovieApiModel> recentMovies;
  final PageController pageController;
  final int currentSliderIndex;
  final ValueChanged<int> onPageChanged;
  final bool isDarkMode;

  static String _formatDuration(int runtime) {
    if (runtime <= 0) return 'Non défini';
    if (runtime < 60) return '${runtime}min';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return minutes > 0 ? '${hours}h${minutes}min' : '${hours}h';
  }

  const HeaderSlider({
    super.key,
    required this.recentMovies,
    required this.pageController,
    required this.currentSliderIndex,
    required this.onPageChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (recentMovies.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 64,
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucun film récent disponible',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifiez votre connexion WiFi',
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

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: pageController,
            itemCount: recentMovies.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final movie = recentMovies[index];
              final hasBackdrop = movie.images.backdrop != null && movie.images.backdrop!.isNotEmpty;
              final hasPoster = movie.images.poster != null && movie.images.poster!.isNotEmpty;
              final imageUrl = hasBackdrop ? movie.images.backdrop! : (hasPoster ? movie.images.poster! : '');
              final isNetwork = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

              Widget imageWidget;
              if (imageUrl.isEmpty) {
                imageWidget = Container(
                  color: AppColors.textSecondaryLight,
                  child: const Icon(
                    Icons.movie,
                    color: AppColors.white,
                    size: 100,
                  ),
                );
              } else if (isNetwork) {
                imageWidget = Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.textSecondaryLight,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.white,
                        size: 100,
                      ),
                    );
                  },
                );
              } else {
                imageWidget = Image.asset(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.textSecondaryLight,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.white,
                        size: 100,
                      ),
                    );
                  },
                );
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailScreen.fromApiMovie(movie),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    imageWidget,
                    // Overlay dégradé seulement en bas (plus sombre)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 90,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              isDarkMode
                                  ? AppColors.darkModeOverlay(0.7)
                                  : AppColors.blackOverlay(0.7),
                              isDarkMode
                                  ? AppColors.darkModeOverlay(0.95)
                                  : AppColors.blackOverlay(0.95),
                            ],
                            stops: const [0.0, 0.2, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Bouton play en face des informations
                    Positioned(
                      bottom: 25,
                      right: 16,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.red : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: isDarkMode ? Colors.white : Colors.red,
                          size: 24,
                        ),
                      ),
                    ),
                    // Informations du film en bas à gauche
                    Positioned(
                      bottom: 30,
                      left: 16,
                      right: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Durée dans cadre gris
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatDuration(movie.runtime),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Date dans cadre gris
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  movie.year.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Note dans cadre blanc
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      movie.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Indicateurs de progression À L'EXTÉRIEUR
        Container(
          padding: const EdgeInsets.only(
            left: 12,
            top: 4,
            bottom: 8,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(recentMovies.length, (dotIndex) {
              return Container(
                width: dotIndex == currentSliderIndex ? 40 : 14,
                height: 12,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: dotIndex == currentSliderIndex
                      ? Colors.red
                      : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
