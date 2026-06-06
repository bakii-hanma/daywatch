import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../widgets/common/marquee_text.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../services/download_service.dart';
import 'movie_detail_screen.dart';
import 'series_detail_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};
  
  List<MovieApiModel> _downloadedMovies = [];
  List<SeriesApiModel> _downloadedSeries = [];
  bool _isLoading = true;

  String _storageUsedString = '0.0 GB';
  String _moviesSizeString = '0.0 GB';
  String _seriesSizeString = '0.0 GB';

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    setState(() => _isLoading = true);
    final movies = await DownloadService.getDownloadedMovies();
    final series = await DownloadService.getDownloadedSeries();
    final storageStr = await DownloadService.getStorageUsedString();
    
    if (mounted) {
      setState(() {
        _downloadedMovies = movies;
        _downloadedSeries = series;
        _storageUsedString = storageStr;
        _moviesSizeString = '${(movies.length * 1.2).toStringAsFixed(1)} GB';
        _seriesSizeString = '${(series.length * 0.6).toStringAsFixed(1)} GB';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(isDarkMode, textColor),

              // Informations de stockage
              _isLoading 
                  ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
                  : _buildStorageInfo(isDarkMode),

              // Barre d'actions en mode sélection
              if (_isSelectionMode) _buildSelectionActions(isDarkMode),

              // Tab Bar Films/Séries
              _buildTabBar(isDarkMode),

              // Contenu des onglets
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        children: [
                          _buildDownloadsList(isDarkMode, true),
                          _buildDownloadsList(isDarkMode, false),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: textColor),
          ),
          Expanded(
            child: Text(
              'Téléchargements',
              style: AppTypography.header(textColor),
              textAlign: TextAlign.center,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            onSelected: (value) {
              switch (value) {
                case 'select':
                  setState(() {
                    _isSelectionMode = !_isSelectionMode;
                    if (!_isSelectionMode) _selectedItems.clear();
                  });
                  break;
                case 'deleteAll':
                  _showDeleteAllDialog();
                  break;
                case 'settings':
                  _showDownloadSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'select',
                child: Row(
                  children: [
                    Icon(
                      _isSelectionMode ? Icons.close : Icons.checklist,
                      size: 20,
                      color: textColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isSelectionMode ? 'Annuler' : 'Sélectionner',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'deleteAll',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text('Tout supprimer', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20, color: textColor),
                    const SizedBox(width: 12),
                    Text('Paramètres', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(bool isDarkMode) {
    // Calcul de la jauge sur un max simulé de 32 Go
    final totalElements = _downloadedMovies.length + _downloadedSeries.length;
    double progress = 0.0;
    try {
      final sizeStr = _storageUsedString.split(' ')[0];
      final size = double.tryParse(sizeStr) ?? 0.0;
      progress = size / 32.0;
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getWidgetBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stockage utilisé',
                style: TextStyle(
                  color: AppColors.getTextColor(isDarkMode),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$_storageUsedString / 32 GB',
                style: TextStyle(
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.getTextSecondaryColor(
                isDarkMode,
              ).withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStorageDetail('Films', _moviesSizeString, '${_downloadedMovies.length} éléments', isDarkMode),
              _buildStorageDetail('Séries', _seriesSizeString, '${_downloadedSeries.length} éléments', isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageDetail(
    String type,
    String size,
    String count,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          type,
          style: TextStyle(
            color: AppColors.getTextColor(isDarkMode),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          size,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          count,
          style: TextStyle(
            color: AppColors.getTextSecondaryColor(isDarkMode),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionActions(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedItems.length} élément(s) sélectionné(s)',
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (_selectedItems.isNotEmpty)
            TextButton.icon(
              onPressed: _deleteSelectedItems,
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              label: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.getButtonColor(isDarkMode),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: () =>
                              DefaultTabController.of(context).animateTo(0),
                          child: AnimatedBuilder(
                            animation: DefaultTabController.of(context),
                            builder: (context, child) {
                              final tabController = DefaultTabController.of(
                                context,
                              );
                              final isSelected = tabController.index == 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.getBackgroundColor(isDarkMode)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  'Films',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.getTextColor(isDarkMode)
                                        : AppColors.getTextSecondaryColor(
                                            isDarkMode,
                                          ),
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: () =>
                              DefaultTabController.of(context).animateTo(1),
                          child: AnimatedBuilder(
                            animation: DefaultTabController.of(context),
                            builder: (context, child) {
                              final tabController = DefaultTabController.of(
                                context,
                              );
                              final isSelected = tabController.index == 1;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.getBackgroundColor(isDarkMode)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  'Séries',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.getTextColor(isDarkMode)
                                        : AppColors.getTextSecondaryColor(
                                            isDarkMode,
                                          ),
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList(bool isDarkMode, bool isMovies) {
    final items = isMovies ? _downloadedMovies : _downloadedSeries;

    if (items.isEmpty) {
      return _buildEmptyState(isDarkMode, isMovies);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemId = '${isMovies ? 'movie' : 'series'}_${isMovies ? (item as MovieApiModel).id : (item as SeriesApiModel).id}';
        final isSelected = _selectedItems.contains(itemId);
        return _buildDownloadCard(
          item,
          isDarkMode,
          isMovies,
          itemId,
          isSelected,
        );
      },
    );
  }

  Widget _buildDownloadCard(
    dynamic item,
    bool isDarkMode,
    bool isMovies,
    String itemId,
    bool isSelected,
  ) {
    // Conversion en modèle classique pour récupérer imagePath, title, etc.
    final dynamic classicItem = isMovies 
        ? (item as MovieApiModel).toMovieModel()
        : (item as SeriesApiModel).toSeriesModel();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.getWidgetBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: _isSelectionMode && isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: InkWell(
        onTap: _isSelectionMode
            ? () => _toggleSelection(itemId)
            : () => _openItemDetail(item, isMovies),
        onLongPress: () {
          if (!_isSelectionMode) {
            setState(() {
              _isSelectionMode = true;
              _selectedItems.add(itemId);
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            if (_isSelectionMode)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleSelection(itemId),
                  activeColor: AppColors.primary,
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                classicItem.imagePath,
                width: 90,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(isDarkMode),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.movie,
                      color: AppColors.getTextColor(
                        isDarkMode,
                      ).withOpacity(0.5),
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarqueeText(
                      text: classicItem.title,
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      animationDuration: const Duration(milliseconds: 4000),
                      pauseDuration: const Duration(milliseconds: 1500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoBadge('HD', isDarkMode),
                        const SizedBox(width: 8),
                        _buildInfoBadge(
                          'Téléchargé',
                          isDarkMode,
                          color: Colors.green,
                        ),
                        if (!isMovies) ...[
                          const SizedBox(width: 8),
                          _buildInfoBadge('S1E1-E5', isDarkMode),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${isMovies ? '1.2 GB' : '850 MB'} • Téléchargé',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lecture de ${classicItem.title}'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Lire'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _deleteItem(isMovies, item),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Supprimer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, bool isDarkMode, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? AppColors.getTextSecondaryColor(isDarkMode))
            .withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? AppColors.getTextColor(isDarkMode),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, bool isMovies) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMovies ? Icons.movie_outlined : Icons.tv_outlined,
            size: 80,
            color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun ${isMovies ? 'film' : 'série'} téléchargé',
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les ${isMovies ? 'films' : 'séries'} que vous téléchargez\napparaîtront ici',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _openItemDetail(dynamic item, bool isMovies) {
    if (isMovies) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MovieDetailScreen.fromApiMovie(item as MovieApiModel)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SeriesDetailScreen.fromApiSeries(apiSeries: item as SeriesApiModel)),
      );
    }
  }

  void _deleteItem(bool isMovie, dynamic item) {
    final title = isMovie ? (item as MovieApiModel).title : (item as SeriesApiModel).title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le téléchargement'),
        content: Text(
          'Voulez-vous supprimer "$title" de vos téléchargements ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (isMovie) {
                await DownloadService.removeDownloadedMovie((item as MovieApiModel).id);
              } else {
                await DownloadService.removeDownloadedSeries((item as SeriesApiModel).id);
              }
              _loadDownloads();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$title supprimé')));
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedItems() async {
    if (_selectedItems.isEmpty) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer les téléchargements'),
        content: Text(
          'Voulez-vous supprimer ${_selectedItems.length} élément(s) sélectionné(s) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (var itemId in _selectedItems) {
        final parts = itemId.split('_');
        final isMovie = parts[0] == 'movie';
        final idStr = parts[1];
        
        if (isMovie) {
          final id = int.tryParse(idStr);
          if (id != null) await DownloadService.removeDownloadedMovie(id);
        } else {
          await DownloadService.removeDownloadedSeries(idStr);
        }
      }
      
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });
      _loadDownloads();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Éléments supprimés')),
      );
    }
  }

  Future<void> _showDeleteAllDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer tous les téléchargements'),
        content: const Text(
          'Cette action supprimera définitivement tous vos téléchargements. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer tout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (var movie in _downloadedMovies) {
        await DownloadService.removeDownloadedMovie(movie.id);
      }
      for (var series in _downloadedSeries) {
        await DownloadService.removeDownloadedSeries(series.id);
      }
      _loadDownloads();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tous les téléchargements supprimés'),
        ),
      );
    }
  }

  void _showDownloadSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres de téléchargement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Télécharger en Wi-Fi uniquement'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.hd),
              title: const Text('Qualité par défaut'),
              subtitle: const Text('HD (720p)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Emplacement de stockage'),
              subtitle: const Text('Stockage interne'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
