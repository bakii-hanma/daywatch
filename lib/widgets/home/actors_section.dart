import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../widgets/common/actor_card.dart';
import '../../screens/actor_detail_screen.dart';
import '../../services/actor_service.dart';

class ActorsSection extends StatelessWidget {
  final List<ActorApiModel> actors;
  final bool isDarkMode;

  const ActorsSection({
    super.key,
    required this.actors,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppColors.white : AppColors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Acteurs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Text(
                'Voir +',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        actors.isEmpty
            ? SizedBox(
                height: 200.0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: textColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun acteur disponible',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 200.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: actors.length,
                  itemBuilder: (context, index) {
                    final actor = actors[index];
                    return Container(
                      width: 130.0,
                      margin: EdgeInsets.only(
                        right: index < actors.length - 1 ? AppSpacing.md : 0,
                      ),
                      child: ActorCard(
                        imagePath: actor.profilePath.isNotEmpty
                            ? actor.profilePath
                            : 'https://via.placeholder.com/500x750/4A5568/FFFFFF?text=${Uri.encodeComponent(actor.name)}',
                        name: actor.name,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          print('🎭 Navigation vers acteur: ${actor.name}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActorDetailScreen(
                                actorId: actor.id,
                                actorName: actor.name,
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
    );
  }
}
