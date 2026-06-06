import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';
import '../../screens/fullscreen_video_player.dart';

class TrailerCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String duration;
  final bool isDarkMode;
  final VoidCallback? onPlayTap;
  final String? trailerUrl;

  const TrailerCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.duration,
    required this.isDarkMode,
    this.onPlayTap,
    this.trailerUrl,
  });

  @override
  State<TrailerCard> createState() => _TrailerCardState();
}

class _TrailerCardState extends State<TrailerCard> {
  YoutubePlayerController? _controller;
  bool _isPlaying = false;
  bool _showPlayer = false;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _extractVideoId();
  }

  void _extractVideoId() {
    if (widget.trailerUrl != null && widget.trailerUrl!.isNotEmpty) {
      _videoId = YoutubePlayer.convertUrlToId(widget.trailerUrl!);
      if (_videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: _videoId!,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            captionLanguage: 'fr',
            showLiveFullscreenButton: true,
          ),
        );
      }
    }
  }

  // Détermine si l'image est une URL ou un asset
  bool get _isNetworkImage => widget.imagePath.startsWith('http');

  void _togglePlayPause() {
    if (_controller != null) {
      setState(() {
        if (_isPlaying) {
          _controller!.pause();
          _isPlaying = false;
          // Désactiver le wakelock
          WakelockPlus.disable();
        } else {
          if (!_showPlayer) {
            _showPlayer = true;
          }
          _controller!.play();
          _isPlaying = true;
          // Activer le wakelock pour empêcher la mise en veille
          WakelockPlus.enable();
        }
      });
    } else if (widget.onPlayTap != null) {
      widget.onPlayTap!();
    }
  }

  void _openFullscreen() {
    if (_controller != null && _videoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullscreenVideoPlayer(
            videoUrl: widget.trailerUrl!,
            title: widget.title,
          ),
        ),
      );
    }
  }

  void _closePlayer() {
    setState(() {
      _showPlayer = false;
      _isPlaying = false;
      if (_controller != null) {
        _controller!.pause();
      }
      // Désactiver le wakelock
      WakelockPlus.disable();
    });
  }

  @override
  void dispose() {
    // S'assurer que le wakelock est désactivé en quittant le widget
    if (_isPlaying) {
      WakelockPlus.disable();
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container principal avec image/vidéo et overlay
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackOverlay(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Stack(
                children: [
                  // Lecteur vidéo ou image de fond
                  _showPlayer && _controller != null
                      ? YoutubePlayer(
                          controller: _controller!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: AppColors.primary,
                          progressColors: ProgressBarColors(
                            playedColor: AppColors.primary,
                            handleColor: AppColors.primary,
                          ),
                          onReady: () {},
                          onEnded: (metaData) {
                            setState(() {
                              _isPlaying = false;
                            });
                            // Désactiver le wakelock quand la vidéo se termine
                            WakelockPlus.disable();
                          },
                        )
                      : Stack(
                          children: [
                            // Image de fond - adaptée pour URL ou asset
                            _isNetworkImage
                                ? Image.network(
                                    widget.imagePath,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.textSecondaryLight,
                                        child: const Icon(
                                          Icons.movie,
                                          color: AppColors.white,
                                          size: 60,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: AppColors.getCardColor(
                                          widget.isDarkMode,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    widget.imagePath,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.textSecondaryLight,
                                        child: const Icon(
                                          Icons.movie,
                                          color: AppColors.white,
                                          size: 60,
                                        ),
                                      );
                                    },
                                  ),
                            // Overlay noir avec dégradé
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.blackOverlay(0.3),
                                    AppColors.blackOverlay(0.7),
                                  ],
                                ),
                              ),
                            ),
                            // Bouton play au centre
                            Center(
                              child: GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.blackOverlay(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: AppColors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            // Texte "BANDE-ANNONCE" au centre
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 80),
                                child: Text(
                                  'BANDE-ANNONCE',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: AppTypography.fontSizeLarge,
                                    fontWeight: AppTypography.fontWeightBold,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.blackOverlay(0.8),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                  // Contrôles vidéo (seulement quand la vidéo est en cours de lecture)
                  if (_showPlayer && _controller != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          // Bouton plein écran
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.blackOverlay(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.fullscreen,
                                color: AppColors.white,
                                size: 20,
                              ),
                              onPressed: _openFullscreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Bouton fermer
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.blackOverlay(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.white,
                                size: 20,
                              ),
                              onPressed: _closePlayer,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Titre et durée
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: AppTypography.subtitle(
                  AppColors.getTextColor(widget.isDarkMode),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.duration.isNotEmpty)
              Text(
                widget.duration,
                style: AppTypography.body(
                  AppColors.getTextSecondaryColor(widget.isDarkMode),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
