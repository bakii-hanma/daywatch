import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';

class GenreItem {
  final String name;
  final String imagePath;

  const GenreItem({required this.name, required this.imagePath});
}

class GenresVerticalGrid extends StatelessWidget {
  final List<GenreItem> genres;
  final bool isDarkMode;

  const GenresVerticalGrid({
    Key? key,
    required this.genres,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4, // Rectangle horizontal
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return _buildGenreCard(genre);
      },
    );
  }

  Widget _buildGenreCard(GenreItem genre) {
    return Container(
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
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Texte du genre
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: _buildGenreText(genre.name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreText(String genreName) {
    if (isDarkMode) {
      // Mode sombre : avec container semi-transparent qui épouse le texte
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            genreName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      // Mode clair : texte simple avec ombres
      return Text(
        genreName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}
