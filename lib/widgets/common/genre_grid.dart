import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';

class GenreItem {
  final String name;
  final String imagePath;
  final VoidCallback? onTap;

  GenreItem({required this.name, required this.imagePath, this.onTap});
}

class GenreGrid extends StatelessWidget {
  final List<GenreItem> genres;
  final bool isDarkMode;
  final String title;
  final VoidCallback? onSeeAllTap;

  const GenreGrid({
    Key? key,
    required this.genres,
    required this.isDarkMode,
    this.title = 'Genres',
    this.onSeeAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec titre et "Voir +"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.title(AppColors.getTextColor(isDarkMode)),
            ),
            if (onSeeAllTap != null)
              TextButton(
                onPressed: onSeeAllTap,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
                child: Text(
                  'Voir +',
                  style: AppTypography.caption(
                    AppColors.primary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Grille des genres (2 colonnes)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
          ),
          itemCount: genres.length > 4
              ? 4
              : genres.length, // Limite à 4 éléments
          itemBuilder: (context, index) {
            final genre = genres[index];
            return GestureDetector(
              onTap: genre.onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getBackgroundColor(
                        isDarkMode,
                      ).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image de fond
                      Image.asset(genre.imagePath, fit: BoxFit.cover),

                      // Overlay sombre
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.darkModeOverlay(0.7),
                            ],
                          ),
                        ),
                      ),

                      // Texte du genre
                      Positioned(
                        bottom: AppSpacing.sm,
                        left: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Text(
                          genre.name,
                          style: AppTypography.bodySemiBold(AppColors.white),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
