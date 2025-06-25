import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/profile_option_item.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header "Profil"
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Profil',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Section utilisateur (sans cadre)
                _buildUserSection(isDarkMode, textColor),

                const SizedBox(height: 32),

                // Section Paramètres
                Column(
                  children: [
                    ProfileOptionItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'Modifier le mot de passe',
                      onTap: () {},
                    ),
                    ProfileOptionItem(
                      icon: Icons.card_membership_rounded,
                      title: 'Plans d\'abonnement',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                        );
                      },
                    ),
                    ProfileOptionItem(
                      icon: Icons.wifi_rounded,
                      title: 'Wi-Fi uniquement',
                      onTap: () {},
                    ),
                    ProfileOptionItem(
                      icon: Icons.dark_mode_rounded,
                      title: 'Thème sombre',
                      onTap: () {},
                    ),
                    ProfileOptionItem(
                      icon: Icons.video_settings_rounded,
                      title: 'Qualité vidéo',
                      trailing: Text(
                        isDarkMode ? '1080p (HD)' : '720p (SD)',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {},
                    ),
                    ProfileOptionItem(
                      icon: Icons.share_rounded,
                      title: 'Partager l\'application',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Section Aide & support
                _buildSectionHeader('Aide & support', textColor, isDarkMode),

                const SizedBox(height: 16),

                Column(
                  children: [
                    ProfileOptionItem(
                      icon: Icons.help_outline_rounded,
                      title: 'FAQ',
                      onTap: () {},
                    ),
                    ProfileOptionItem(
                      icon: Icons.support_agent_rounded,
                      title: 'Support technique',
                      onTap: () {},
                    ),
                    ProfileOptionItem(
                      icon: Icons.info_outline_rounded,
                      title: 'À propos',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Bouton de déconnexion
                _buildLogoutButton(isDarkMode),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(bool isDarkMode, Color textColor) {
    return Row(
      children: [
        // Avatar agrandi (80px au lieu de 60px)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Informations utilisateur (sans container/cadre)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Artemis Sardes',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'artemissardes@adantics.com',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '066 15 77 70',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Membre depuis le 30/10/2023',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Action modifier profil
                },
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

  Widget _buildSectionHeader(String title, Color textColor, bool isDarkMode) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.red : Colors.red.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 1, color: Colors.red.withOpacity(0.3)),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Action de déconnexion
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.red, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Se déconnecter',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
