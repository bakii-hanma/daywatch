import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';

class ActorCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const ActorCard({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.isDarkMode,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
            child: Container(
              width: 170,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.greyOverlay(0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
              ),
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      width: 170,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 170,
                          height: 130,
                          color: AppColors.greyOverlay(0.3),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.getTextSecondaryColor(isDarkMode),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      imagePath,
                      width: 170,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            name,
            style: AppTypography.bodySemiBold(
              AppColors.getTextColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
