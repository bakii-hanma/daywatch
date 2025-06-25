import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeMore;
  final VoidCallback? onSeeMoreTap;
  final bool isDarkMode;

  const SectionHeader({
    Key? key,
    required this.title,
    this.showSeeMore = true,
    this.onSeeMoreTap,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.title(AppColors.getTextColor(isDarkMode)),
        ),
        if (showSeeMore)
          GestureDetector(
            onTap: onSeeMoreTap,
            child: Text(
              'Voir +',
              style: AppTypography.linkText(AppColors.primary),
            ),
          ),
      ],
    );
  }
}
