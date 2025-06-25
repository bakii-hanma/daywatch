import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/common/genre_filter_bar.dart';
import '../widgets/common/replay_card.dart';

class ReplaysScreen extends StatefulWidget {
  const ReplaysScreen({Key? key}) : super(key: key);

  @override
  State<ReplaysScreen> createState() => _ReplaysScreenState();
}

class _ReplaysScreenState extends State<ReplaysScreen> {
  String selectedCategory = 'Tous';

  final List<String> categories = [
    'Tous',
    'Football',
    'Basketball',
    'Tennis',
    'Formule 1',
    'Rugby',
    'Documentaires',
  ];

  final List<String> posterImages = [
    'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
    'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
    'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
    'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
    'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
    'assets/poster/a540bacb454d0bcc68204ff72c60210d17f9679f.jpg',
    'assets/poster/d88c27338531793104f79107f3fdf1722a0e9fdc.jpg',
    'assets/poster/ee95c8d574be76182adb5fd79675435e550090e2.jpg',
  ];

  final List<Map<String, String>> allReplays = [
    // Football
    {
      'title': 'PSG vs Marseille - Classique',
      'category': 'Football',
      'duration': '90 min',
    },
    {
      'title': 'Real Madrid vs Barcelona - El Clasico',
      'category': 'Football',
      'duration': '105 min',
    },
    {
      'title': 'Manchester United vs Liverpool',
      'category': 'Football',
      'duration': '95 min',
    },
    {
      'title': 'Bayern Munich vs Dortmund',
      'category': 'Football',
      'duration': '92 min',
    },
    {
      'title': 'Chelsea vs Arsenal - Derby londonien',
      'category': 'Football',
      'duration': '88 min',
    },

    // Basketball
    {
      'title': 'NBA Finals - Lakers vs Celtics',
      'category': 'Basketball',
      'duration': '2h 15min',
    },
    {
      'title': 'Warriors vs Nets - Highlights',
      'category': 'Basketball',
      'duration': '1h 45min',
    },
    {
      'title': 'Bulls vs Heat - Playoffs',
      'category': 'Basketball',
      'duration': '2h 05min',
    },
    {
      'title': 'Clippers vs Suns - Conference Finals',
      'category': 'Basketball',
      'duration': '2h 20min',
    },

    // Tennis
    {
      'title': 'Roland Garros - Finale hommes',
      'category': 'Tennis',
      'duration': '3h 30min',
    },
    {
      'title': 'Wimbledon - Federer vs Nadal',
      'category': 'Tennis',
      'duration': '4h 15min',
    },
    {
      'title': 'US Open - Finale dames',
      'category': 'Tennis',
      'duration': '2h 45min',
    },
    {
      'title': 'Open d\'Australie - Djokovic vs Murray',
      'category': 'Tennis',
      'duration': '3h 20min',
    },

    // Formule 1
    {
      'title': 'Grand Prix Monaco - Course complète',
      'category': 'Formule 1',
      'duration': '1h 45min',
    },
    {
      'title': 'GP de France - Highlights',
      'category': 'Formule 1',
      'duration': '45 min',
    },
    {
      'title': 'Silverstone - Bataille Hamilton vs Verstappen',
      'category': 'Formule 1',
      'duration': '1h 35min',
    },
    {
      'title': 'Spa-Francorchamps - Course sous la pluie',
      'category': 'Formule 1',
      'duration': '2h 10min',
    },

    // Rugby
    {
      'title': 'France vs Angleterre - Tournoi 6 Nations',
      'category': 'Rugby',
      'duration': '80 min',
    },
    {
      'title': 'Nouvelle-Zélande vs Afrique du Sud',
      'category': 'Rugby',
      'duration': '85 min',
    },
    {
      'title': 'Coupe du Monde - Finale',
      'category': 'Rugby',
      'duration': '95 min',
    },

    // Documentaires
    {
      'title': 'The Last Dance - Michael Jordan',
      'category': 'Documentaires',
      'duration': '10 épisodes',
    },
    {
      'title': 'Senna - Portrait d\'une légende',
      'category': 'Documentaires',
      'duration': '1h 45min',
    },
    {
      'title': 'All or Nothing - Manchester City',
      'category': 'Documentaires',
      'duration': '8 épisodes',
    },
    {
      'title': 'Diego Maradona - Documentaire',
      'category': 'Documentaires',
      'duration': '2h 10min',
    },
  ];

  List<Map<String, String>> get filteredReplays {
    if (selectedCategory == 'Tous') {
      return allReplays;
    }
    return allReplays
        .where((replay) => replay['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

    return Scaffold(
      backgroundColor: backgroundColor,
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
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceColor(isDarkMode),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: textColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Replay disponibles',
                    style: AppTypography.title(textColor),
                  ),
                ],
              ),
            ),

            // Filtres par catégorie
            GenreFilterBar(
              genres: categories,
              selectedGenre: selectedCategory,
              onGenreSelected: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),

            // Compteur et info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${filteredReplays.length} replays disponibles',
                    style: AppTypography.caption(
                      AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.replay,
                          color: AppColors.primary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'REPLAY',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Grille des replays
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredReplays.length,
                itemBuilder: (context, index) {
                  final replay = filteredReplays[index];
                  return ReplayCard(
                    title: replay['title']!,
                    duration: replay['duration']!,
                    imagePath: posterImages[index % posterImages.length],
                    onTap: () {
                      // Navigation vers la lecture du replay
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lecture de "${replay['title']}"'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
