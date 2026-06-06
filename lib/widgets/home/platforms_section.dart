import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../screens/platform_results_screen.dart';

class PlatformsSection extends StatelessWidget {
  final bool isDarkMode;

  const PlatformsSection({
    super.key,
    required this.isDarkMode,
  });

  String _getPlatformApiName(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'netflix':
        return 'netflix';
      case 'prime video':
        return 'prime';
      case 'disney+':
        return 'disney';
      case 'apple tv+':
        return 'apple';
      default:
        return displayName
            .toLowerCase()
            .replaceAll(' ', '')
            .replaceAll('+', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plateformes',
                style: AppTypography.header(
                  AppColors.getTextColor(isDarkMode),
                ),
              ),
              Text(
                'Voir +',
                style: AppTypography.linkText(AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Grille des plateformes (3x2)
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: SampleData.platforms.length,
            itemBuilder: (context, index) {
              final platform = SampleData.platforms[index];
              return GestureDetector(
                onTap: () {
                  // Navigation vers la page de résultats par plateforme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlatformResultsScreen(
                        platformName: _getPlatformApiName(platform.name),
                        platformDisplayName: platform.name,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.getWidgetBackgroundColor(isDarkMode),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackOverlay(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    child: Image.asset(
                      platform.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
