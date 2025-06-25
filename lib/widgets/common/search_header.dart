import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../screens/active_search_screen.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String hintText;
  final bool isDarkMode;
  final VoidCallback? onSearchChanged;
  final Function(String)? onSearchActivated;

  const SearchHeader({
    Key? key,
    required this.searchController,
    this.hintText = 'Entrez votre recherche',
    required this.isDarkMode,
    this.onSearchChanged,
    this.onSearchActivated,
  }) : super(key: key);

  void _navigateToActiveSearch(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ActiveSearchScreen(onSearchActivated: onSearchActivated),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Espace en haut
        const SizedBox(height: AppSpacing.xxxl),

        // Titre "RECHERCHE"
        Text(
          'RECHERCHE',
          style: AppTypography.header(AppColors.getTextColor(isDarkMode)),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // Bouton de recherche
        InkWell(
          onTap: () => _navigateToActiveSearch(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.getButtonColor(isDarkMode),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu,
                  color: AppColors.getTextColor(isDarkMode),
                  size: 23,
                ),
                const SizedBox(width: 12),
                Text(
                  hintText,
                  style: TextStyle(
                    color: AppColors.getTextColor(isDarkMode),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
