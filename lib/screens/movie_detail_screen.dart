import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../design_system/colors.dart';
import '../models/movie_model.dart';
import '../widgets/common/horizontal_section.dart';
import '../widgets/common/actor_card.dart';
import '../widgets/common/movies_grid.dart';
import '../widgets/common/comment_card.dart';
import '../widgets/common/comment_input_field.dart';
import '../data/sample_data.dart';
import '../screens/fullscreen_video_player.dart';
import '../screens/image_gallery_viewer.dart';
import '../config/server_config.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel? movie;
  final MovieApiModel? apiMovie;

  const MovieDetailScreen({Key? key, this.movie, this.apiMovie})
    : assert(
        movie != null || apiMovie != null,
        'Either movie or apiMovie must be provided',
      ),
      super(key: key);

  // Constructor pour les films classiques
  const MovieDetailScreen.fromMovie(this.movie, {Key? key})
    : apiMovie = null,
      super(key: key);

  // Constructor pour les films de l'API
  const MovieDetailScreen.fromApiMovie(this.apiMovie, {Key? key})
    : movie = null,
      super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPlayerVisible = false; // État pour contrôler l'affichage du lecteur
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showNormalInterface =
      true; // État pour contrôler l'affichage de l'interface normale

  // Variables pour le lecteur YouTube
  YoutubePlayerController? _youtubeController;
  bool _isTrailerVisible = false;

  // Variables pour MediaKit (fallback)
  Player? _mediaKitPlayer;
  VideoController? _mediaKitController;
  bool _isUsingMediaKit = false;

  // Getters pour unifier l'accès aux données
  String get title => widget.apiMovie?.title ?? widget.movie?.title ?? '';
  String get overview =>
      widget.apiMovie?.overview ?? widget.movie?.description ?? '';
  String get posterPath =>
      widget.apiMovie?.images.poster ?? widget.movie?.imagePath ?? '';
  String get backdropPath =>
      widget.apiMovie?.images.backdrop ?? widget.movie?.imagePath ?? '';
  double get rating => widget.apiMovie?.rating ?? widget.movie?.rating ?? 0.0;
  String get year =>
      widget.apiMovie?.year.toString() ?? widget.movie?.releaseDate ?? '';
  String get duration => widget.apiMovie != null
      ? '${widget.apiMovie!.runtime}min'
      : (widget.movie?.duration ?? '');
  List<String> get genres =>
      widget.apiMovie?.genres ?? [widget.movie?.genre ?? ''];
  String get certification => widget.apiMovie?.certification ?? 'PG-13';
  bool get isApiMovie => widget.apiMovie != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Rebuilder à chaque changement d'onglet
      });
    });
  }

  @override
  void dispose() {
    // S'assurer que le wakelock est désactivé en quittant l'écran
    if (_isPlayerVisible || _isTrailerVisible) {
      WakelockPlus.disable();
      print('🔋 Wakelock désactivé - Sortie de l\'écran de détails');
    }

    _tabController.dispose();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _youtubeController?.dispose();

    // Nettoyage MediaKit
    _mediaKitPlayer?.dispose();

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
            // Header avec backdrop et boutons
            _buildHeaderSection(isDarkMode),

            // Boutons d'action
            _buildActionButtons(isDarkMode),

            // Bouton "Regarder maintenant"
            _buildWatchNowButton(isDarkMode),

            // Bouton "Bande annonce"
            _buildTrailerButton(isDarkMode),

            // Tab Bar (sans TabBarView)
            _buildTabBar(isDarkMode),

            // Contenu des tabs intégré directement
            _buildTabContent(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDarkMode) {
    return Column(
      children: [
        // Image de fond avec boutons OU Lecteur
        Stack(
          children: [
            // Image de fond OU Lecteur vidéo
            (_isPlayerVisible || _isTrailerVisible)
                ? Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 200, maxHeight: 300),
                    child: _buildBackdropPlayer(isDarkMode),
                  )
                : Container(
                    width: double.infinity,
                    height:
                        220, // Hauteur fixe réduite pour les images statiques
                    child: ClipRRect(
                      child: _buildNetworkOrAssetImage(
                        backdropPath.isNotEmpty ? backdropPath : posterPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

            // Gradient overlay (seulement si pas en mode lecteur)
            if (!_isPlayerVisible && !_isTrailerVisible)
              Container(
                height: 220, // Même hauteur que l'image
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),

            // Boutons retour et options en haut (seulement si pas en mode lecteur)
            if (!_isPlayerVisible && !_isTrailerVisible)
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
                  child: _buildNetworkOrAssetImage(
                    posterPath,
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
                      title,
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tags : durée, année, certification, note
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (duration.isNotEmpty)
                          _buildInfoChip(duration, Colors.grey),
                        if (year.isNotEmpty) _buildInfoChip(year, Colors.grey),
                        if (isApiMovie)
                          _buildInfoChip(certification, Colors.orange),
                        _buildRatingChip(rating, isDarkMode),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Genres
                    Text(
                      genres.join(' • '),
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 14,
                      ),
                    ),

                    if (isApiMovie && widget.apiMovie!.studio != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Studio: ${widget.apiMovie!.studio}',
                        style: TextStyle(
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    // Statut de disponibilité pour les films API
                    if (isApiMovie && !widget.apiMovie!.downloaded) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _getAvailabilityText(),
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getAvailabilityText() {
    if (!isApiMovie) return 'Bientôt disponible';

    final releaseInfo = widget.apiMovie!.releaseInfo;
    final now = DateTime.now();

    // Vérifier si le film est déjà sorti en salles
    if (releaseInfo.inCinemas != null && releaseInfo.inCinemas!.isNotEmpty) {
      try {
        final inCinemasDate = DateTime.parse(releaseInfo.inCinemas!);
        if (now.isAfter(inCinemasDate)) {
          // Film déjà sorti en salles mais pas encore disponible
          return 'Bientôt disponible';
        }
      } catch (e) {
        // En cas d'erreur de parsing, on considère comme déjà sorti
        return 'Bientôt disponible';
      }
    }

    // Vérifier si le film est déjà sorti en digital
    if (releaseInfo.digitalRelease != null &&
        releaseInfo.digitalRelease!.isNotEmpty) {
      try {
        final digitalDate = DateTime.parse(releaseInfo.digitalRelease!);
        if (now.isAfter(digitalDate)) {
          // Film déjà sorti en digital mais pas encore disponible
          return 'Bientôt disponible';
        }
      } catch (e) {
        // En cas d'erreur de parsing, on considère comme déjà sorti
        return 'Bientôt disponible';
      }
    }

    // Si aucune date de sortie n'est définie ou si le film n'est pas encore sorti
    if (releaseInfo.inCinemas != null && releaseInfo.inCinemas!.isNotEmpty) {
      try {
        final inCinemasDate = DateTime.parse(releaseInfo.inCinemas!);
        return 'Sortie le ${_formatDate(inCinemasDate)}';
      } catch (e) {
        return 'Bientôt disponible';
      }
    }

    if (releaseInfo.digitalRelease != null &&
        releaseInfo.digitalRelease!.isNotEmpty) {
      try {
        final digitalDate = DateTime.parse(releaseInfo.digitalRelease!);
        return 'Sortie le ${_formatDate(digitalDate)}';
      } catch (e) {
        return 'Bientôt disponible';
      }
    }

    // Fallback
    return 'Bientôt disponible';
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildRatingChip(double rating, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: isDarkMode ? Colors.black : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkOrAssetImage(
    String imagePath, {
    BoxFit fit = BoxFit.cover,
  }) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.movie, size: 40, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.asset(imagePath, fit: fit);
    }
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.share, 'Partager', isDarkMode),
          _buildActionButton(Icons.bookmark_border, 'Ma liste', isDarkMode),
          // Suppression du bouton télécharger/téléchargé
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
    // Ne pas afficher le bouton "Regarder maintenant" si le film n'est pas disponible
    if (isApiMovie && !widget.apiMovie!.downloaded) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _isPlayerVisible
              ? null
              : () {
                  // Lancer le lecteur en plein écran
                  _launchFullscreenPlayer();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPlayerVisible ? Colors.grey : Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(
            _isPlayerVisible ? Icons.play_disabled : Icons.play_arrow,
            color: Colors.white,
          ),
          label: Text(
            _isPlayerVisible ? 'En cours de lecture' : 'Regarder maintenant',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(bool isDarkMode) {
    return Container(
      width: 120,
      height: 160,
      color: Colors.black,
      child: Stack(
        children: [
          // Zone du lecteur
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_filled,
                  size: 40,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lecture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Bouton pour arrêter la lecture
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isPlayerVisible = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdropPlayer(bool isDarkMode) {
    // Si une bande-annonce est en cours, afficher le lecteur YouTube
    if (_isTrailerVisible && _youtubeController != null) {
      return _buildYouTubePlayer(isDarkMode);
    }

    // Sinon afficher le lecteur vidéo normal
    return GestureDetector(
      onTap: () {
        setState(() {
          _showNormalInterface =
              !_showNormalInterface; // Basculer l'affichage des contrôles
        });
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 200, maxHeight: 300),
        color: Colors.black,
        child: Stack(
          children: [
            // Zone du lecteur vidéo avec AspectRatio
            if (_isVideoInitialized &&
                !_isUsingMediaKit &&
                _chewieController != null)
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Chewie(controller: _chewieController!),
                ),
              )
            else if (_isVideoInitialized &&
                _isUsingMediaKit &&
                _mediaKitController != null)
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Video(controller: _mediaKitController!),
                ),
              )
            else
              // Écran de chargement ou d'erreur
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_videoPlayerController != null &&
                        !_isVideoInitialized) ...[
                      CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        _isUsingMediaKit
                            ? 'Chargement MediaKit Player...'
                            : 'Chargement de la vidéo...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      if (_isUsingMediaKit) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'MediaKit - 300+ formats',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ] else ...[
                      Icon(
                        Icons.play_circle_filled,
                        size: 80,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lecteur vidéo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (isApiMovie) ...[
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

            // Contrôles de lecteur superposés (seulement pour Chewie/MediaKit, pas pour YouTube)
            if (_isVideoInitialized &&
                !_isTrailerVisible &&
                (_chewieController != null || _isUsingMediaKit) &&
                _showNormalInterface)
              _buildVideoControls(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailerButton(bool isDarkMode) {
    // Vérifier s'il y a une bande-annonce disponible
    final hasTrailer =
        isApiMovie &&
        widget.apiMovie!.youTubeTrailerId != null &&
        widget.apiMovie!.youTubeTrailerId!.isNotEmpty;

    if (!hasTrailer) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: _isTrailerVisible
              ? null
              : () {
                  _launchTrailer();
                },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: _isTrailerVisible ? Colors.grey : Colors.red,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(
            _isTrailerVisible ? Icons.play_disabled : Icons.play_circle_outline,
            color: _isTrailerVisible ? Colors.grey : Colors.red,
          ),
          label: Text(
            _isTrailerVisible ? 'Bande annonce en cours' : 'Bande annonce',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isTrailerVisible ? Colors.grey : Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  void _launchFullscreenPlayer() {
    print('🎬 _launchFullscreenPlayer appelé');
    print('📺 isApiMovie: $isApiMovie');

    if (isApiMovie) {
      print('📁 API Movie détecté');
      print('🔗 mediaInfo.fullPath: ${widget.apiMovie!.mediaInfo.fullPath}');

      if (widget.apiMovie!.mediaInfo.fullPath != null) {
        // Construire l'URL complète avec le préfixe du serveur
        final fullPath = widget.apiMovie!.mediaInfo.fullPath!;
        final videoUrl = ServerConfig.getStreamingUrl(fullPath);

        print('🎬 Lancement du lecteur avec URL: $videoUrl');

        // Initialiser le contrôleur vidéo
        _initializeChewiePlayer(videoUrl);

        // Activer le wakelock pour empêcher la mise en veille
        WakelockPlus.enable();
        print('🔋 Wakelock activé - Lecture intégrée démarrée');

        // Afficher le lecteur à la place du header et réinitialiser l'interface
        setState(() {
          _isPlayerVisible = true;
          _showNormalInterface =
              true; // Réinitialiser l'affichage de l'interface
        });
      } else {
        print('❌ Aucun chemin de fichier disponible');
        _showErrorDialog('Aucun fichier vidéo disponible pour ce film.');
      }
    } else {
      print('📽️ Film classique détecté');
      // Pour les films classiques, utiliser une URL de démonstration
      // ou naviguer vers l'écran de lecteur plein écran
      _launchClassicMoviePlayer();
    }
  }

  void _launchClassicMoviePlayer() {
    print('🎭 Lancement lecteur pour film classique');

    // URL de démonstration pour tester le lecteur
    const demoVideoUrl =
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

    print('🎬 URL de démo: $demoVideoUrl');

    // Naviguer vers l'écran de lecteur plein écran
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(
          videoUrl: demoVideoUrl,
          title: title,
          subtitle: '$year • $duration',
          shouldAutoPlay: true,
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _initializeChewiePlayer(String videoUrl) {
    // Libérer les contrôleurs précédents s'ils existent
    _chewieController?.dispose();
    _videoPlayerController?.dispose();

    print('🎬 Initialisation du lecteur avec URL: $videoUrl');

    // Encoder correctement l'URL pour gérer les espaces et caractères spéciaux
    final encodedUrl = _encodeVideoUrl(videoUrl);
    print('🔗 URL encodée: $encodedUrl');

    // Créer le contrôleur VideoPlayer avec headers optimisés pour les fichiers AVI
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(encodedUrl),
      httpHeaders: _getOptimizedHeaders(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
        allowBackgroundPlayback: false,
      ),
    );

    // Configuration avec timeout et retry
    _videoPlayerController!
        .initialize()
        .timeout(const Duration(seconds: 30))
        .then((_) {
          print('✅ VideoPlayer initialisé avec succès');

          // Créer le contrôleur Chewie après l'initialisation de VideoPlayer
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
            allowFullScreen: true,
            allowMuting: true,
            showControlsOnInitialize: false,
            // Désactiver les contrôles Chewie pour utiliser nos contrôles personnalisés
            showOptions: false,
            showControls: false,
            placeholder: Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Chargement de la vidéo...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Support: MP4, AVI, MKV, TS, FLV, WEBM',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            errorBuilder: (context, errorMessage) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Erreur de lecture vidéo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Format ou codec non supporté',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _initializeChewiePlayer(videoUrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Réessayer',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.red,
              handleColor: Colors.red,
              backgroundColor: Colors.grey.withOpacity(0.3),
              bufferedColor: Colors.white.withOpacity(0.2),
            ),
          );

          setState(() {
            _isVideoInitialized = true;
          });
          print('✅ Lecteur Chewie initialisé avec succès');
        })
        .catchError((error) {
          print('❌ Erreur Chewie/VideoPlayer: $error');
          print('🔧 Type d\'erreur: ${error.runtimeType}');
          print('🚀 Tentative de fallback vers MediaKit...');

          // Essayer MediaKit comme fallback
          _initializeMediaKitPlayer(videoUrl);
        });
  }

  // Encoder l'URL pour gérer les espaces et caractères spéciaux
  String _encodeVideoUrl(String url) {
    // Séparer la base de l'URL du chemin
    final uri = Uri.parse(url);
    final scheme = uri.scheme;
    final host = uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';
    final pathSegments = uri.pathSegments;

    // Encoder chaque segment du chemin séparément
    final encodedPath = pathSegments
        .map((segment) => Uri.encodeComponent(segment))
        .join('/');

    final encodedUrl = '$scheme://$host$port/$encodedPath';
    return encodedUrl;
  }

  // Headers optimisés selon le type de fichier
  Map<String, String> _getOptimizedHeaders(String url) {
    final isAviFile = url.toLowerCase().endsWith('.avi');

    Map<String, String> headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': 'video/*, application/octet-stream, */*',
      'Accept-Encoding': 'identity',
      'Connection': 'keep-alive',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    };

    // Headers spécifiques pour les fichiers AVI
    if (isAviFile) {
      headers.addAll({
        'Accept':
            'video/avi, video/msvideo, video/x-msvideo, application/octet-stream, */*',
        'Range': 'bytes=0-',
      });
      print('📹 Headers AVI optimisés appliqués');
    }

    print('🌐 Headers HTTP: $headers');
    return headers;
  }

  void _initializeMediaKitPlayer(String videoUrl) async {
    try {
      print('🎬 Initialisation MediaKit Player: $videoUrl');

      // Nettoyer les contrôleurs précédents
      _chewieController?.dispose();
      _videoPlayerController?.dispose();
      _mediaKitPlayer?.dispose();

      // Créer un nouveau player MediaKit
      _mediaKitPlayer = Player();
      _mediaKitController = VideoController(_mediaKitPlayer!);

      // Encoder l'URL
      final encodedUrl = _encodeVideoUrl(videoUrl);
      print('🔗 URL encodée MediaKit: $encodedUrl');

      // Créer le Media avec headers optimisés
      final media = Media(
        encodedUrl,
        httpHeaders: _getOptimizedHeaders(videoUrl),
      );

      // Ouvrir le media
      await _mediaKitPlayer!.open(media, play: true);

      setState(() {
        _isUsingMediaKit = true;
        _isVideoInitialized = true;
      });

      print('✅ MediaKit Player initialisé avec succès');
      _showSuccessMessage('Lecteur MediaKit activé - Support de 300+ formats');
    } catch (error) {
      print('❌ Erreur MediaKit Player: $error');

      setState(() {
        _isVideoInitialized = false;
        _isUsingMediaKit = false;
      });

      // Si MediaKit échoue aussi, afficher l'erreur finale
      _showErrorDialog(
        'Impossible de lire ce fichier vidéo.\n\n'
        'Erreur Chewie: Format non supporté\n'
        'Erreur MediaKit: ${error.toString()}\n\n'
        'Formats testés: Chewie (MP4, WEBM) → MediaKit (300+ formats)\n'
        'Vérifiez la connexion au serveur (${ServerConfig.streamingBaseUrl})',
      );
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _stopChewiePlayer() {
    // Désactiver le wakelock
    WakelockPlus.disable();
    print('🔋 Wakelock désactivé - Lecture intégrée arrêtée');

    // Arrêter Chewie
    _chewieController?.pause();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;

    // Arrêter MediaKit
    _mediaKitPlayer?.pause();
    _mediaKitPlayer?.dispose();
    _mediaKitPlayer = null;
    _mediaKitController = null;

    setState(() {
      _isVideoInitialized = false;
      _isUsingMediaKit = false;
    });
  }

  Widget _buildVideoControls(bool isDarkMode) {
    return Stack(
      children: [
        // Bouton retour en haut à gauche uniquement
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  _stopChewiePlayer(); // Ceci désactive déjà le wakelock
                  setState(() {
                    _isPlayerVisible = false;
                    _showNormalInterface = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Contrôles personnalisés au centre
        Center(
          child: AnimatedOpacity(
            opacity: _showNormalInterface ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton reculer 10s
                  InkWell(
                    onTap: () {
                      final currentPosition =
                          _videoPlayerController!.value.position;
                      final newPosition =
                          currentPosition - const Duration(seconds: 10);
                      _videoPlayerController!.seekTo(
                        newPosition < Duration.zero
                            ? Duration.zero
                            : newPosition,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Bouton play/pause personnalisé avec mise à jour en temps réel
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _videoPlayerController!,
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: () {
                          if (value.isPlaying) {
                            _videoPlayerController!.pause();
                          } else {
                            _videoPlayerController!.play();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.red : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: isDarkMode ? Colors.white : Colors.red,
                            size: 36,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  // Bouton avancer 10s
                  InkWell(
                    onTap: () {
                      final currentPosition =
                          _videoPlayerController!.value.position;
                      final duration = _videoPlayerController!.value.duration;
                      final newPosition =
                          currentPosition + const Duration(seconds: 10);
                      _videoPlayerController!.seekTo(
                        newPosition > duration ? duration : newPosition,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _launchTrailer() {
    if (isApiMovie && widget.apiMovie!.youTubeTrailerId != null) {
      final videoId = widget.apiMovie!.youTubeTrailerId!;

      print('🎬 Lancement de la bande-annonce YouTube: $videoId');

      // Arrêter le lecteur vidéo s'il est en cours
      if (_isPlayerVisible) {
        _stopChewiePlayer();
      }

      // Initialiser le contrôleur YouTube
      _initializeYouTubePlayer(videoId);

      // Activer le wakelock pour la bande-annonce
      WakelockPlus.enable();
      print('🔋 Wakelock activé - Bande-annonce démarrée');

      setState(() {
        _isTrailerVisible = true;
        _isPlayerVisible =
            false; // S'assurer que le lecteur vidéo est désactivé
        _showNormalInterface = true;
      });
    }
  }

  void _initializeYouTubePlayer(String videoId) {
    // Libérer le contrôleur précédent s'il existe
    _youtubeController?.dispose();

    // Créer un nouveau contrôleur YouTube
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        captionLanguage: 'fr',
        showLiveFullscreenButton: true, // Activer le plein écran natif YouTube
        useHybridComposition: true, // Meilleure performance
      ),
    );
  }

  void _stopYouTubePlayer() {
    // Désactiver le wakelock
    WakelockPlus.disable();
    print('🔋 Wakelock désactivé - Bande-annonce arrêtée');

    _youtubeController?.dispose();
    _youtubeController = null;
    setState(() {
      _isTrailerVisible = false;
    });
  }

  void _openFullscreenPlayer() {
    if (isApiMovie && widget.apiMovie!.mediaInfo.fullPath != null) {
      final fullPath = widget.apiMovie!.mediaInfo.fullPath!;
      final videoUrl = ServerConfig.getStreamingUrl(fullPath);

      // Récupérer la position actuelle si le lecteur est actif
      Duration? currentPosition;
      bool wasPlaying = false;

      if (_isVideoInitialized) {
        if (_isUsingMediaKit && _mediaKitPlayer != null) {
          // MediaKit
          currentPosition = _mediaKitPlayer!.state.position;
          wasPlaying = _mediaKitPlayer!.state.playing;
          // Pause temporaire pour éviter les conflits
          _mediaKitPlayer!.pause();
        } else if (_videoPlayerController != null) {
          // Chewie/VideoPlayer
          currentPosition = _videoPlayerController!.value.position;
          wasPlaying = _videoPlayerController!.value.isPlaying;
          // Pause temporaire pour éviter les conflits
          _videoPlayerController!.pause();
        }

        // Désactiver temporairement le wakelock du lecteur intégré
        // car le lecteur plein écran va gérer son propre wakelock
        WakelockPlus.disable();
        print('🔋 Wakelock désactivé temporairement - Passage en plein écran');
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullscreenVideoPlayer(
            videoUrl: videoUrl,
            title: title,
            subtitle: isApiMovie
                ? '${year} • ${_formatDuration(Duration(minutes: widget.apiMovie!.runtime))}'
                : '',
            initialPosition: currentPosition,
            shouldAutoPlay: wasPlaying,
          ),
        ),
      ).then((returnedPosition) {
        // Quand on revient du plein écran, continuer la lecture à la même position
        if (returnedPosition != null && returnedPosition is Duration) {
          // Réactiver le wakelock pour le lecteur intégré
          WakelockPlus.enable();
          print('🔋 Wakelock réactivé - Retour du plein écran avec lecture');

          if (_isVideoInitialized) {
            if (_isUsingMediaKit && _mediaKitPlayer != null) {
              // MediaKit
              _mediaKitPlayer!.seek(returnedPosition);
              _mediaKitPlayer!.play();
            } else if (_chewieController != null &&
                _videoPlayerController != null) {
              // Chewie/VideoPlayer
              _videoPlayerController!.seekTo(returnedPosition);
              _videoPlayerController!.play();
            }
          } else {
            // Si le lecteur n'était pas initialisé, l'initialiser avec la position
            if (_isUsingMediaKit) {
              _initializeMediaKitPlayer(videoUrl);
              // Aller à la position après initialisation
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_mediaKitPlayer != null) {
                  _mediaKitPlayer!.seek(returnedPosition);
                  _mediaKitPlayer!.play();
                }
              });
            } else {
              _initializeChewiePlayer(videoUrl);
              // Aller à la position après initialisation
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_videoPlayerController != null) {
                  _videoPlayerController!.seekTo(returnedPosition);
                  _videoPlayerController!.play();
                }
              });
            }
          }
        }
      });
    }
  }

  Widget _buildTabBar(bool isDarkMode) {
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
          Tab(text: 'Commentaires'),
          Tab(text: 'Similaires'),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isDarkMode) {
    switch (_tabController.index) {
      case 0: // Détails
        return Column(
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
                    overview.isNotEmpty
                        ? overview
                        : 'Aucun synopsis disponible.',
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
            if (isApiMovie && widget.apiMovie!.gallery != null)
              _buildApiGallery(isDarkMode)
            else
              _buildClassicGallery(isDarkMode),

            // Bande-annonce YouTube
            if (isApiMovie && widget.apiMovie!.youTubeTrailerId != null)
              _buildTrailerSection(isDarkMode),

            // Espacement en bas pour surélever le contenu
            const SizedBox(height: 100),
          ],
        );
      case 1: // Commentaires
        return Container(
          height: 600, // Hauteur fixe pour les commentaires
          child: _buildCommentsTab(isDarkMode),
        );
      case 2: // Similaires
        return Column(
          children: [
            Container(
              height: 800, // Hauteur fixe pour les films similaires
              child: _buildSimilarTab(isDarkMode),
            ),
            // Espacement en bas pour surélever le contenu
            const SizedBox(height: 100),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildCastingSection(bool isDarkMode) {
    List<ActorModel> actors = [];

    if (isApiMovie && widget.apiMovie!.cast != null) {
      // Convertir CastMember vers ActorModel pour utiliser HorizontalSection
      actors = widget.apiMovie!.cast!.cast.map((castMember) {
        // Construire l'URL complète pour l'image TMDB
        String imageUrl = '';
        if (castMember.profilePath != null &&
            castMember.profilePath!.isNotEmpty) {
          if (castMember.profilePath!.startsWith('http')) {
            imageUrl = castMember.profilePath!;
          } else {
            // Ajouter le préfixe TMDB si ce n'est qu'un chemin
            imageUrl =
                'https://image.tmdb.org/t/p/w500${castMember.profilePath!}';
          }
        }

        return ActorModel(
          id: castMember.id.toString(),
          name: castMember.name,
          imagePath: imageUrl,
          bio: castMember.character,
        );
      }).toList();
    }

    // Fallback vers les données d'exemple si pas de casting API
    if (actors.isEmpty) {
      actors = SampleData.actors;
    }

    return HorizontalSection<ActorModel>(
      title: 'Casting',
      items: actors,
      itemWidth: 120,
      sectionHeight: 200,
      showSeeMore: actors.length > 6,
      onSeeMoreTap: () {
        // TODO: Naviguer vers une page de casting complète
      },
      isDarkMode: isDarkMode,
      itemBuilder: (actor, index) {
        return ActorCard(
          imagePath: actor.imagePath,
          name: actor.name,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget _buildCommentsTab(bool isDarkMode) {
    return Column(
      children: [
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
        CommentInputField(
          isDarkMode: isDarkMode,
          onSend: () {
            // Ajouter commentaire
          },
        ),
      ],
    );
  }

  Widget _buildSimilarTab(bool isDarkMode) {
    if (isApiMovie && widget.apiMovie!.similarMovies.isNotEmpty) {
      return _buildApiSimilarMovies(isDarkMode);
    }

    // Fallback vers les films d'exemple avec une grille simple
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${SampleData.popularMovies.take(6).length} films similaires',
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
            itemCount: SampleData.popularMovies.take(6).length,
            itemBuilder: (context, index) {
              final movie = SampleData.popularMovies[index];
              return _buildSampleMovieCard(movie, isDarkMode);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSampleMovieCard(MovieModel movie, bool isDarkMode) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen.fromMovie(movie),
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
                  movie.imagePath,
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
                    movie.title,
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
                        movie.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        movie.releaseDate,
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

  Widget _buildApiSimilarMovies(bool isDarkMode) {
    final similarMovies = widget.apiMovie!.similarMovies;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${similarMovies.length} films similaires',
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
              itemCount: similarMovies.length,
              itemBuilder: (context, index) {
                final movie = similarMovies[index];
                return _buildSimilarMovieCard(movie, isDarkMode);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarMovieCard(SimilarMovie movie, bool isDarkMode) {
    return InkWell(
      onTap: () {
        // Navigation vers les détails du film similaire
        // On pourrait créer un MovieApiModel basique à partir de SimilarMovie
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
                child: movie.poster != null
                    ? _buildNetworkOrAssetImage(
                        movie.poster!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
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
                        movie.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        movie.year.toString(),
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

  // Autres méthodes manquantes...
  Widget _buildApiGallery(bool isDarkMode) {
    final gallery = widget.apiMovie!.gallery!;
    final hasTrailer =
        widget.apiMovie!.youTubeTrailerId != null &&
        widget.apiMovie!.youTubeTrailerId!.isNotEmpty;

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

          // Bande-annonce en premier (si disponible)
          if (hasTrailer) ...[
            Text(
              'Bande-annonce',
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                _launchTrailer();
              },
              child: Container(
                width: 200,
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://img.youtube.com/vi/${widget.apiMovie!.youTubeTrailerId}/maxresdefault.jpg',
                        width: 200,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
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
            ),
          ],

          // Backdrops (images horizontales)
          if (gallery.backdrops.isNotEmpty) ...[
            Text(
              'Images du film',
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
                        // Ouvrir la galerie d'images avec toutes les backdrops
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
                        child: _buildNetworkOrAssetImage(
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

          // Posters (images verticales)
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
                        // Ouvrir la galerie d'images avec toutes les affiches
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
                        child: _buildNetworkOrAssetImage(
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

  Widget _buildClassicGallery(bool isDarkMode) {
    final hasTrailer =
        isApiMovie &&
        widget.apiMovie!.youTubeTrailerId != null &&
        widget.apiMovie!.youTubeTrailerId!.isNotEmpty;

    final trailerImages = [
      'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
    ];

    final galleryImages = [
      'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
      'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
    ];

    // Combiner toutes les images pour la galerie
    final allImages = [...trailerImages, ...galleryImages];

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

          // Bande-annonce en premier (si disponible)
          if (hasTrailer) ...[
            Text(
              'Bande-annonce',
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                _launchTrailer();
              },
              child: Container(
                width: 200,
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://img.youtube.com/vi/${widget.apiMovie!.youTubeTrailerId}/maxresdefault.jpg',
                        width: 200,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
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
            ),
          ],

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 16 / 9,
            ),
            itemCount: allImages.length,
            itemBuilder: (context, index) {
              final isTrailer = index < trailerImages.length;
              final imagePath = allImages[index];

              return InkWell(
                onTap: () {
                  if (isTrailer && hasTrailer) {
                    // Lancer la bande-annonce
                    _launchTrailer();
                  } else {
                    // Ouvrir la galerie d'images
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageGalleryViewer(
                          imageUrls: allImages,
                          initialIndex: index,
                          imageNames: List.generate(
                            allImages.length,
                            (i) => i < trailerImages.length
                                ? 'Bande-annonce ${i + 1}'
                                : 'Image ${i - trailerImages.length + 1}',
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
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
                        Image.asset(imagePath, fit: BoxFit.cover),
                        if (isTrailer && hasTrailer) ...[
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrailerSection(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bande-annonce',
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
            ),
            child: InkWell(
              onTap: () {
                // Ouvrir YouTube avec l'ID de la bande-annonce
                print(
                  '🎬 Ouverture YouTube: ${widget.apiMovie!.youTubeTrailerId}',
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://img.youtube.com/vi/${widget.apiMovie!.youTubeTrailerId}/maxresdefault.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubePlayer(bool isDarkMode) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 200, maxHeight: 300),
      color: Colors.black,
      child: Stack(
        children: [
          // Lecteur YouTube avec aspect ratio
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9, // Ratio standard pour YouTube
              child: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
              ),
            ),
          ),

          // Bouton X pour fermer la bande-annonce (en haut à droite)
          // YouTube gère son propre plein écran, on garde seulement le bouton fermer
          SafeArea(
            child: Positioned(
              top: 16,
              right: 16,
              child: InkWell(
                onTap: () {
                  _stopYouTubePlayer();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
