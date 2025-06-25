import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../models/movie_model.dart';
import '../widgets/common/horizontal_section.dart';
import '../widgets/common/actor_card.dart';
import '../widgets/common/series_grid.dart';
import '../widgets/common/comment_card.dart';
import '../widgets/common/comment_input_field.dart';
import '../widgets/common/season_card.dart';
import '../screens/season_detail_screen.dart';
import '../data/sample_data.dart';

class SeriesDetailScreen extends StatefulWidget {
  final SeriesModel series;

  const SeriesDetailScreen({Key? key, required this.series}) : super(key: key);

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              child: Image.asset(widget.series.imagePath, fit: BoxFit.cover),
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
                  child: Image.asset(
                    widget.series.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Informations à côté du poster
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.series.title,
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
                            widget.series.seasons,
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
                            widget.series.years,
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
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[800],
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
                              const SizedBox(width: 3),
                              Text(
                                widget.series.rating.toString(),
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.series.genre,
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Une série captivante.',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
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
          _buildActionButton(Icons.share, 'Partager', isDarkMode),
          _buildActionButton(Icons.bookmark_border, 'Sauvegarder', isDarkMode),
          _buildActionButton(Icons.download, 'Télécharger', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, bool isDarkMode) {
    return Column(
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
    return Column(
      children: [
        // Tab Bar
        Container(
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
        ),

        // Tab Content
        Container(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(isDarkMode),
              _buildSeasonsTab(isDarkMode),
              _buildCommentsTab(isDarkMode),
              _buildSimilarTab(isDarkMode),
            ],
          ),
        ),
      ],
    );
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
          HorizontalSection<ActorModel>(
            title: 'Casting',
            items: SampleData.actors.take(6).toList(),
            itemBuilder: (actor, index) => ActorCard(
              imagePath: actor.imagePath,
              name: actor.name,
              isDarkMode: isDarkMode,
            ),
            itemWidth: 130,
            sectionHeight: 200,
            showSeeMore: false,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 16),

          // Section Galerie
          Padding(
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
                _buildGallery(isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonsTab(bool isDarkMode) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: SampleData.seasons.map((season) {
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
                    builder: (context) => SeasonDetailScreen(season: season),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGallery(bool isDarkMode) {
    final trailerImages = [
      'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
    ];

    final galleryImages = [
      'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
      'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
    ];

    return Column(
      children: [
        // Section Bandes-annonces en haut
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 16 / 9,
          ),
          itemCount: trailerImages.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(trailerImages[index], fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'BANDE-ANNONCE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // Section Photos/Posters en bas
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 16 / 9,
          ),
          itemCount: galleryImages.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(galleryImages[index], fit: BoxFit.cover),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentsTab(bool isDarkMode) {
    return Column(
      children: [
        // Liste des commentaires
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: SampleData.comments.length,
            itemBuilder: (context, index) {
              final comment = SampleData.comments[index];
              return CommentCard(
                userName: comment.userName,
                timeAgo: comment.timeAgo,
                comment: comment.comment,
                avatarPath: comment.avatarPath,
                isDarkMode: isDarkMode,
              );
            },
          ),
        ),

        // Champ pour ajouter un commentaire
        CommentInputField(
          isDarkMode: isDarkMode,
          hintText: 'Écrire un commentaire à propos de la série',
          onSend: () {
            // Ajouter commentaire
          },
        ),
      ],
    );
  }

  Widget _buildSimilarTab(bool isDarkMode) {
    return SeriesGrid(
      series: SampleData.popularSeries.take(6).toList(),
      isDarkMode: isDarkMode,
      countText: '${SampleData.popularSeries.take(6).length} séries similaires',
    );
  }
}
