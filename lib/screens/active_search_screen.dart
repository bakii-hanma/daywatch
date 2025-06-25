import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import 'search_results_screen.dart';

class ActiveSearchScreen extends StatefulWidget {
  final Function(String)? onSearchActivated;

  const ActiveSearchScreen({Key? key, this.onSearchActivated})
    : super(key: key);

  @override
  State<ActiveSearchScreen> createState() => _ActiveSearchScreenState();
}

class _ActiveSearchScreenState extends State<ActiveSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Suggestions de recherche
  final List<String> _searchSuggestions = [
    'Avengers',
    'Aquaman',
    'One piece',
    'Spider-Man',
    'Batman',
    'Superman',
    'Iron Man',
    'Naruto',
  ];

  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = _searchSuggestions;
    // Auto-focus sur le champ de recherche
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = _searchSuggestions;
      } else {
        _filteredSuggestions = _searchSuggestions
            .where(
              (suggestion) =>
                  suggestion.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _navigateToResults(String query) {
    if (query.trim().isNotEmpty) {
      if (widget.onSearchActivated != null) {
        // Utiliser le callback pour activer la recherche dans l'onglet
        Navigator.pop(context); // Fermer ActiveSearchScreen
        widget.onSearchActivated!(query.trim());
      } else {
        // Fallback vers l'ancienne navigation
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SearchResultsScreen(searchQuery: query.trim()),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec barre de recherche
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(isDarkMode),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.getTextSecondaryColor(
                      isDarkMode,
                    ).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Bouton retour
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

                  // Champ de recherche
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        onSubmitted: _navigateToResults,
                        style: TextStyle(
                          color: AppColors.getTextColor(isDarkMode),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Marvel studios',
                          hintStyle: TextStyle(
                            color: AppColors.getTextSecondaryColor(isDarkMode),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Bouton fermer
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.close,
                        color: AppColors.getTextColor(isDarkMode),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Liste des suggestions
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return InkWell(
                    onTap: () {
                      _searchController.text = suggestion;
                      _navigateToResults(suggestion);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.getTextSecondaryColor(
                              isDarkMode,
                            ).withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: AppColors.getTextSecondaryColor(isDarkMode),
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            suggestion,
                            style: TextStyle(
                              color: AppColors.getTextColor(isDarkMode),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
