import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../models/series_model.dart';
import '../../screens/episode_player_screen.dart';
import '../../config/server_config.dart';

class EpisodeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String duration;
  final String description;
  final int episodeNumber;
  final double rating;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final EpisodeApiModel? episode; // Nouveau paramètre pour l'épisode API

  const EpisodeCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.duration,
    required this.description,
    required this.episodeNumber,
    required this.rating,
    required this.isDarkMode,
    this.onTap,
    this.episode, // Nouveau paramètre optionnel
  }) : super(key: key);

  // Constructeur pour les épisodes API
  EpisodeCard.fromApi({
    Key? key,
    required this.episode,
    required this.isDarkMode,
  }) : imagePath = episode!.getMainImage(),
       title = episode!.title,
       duration = '${episode!.runtime} min',
       description = episode!.overview,
       episodeNumber = episode!.episodeNumber,
       rating = episode!.rating,
       onTap = null,
       super(key: key);

  void _launchEpisodePlayer(BuildContext context) {
    if (episode == null || episode!.file == null) {
      // Afficher un message d'erreur si l'épisode n'est pas disponible
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Épisode non disponible pour la lecture'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fileInfo = episode!.file!;
    print('🎬 Lancement de l\'épisode: ${episode!.title}');
    print('📁 Fichier: ${fileInfo.fileName}');
    print('📂 Chemin: ${fileInfo.fullPath}');

    // Naviguer vers le lecteur d'épisode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EpisodePlayerScreen(episode: episode!),
      ),
    );
  }

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
      onTap: episode != null ? () => _launchEpisodePlayer(context) : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'épisode en pleine largeur
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(),
                  ),
                ),

                // Gradient overlay
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Numéro d'épisode en haut à gauche
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Episode $episodeNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Badges durée et note en haut à droite
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Qualité du fichier en bas à droite (si disponible)
                if (episode?.file != null)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        episode!.file!.quality.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Titre en bas à gauche
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: episode?.file != null ? 80 : 12,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Icône play au centre
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Titre de l'épisode
            Text(
              title,
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Description complète
            Text(
              description,
              style: TextStyle(
                color: AppColors.getTextSecondaryColor(isDarkMode),
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            // Informations supplémentaires pour les épisodes API
            if (episode?.file != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.hd, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${episode!.file!.quality.resolution}p • ${episode!.file!.sizeGB.toStringAsFixed(2)}GB',
                    style: TextStyle(
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
