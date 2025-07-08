import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/common/genre_filter_bar.dart';
import '../widgets/common/tv_channel_card.dart';
import '../models/tv_channel_model.dart';
import '../services/tv_channel_service.dart';

class TvChannelsScreen extends StatefulWidget {
  const TvChannelsScreen({Key? key}) : super(key: key);

  @override
  State<TvChannelsScreen> createState() => _TvChannelsScreenState();
}

class _TvChannelsScreenState extends State<TvChannelsScreen> {
  String selectedCategory = 'Toutes';
  List<String> categories = [
    'Toutes',
    'Généralistes',
    'Sport',
    'Info',
    'Divertissement',
    'Cinéma',
    'Documentaires',
  ];

  List<TvChannelModel> allChannels = [];
  List<TvChannelModel> filteredChannels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    try {
      final channels = await TvChannelService.getAllChannels();
      final availableCategories =
          await TvChannelService.getAvailableCategories();

      setState(() {
        allChannels = channels;
        filteredChannels = channels;
        categories = availableCategories;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des chaînes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _filterChannels(String category) async {
    setState(() {
      selectedCategory = category;
      isLoading = true;
    });

    try {
      final channels = await TvChannelService.getChannelsByCategory(category);
      setState(() {
        filteredChannels = channels;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du filtrage: $e');
      setState(() {
        isLoading = false;
      });
    }
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
              onGenreSelected: _filterChannels,
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredChannels.length,
                      itemBuilder: (context, index) {
                        final channel = filteredChannels[index];
                        return TvChannelCard(
                          channel: channel,
                          onTap: () {
                            // Navigation vers la lecture de la chaîne
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ouverture de ${channel.name}'),
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
