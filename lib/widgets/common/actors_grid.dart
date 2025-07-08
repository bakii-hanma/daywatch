import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../models/movie_model.dart';

class ActorsGrid extends StatelessWidget {
  final List<ActorModel> actors;
  final bool isDarkMode;
  final String countText;

  const ActorsGrid({
    Key? key,
    required this.actors,
    required this.isDarkMode,
    required this.countText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header avec compteur
        Padding(
          padding: const EdgeInsets.all(16),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${actors.length}',
                  style: TextStyle(
                    color: AppColors.getTextColor(isDarkMode),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' acteurs',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(isDarkMode),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Grille d'acteurs compacte
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 colonnes pour plus de compacité
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              childAspectRatio:
                  0.7, // Ratio pour avoir des rectangles verticaux
            ),
            itemCount: actors.length,
            itemBuilder: (context, index) {
              final actor = actors[index];
              return _buildActorGridItem(actor, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActorGridItem(ActorModel actor, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image de l'acteur
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: actor.imagePath.startsWith('http')
                    ? Image.network(
                        actor.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                            ),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        actor.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                            ),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          // Nom de l'acteur
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                actor.name,
                style: TextStyle(
                  color: AppColors.getTextColor(isDarkMode),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
