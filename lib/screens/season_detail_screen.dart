import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../design_system/colors.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../widgets/common/episode_card.dart';
import '../screens/episode_detail_screen.dart';
import '../services/series_service.dart';
import '../config/server_config.dart';

class SeasonDetailScreen extends StatefulWidget {
  final SeasonModel season;
  final String? seriesId; // ID de la série pour récupérer les épisodes
  final int? seasonNumber; // Numéro de la saison pour récupérer les épisodes
  final List<EpisodeApiModel>? episodes; // Épisodes déjà récupérés

  const SeasonDetailScreen({super.key, required this.season})
    : seriesId = null,
      seasonNumber = null,
      episodes = null;

  const SeasonDetailScreen.fromApi({
    super.key,
    required this.season,
    required this.seriesId,
    required this.seasonNumber,
    this.episodes, // Nouveau paramètre pour les épisodes pré-récupérés
  });

  @override
  State<SeasonDetailScreen> createState() => _SeasonDetailScreenState();
}

class _SeasonDetailScreenState extends State<SeasonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<EpisodeApiModel> _episodes = [];
  bool _isLoadingEpisodes = false;
  String? _episodesError;

  // Variables pour le lecteur vidéo
  bool _isPlayerVisible = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showNormalInterface = true;

  // Variables pour MediaKit (fallback)
  Player? _mediaKitPlayer;
  VideoController? _mediaKitController;
  bool _isUsingMediaKit = false;

  // Épisode en cours de lecture
  EpisodeApiModel? _currentEpisode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    print(
      '🔄 Début du chargement des épisodes pour la saison ${widget.seasonNumber}',
    );

    // Si les épisodes sont déjà fournis, les utiliser directement
    if (widget.episodes != null) {
      setState(() {
        _episodes = widget.episodes!;
        _isLoadingEpisodes = false;
      });
      print('✅ Utilisation de ${_episodes.length} épisodes pré-récupérés');

      // Debug: afficher les détails des épisodes
      for (var episode in _episodes.take(3)) {
        print(
          '   - Épisode ${episode.episodeNumber}: ${episode.title} (${episode.runtime}min)',
        );
        if (episode.stillPath != null) {
          print('     📸 Still: ${episode.stillPath}');
        }
      }
      return;
    }

    // Sinon, récupérer les épisodes depuis l'API
    if (widget.seriesId == null || widget.seasonNumber == null) {
      print(
        '⚠️ Pas d\'ID de série ou de numéro de saison, utilisation des données d\'exemple',
      );
      return;
    }

    setState(() {
      _isLoadingEpisodes = true;
      _episodesError = null;
    });

    try {
      print('📥 Récupération des épisodes depuis l\'API...');
      final episodes = await SeriesService.getSeasonEpisodes(
        seriesId: widget.seriesId!,
        seasonNumber: widget.seasonNumber!,
      );

      setState(() {
        _episodes = episodes;
        _isLoadingEpisodes = false;
      });

      print('✅ ${episodes.length} épisodes récupérés depuis l\'API');
    } catch (e) {
      print('❌ Erreur lors du chargement des épisodes: $e');
      setState(() {
        _episodesError = 'Erreur lors du chargement des épisodes: $e';
        _isLoadingEpisodes = false;
      });
    }
  }

  @override
  void dispose() {
    // S'assurer que le wakelock est désactivé en quittant l'écran
    if (_isPlayerVisible) {
      WakelockPlus.disable();
      print('🔋 Wakelock désactivé - Sortie de l\'écran de détails de saison');
    }

    _tabController.dispose();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
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
            // Header avec poster et boutons
            _buildHeaderSection(isDarkMode),

            // Bouton "Regarder maintenant"
            _buildWatchNowButton(isDarkMode),

            // Tabs (Détails, Épisodes)
            _buildTabSection(isDarkMode),
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
            _isPlayerVisible
                ? Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 200, maxHeight: 300),
                    child: _buildVideoPlayer(isDarkMode),
                  )
                : SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: _buildSeasonImage(),
                  ),

            // Gradient overlay (seulement si pas en mode lecteur)
            if (!_isPlayerVisible)
              Container(
                height: 250,
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
            if (!_isPlayerVisible)
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
                  child: _buildSeasonPoster(),
                ),
              ),

              const SizedBox(width: 16),

              // Informations à côté du poster
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.season.title,
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
                            widget.season.episodes,
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
                            widget.season.year,
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
                                widget.season.rating.toString(),
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
                      'Saison complète',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 14,
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

  Widget _buildWatchNowButton(bool isDarkMode) {
    // Vérifier s'il y a des épisodes disponibles
    final hasEpisodes = _episodes.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _isPlayerVisible || !hasEpisodes
              ? null
              : () {
                  _startFirstEpisode();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPlayerVisible || !hasEpisodes
                ? Colors.grey
                : Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(
            _isPlayerVisible ? Icons.play_disabled : Icons.play_arrow,
            color: Colors.white,
          ),
          label: Text(
            _isPlayerVisible
                ? 'Lecture en cours'
                : hasEpisodes
                ? 'Commencer la saison'
                : 'Aucun épisode disponible',
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

  void _startFirstEpisode() {
    if (_episodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun épisode disponible pour cette saison'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final firstEpisode = _episodes.first;
    print('🎬 Lancement du premier épisode: ${firstEpisode.title}');

    _launchEpisodePlayer(firstEpisode);
  }

  void _launchEpisodePlayer(EpisodeApiModel episode) {
    print('🎬 _launchEpisodePlayer appelé pour: ${episode.title}');
    print('📁 Episode hasFile: ${episode.hasFile}');
    print('📁 Episode file: ${episode.file?.fullPath}');

    // Debug: afficher la structure complète de l'épisode
    print('🔍 Structure complète de l\'épisode:');
    print('   - ID: ${episode.id}');
    print('   - Title: ${episode.title}');
    print('   - hasFile: ${episode.hasFile}');
    print('   - file: ${episode.file}');

    // Essayer de récupérer le chemin depuis différentes sources
    String? videoPath;

    if (episode.file != null && episode.file!.fullPath.isNotEmpty) {
      videoPath = episode.file!.fullPath;
      print('✅ Chemin trouvé dans file.fullPath: $videoPath');
    } else {
      print('❌ Aucun chemin de fichier trouvé');
      _showErrorDialog('Aucun fichier vidéo disponible pour cet épisode.');
      return;
    }

    if (episode.hasFile && videoPath.isNotEmpty) {
      // Construire l'URL complète avec le préfixe du serveur
      final videoUrl = ServerConfig.getStreamingUrl(videoPath);

      print('🎬 Lancement du lecteur avec URL: $videoUrl');

      // Initialiser le contrôleur vidéo
      _initializeChewiePlayer(videoUrl, episode);

      // Activer le wakelock pour empêcher la mise en veille
      WakelockPlus.enable();
      print('🔋 Wakelock activé - Lecture d\'épisode démarrée');

      // Afficher le lecteur à la place du header et réinitialiser l'interface
      setState(() {
        _isPlayerVisible = true;
        _currentEpisode = episode;
        _showNormalInterface = true;
      });
    } else {
      print('❌ Aucun fichier vidéo disponible pour l\'épisode');
      _showErrorDialog('Aucun fichier vidéo disponible pour cet épisode.');
    }
  }

  void _initializeChewiePlayer(String videoUrl, EpisodeApiModel episode) {
    // Libérer les contrôleurs précédents s'ils existent
    _chewieController?.dispose();
    _videoPlayerController?.dispose();

    print('🎬 Initialisation du lecteur avec URL: $videoUrl');

    // Encoder correctement l'URL pour gérer les espaces et caractères spéciaux
    final encodedUrl = _encodeVideoUrl(videoUrl);
    print('🔗 URL encodée: $encodedUrl');

    // Créer le contrôleur VideoPlayer avec headers optimisés
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
            showOptions: false,
            showControls: false,
            placeholder: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement de l\'épisode...',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      episode.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
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
                        onPressed: () =>
                            _initializeChewiePlayer(videoUrl, episode),
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
          _initializeMediaKitPlayer(videoUrl, episode);
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

  void _initializeMediaKitPlayer(
    String videoUrl,
    EpisodeApiModel episode,
  ) async {
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
        'Impossible de lire cet épisode.\n\n'
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

  void _stopVideoPlayer() {
    // Désactiver le wakelock
    WakelockPlus.disable();
    print('🔋 Wakelock désactivé - Lecture d\'épisode arrêtée');

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
      _currentEpisode = null;
    });
  }

  Widget _buildVideoPlayer(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showNormalInterface = !_showNormalInterface;
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
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        _isUsingMediaKit
                            ? 'Chargement MediaKit Player...'
                            : 'Chargement de l\'épisode...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
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
                      const Icon(
                        Icons.play_circle_filled,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lecteur d\'épisode',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (_currentEpisode != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _currentEpisode!.title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

            // Contrôles de lecteur superposés
            if (_isVideoInitialized &&
                (_chewieController != null || _isUsingMediaKit) &&
                _showNormalInterface)
              _buildVideoControls(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonImage() {
    // Prioriser explicitement le fanart pour l'image de fond
    String backgroundImage;

    print('🎬 Saison ${widget.season.title}:');
    print('   🖼️ Fanart: ${widget.season.fanart ?? "Non disponible"}');
    print('   🎭 Banner: ${widget.season.banner ?? "Non disponible"}');
    print('   📸 Poster: ${widget.season.poster ?? "Non disponible"}');
    print('   📷 ImagePath: ${widget.season.imagePath}');

    // Prioriser le fanart en premier pour l'image de fond
    if (widget.season.fanart != null && widget.season.fanart!.isNotEmpty) {
      backgroundImage = widget.season.fanart!;
      print('   ✅ Utilisation du FANART comme image de fond: $backgroundImage');
    } else if (widget.season.banner != null &&
        widget.season.banner!.isNotEmpty) {
      backgroundImage = widget.season.banner!;
      print('   ✅ Utilisation du BANNER comme image de fond: $backgroundImage');
    } else {
      backgroundImage = widget.season.imagePath;
      print(
        '   ✅ Utilisation de l\'IMAGE PATH comme image de fond: $backgroundImage',
      );
    }

    return Image.network(
      backgroundImage,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Erreur de chargement de l\'image de fond: $error');
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.tv, size: 40, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildSeasonPoster() {
    // Utiliser le poster spécifique de la saison en priorité, puis l'image par défaut
    final posterImage = widget.season.getPosterImage();

    print('📸 Poster de saison utilisé: $posterImage');

    return Image.network(
      posterImage,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Erreur de chargement du poster: $error');
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.tv, size: 40, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildVideoControls(bool isDarkMode) {
    return Stack(
      children: [
        // Bouton retour en haut à gauche
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  _stopVideoPlayer();
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
                      if (_isUsingMediaKit && _mediaKitPlayer != null) {
                        final currentPosition = _mediaKitPlayer!.state.position;
                        final newPosition =
                            currentPosition - const Duration(seconds: 10);
                        _mediaKitPlayer!.seek(
                          newPosition < Duration.zero
                              ? Duration.zero
                              : newPosition,
                        );
                      } else if (_videoPlayerController != null) {
                        final currentPosition =
                            _videoPlayerController!.value.position;
                        final newPosition =
                            currentPosition - const Duration(seconds: 10);
                        _videoPlayerController!.seekTo(
                          newPosition < Duration.zero
                              ? Duration.zero
                              : newPosition,
                        );
                      }
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

                  // Bouton play/pause personnalisé
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _videoPlayerController!,
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: () {
                          if (_isUsingMediaKit && _mediaKitPlayer != null) {
                            if (_mediaKitPlayer!.state.playing) {
                              _mediaKitPlayer!.pause();
                            } else {
                              _mediaKitPlayer!.play();
                            }
                          } else if (_videoPlayerController != null) {
                            if (value.isPlaying) {
                              _videoPlayerController!.pause();
                            } else {
                              _videoPlayerController!.play();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.red : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            _isUsingMediaKit
                                ? (_mediaKitPlayer?.state.playing == true
                                      ? Icons.pause
                                      : Icons.play_arrow)
                                : (value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow),
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
                      if (_isUsingMediaKit && _mediaKitPlayer != null) {
                        final currentPosition = _mediaKitPlayer!.state.position;
                        final duration = _mediaKitPlayer!.state.duration;
                        final newPosition =
                            currentPosition + const Duration(seconds: 10);
                        _mediaKitPlayer!.seek(
                          newPosition > duration ? duration : newPosition,
                        );
                      } else if (_videoPlayerController != null) {
                        final currentPosition =
                            _videoPlayerController!.value.position;
                        final duration = _videoPlayerController!.value.duration;
                        final newPosition =
                            currentPosition + const Duration(seconds: 10);
                        _videoPlayerController!.seekTo(
                          newPosition > duration ? duration : newPosition,
                        );
                      }
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
              Tab(text: 'Épisodes'),
            ],
          ),
        ),

        // Tab Content
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(isDarkMode),
              _buildEpisodesTab(isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(bool isDarkMode) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Synopsis
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
              widget.season.description,
              style: TextStyle(
                color: AppColors.getTextSecondaryColor(isDarkMode),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Informations générales
            Text(
              'Informations',
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoRow('Épisodes', widget.season.episodes, isDarkMode),
            const SizedBox(height: 8),
            _buildInfoRow('Année', widget.season.year, isDarkMode),
            const SizedBox(height: 8),
            _buildInfoRow('Note', '${widget.season.rating}/10', isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodesTab(bool isDarkMode) {
    if (_isLoadingEpisodes) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des épisodes...'),
          ],
        ),
      );
    }

    if (_episodesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _episodesError!,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadEpisodes, child: Text('Réessayer')),
          ],
        ),
      );
    }

    // Indicateur si les épisodes sont pré-récupérés
    Widget? episodesHeader;
    if (widget.episodes != null && widget.episodes!.isNotEmpty) {
      episodesHeader = Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text(
              '${_episodes.length} épisodes chargés instantanément',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_episodes.isEmpty) {
      // Fallback vers les données d'exemple
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          if (episodesHeader != null) episodesHeader,
          ...widget.season.episodesList.map((episode) {
            return EpisodeCard(
              imagePath: episode.imagePath,
              title: episode.title,
              duration: episode.duration,
              description: episode.description,
              episodeNumber: episode.episodeNumber,
              rating: episode.rating,
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpisodeDetailScreen(
                      episode: episode,
                      seasonTitle: widget.season.title,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      );
    }

    // Afficher les épisodes de l'API
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (episodesHeader != null) episodesHeader,
        ..._episodes.map((apiEpisode) {
          return EpisodeCard.fromApi(
            episode: apiEpisode,
            isDarkMode: isDarkMode,
          );
        }),
      ],
    );
  }
}
