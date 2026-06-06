import 'package:flutter/material.dart';
import 'dart:io';
import '../design_system/colors.dart';
import '../widgets/daywatch_logo.dart';
import '../services/user_storage_service.dart';
import '../services/profile_service.dart';
import '../utils/alert_utils.dart';
import 'home_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  List<dynamic> _profiles = [];
  bool _isLoading = true;

  // Couleurs prédéfinies pour les avatars de profils (style premium/Netflix)
  final List<Color> _avatarColors = [
    const Color(0xFFE50914), // Rouge DayWatch/Netflix
    const Color(0xFF54B143), // Vert
    const Color(0xFF1A73E8), // Bleu
    const Color(0xFFAB47BC), // Violet
    const Color(0xFFFFB300), // Jaune/Orange
  ];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      // 1. Charger d'abord les profils du cache local pour un affichage instantané
      final userData = await UserStorageService.getUserData();
      final actualData = UserStorageService.isUsingMemoryFallback() 
          ? userData 
          : (userData?.containsKey('data') == true ? userData!['data'] : userData);
          
      final profilesObj = actualData?['profiles'];
      
      List<dynamic> loadedProfiles = [];
      if (profilesObj != null && profilesObj['data'] != null) {
        loadedProfiles = profilesObj['data'] as List<dynamic>;
      }

      if (loadedProfiles.isNotEmpty) {
        setState(() {
          _profiles = loadedProfiles;
          _isLoading = false;
        });
      }

      // 2. Charger les profils en direct depuis l'API pour garantir la fraîcheur
      final apiResponse = await ProfileService.getUserProfiles();
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final List<Map<String, dynamic>> freshProfiles = 
            apiResponse.data!.map((p) => p.toJson()).toList();

        if (mounted) {
          setState(() {
            _profiles = freshProfiles;
            _isLoading = false;
          });
        }

        // Mettre à jour le cache local
        if (userData != null) {
          final targetData = userData.containsKey('data') ? userData['data'] : userData;
          if (targetData != null) {
            targetData['profiles'] = {
              'count': freshProfiles.length,
              'data': freshProfiles,
            };
            await UserStorageService.saveUserData(userData);
          }
        }
      } else {
        // En cas d'échec de l'API et si le cache était vide, afficher l'erreur
        if (loadedProfiles.isEmpty) {
          setState(() => _isLoading = false);
          if (mounted) {
            AlertUtils.showError(
              context: context,
              message: apiResponse.error ?? 'Erreur lors du chargement des profils depuis le serveur.',
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AlertUtils.showError(
          context: context,
          message: 'Erreur lors du chargement des profils.',
          debugDetails: 'Exception chargement profils: $e',
        );
      }
    }
  }

  Future<void> _selectProfile(Map<String, dynamic> profile) async {
    try {
      await UserStorageService.saveSelectedProfile(profile);

      if (!mounted) return;

      // Afficher un toast de bienvenue
      final profileName = profile['profileName'] ?? 'Utilisateur';
      AlertUtils.showSuccess(
        context: context,
        message: 'Bienvenue de retour, $profileName !',
      );

      // Naviguer vers l'accueil
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        AlertUtils.showError(
          context: context,
          message: 'Impossible de sélectionner ce profil.',
          debugDetails: 'Exception sélection profil: $e',
        );
      }
    }
  }

  Widget _buildAddProfileCard(BuildContext context, bool isDarkMode, Color textColor) {
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
          // Cercle Ajouter (+)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
            ),
            child: Icon(
              Icons.add,
              size: 40,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          
          // Texte Ajouter
          Text(
            'Ajouter',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Espace vide égal au badge PRINCIPAL pour préserver l'alignement vertical
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo DAYWATCH
                      DaywatchLogo(
                        size: LogoSize.large,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 50),

                      // Titre
                      Text(
                        'Qui regarde ?',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Grille des profils
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Wrap(
                          spacing: 30,
                          runSpacing: 30,
                          alignment: WrapAlignment.center,
                          children: [
                            ...List.generate(_profiles.length, (index) {
                              final profile = _profiles[index] as Map<String, dynamic>;
                              return _ProfileCard(
                                profile: profile,
                                avatarColor: _avatarColors[index % _avatarColors.length],
                                onTap: () => _selectProfile(profile),
                              );
                            }),
                            // Carte d'ajout de profil
                            _buildAddProfileCard(context, isDarkMode, textColor),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Bouton de déconnexion ovale style pilule gris foncé
                      GestureDetector(
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          await UserStorageService.logout();
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (_) => false,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.white.withOpacity(0.06) 
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFE50914),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Se déconnecter',
                                style: TextStyle(
                                  color: Color(0xFFE50914),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final Map<String, dynamic> profile;
  final Color avatarColor;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.profile,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  bool _isHovered = false;

  Widget _buildAvatar(String profileName) {
    final avatarUrl = widget.profile['profileAvatarUrl'];

    if (avatarUrl != null && avatarUrl.startsWith('/')) {
      return Image.file(
        File(avatarUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultLetterAvatar(profileName),
      );
    }

    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultLetterAvatar(profileName),
      );
    }

    return _defaultLetterAvatar(profileName);
  }

  Widget _defaultLetterAvatar(String name) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: widget.avatarColor,
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileName = widget.profile['profileName'] ?? 'Utilisateur';
    final isCurrentDefault = widget.profile['isDefault'] == true || 
        widget.profile['isDefault'] == 1 || 
        widget.profile['isDefault']?.toString().toLowerCase() == 'true';

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cadre d'avatar (Stack pour le badge de couronne)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrentDefault
                            ? const Color(0xFFE50914)
                            : (_isHovered ? Colors.white : Colors.transparent),
                        width: 3,
                      ),
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: widget.avatarColor.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: ClipOval(
                      child: _buildAvatar(profileName),
                    ),
                  ),
                  
                  // Badge couronne si c'est le profil principal
                  if (isCurrentDefault)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE50914),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Nom du profil
              Text(
                profileName,
                style: TextStyle(
                  color: _isHovered ? Colors.white : Colors.white70,
                  fontSize: 16,
                  fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
                ),
              ),

              // Label "👑 PRINCIPAL" si applicable
              if (isCurrentDefault) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFE50914),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PRINCIPAL',
                      style: TextStyle(
                        color: const Color(0xFFE50914),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Espacement vide pour aligner verticalement les autres profils
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
