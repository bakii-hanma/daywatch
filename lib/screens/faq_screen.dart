import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';

class FaqItem {
  final String category;
  final String question;
  final String answer;

  FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';
  String _searchQuery = '';

  final List<String> _categories = [
    'Tous',
    'Compte',
    'Abonnement',
    'Lecture',
    'Téléchargement',
  ];

  final List<FaqItem> _faqItems = [
    FaqItem(
      category: 'Compte',
      question: 'Comment changer mon mot de passe ?',
      answer: 'Va dans Profil → Mon compte → Modifier le mot de passe. Tu auras besoin de ton mot de passe actuel.',
    ),
    FaqItem(
      category: 'Compte',
      question: 'Comment supprimer mon compte ?',
      answer: 'Contacte le support technique pour demander la suppression définitive de ton compte. Toutes tes données seront effacées sous 30 jours.',
    ),
    FaqItem(
      category: 'Abonnement',
      question: 'Comment annuler mon abonnement ?',
      answer: 'Profil → Mon abonnement → choisis \'Découverte\' (gratuit) pour annuler. Tu garderas l\'accès Premium jusqu\'à la fin de ta période en cours.',
    ),
    FaqItem(
      category: 'Abonnement',
      question: 'Quels modes de paiement acceptez-vous ?',
      answer: 'Mobile Money (Airtel Money, Moov Money), carte bancaire et PayPal. Au Gabon, le paiement Mobile Money est instantané et sans frais cachés.',
    ),
    FaqItem(
      category: 'Lecture',
      question: 'Pourquoi la vidéo se met en pause / bufferise ?',
      answer: 'Vérifie ta connexion Internet. Tu peux aussi réduire la qualité dans Profil → Préférences → Qualité vidéo.',
    ),
    FaqItem(
      category: 'Lecture',
      question: 'Comment activer les sous-titres ?',
      answer: 'Pendant la lecture, clique sur l\'icône Sous-titres dans la barre du lecteur, puis sélectionne la langue souhaitée.',
    ),
    FaqItem(
      category: 'Téléchargement',
      question: 'Comment télécharger un film pour le regarder hors-ligne ?',
      answer: 'Ouvre la page d\'un film et clique sur Télécharger. Le film reste disponible dans Bibliothèque → Téléchargements.',
    ),
    FaqItem(
      category: 'Téléchargement',
      question: 'Combien de films puis-je télécharger ?',
      answer: 'Limité par l\'espace de stockage de ton appareil. Le plan Premium permet les téléchargements hors-ligne.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqItem> get _filteredFaqItems {
    return _faqItems.where((item) {
      final matchesCategory = _selectedCategory == 'Tous' || item.category == _selectedCategory;
      final matchesSearch = item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);
    final textSecondaryColor = AppColors.getTextSecondaryColor(isDarkMode);
    final surfaceColor = AppColors.getSurfaceColor(isDarkMode);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FAQ / Centre d\'aide',
          style: AppTypography.title(textColor).copyWith(
            fontSize: AppTypography.fontSizeTitle + 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                boxShadow: isDarkMode
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: TextField(
                controller: _searchController,
                style: AppTypography.body(textColor),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher une question...',
                  hintStyle: AppTypography.body(textSecondaryColor),
                  prefixIcon: Icon(Icons.search_rounded, color: textSecondaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textSecondaryColor),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                    horizontal: AppSpacing.xl,
                  ),
                ),
              ),
            ),
          ),

          // CHIPS DE CATÉGORIES
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : surfaceColor,
                        width: 1,
                      ),
                    ),
                    elevation: isSelected ? 2 : 0,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // LISTE DES QUESTIONS / RÉPONSES
          Expanded(
            child: _filteredFaqItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 64,
                          color: textSecondaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Aucun résultat trouvé',
                          style: AppTypography.subtitle(textColor),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Essaie d\'autres mots clés ou une autre catégorie.',
                          style: AppTypography.body(textSecondaryColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: _filteredFaqItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredFaqItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(item.category),
                                color: AppColors.primary,
                                size: AppSpacing.iconSizeSmall + 2,
                              ),
                            ),
                            title: Text(
                              item.question,
                              style: AppTypography.bodySemiBold(textColor),
                            ),
                            iconColor: AppColors.primary,
                            collapsedIconColor: textSecondaryColor,
                            childrenPadding: const EdgeInsets.only(
                              left: AppSpacing.xxl + 24, // Align with title
                              right: AppSpacing.xl,
                              bottom: AppSpacing.xl,
                            ),
                            expandedCrossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.answer,
                                style: AppTypography.body(textSecondaryColor).copyWith(
                                  height: 1.5,
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
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Compte':
        return Icons.person_rounded;
      case 'Abonnement':
        return Icons.credit_card_rounded;
      case 'Lecture':
        return Icons.play_circle_fill_rounded;
      case 'Téléchargement':
        return Icons.download_for_offline_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
