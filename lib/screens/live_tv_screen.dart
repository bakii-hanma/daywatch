import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../models/tv_channel_model.dart';
import '../services/tv_channel_service.dart';
import 'simple_tv_player_screen.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  List<TvChannelModel> _allChannels = [];
  List<TvChannelModel> _displayedChannels = [];
  bool _isLoading = true;

  String _activeTabId = 'all';
  String _searchQuery = '';
  bool _showSearch = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Mots-clés identiques à l'application Web pour le filtrage par catégories
  static const Map<String, List<String>> _categoryKeywords = {
    'sport': ['sport', 'bein', 'espn', 'fox sport', 'eurosport', 'rmc', 'sky sport', 'nfl', 'nba', 'golf', 'bt sport', 'dazn'],
    'info': ['news', 'cnn', 'bbc', 'jt', 'sky news', 'al jazeera', 'france 24', 'euronews', 'bfm', 'cnews', 'franceinfo', 'dw', 'africa24', 'reuters', 'bloomberg', 'fox news', 'cbc', 'rt '],
    'jeunesse': ['kids', 'cartoon', 'disney', 'nick', 'enfant', 'gulli', 'tiji', 'boomerang', 'junior'],
    'divertissement': ['entertainment', 'comedy', 'tlc', 'paramount', 'tf1', 'm6', 'tmc', 'amc', 'syfy', 'hbo', 'showtime', 'bravo'],
    'musique': ['music', 'musique', 'mtv', 'trace', 'mezzo', 'mcm', 'vh1'],
    'style': ['lifestyle', 'travel', 'cuisine', 'food', 'national geographic', 'discovery', 'animal', 'history'],
    'gabon': ['gabon', 'gabonaise', 'gabon 24', 'rtg'],
  };

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'Tout'},
    {'id': 'sport', 'label': 'Sport'},
    {'id': 'info', 'label': 'Info'},
    {'id': 'jeunesse', 'label': 'Jeunesse'},
    {'id': 'divertissement', 'label': 'Divertissement'},
    {'id': 'musique', 'label': 'Musique'},
    {'id': 'style', 'label': 'Style de vie'},
    {'id': 'gabon', 'label': 'Gabon'},
  ];

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Récupérer un grand nombre de chaînes pour la liste complète
      final channels = await TvChannelService.getAllChannels(page: 1, limit: 500);

      if (mounted) {
        setState(() {
          _allChannels = channels;
          _isLoading = false;
        });
        _filterChannels();
      }
    } catch (e) {
      print('Erreur lors du chargement des chaînes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterChannels() {
    setState(() {
      _displayedChannels = _allChannels.where((channel) {
        // 1. Filtrage par Catégorie (Chips)
        bool matchesCategory = true;
        if (_activeTabId != 'all') {
          final keywords = _categoryKeywords[_activeTabId] ?? [];
          final blob = '${channel.name} ${channel.category}'.toLowerCase();
          matchesCategory = keywords.any((k) => blob.contains(k));
        }

        // 2. Filtrage par Barre de Recherche
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          matchesSearch = channel.name.toLowerCase().contains(query) ||
              channel.category.toLowerCase().contains(query);
        }

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }



  Widget _buildHeader(Color textColor, bool isDarkMode) {
    if (_showSearch) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: textColor.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: true,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher une chaîne...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                          _filterChannels();
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterChannels();
                        },
                        child: Icon(
                          Icons.clear_rounded,
                          color: textColor.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
                setState(() {
                  _showSearch = false;
                  _searchQuery = '';
                });
                _filterChannels();
              },
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'TV en direct',
                style: AppTypography.header(textColor),
              ),
              if (_activeTabId != 'all') ...[
                const SizedBox(width: 8),
                Text(
                  ': ${_categories.firstWhere((cat) => cat['id'] == _activeTabId)['label']}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showSearch = true;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                color: textColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(Color textColor, bool isDarkMode) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final catId = cat['id']!;
          final catLabel = cat['label']!;
          final isActive = _activeTabId == catId;

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeTabId = catId;
              });
              _filterChannels();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive 
                    ? AppColors.primary 
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ] : null,
              ),
              child: Center(
                child: Text(
                  catLabel,
                  style: TextStyle(
                    color: isActive ? Colors.white : textColor.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChannelList(bool isDarkMode) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _displayedChannels.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.white.withOpacity(0.06),
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final channel = _displayedChannels[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SimpleTvPlayerScreen(channel: channel),
                  fullscreenDialog: true,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          channel.category.isNotEmpty ? channel.category : 'Chaîne en direct',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'DIRECT',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerList(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[900]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[850]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 10,
        separatorBuilder: (context, index) => Divider(
          color: Colors.white.withOpacity(0.06),
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_off_rounded,
              size: 64,
              color: textColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune chaîne',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Aucun résultat pour "$_searchQuery"'
                  : 'Aucune chaîne disponible dans cette catégorie.',
              style: TextStyle(
                color: textColor.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(textColor, isDarkMode),
            if (!_showSearch) _buildCategoryChips(textColor, isDarkMode),
            Expanded(
              child: _isLoading
                  ? _buildShimmerList(isDarkMode)
                  : _displayedChannels.isEmpty
                      ? _buildEmptyState(textColor, isDarkMode)
                      : _buildChannelList(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }
}
