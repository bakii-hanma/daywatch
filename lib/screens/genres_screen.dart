import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/genres_vertical_grid.dart';

class GenresScreen extends StatelessWidget {
  const GenresScreen({Key? key}) : super(key: key);

  // Liste étendue des genres avec plus d'éléments
  static final List<GenreItem> _allGenres = [
    GenreItem(
      name: 'Action',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
    ),
    GenreItem(
      name: 'Aventure',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
    ),
    GenreItem(
      name: 'Animation',
      imagePath: 'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
    ),
    GenreItem(
      name: 'Comédie',
      imagePath: 'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
    ),
    GenreItem(
      name: 'Crime',
      imagePath: 'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
    ),
    GenreItem(
      name: 'Aventure',
      imagePath: 'assets/poster/a540bacb454d0bcc68204ff72c60210d17f9679f.jpg',
    ),
    GenreItem(
      name: 'Animation',
      imagePath: 'assets/poster/d88c27338531793104f79107f3fdf1722a0e9fdc.jpg',
    ),
    GenreItem(
      name: 'Comédie',
      imagePath: 'assets/poster/ee95c8d574be76182adb5fd79675435e550090e2.jpg',
    ),
    // Répétition pour avoir plus d'éléments
    GenreItem(
      name: 'Action',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
    ),
    GenreItem(
      name: 'Aventure',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec bouton retour et titre
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.getTextColor(isDarkMode),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Genres',
                    style: TextStyle(
                      color: AppColors.getTextColor(isDarkMode),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Grille des genres
            Expanded(
              child: GenresVerticalGrid(
                genres: _allGenres,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
