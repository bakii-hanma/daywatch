import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../design_system/colors.dart';

class FullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String subtitle;
  final Duration? initialPosition;
  final bool shouldAutoPlay;

  const FullscreenVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.title,
    this.subtitle = '',
    this.initialPosition,
    this.shouldAutoPlay = false,
  }) : super(key: key);

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Forcer l'orientation paysage
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Masquer la barre de statut
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Activer le wakelock pour empêcher la mise en veille
    WakelockPlus.enable();
    print('🔋 Wakelock activé - Écran maintenu allumé');

    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    // Désactiver le wakelock
    WakelockPlus.disable();
    print('🔋 Wakelock désactivé - Retour à la gestion normale de l\'écran');

    // Restaurer l'orientation portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Restaurer la barre de statut
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _exitFullscreen() {
    // Désactiver le wakelock avant de quitter
    WakelockPlus.disable();
    print('🔋 Wakelock désactivé - Sortie du plein écran');

    // Récupérer la position actuelle avant de fermer
    Duration? currentPosition;
    if (_videoPlayerController != null && _isVideoInitialized) {
      currentPosition = _videoPlayerController!.value.position;
    }

    // Retourner la position au parent
    Navigator.pop(context, currentPosition);
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      httpHeaders: {
        'User-Agent': 'DayWatch-Player/1.0',
        'Accept': '*/*',
        'Connection': 'keep-alive',
      },
    );

    _videoPlayerController!
        .initialize()
        .then((_) {
          // Créer le contrôleur Chewie après l'initialisation de VideoPlayer
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: widget.shouldAutoPlay,
            looping: false,
            allowFullScreen: true,
            allowMuting: true,
            allowPlaybackSpeedChanging: true,
            showControlsOnInitialize: true,
            placeholder: Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
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
                        color: Colors.white,
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
                        'Vérifiez le format ou la connexion',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _initializeVideoPlayer(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            },
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.primary,
              handleColor: AppColors.primary,
              backgroundColor: Colors.grey.withOpacity(0.3),
              bufferedColor: Colors.white.withOpacity(0.2),
            ),
            customControls: _buildCustomControls(),
          );

          setState(() {
            _isVideoInitialized = true;
            _isLoading = false;
          });

          // Si une position initiale est fournie, aller à cette position
          if (widget.initialPosition != null) {
            _videoPlayerController!.seekTo(widget.initialPosition!);
          }

          print('✅ Lecteur vidéo Chewie initialisé');
          print('📺 URL: ${widget.videoUrl}');
          print('🎬 Formats supportés: MP4, MKV, AVI, TS, WEBM, MOV, FLV');
        })
        .catchError((error) {
          print('❌ Erreur lors de l\'initialisation de la vidéo: $error');
          setState(() {
            _isLoading = false;
          });
        });
  }

  Widget _buildCustomControls() {
    return MaterialControls();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _exitFullscreen();
        return false; // On gère manuellement la navigation
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isVideoInitialized && _chewieController != null
            ? Stack(
                children: [
                  // Lecteur vidéo avec Chewie
                  Center(child: Chewie(controller: _chewieController!)),

                  // Bouton de sortie personnalisé en haut à gauche
                  Positioned(
                    top: 40,
                    left: 16,
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _exitFullscreen,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Titre et informations en haut
                  Positioned(
                    top: 40,
                    left: 70,
                    right: 16,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _buildLoadingOrError(),
      ),
    );
  }

  Widget _buildLoadingOrError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading) ...[
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Chargement de la vidéo...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Formats supportés: MP4, MKV, AVI, TS, FLV, WEBM, MOV',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const Icon(Icons.error_outline, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Erreur de lecture',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez le format ou la connexion',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
