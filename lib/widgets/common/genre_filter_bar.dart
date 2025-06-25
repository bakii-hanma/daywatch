import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

class GenreFilterBar extends StatelessWidget {
  final List<String> genres;
  final String selectedGenre;
  final Function(String) onGenreSelected;

  const GenreFilterBar({
    Key? key,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 40, // Réduit de 50 à 40
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre;

          return Container(
            margin: const EdgeInsets.only(right: 10), // Réduit de 12 à 10
            child: GestureDetector(
              onTap: () => onGenreSelected(genre),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, // Réduit de 20 à 16
                  vertical: 8, // Réduit de 12 à 8
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.getButtonColor(isDarkMode),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  genre,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.getTextColor(isDarkMode),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
