import 'dart:async';
import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../widgets/common/horizontal_section.dart';
import '../widgets/common/actor_card.dart';
import '../widgets/common/series_grid.dart';
import '../widgets/common/comment_card.dart';
import '../widgets/common/comment_input_field.dart';
import '../widgets/common/season_card.dart';
import '../screens/season_detail_screen.dart';
import '../screens/image_gallery_viewer.dart';
import '../screens/series_detail_screen.dart';
import '../data/sample_data.dart';
import '../services/series_service.dart'; // Added import for SeriesService

class SeriesDetailScreen extends StatefulWidget {
  final SeriesModel? series;
  final SeriesApiModel? apiSeries;

  const SeriesDetailScreen({Key? key, required this.series})
    : apiSeries = null,
      super(key: key);

  const SeriesDetailScreen.fromApiSeries({Key? key, required this.apiSeries})
    : series = null,
      super(key: key);

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SeriesApiModel? _enrichedSeries; // Série enrichie avec les épisodes
  bool _isLoadingEpisodes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    // Enrichir la série avec ses épisodes si c'est une série API
    if (widget.apiSeries != null) {
      _enrichSeriesWithEpisodes();
    }
  }

  Future<void> _enrichSeriesWithEpisodes() async {
    if (widget.apiSeries == null) return;

    setState(() {
      _isLoadingEpisodes = true;
    });

    try {
      print(
        '🔄 Début de l\'enrichissement de la série "${widget.apiSeries!.title}"...',
      );

      final enrichedSeries =
          await SeriesService.enrichSeriesWithEpisodes(
            series: widget.apiSeries!,
          ).timeout(
            const Duration(
              seconds: 120,
            ), // Timeout de 2 minutes pour l'enrichissement
            onTimeout: () {
              print('⏰ Timeout lors de l\'enrichissement de la série');
              throw TimeoutException('Enrichissement de la série trop long');
            },
          );

      if (mounted) {
        setState(() {
          _enrichedSeries = enrichedSeries;
          _isLoadingEpisodes = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors de l\'enrichissement de la série: $e');
      if (mounted) {
        setState(() {
          _enrichedSeries = widget.apiSeries; // Utiliser la série originale
          _isLoadingEpisodes = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Getters pour récupérer les propriétés depuis le bon modèle
  String get _imagePath =>
      widget.series?.imagePath ?? widget.apiSeries?.poster ?? '';
  String get _bannerPath =>
      widget.series?.imagePath ??
      widget.apiSeries?.fanart ??
      widget.apiSeries?.poster ??
      '';
  String get _title => widget.series?.title ?? widget.apiSeries?.title ?? '';
  String get _seasons =>
      widget.series?.seasons ??
      '${widget.apiSeries?.seasonInfo.totalSeasons ?? 0} saisons';
  String get _years =>
      widget.series?.years ?? widget.apiSeries?.year.toString() ?? '';
  double get _rating =>
      widget.series?.rating ?? widget.apiSeries?.rating ?? 0.0;
  String get _genre =>
      widget.series?.genre ??
      (widget.apiSeries?.genres.isNotEmpty == true
          ? widget.apiSeries!.genres.first
          : 'Série');
  String get _overview =>
      widget.series?.description ?? widget.apiSeries?.overview ?? '';
  String get _network => widget.apiSeries?.network ?? '';
  String get _status => widget.apiSeries?.status ?? '';
  String get _premiered => widget.apiSeries?.premiered ?? '';
  bool get _isNetworkImage => widget.apiSeries != null;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getSearchBackgroundColor(isDarkMode),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec poster et boutons
            _buildHeaderSection(isDarkMode),

            // Boutons d'action
            _buildActionButtons(isDarkMode),

            // Bouton "Regarder maintenant"
            _buildWatchNowButton(isDarkMode),

            // Tabs (Détails, Saisons, Commentaires, Similaires)
            _buildTabSection(isDarkMode),

            // Affichage du contenu du tab sélectionné
            _buildTabContent(isDarkMode),

            // Indicateur de chargement des épisodes
            if (_isLoadingEpisodes)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chargement des épisodes...',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDarkMode) {
    return Column(
      children: [
        // Image de fond avec boutons
        Stack(
          children: [
            // Image de fond
            Container(
              height: 250,
              width: double.infinity,
              child: _isNetworkImage
                  ? Image.network(
                      _bannerPath.isNotEmpty ? _bannerPath : _imagePath,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      _bannerPath.isNotEmpty ? _bannerPath : _imagePath,
                      fit: BoxFit.cover,
                    ),
            ),

            // Boutons retour et options en haut
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Options menu
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Section poster et informations
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _isNetworkImage
                      ? Image.network(_imagePath, fit: BoxFit.cover)
                      : Image.asset(_imagePath, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(width: 16),

              // Informations à côté du poster
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _seasons,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _years,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _genre,
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.add,
            label: 'Ma liste',
            isDarkMode: isDarkMode,
            onTap: () {
              // Ajouter à la liste
            },
          ),
          _buildActionButton(
            icon: Icons.download,
            label: 'Télécharger',
            isDarkMode: isDarkMode,
            onTap: () {
              // Télécharger
            },
          ),
          _buildActionButton(
            icon: Icons.share,
            label: 'Partager',
            isDarkMode: isDarkMode,
            onTap: () {
              // Partager
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.getTextSecondaryColor(isDarkMode),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchNowButton(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // Action regarder maintenant
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Regarder maintenant',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.getTextColor(isDarkMode),
        unselectedLabelColor: AppColors.getTextSecondaryColor(isDarkMode),
        indicatorColor: Colors.red,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: false,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: const [
          Tab(text: 'Détails'),
          Tab(text: 'Saisons'),
          Tab(text: 'Commentaires'),
          Tab(text: 'Similaires'),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isDarkMode) {
    switch (_tabController.index) {
      case 0:
        return _buildDetailsTab(isDarkMode);
      case 1:
        return _buildSeasonsTab(isDarkMode);
      case 2:
        return _buildCommentsTab(isDarkMode);
      case 3:
        return _buildSimilarTab(isDarkMode);
      default:
        return Container();
    }
  }

  Widget _buildDetailsTab(bool isDarkMode) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Synopsis
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Synopsis',
                  style: TextStyle(
                    color: AppColors.getTextColor(isDarkMode),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_overview.isNotEmpty)
                  Text(
                    _overview,
                    style: TextStyle(
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  )
                else
                  Text(
                    'Une série passionnante qui suit les aventures extraordinaires de nos héros à travers différentes saisons. Chaque épisode apporte son lot de surprises et d\'émotions dans un univers riche et captivant.',
                    style: TextStyle(
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Section Casting
          _buildCastingSection(isDarkMode),

          const SizedBox(height: 16),

          // Section Galerie
          _buildGallerySection(isDarkMode),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCastingSection(bool isDarkMode) {
    final cast = widget.apiSeries?.cast;
    if (cast != null && cast.cast.isNotEmpty) {
      final actors = cast.cast.map((castMember) {
        String imageUrl = '';
        if (castMember.profilePath != null &&
            castMember.profilePath!.isNotEmpty) {
          imageUrl = castMember.profilePath!.startsWith('http')
              ? castMember.profilePath!
              : 'https://image.tmdb.org/t/p/w500${castMember.profilePath!}';
        }
        return ActorModel(
          id: castMember.id.toString(),
          name: castMember.name,
          imagePath: imageUrl,
          bio: castMember.character,
        );
      }).toList();
      return HorizontalSection<ActorModel>(
        title: 'Casting',
        items: actors,
        itemBuilder: (actor, index) => ActorCard(
          imagePath: actor.imagePath,
          name: actor.name,
          isDarkMode: isDarkMode,
        ),
        itemWidth: 120,
        sectionHeight: 200,
        showSeeMore: actors.length > 6,
        onSeeMoreTap: () {},
        isDarkMode: isDarkMode,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildGallerySection(bool isDarkMode) {
    final gallery = widget.apiSeries?.gallery;
    if (gallery != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Galerie',
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (gallery.backdrops.isNotEmpty) ...[
              Text(
                'Images de la série',
                style: TextStyle(
                  color: AppColors.getTextColor(isDarkMode),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: gallery.backdrops.take(5).length,
                  itemBuilder: (context, index) {
                    final image = gallery.backdrops[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          final allBackdrops = gallery.backdrops
                              .map((img) => img.filePath)
                              .toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageGalleryViewer(
                                imageUrls: allBackdrops,
                                initialIndex: index,
                                imageNames: List.generate(
                                  allBackdrops.length,
                                  (i) => 'Image ${i + 1}',
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image.filePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (gallery.posters.isNotEmpty) ...[
              Text(
                'Affiches',
                style: TextStyle(
                  color: AppColors.getTextColor(isDarkMode),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: gallery.posters.take(5).length,
                  itemBuilder: (context, index) {
                    final image = gallery.posters[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          final allPosters = gallery.posters
                              .map((img) => img.filePath)
                              .toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageGalleryViewer(
                                imageUrls: allPosters,
                                initialIndex: index,
                                imageNames: List.generate(
                                  allPosters.length,
                                  (i) => 'Affiche ${i + 1}',
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image.filePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSeriesInfo(bool isDarkMode) {
    String statusText = '';
    switch (_status.toLowerCase()) {
      case 'ended':
        statusText = 'Terminée';
        break;
      case 'continuing':
        statusText = 'En cours';
        break;
      case 'upcoming':
        statusText = 'À venir';
        break;
      default:
        statusText = _status;
    }

    String premiereDateText = '';
    if (_premiered.isNotEmpty) {
      try {
        final date = DateTime.parse(_premiered);
        premiereDateText = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        premiereDateText = _premiered;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations',
          style: TextStyle(
            color: AppColors.getTextColor(isDarkMode),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (_network.isNotEmpty)
          Text(
            '📺 Réseau: $_network',
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
              fontSize: 14,
            ),
          ),
        if (premiereDateText.isNotEmpty)
          Text(
            '📅 Première diffusion: $premiereDateText',
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
              fontSize: 14,
            ),
          ),
        if (statusText.isNotEmpty)
          Text(
            '📊 Statut: $statusText',
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
              fontSize: 14,
            ),
          ),
        Text(
          '🎬 Nombre de saisons: ${widget.apiSeries!.seasonInfo.totalSeasons}',
          style: TextStyle(
            color: AppColors.getTextSecondaryColor(isDarkMode),
            fontSize: 14,
          ),
        ),
        Text(
          '⭐ Note: ${_rating.toStringAsFixed(1)}/10',
          style: TextStyle(
            color: AppColors.getTextSecondaryColor(isDarkMode),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonsTab(bool isDarkMode) {
    // Utiliser la série enrichie si disponible, sinon la série originale
    final seriesToUse = _enrichedSeries ?? widget.apiSeries;

    if (seriesToUse != null && seriesToUse.seasonInfo.seasons.isNotEmpty) {
      final realSeasons = seriesToUse.seasonInfo.seasons
          .where((season) => season.number > 0)
          .toList();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            ...realSeasons.map((apiSeason) {
              // Logique de fallback pour l'image de la saison
              String seasonImagePath =
                  _imagePath; // Commence par l'image de la série

              // Si la série a des images spécifiques, on peut les utiliser
              if (seriesToUse != null) {
                // Vérifier si la saison a ses propres images
                if (apiSeason.poster.isNotEmpty) {
                  seasonImagePath = apiSeason.poster;
                } else if (apiSeason.fanart.isNotEmpty) {
                  seasonImagePath = apiSeason.fanart;
                } else if (apiSeason.banner.isNotEmpty) {
                  seasonImagePath = apiSeason.banner;
                } else {
                  // Fallback vers les images de la série
                  if (seriesToUse.poster.isNotEmpty) {
                    seasonImagePath = seriesToUse.poster;
                  } else if (seriesToUse.fanart.isNotEmpty) {
                    seasonImagePath = seriesToUse.fanart;
                  } else if (seriesToUse.banner.isNotEmpty) {
                    seasonImagePath = seriesToUse.banner;
                  }
                }
              }

              // Créer le SeasonModel avec les images de la saison
              final seasonModel = SeasonModel(
                id: apiSeason.number.toString(),
                imagePath: seasonImagePath,
                poster: apiSeason.poster.isNotEmpty ? apiSeason.poster : null,
                fanart: apiSeason.fanart.isNotEmpty ? apiSeason.fanart : null,
                banner: apiSeason.banner.isNotEmpty ? apiSeason.banner : null,
                title: apiSeason.title.isNotEmpty
                    ? apiSeason.title
                    : 'Saison ${apiSeason.number}',
                episodes: '${apiSeason.episodeCount} épisodes',
                year: _years,
                rating: _rating,
                description: _overview.isNotEmpty
                    ? _overview
                    : 'Synopsis de la série non disponible.',
                episodesList: [],
              );

              print('🎬 SeasonModel créé pour la saison ${apiSeason.number}:');
              print('   📸 Poster: ${seasonModel.poster ?? "Non disponible"}');
              print('   🖼️ Fanart: ${seasonModel.fanart ?? "Non disponible"}');
              print('   🎭 Banner: ${seasonModel.banner ?? "Non disponible"}');

              return Column(
                children: [
                  SeasonCard(
                    imagePath: seasonModel.imagePath,
                    title: seasonModel.title,
                    episodes: seasonModel.episodes,
                    year: seasonModel.year,
                    rating: seasonModel.rating,
                    description: seasonModel.description,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Récupérer les épisodes de la saison depuis la série enrichie
                      List<EpisodeApiModel>? seasonEpisodes;
                      if (seriesToUse != null &&
                          seriesToUse.hasEpisodesForSeason(apiSeason.number)) {
                        seasonEpisodes = seriesToUse.getEpisodesForSeason(
                          apiSeason.number,
                        );
                        print(
                          '📺 Navigation vers saison ${apiSeason.number} avec ${seasonEpisodes.length} épisodes pré-récupérés',
                        );
                      } else {
                        print(
                          '📺 Navigation vers saison ${apiSeason.number} sans épisodes pré-récupérés',
                        );
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeasonDetailScreen.fromApi(
                            season: seasonModel,
                            seriesId: seriesToUse!.id,
                            seasonNumber: apiSeason.number,
                            episodes: seasonEpisodes,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
            const SizedBox(height: 40), // Espace pour la barre de navigation
          ],
        ),
      );
    }

    // Fallback vers les données d'exemple
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ...SampleData.seasons.map((season) {
            return Column(
              children: [
                SeasonCard(
                  imagePath: season.imagePath,
                  title: season.title,
                  episodes: season.episodes,
                  year: season.year,
                  rating: season.rating,
                  description: season.description,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SeasonDetailScreen(season: season),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
          const SizedBox(height: 40), // Espace pour la barre de navigation
        ],
      ),
    );
  }

  Widget _buildCommentsTab(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...SampleData.comments.map(
            (comment) => CommentCard(
              userName: comment.userName,
              timeAgo: comment.timeAgo,
              comment: comment.comment,
              avatarPath: comment.avatarPath,
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(height: 16),
          CommentInputField(
            isDarkMode: isDarkMode,
            onSend: () {
              // Ajouter commentaire
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarTab(bool isDarkMode) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${SampleData.popularSeries.length} séries similaires',
              style: TextStyle(
                color: AppColors.getTextSecondaryColor(isDarkMode),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: SampleData.popularSeries.length,
              itemBuilder: (context, index) {
                final series = SampleData.popularSeries[index];
                return _buildSimilarSeriesCard(series, isDarkMode);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarSeriesCard(SeriesModel series, bool isDarkMode) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeriesDetailScreen(series: series),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.asset(
                  series.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.title,
                    style: TextStyle(
                      color: AppColors.getTextColor(isDarkMode),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        series.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        series.years,
                        style: TextStyle(
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
