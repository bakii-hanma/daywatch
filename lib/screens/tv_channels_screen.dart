import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/common/genre_filter_bar.dart';
import '../widgets/common/tv_channel_card.dart';

class TvChannelsScreen extends StatefulWidget {
  const TvChannelsScreen({Key? key}) : super(key: key);

  @override
  State<TvChannelsScreen> createState() => _TvChannelsScreenState();
}

class _TvChannelsScreenState extends State<TvChannelsScreen> {
  String selectedCategory = 'Toutes';

  final List<String> categories = [
    'Toutes',
    'Généralistes',
    'Sport',
    'Info',
    'Divertissement',
    'Cinéma',
    'Documentaires',
  ];

  final List<Map<String, String>> allChannels = [
    // Généralistes
    {
      'name': 'TF1',
      'category': 'Généralistes',
      'program': 'Journal de 13h - Actualités nationales',
    },
    {
      'name': 'France 2',
      'category': 'Généralistes',
      'program': 'Télématin - Magazine matinal',
    },
    {
      'name': 'M6',
      'category': 'Généralistes',
      'program': 'Capital - Magazine économique',
    },
    {
      'name': 'France 3',
      'category': 'Généralistes',
      'program': 'Plus belle la vie - Série',
    },

    // Sport
    {
      'name': 'RMC Sport',
      'category': 'Sport',
      'program': 'Ligue 1 en direct - PSG vs Marseille',
    },
    {
      'name': 'Eurosport',
      'category': 'Sport',
      'program': 'Tennis Roland Garros - Finale',
    },
    {
      'name': 'beIN Sports',
      'category': 'Sport',
      'program': 'Champions League - Highlights',
    },
    {
      'name': 'L\'Équipe',
      'category': 'Sport',
      'program': 'L\'Équipe du soir - Talk show',
    },

    // Info
    {
      'name': 'BFM TV',
      'category': 'Info',
      'program': 'BFM Story - Actualités en continu',
    },
    {
      'name': 'CNews',
      'category': 'Info',
      'program': 'L\'Heure des Pros - Débat politique',
    },
    {
      'name': 'LCI',
      'category': 'Info',
      'program': '24h Pujadas - Journal en continu',
    },

    // Divertissement
    {
      'name': 'W9',
      'category': 'Divertissement',
      'program': 'Les Marseillais - Télé-réalité',
    },
    {
      'name': 'TMC',
      'category': 'Divertissement',
      'program': 'Quotidien - Talk show',
    },
    {
      'name': 'NRJ 12',
      'category': 'Divertissement',
      'program': 'Les Anges - Télé-réalité',
    },

    // Cinéma
    {
      'name': 'Canal+',
      'category': 'Cinéma',
      'program': 'Fast & Furious 9 - Action',
    },
    {
      'name': 'OCS Max',
      'category': 'Cinéma',
      'program': 'The Batman - Super-héros',
    },
    {
      'name': 'Ciné+ Premier',
      'category': 'Cinéma',
      'program': 'Dune - Science-fiction',
    },

    // Documentaires
    {
      'name': 'Arte',
      'category': 'Documentaires',
      'program': 'Nature - Documentaire animalier',
    },
    {
      'name': 'National Geographic',
      'category': 'Documentaires',
      'program': 'Cosmos - Exploration spatiale',
    },
    {
      'name': 'Discovery',
      'category': 'Documentaires',
      'program': 'How It\'s Made - Fabrication',
    },
  ];

  List<Map<String, String>> get filteredChannels {
    if (selectedCategory == 'Toutes') {
      return allChannels;
    }
    return allChannels
        .where((channel) => channel['category'] == selectedCategory)
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
                  Text('Chaînes TV', style: AppTypography.title(textColor)),
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
                    '${filteredChannels.length} chaînes disponibles',
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
                          'EN DIRECT',
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

            // Grille des chaînes
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredChannels.length,
                itemBuilder: (context, index) {
                  final channel = filteredChannels[index];
                  return TvChannelCard(
                    channelName: channel['name']!,
                    program: channel['program']!,
                    onTap: () {
                      // Navigation vers la lecture de la chaîne
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ouverture de ${channel['name']}'),
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
