import 'package:flutter/material.dart';
import 'dart:io';
import '../../utils/alert_utils.dart';

class ProfileAvatarList extends StatelessWidget {
  final List<dynamic> profiles;
  final Map<String, dynamic>? activeProfile;
  final Function(Map<String, dynamic>) onProfileSelected;
  final bool isDarkMode;
  final Color textColor;
  final Color backgroundColor;

  // Couleurs prédéfinies pour les avatars de profils (style premium/Netflix)
  final List<Color> _avatarColors = const [
    Color(0xFFE50914), // Rouge DayWatch
    Color(0xFF54B143), // Vert
    Color(0xFF1A73E8), // Bleu
    Color(0xFFAB47BC), // Violet
    Color(0xFFFFB300), // Jaune/Orange
  ];

  const ProfileAvatarList({
    super.key,
    required this.profiles,
    required this.activeProfile,
    required this.onProfileSelected,
    required this.isDarkMode,
    required this.textColor,
    required this.backgroundColor,
  });

  Widget _buildAvatar(String profileName, String? avatarUrl, Color avatarColor) {
    if (avatarUrl != null && avatarUrl.startsWith('/')) {
      return Image.file(
        File(avatarUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultLetterAvatar(profileName, avatarColor),
      );
    }

    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultLetterAvatar(profileName, avatarColor),
      );
    }

    return _defaultLetterAvatar(profileName, avatarColor);
  }

  Widget _defaultLetterAvatar(String name, Color color) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAddProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AlertUtils.showError(
          context: context,
          message: 'Connecte-toi au compte principal pour ajouter des profils.',
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
            ),
            child: Icon(
              Icons.add,
              size: 32,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ajouter',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(profiles.length, (index) {
            final profile = profiles[index] as Map<String, dynamic>;
            final pName = profile['profileName'] ?? 'Utilisateur';
            final pAvatarUrl = profile['profileAvatarUrl'];
            
            final isCurrentDefault = profile['isDefault'] == true ||
                profile['isDefault'] == 1 ||
                profile['isDefault']?.toString().toLowerCase() == 'true';
                
            final isActiveProfile = activeProfile?['id'] == profile['id'];

            return Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: GestureDetector(
                onTap: () => onProfileSelected(profile),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Cercle d'avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrentDefault
                                  ? const Color(0xFFE50914)
                                  : (isActiveProfile ? Colors.white70 : Colors.transparent),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: _buildAvatar(
                              pName,
                              pAvatarUrl,
                              _avatarColors[index % _avatarColors.length],
                            ),
                          ),
                        ),
                        
                        // Badge couronne si profil principal
                        if (isCurrentDefault)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE50914),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                          
                        // Badge type d'appareil (smartphone) en bas à gauche sur le profil actif
                        if (isActiveProfile)
                          Positioned(
                            bottom: -2,
                            left: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                shape: BoxShape.circle,
                                border: Border.all(color: backgroundColor, width: 2),
                              ),
                              child: const Icon(
                                Icons.smartphone_rounded,
                                color: Colors.white70,
                                size: 10,
                              ),
                            ),
                          ),
                          
                        // Point vert en ligne en bas à droite sur le profil actif
                        if (isActiveProfile)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853),
                                shape: BoxShape.circle,
                                border: Border.all(color: backgroundColor, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pName,
                      style: TextStyle(
                        color: isActiveProfile ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: isActiveProfile ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isCurrentDefault) ...[
                      const SizedBox(height: 4),
                      const Text(
                        '👑 PRINCIPAL',
                        style: TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            );
          }),
          _buildAddProfileCard(context),
        ],
      ),
    );
  }
}
