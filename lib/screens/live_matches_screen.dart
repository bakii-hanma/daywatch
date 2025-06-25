import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/common/genre_filter_bar.dart';
import '../widgets/common/live_match_card.dart';

class LiveMatchesScreen extends StatefulWidget {
  const LiveMatchesScreen({Key? key}) : super(key: key);

  @override
  State<LiveMatchesScreen> createState() => _LiveMatchesScreenState();
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  String selectedSport = 'Tous';

  final List<String> sports = [
    'Tous',
    'Football',
    'Basketball',
    'Tennis',
    'Rugby',
    'Hockey',
    'Baseball',
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

  final List<Map<String, String>> allMatches = [
    // Football
    {
      'team1': 'PSG',
      'team2': 'Real Madrid',
      'time': '21:00',
      'sport': 'Football',
    },
    {
      'team1': 'Manchester City',
      'team2': 'Liverpool',
      'time': '18:30',
      'sport': 'Football',
    },
    {
      'team1': 'Barcelona',
      'team2': 'Atletico Madrid',
      'time': '16:15',
      'sport': 'Football',
    },
    {
      'team1': 'Chelsea',
      'team2': 'Arsenal',
      'time': '20:45',
      'sport': 'Football',
    },
    {
      'team1': 'Bayern Munich',
      'team2': 'Dortmund',
      'time': '19:30',
      'sport': 'Football',
    },

    // Basketball
    {
      'team1': 'Lakers',
      'team2': 'Warriors',
      'time': '02:30',
      'sport': 'Basketball',
    },
    {
      'team1': 'Celtics',
      'team2': 'Heat',
      'time': '01:00',
      'sport': 'Basketball',
    },
    {
      'team1': 'Nets',
      'team2': 'Knicks',
      'time': '03:15',
      'sport': 'Basketball',
    },
    {
      'team1': 'Bulls',
      'team2': 'Pistons',
      'time': '01:45',
      'sport': 'Basketball',
    },

    // Tennis
    {'team1': 'Federer', 'team2': 'Nadal', 'time': '14:30', 'sport': 'Tennis'},
    {
      'team1': 'Djokovic',
      'team2': 'Murray',
      'time': '16:00',
      'sport': 'Tennis',
    },
    {
      'team1': 'Serena Williams',
      'team2': 'Osaka',
      'time': '13:15',
      'sport': 'Tennis',
    },
    {
      'team1': 'Tsitsipas',
      'team2': 'Zverev',
      'time': '15:45',
      'sport': 'Tennis',
    },

    // Rugby
    {
      'team1': 'France',
      'team2': 'Angleterre',
      'time': '18:45',
      'sport': 'Rugby',
    },
    {
      'team1': 'Nouvelle-Zélande',
      'team2': 'Afrique du Sud',
      'time': '09:00',
      'sport': 'Rugby',
    },
    {'team1': 'Irlande', 'team2': 'Galles', 'time': '17:30', 'sport': 'Rugby'},

    // Hockey
    {
      'team1': 'Canadiens',
      'team2': 'Rangers',
      'time': '00:30',
      'sport': 'Hockey',
    },
    {'team1': 'Bruins', 'team2': 'Flyers', 'time': '01:15', 'sport': 'Hockey'},

    // Baseball
    {
      'team1': 'Yankees',
      'team2': 'Red Sox',
      'time': '23:45',
      'sport': 'Baseball',
    },
    {
      'team1': 'Dodgers',
      'team2': 'Giants',
      'time': '04:10',
      'sport': 'Baseball',
    },
  ];

  List<Map<String, String>> get filteredMatches {
    if (selectedSport == 'Tous') {
      return allMatches;
    }
    return allMatches
        .where((match) => match['sport'] == selectedSport)
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
                    'Matchs en direct',
                    style: AppTypography.title(textColor),
                  ),
                ],
              ),
            ),

            // Filtres par sport
            GenreFilterBar(
              genres: sports,
              selectedGenre: selectedSport,
              onGenreSelected: (sport) {
                setState(() {
                  selectedSport = sport;
                });
              },
            ),

            // Compteur et info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${filteredMatches.length} matchs en cours',
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
                          'LIVE',
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

            // Liste des matchs
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredMatches.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final match = filteredMatches[index];
                  return LiveMatchCard(
                    team1: match['team1']!,
                    team2: match['team2']!,
                    time: match['time']!,
                    sport: match['sport']!,
                    imagePath: posterImages[index % posterImages.length],
                    onTap: () {
                      // Navigation vers la lecture du match
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ouverture du match ${match['team1']} vs ${match['team2']}',
                          ),
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
