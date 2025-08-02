import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/user_storage_service.dart';

class UserInfoSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? mainProfile;
  final Color textColor;
  final VoidCallback onEditProfile;

  const UserInfoSection({
    Key? key,
    required this.userData,
    required this.mainProfile,
    required this.textColor,
    required this.onEditProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final username =
        mainProfile?['profileName'] ?? userData?['username'] ?? 'Utilisateur';
    final email = userData?['email'] ?? 'email@example.com';
    final createdAt = mainProfile?['createdAt'];

    String memberSince = 'Membre depuis récemment';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        memberSince =
            'Membre depuis le ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        print('Erreur parsing date: $e');
      }
    }

    return Row(
      children: [
        // Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: _buildProfileImage(),
          ),
        ),

        const SizedBox(width: 16),

        // Informations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                memberSince,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              if (UserStorageService.isUsingMemoryFallback()) ...[
                const SizedBox(height: 4),
                Text(
                  '⚠️ Mode mémoire temporaire',
                  style: TextStyle(
                    color: Colors.orange.withOpacity(0.8),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onEditProfile,
                child: const Text(
                  'Modifier le profil',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final avatarUrl = mainProfile?['profileAvatarUrl'];

    if (avatarUrl != null && avatarUrl.startsWith('/')) {
      return Image.file(
        File(avatarUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(),
      );
    }

    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(),
      );
    }

    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Image.asset(
      'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      fit: BoxFit.cover,
    );
  }
}
