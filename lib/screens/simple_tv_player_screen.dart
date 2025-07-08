import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../models/tv_channel_model.dart';

class SimpleTvPlayerScreen extends StatefulWidget {
  final TvChannelModel channel;

  const SimpleTvPlayerScreen({Key? key, required this.channel})
    : super(key: key);

  @override
  State<SimpleTvPlayerScreen> createState() => _SimpleTvPlayerScreenState();
}

class _SimpleTvPlayerScreenState extends State<SimpleTvPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _showControls = true;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

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
      if (widget.channel.url.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Aucun stream disponible pour cette chaîne';
        });
        return;
      }

      // Créer le contrôleur VideoPlayer
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.url),
        httpHeaders: {
          'User-Agent': 'DayWatch-SimplePlayer/1.0',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },
      );

      await _videoPlayerController!.initialize();

      // Créer le contrôleur Chewie
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: false,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
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

      print('✅ Lecteur simple Chewie initialisé - ${widget.channel.name}');
      print('📺 Support: MP4, MKV, AVI, TS, FLV, WEBM, HLS, DASH');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });

      print('❌ Erreur lecteur simple ${widget.channel.name}: $e');
    }
  }

  Widget _buildErrorWidget(String? errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la chaîne si disponible
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
            const Text(
              'Format non supporté ou problème de connexion',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null && errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
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

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // Masquer automatiquement après 3 secondes
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showControls) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
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
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Zone de lecture vidéo
            _buildVideoPlayer(),

            // Contrôles overlay
            if (_showControls) _buildControlsOverlay(),

            // Indicateur de chargement
            if (_isLoading) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return _buildErrorWidget(_errorMessage);
    }

    if (_chewieController == null) {
      return _buildLoadingIndicator();
    }

    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
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
                margin: const EdgeInsets.only(bottom: 20),
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

            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              'Chargement de ${widget.channel.name}...',
              style: AppTypography.title(Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Support: MP4, MKV, AVI, TS, FLV, WEBM, HLS, DASH',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header simple
            _buildSimpleHeader(),

            const Spacer(),

            // Contrôles centraux
            _buildSimpleControls(),

            const Spacer(),

            // Footer minimal
            _buildSimpleFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Indicateur en direct
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'DIRECT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Nom de la chaîne
          Expanded(
            child: Text(
              widget.channel.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Bouton fermer
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton actualiser
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _initializePlayer,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _hasError
                  ? Colors.red.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _hasError ? Colors.red : Colors.green),
            ),
            child: Text(
              _hasError ? 'Erreur' : 'En direct',
              style: TextStyle(
                color: _hasError ? Colors.red : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Spacer(),

          // Instructions
          const Text(
            'Touchez pour afficher/masquer',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
