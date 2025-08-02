import 'package:flutter/material.dart';
import '../common/profile_option_item.dart';
import '../../screens/subscription_screen.dart';

class ProfileOptionsSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;

  const ProfileOptionsSection({
    Key? key,
    required this.isDarkMode,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Paramètres
        ..._buildSettingsOptions(context),

        const SizedBox(height: 32),

        // Section Aide & support
        _buildSectionHeader('Aide & support'),
        const SizedBox(height: 16),
        ..._buildSupportOptions(),
      ],
    );
  }

  List<Widget> _buildSettingsOptions(BuildContext context) {
    return [
      ProfileOptionItem(
        icon: Icons.lock_outline_rounded,
        title: 'Modifier le mot de passe',
        onTap: () {},
      ),
      ProfileOptionItem(
        icon: Icons.card_membership_rounded,
        title: 'Plans d\'abonnement',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        ),
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
          style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
        ),
        onTap: () {},
      ),
      ProfileOptionItem(
        icon: Icons.share_rounded,
        title: 'Partager l\'application',
        onTap: () {},
      ),
    ];
  }

  List<Widget> _buildSupportOptions() {
    return [
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
    ];
  }

  Widget _buildSectionHeader(String title) {
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
}
