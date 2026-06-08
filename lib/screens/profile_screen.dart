import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_avatar_list.dart';
import '../widgets/profile/profile_option_group.dart';
import '../widgets/profile/profile_option_tile.dart';
import '../widgets/profile/profile_logout_button.dart';
import '../services/user_storage_service.dart';
import '../services/profile_service.dart';
import '../services/device_service.dart';
import '../services/theme_service.dart';
import '../services/plan_service.dart';
import '../models/subscription_status_model.dart';
import 'devices_screen.dart';
import 'subscription_screen.dart';
import 'edit_profile_screen.dart';
import 'faq_screen.dart';
import 'support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _mainProfile;
  List<dynamic> _profiles = [];
  int _connectedDevicesCount = 1;
  bool _isLoading = true;
  UserSubscriptionStatusModel? _subStatus;
  
  // États locaux pour les commutateurs (Wi-Fi et Thème)
  bool _wifiOnly = false;
  bool _isDarkTheme = true;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = ThemeService.themeModeNotifier.value == ThemeMode.dark;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserStorageService.getUserData();
      final mainProfile = await UserStorageService.getMainProfile();

      // Charger d'abord les profils en cache local
      final actualData = UserStorageService.isUsingMemoryFallback()
          ? userData
          : (userData?.containsKey('data') == true ? userData!['data'] : userData);
      final profilesObj = actualData?['profiles'];
      
      List<dynamic> cachedProfiles = [];
      if (profilesObj != null && profilesObj['data'] != null) {
        cachedProfiles = profilesObj['data'] as List<dynamic>;
      }

      setState(() {
        _userData = userData;
        _mainProfile = mainProfile;
        _profiles = cachedProfiles;
        _isLoading = false;
      });

      // Charger les profils en direct
      final apiResponse = await ProfileService.getUserProfiles();
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final List<Map<String, dynamic>> freshProfiles =
            apiResponse.data!.map((p) => p.toJson()).toList();
            
        if (mounted) {
          setState(() {
            _profiles = freshProfiles;
          });
        }
      }

      // Charger le nombre d'appareils connectés
      final devices = await DeviceService.listDevices();
      final activeDevices = devices.where((d) => d.isConnected).length;
      if (mounted) {
        setState(() {
          _connectedDevicesCount = activeDevices > 0 ? activeDevices : 1;
        });
      }

      // Charger le statut d'abonnement
      final subStatus = await PlanService.getSubscriptionStatus();
      if (mounted) {
        setState(() {
          _subStatus = subStatus;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données utilisateur: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (_mainProfile == null || _userData == null) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          profile: _mainProfile!,
          userData: _userData!,
        ),
      ),
    );

    if (updated == true) {
      _loadUserData();
    }
  }

  void _showPremiumSubscriptionRequiredDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Abonnement requis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'La gestion des profils est réservée aux abonnés. Passe à Premium pour en profiter.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            child: const Text(
              'Passe à Premium',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBadge(Color textColor) {
    if (_subStatus == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'CHARGEMENT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final status = _subStatus!.status?.toUpperCase() ?? '';
    final daysRemaining = _subStatus!.daysRemaining;

    if (_subStatus!.isTrialPeriod || status.startsWith('TRIAL')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.amber[700],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'ESSAI (${daysRemaining}J)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final isPaidActive = ['ACTIVE', 'SUBSCRIPTION_ENDING_SOON', 'SUBSCRIPTION_ENDING_CRITICAL'].contains(status);
    if (isPaidActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF00C853),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _subStatus!.plan?.name.toUpperCase() ?? 'ACTIF',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE50914),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'S\'ABONNER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN-TÊTE DE LA PAGE
              ProfileHeader(textColor: textColor),

              const SizedBox(height: 24),

              // LISTE HORIZONTALE DES PROFILS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ProfileAvatarList(
                  profiles: _profiles,
                  activeProfile: _mainProfile,
                  onProfileSelected: (profile) async {
                    await UserStorageService.saveSelectedProfile(profile);
                    setState(() {
                      _mainProfile = profile;
                    });
                    _loadUserData();
                  },
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  backgroundColor: backgroundColor,
                ),
              ),

              const SizedBox(height: 24),

              // PREMIÈRE BOÎTE D'OPTIONS (Compte & Abonnement)
              ProfileOptionGroup(
                children: [
                  ProfileOptionTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Modifier mon profil',
                    onTap: _navigateToEditProfile,
                  ),
                  ProfileOptionTile(
                    icon: Icons.key_rounded,
                    title: 'Modifier le mot de passe',
                    onTap: () {},
                  ),
                  ProfileOptionTile(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Gérer les profils',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRINCIPAL',
                            style: TextStyle(
                              color: Color(0xFFE50914),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, color: textColor.withOpacity(0.3), size: 20),
                      ],
                    ),
                    onTap: _showPremiumSubscriptionRequiredDialog,
                  ),
                  ProfileOptionTile(
                    icon: Icons.credit_card_rounded,
                    title: 'Mon abonnement',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSubscriptionBadge(textColor),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, color: textColor.withOpacity(0.3), size: 20),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                      );
                      _loadUserData();
                    },
                  ),
                  ProfileOptionTile(
                    icon: Icons.phone_android_rounded,
                    title: 'Appareils connectés',
                    showDivider: false,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C853),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_connectedDevicesCount',
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, color: textColor.withOpacity(0.3), size: 20),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DevicesScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // DEUXIÈME BOÎTE D'OPTIONS (Préférences de l'application)
              ProfileOptionGroup(
                children: [
                  ProfileOptionTile(
                    icon: Icons.wifi_rounded,
                    title: 'Wi-Fi uniquement',
                    subtitle: 'Streamer/télécharger seulement en Wi-Fi',
                    trailing: Switch(
                      value: _wifiOnly,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFFE50914),
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor: Colors.grey[800],
                      onChanged: (val) {
                        setState(() {
                          _wifiOnly = val;
                        });
                      },
                    ),
                  ),
                  ProfileOptionTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Thème sombre',
                    subtitle: 'Interface en mode sombre',
                    trailing: Switch(
                      value: _isDarkTheme,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFFE50914),
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor: Colors.grey[800],
                      onChanged: (val) {
                        setState(() {
                          _isDarkTheme = val;
                        });
                        ThemeService.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ),
                  ProfileOptionTile(
                    icon: Icons.share_rounded,
                    title: 'Partager l\'application',
                    showDivider: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Partage de l\'application...')),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // SECTION AIDE & SUPPORT
              Text(
                'AIDE & SUPPORT',
                style: TextStyle(
                  color: isDarkMode ? Colors.red : Colors.red.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              ProfileOptionGroup(
                children: [
                  ProfileOptionTile(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FaqScreen()),
                      );
                    },
                  ),
                  ProfileOptionTile(
                    icon: Icons.support_agent_rounded,
                    title: 'Support technique',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SupportScreen()),
                      );
                    },
                  ),
                  ProfileOptionTile(
                    icon: Icons.info_outline_rounded,
                    title: 'À propos',
                    showDivider: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // BOUTON DE DÉCONNEXION OVALE
              const ProfileLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
