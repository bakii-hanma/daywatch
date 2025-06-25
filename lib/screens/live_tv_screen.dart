import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/common/horizontal_section.dart';
import '../widgets/common/tv_channel_card.dart';
import '../widgets/common/live_match_card.dart';
import '../widgets/common/replay_card.dart';
import 'tv_channels_screen.dart';
import 'live_matches_screen.dart';
import 'replays_screen.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
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

  final List<Map<String, String>> tvChannels = [
    {
      'name': 'TF1',
      'program': 'Journal de 13h - Actualités nationales et internationales',
    },
    {
      'name': 'France 2',
      'program': 'Télématin - Magazine matinal d\'information',
    },
    {
      'name': 'Canal+',
      'program': 'Les Guignols - Émission satirique quotidienne',
    },
    {'name': 'M6', 'program': 'Capital - Magazine économique et société'},
    {'name': 'Arte', 'program': 'Documentaire - Nature et environnement'},
    {'name': 'France 3', 'program': 'Plus belle la vie - Série télévisée'},
    {'name': 'RMC Sport', 'program': 'Football - Ligue 1 en direct'},
    {'name': 'Eurosport', 'program': 'Tennis - Roland Garros live'},
  ];

  final List<Map<String, String>> liveMatches = [
    {
      'team1': 'PSG',
      'team2': 'Real Madrid',
      'time': '21:00',
      'sport': 'Football',
    },
    {
      'team1': 'Lakers',
      'team2': 'Warriors',
      'time': '02:30',
      'sport': 'Basketball',
    },
    {'team1': 'France', 'team2': 'Italie', 'time': '18:45', 'sport': 'Rugby'},
    {
      'team1': 'Chelsea',
      'team2': 'Arsenal',
      'time': '16:00',
      'sport': 'Football',
    },
    {'team1': 'Federer', 'team2': 'Nadal', 'time': '14:30', 'sport': 'Tennis'},
    {
      'team1': 'Celtics',
      'team2': 'Heat',
      'time': '01:00',
      'sport': 'Basketball',
    },
  ];

  final List<String> replayTitles = [
    'PSG vs Marseille - Classique',
    'Tennis Roland Garros - Finale',
    'NBA Finals - Lakers vs Celtics',
    'Formule 1 - Grand Prix Monaco',
    'Champions League - Bayern vs City',
    'Rugby World Cup - France vs All Blacks',
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header moderne
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DIRECT', style: AppTypography.header(textColor)),
                        const SizedBox(height: 4),
                        Text(
                          'Regardez en direct ou en replay',
                          style: AppTypography.body(textColor.withOpacity(0.7)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.getSurfaceColor(isDarkMode),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: textColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.getSurfaceColor(isDarkMode),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: textColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Section En direct maintenant (Hero section)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '🔴 EN DIRECT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PSG vs Real Madrid',
                            style: AppTypography.title(textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Champions League • 21:00',
                            style: AppTypography.body(
                              textColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Regarder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        posterImages[0],
                        width: 80,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Section Chaînes TV avec HorizontalSection
              HorizontalSection<Map<String, String>>(
                title: 'Chaînes TV',
                items: tvChannels,
                itemWidth: 160,
                sectionHeight: 260,
                isDarkMode: isDarkMode,
                onSeeMoreTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TvChannelsScreen(),
                    ),
                  );
                },
                itemBuilder: (channel, index) {
                  return TvChannelCard(
                    channelName: channel['name']!,
                    program: channel['program']!,
                    onTap: () {
                      // Action de sélection de chaîne
                    },
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Section Matchs en direct avec HorizontalSection
              HorizontalSection<Map<String, String>>(
                title: 'Matchs en direct',
                items: liveMatches,
                itemWidth: 300,
                sectionHeight: 140,
                isDarkMode: isDarkMode,
                onSeeMoreTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveMatchesScreen(),
                    ),
                  );
                },
                itemBuilder: (match, index) {
                  return LiveMatchCard(
                    team1: match['team1']!,
                    team2: match['team2']!,
                    time: match['time']!,
                    sport: match['sport']!,
                    imagePath: posterImages[index % posterImages.length],
                    onTap: () {
                      // Action de lecture du match
                    },
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Section Replay avec HorizontalSection style
              HorizontalSection<String>(
                title: 'Replay disponibles',
                items: replayTitles,
                itemWidth: 160,
                sectionHeight: 260,
                isDarkMode: isDarkMode,
                onSeeMoreTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReplaysScreen(),
                    ),
                  );
                },
                itemBuilder: (title, index) {
                  return ReplayCard(
                    title: title,
                    imagePath: posterImages[index % posterImages.length],
                    onTap: () {
                      // Action de lecture du replay
                    },
                  );
                },
              ),

              const SizedBox(height: 100), // Espace pour la bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}
