import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../widgets/common/marquee_text.dart';
import '../models/movie_model.dart';
import '../data/sample_data.dart';
import 'movie_detail_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};

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
              _buildStorageInfo(isDarkMode),

              // Barre d'actions en mode sélection
              if (_isSelectionMode) _buildSelectionActions(isDarkMode),

              // Tab Bar Films/Séries
              _buildTabBar(isDarkMode),

              // Contenu des onglets
              Expanded(
                child: TabBarView(
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
                '2.8 GB / 32 GB',
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
              value: 0.08,
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
              _buildStorageDetail('Films', '1.9 GB', '6 éléments', isDarkMode),
              _buildStorageDetail('Séries', '0.9 GB', '4 éléments', isDarkMode),
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
                            animation: DefaultTabController.of(context)!,
                            builder: (context, child) {
                              final tabController = DefaultTabController.of(
                                context,
                              )!;
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
                            animation: DefaultTabController.of(context)!,
                            builder: (context, child) {
                              final tabController = DefaultTabController.of(
                                context,
                              )!;
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
    final items = isMovies
        ? SampleData.popularMovies.take(6).toList()
        : SampleData.popularSeries.take(4).toList();

    if (items.isEmpty) {
      return _buildEmptyState(isDarkMode, isMovies);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemId = '${isMovies ? 'movie' : 'series'}_$index';
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
              child: Image.asset(
                item.imagePath,
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
                      text: item.title,
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
                      '${isMovies ? '1.2 GB' : '850 MB'} • Téléchargé le 15 nov.',
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
                                content: Text('Lecture de ${item.title}'),
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
                          onPressed: () => _deleteItem(itemId, item.title),
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
        MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: item)),
      );
    }
  }

  void _deleteItem(String itemId, String title) {
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
            onPressed: () {
              Navigator.pop(context);
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

  void _deleteSelectedItems() {
    if (_selectedItems.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer les téléchargements'),
        content: Text(
          'Voulez-vous supprimer ${_selectedItems.length} élément(s) sélectionné(s) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedItems.clear();
                _isSelectionMode = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Éléments supprimés')),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer tous les téléchargements'),
        content: const Text(
          'Cette action supprimera définitivement tous vos téléchargements. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tous les téléchargements supprimés'),
                ),
              );
            },
            child: const Text(
              'Supprimer tout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
