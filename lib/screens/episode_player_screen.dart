import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../design_system/colors.dart';
import '../models/series_model.dart';
import '../config/server_config.dart';

class EpisodePlayerScreen extends StatefulWidget {
  final EpisodeApiModel episode;

  const EpisodePlayerScreen({Key? key, required this.episode})
    : super(key: key);

  @override
  State<EpisodePlayerScreen> createState() => _EpisodePlayerScreenState();
}

class _EpisodePlayerScreenState extends State<EpisodePlayerScreen> {
  bool _isPlayerVisible = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showNormalInterface = true;

  // Variables pour MediaKit (fallback)
  Player? _mediaKitPlayer;
  VideoController? _mediaKitController;
  bool _isUsingMediaKit = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    if (widget.episode.file == null) {
      _showErrorDialog('Aucun fichier vidéo disponible pour cet épisode.');
      return;
    }

    final fileInfo = widget.episode.file!;

    // Utiliser fullPath directement
    if (fileInfo.fullPath.isEmpty) {
      _showErrorDialog('Aucun chemin de fichier disponible pour cet épisode.');
      return;
    }

    final videoPath = fileInfo.fullPath;
    print('📂 Utilisation du chemin complet: $videoPath');

    final videoUrl = ServerConfig.getStreamingUrl(videoPath!);

    print('🎬 Initialisation du lecteur d\'épisode');
    print('📁 Fichier: ${fileInfo.fileName}');
    print('🔗 URL finale: $videoUrl');
    print(
      '🎬 Qualité: ${fileInfo.quality.name} (${fileInfo.quality.resolution}p)',
    );
    print('📊 Taille: ${fileInfo.sizeGB}GB');

    // Activer le wakelock
    WakelockPlus.enable();
    print('🔋 Wakelock activé - Lecture d\'épisode démarrée');

    setState(() {
      _isPlayerVisible = true;
    });

    _initializeChewiePlayer(videoUrl);
  }

  void _initializeChewiePlayer(String videoUrl) {
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Chargement de l\'épisode...',
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
          print('🚀 Tentative de fallback vers MediaKit...');

          // Essayer MediaKit comme fallback
          _initializeMediaKitPlayer(videoUrl);
        });
  }

  // Encoder l'URL pour gérer les espaces et caractères spéciaux
  String _encodeVideoUrl(String url) {
    final uri = Uri.parse(url);
    final scheme = uri.scheme;
    final host = uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';
    final pathSegments = uri.pathSegments;

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

    if (isAviFile) {
      headers.addAll({
        'Accept':
            'video/avi, video/msvideo, video/x-msvideo, application/octet-stream, */*',
        'Range': 'bytes=0-',
      });
      print('📹 Headers AVI optimisés appliqués');
    }

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

  void _stopPlayer() {
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
      _isPlayerVisible = false;
    });
  }

  @override
  void dispose() {
    _stopPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header avec informations de l'épisode
            if (!_isPlayerVisible)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.episode.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Saison ${widget.episode.seasonNumber} • Épisode ${widget.episode.episodeNumber}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Lecteur vidéo
            Expanded(
              child: _isPlayerVisible
                  ? _buildVideoPlayer(isDarkMode)
                  : _buildPlaceholder(isDarkMode),
            ),
          ],
        ),
      ),
    );
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
              _buildLoadingScreen(isDarkMode),

            // Contrôles personnalisés
            if (_isVideoInitialized &&
                (_chewieController != null || _isUsingMediaKit) &&
                _showNormalInterface)
              _buildVideoControls(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_videoPlayerController != null && !_isVideoInitialized) ...[
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _isUsingMediaKit
                  ? 'Chargement MediaKit Player...'
                  : 'Chargement de l\'épisode...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (_isUsingMediaKit) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            const Icon(Icons.play_circle_filled, color: Colors.white, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Lecteur d\'épisode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.episode.title,
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_filled, color: Colors.white, size: 80),
          const SizedBox(height: 16),
          const Text(
            'Lecteur d\'épisode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.episode.title,
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializePlayer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Lancer l\'épisode'),
          ),
        ],
      ),
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
                  _stopPlayer();
                  Navigator.pop(context);
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
                  if (_isUsingMediaKit && _mediaKitPlayer != null)
                    InkWell(
                      onTap: () {
                        if (_mediaKitPlayer!.state.playing) {
                          _mediaKitPlayer!.pause();
                        } else {
                          _mediaKitPlayer!.play();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.red : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          _mediaKitPlayer!.state.playing
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: isDarkMode ? Colors.white : Colors.red,
                          size: 36,
                        ),
                      ),
                    )
                  else if (_videoPlayerController != null)
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
}
