import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final String description;
  final String lightImagePath;
  final String darkImagePath;
  final bool isSelected;
  final VoidCallback? onTap;

  const SubscriptionCard({
    Key? key,
    required this.title,
    required this.price,
    required this.duration,
    required this.description,
    required this.lightImagePath,
    required this.darkImagePath,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(isDarkMode);
    final imagePath = isDarkMode ? darkImagePath : lightImagePath;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.getWidgetBackgroundColor(isDarkMode),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 130, // Hauteur augmentée
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.red, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Arrière-plan de base avec couleur d'image
                  Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: isDarkMode
                            ? [
                                const Color(
                                  0xFF1A1A2E,
                                ), // Bleu foncé pour le mode sombre
                                const Color(0xFF16213E),
                              ]
                            : [
                                const Color(
                                  0xFFF5F5F5,
                                ), // Gris clair pour le mode jour
                                const Color(0xFFE8E8E8),
                              ],
                      ),
                    ),
                  ),

                  // Image positionnée à droite
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 120, // Largeur de l'image à droite
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[600],
                            child: const Icon(Icons.image, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),

                  // Overlay gradient
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Contenu
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Informations à gauche (prend plus de place)
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Badge prix
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '$price Fcfa',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Durée
                                Text(
                                  duration,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // Description (réduite)
                                Flexible(
                                  child: Text(
                                    description,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Espace pour l'image à droite
                          const Expanded(flex: 2, child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
