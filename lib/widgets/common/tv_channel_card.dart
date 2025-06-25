import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';

class TvChannelCard extends StatelessWidget {
  final String channelName;
  final String program;
  final VoidCallback? onTap;

  const TvChannelCard({
    Key? key,
    required this.channelName,
    required this.program,
    this.onTap,
  }) : super(key: key);

  // Images pour simuler les logos de chaînes TV
  String _getChannelImage(String channelName) {
    const Map<String, String> channelImages = {
      'TF1': 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      'France 2': 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
      'Canal+': 'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
      'M6': 'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
      'Arte': 'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
      'France 3': 'assets/poster/a540bacb454d0bcc68204ff72c60210d17f9679f.jpg',
      'RMC Sport': 'assets/poster/d88c27338531793104f79107f3fdf1722a0e9fdc.jpg',
      'Eurosport': 'assets/poster/ee95c8d574be76182adb5fd79675435e550090e2.jpg',
    };
    return channelImages[channelName] ??
        'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getWidgetBackgroundColor(isDarkMode),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOverlay(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badges (exactement comme MovieCard)
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: Stack(
                  children: [
                    Image.asset(
                      _getChannelImage(channelName),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // Badge "EN DIRECT" en haut à gauche (même style que la note dans MovieCard)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSmall,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'DIRECT',
                              style: AppTypography.small(AppColors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Icône favoris en haut à droite (même position que MovieCard)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: GestureDetector(
                        onTap: () {
                          // Action d'ajout aux favoris
                        },
                        child: const Icon(
                          Icons.bookmark,
                          color: AppColors.primary,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Informations de la chaîne (exactement comme MovieCard)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.getWidgetBackgroundColor(isDarkMode),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusMedium),
                    bottomRight: Radius.circular(AppSpacing.radiusMedium),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channelName,
                      style: AppTypography.bodySemiBold(
                        AppColors.getTextColor(isDarkMode),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'TV • Direct',
                      style: AppTypography.caption(
                        AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Badge programme (même style que les badges dans MovieCard)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greyOverlay(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'En cours',
                        style: AppTypography.small(
                          AppColors.getTextSecondaryColor(isDarkMode),
                        ),
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
}
