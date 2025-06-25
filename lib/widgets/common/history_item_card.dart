import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import 'marquee_text.dart';

class HistoryItemCard extends StatelessWidget {
  final dynamic item;
  final bool isDarkMode;
  final bool isMovies;
  final VoidCallback? onTap;

  const HistoryItemCard({
    Key? key,
    required this.item,
    required this.isDarkMode,
    required this.isMovies,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.getWidgetBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Image du film/série - côté gauche, plus longue et arrondie de partout
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.imagePath,
                width: 120,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(isDarkMode),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.movie,
                      color: AppColors.getTextColor(
                        isDarkMode,
                      ).withOpacity(0.5),
                      size: 40,
                    ),
                  );
                },
              ),
            ),

            // Informations à droite
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre avec animation marquee
                    MarqueeText(
                      text: item.title,
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      animationDuration: const Duration(milliseconds: 4000),
                      pauseDuration: const Duration(milliseconds: 1500),
                    ),

                    const SizedBox(height: 4),

                    // Note et autres infos
                    Row(
                      children: [
                        // Badge note
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.getTextSecondaryColor(
                              isDarkMode,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '⭐ ${item.rating}',
                                style: TextStyle(
                                  color: AppColors.getTextColor(isDarkMode),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Autres badges
                        if (isMovies) ...[
                          _buildInfoBadge('HD', isDarkMode),
                          const SizedBox(width: 4),
                          _buildInfoBadge('VF', isDarkMode),
                        ] else ...[
                          _buildInfoBadge('S1E5', isDarkMode),
                          const SizedBox(width: 4),
                          _buildInfoBadge('HD', isDarkMode),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Genre et durée avec animation marquee
                    MarqueeText(
                      text: isMovies
                          ? '${item.genre} • ${item.duration}'
                          : '${item.genre} • ${item.seasons}',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 12,
                      ),
                      animationDuration: const Duration(milliseconds: 3500),
                      pauseDuration: const Duration(milliseconds: 1200),
                    ),

                    const SizedBox(height: 6),

                    // Date
                    Text(
                      '12 septembre 2023',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      '100%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.getTextColor(isDarkMode),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
