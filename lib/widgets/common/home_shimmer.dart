import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';

class HomeShimmer extends StatelessWidget {
  final bool isDarkMode;

  const HomeShimmer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500), // Animation plus lente
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer pour le slider principal (plus petit)
            Container(
              height: 200, // Réduit de 250 à 200
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Shimmer pour les films populaires (simplifié)
            _buildSimpleSectionShimmer(),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Shimmer pour les séries populaires (simplifié)
            _buildSimpleSectionShimmer(),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Shimmer pour les acteurs (simplifié)
            _buildSimpleSectionShimmer(),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Shimmer pour les trailers (simplifié)
            _buildSimpleTrailersShimmer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleSectionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section (plus petit)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 16, // Réduit de 20 à 16
                width: 120, // Réduit de 150 à 120
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 14, // Réduit de 16 à 14
                width: 50, // Réduit de 60 à 50
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md), // Réduit de lg à md
        // Liste horizontale (moins d'éléments)
        SizedBox(
          height: AppSpacing.sectionHeightLarge, // Réduit de XLarge à Large
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: 3, // Réduit de 5 à 3
            itemBuilder: (context, index) {
              return Container(
                width: 140.0, // Largeur fixe pour le shimmer
                margin: EdgeInsets.only(right: index < 2 ? AppSpacing.lg : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image (plus petite)
                    Container(
                      height: 100, // Réduit de 120 à 100
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6), // Réduit de 8 à 6
                    // Titre (plus petit)
                    Container(
                      height: 12, // Réduit de 14 à 12
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 3), // Réduit de 4 à 3
                    // Métadonnées (plus petit)
                    Container(
                      height: 10, // Réduit de 12 à 10
                      width: 60, // Réduit de 80 à 60
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTrailersShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête (plus petit)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 16, // Réduit de 20 à 16
                width: 100, // Réduit de 120 à 100
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 14, // Réduit de 16 à 14
                width: 50, // Réduit de 60 à 50
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md), // Réduit de lg à md
        // Grille de trailers (moins d'éléments)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 2, // Réduit de 4 à 2
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image (plus petite)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6), // Réduit de 8 à 6
                  // Titre (plus petit)
                  Container(
                    height: 12, // Réduit de 14 à 12
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
