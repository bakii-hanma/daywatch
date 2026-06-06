import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../design_system/colors.dart';
import '../widgets/common/trailer_card.dart';
import '../models/movie_model.dart';
import '../services/trailer_service.dart';

class TrailersScreen extends StatefulWidget {
  const TrailersScreen({super.key});

  @override
  State<TrailersScreen> createState() => _TrailersScreenState();
}

class _TrailersScreenState extends State<TrailersScreen> {
  List<TrailerApiModel> _trailers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrailers();
  }

  Future<void> _loadTrailers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Charger tous les trailers (pas de limite)
      final trailers = await TrailerService.getRecentTrailers();

      setState(() {
        _trailers = trailers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les bandes-annonces';
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadTrailers();
  }

  @override
  void dispose() {
    // S'assurer que le wakelock est désactivé en quittant l'écran
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getSearchBackgroundColor(isDarkMode),
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.getTextColor(isDarkMode),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Bandes annonces',
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Compteur de trailers
                  if (!_isLoading && _trailers.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_trailers.length}',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Contenu principal
            Expanded(child: _buildContent(isDarkMode)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Chargement des bandes-annonces...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getTextColor(isDarkMode),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrailers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_trailers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune bande-annonce disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez la connexion au serveur',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondaryColor(isDarkMode),
              ),
            ),
          ],
        ),
      );
    }

    // Liste des trailers avec pull-to-refresh
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.red,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1.5,
          mainAxisSpacing: 20,
        ),
        itemCount: _trailers.length,
        itemBuilder: (context, index) {
          final trailer = _trailers[index];
          return TrailerCard(
            imagePath: trailer.fullPosterUrl.isNotEmpty
                ? trailer.fullPosterUrl
                : 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
            title: trailer.title,
            duration: trailer.duration,
            isDarkMode: isDarkMode,
            trailerUrl: trailer.trailerUrl,
            onPlayTap: () {
              print('🎬 Lecture trailer: ${trailer.title}');
              print('🔗 URL: ${trailer.trailerUrl}');
            },
          );
        },
      ),
    );
  }
}
