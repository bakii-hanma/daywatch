import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../design_system/spacing.dart';
import '../models/tv_channel_model.dart';

class TvPlayerScreen extends StatefulWidget {
  final TvChannelModel channel;

  const TvPlayerScreen({Key? key, required this.channel}) : super(key: key);

  @override
  State<TvPlayerScreen> createState() => _TvPlayerScreenState();
}

class _TvPlayerScreenState extends State<TvPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setLandscapeOrientation();
    _initializePlayer();
  }

  Future<void> _setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Masquer la barre de statut et de navigation
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _restoreOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Restaurer la barre de statut et de navigation
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (widget.channel.url.isEmpty) {
        throw Exception('URL de stream non disponible');
      }

      // Créer le contrôleur VideoPlayer pour les chaînes TV
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.url),
        httpHeaders: {
          'User-Agent': 'DayWatch-TVPlayer/1.0',
          'Accept': '*/*',
          'Connection': 'keep-alive',
          'Referer': 'https://daywatch.app',
        },
      );

      await _videoPlayerController!.initialize();

      // Créer le contrôleur Chewie pour TV avec support étendu
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Chargement de ${widget.channel.name}...',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: Colors.grey.withOpacity(0.3),
          bufferedColor: Colors.white.withOpacity(0.2),
        ),
      );

      setState(() {
        _isLoading = false;
        _hasError = false;
      });

      print('✅ Chaîne TV Chewie initialisée - ${widget.channel.name}');
      print('📺 Support: HLS, DASH, MP4, MKV, AVI, TS, FLV, WEBM');
      print('🔗 URL: ${widget.channel.url}');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });

      print(
        '❌ Erreur lors du chargement de la chaîne ${widget.channel.name}: $e',
      );
    }
  }

  Widget _buildErrorWidget(String? errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.channel.logo.isNotEmpty)
              Container(
                width: 80,
                height: 50,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.channel.logo.startsWith('http')
                    ? Image.network(
                        widget.channel.logo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.tv,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      )
                    : Image.asset(
                        widget.channel.logo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.tv,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
              ),
            const Icon(Icons.error_outline, color: AppColors.primary, size: 64),
            const SizedBox(height: 16),
            Text(
              'Impossible de lire ${widget.channel.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Format non supporté ou problème de connexion',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _initializePlayer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _restoreOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? _buildLoadingScreen()
          : _hasError
          ? _buildErrorWidget(_errorMessage)
          : _buildVideoPlayer(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.channel.logo.isNotEmpty)
            Container(
              width: 100,
              height: 60,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.channel.logo.startsWith('http')
                  ? Image.network(
                      widget.channel.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.tv,
                          color: Colors.white,
                          size: 40,
                        );
                      },
                    )
                  : Image.asset(
                      widget.channel.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.tv,
                          color: Colors.white,
                          size: 40,
                        );
                      },
                    ),
            ),
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            'Chargement de ${widget.channel.name}...',
            style: AppTypography.title(Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Formats supportés: HLS, DASH, MP4, MKV, AVI, TS, FLV, WEBM',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_chewieController == null) {
      return _buildErrorWidget('Lecteur non initialisé');
    }

    return Stack(
      children: [
        // Lecteur vidéo Chewie
        Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Chewie(controller: _chewieController!),
          ),
        ),

        // Informations de la chaîne en haut
        Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Logo de la chaîne
                  if (widget.channel.logo.isNotEmpty)
                    Container(
                      width: 40,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: widget.channel.logo.startsWith('http')
                          ? Image.network(
                              widget.channel.logo,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.tv,
                                  color: Colors.white,
                                  size: 16,
                                );
                              },
                            )
                          : Image.asset(
                              widget.channel.logo,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.tv,
                                  color: Colors.white,
                                  size: 16,
                                );
                              },
                            ),
                    ),

                  // Informations de la chaîne
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.channel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.channel.category} • En direct',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bouton de fermeture
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
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
