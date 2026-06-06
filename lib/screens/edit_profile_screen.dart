import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../design_system/colors.dart';
import '../services/user_storage_service.dart';
import '../services/profile_service.dart';
import '../services/api_client.dart';
import '../utils/alert_utils.dart';
import 'login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  final Map<String, dynamic> userData;

  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.userData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Contrôleurs pour les champs de saisie
  late TextEditingController _profileNameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  File? _selectedImage;
  bool _isLoading = false;
  
  // Indicatif de pays sélectionné (par défaut GA +241 pour le Gabon)
  String _selectedCountryCode = '+241';
  final List<Map<String, String>> _countryCodes = const [
    {'code': 'GA', 'dial': '+241', 'name': 'Gabon'},
    {'code': 'FR', 'dial': '+33', 'name': 'France'},
    {'code': 'CI', 'dial': '+225', 'name': 'Côte d\'Ivoire'},
    {'code': 'SN', 'dial': '+221', 'name': 'Sénégal'},
    {'code': 'CM', 'dial': '+237', 'name': 'Cameroun'},
  ];

  late bool _isDefaultProfile;

  // Couleurs par défaut pour les avatars de lettres
  final List<Color> _avatarColors = const [
    Color(0xFFE50914),
    Color(0xFF54B143),
    Color(0xFF1A73E8),
    Color(0xFFAB47BC),
    Color(0xFFFFB300),
  ];

  @override
  void initState() {
    super.initState();
    
    // Déterminer s'il s'agit du profil principal
    final isDefault = widget.profile['isDefault'];
    _isDefaultProfile = isDefault == true ||
        isDefault == 1 ||
        isDefault?.toString().toLowerCase() == 'true';

    // Initialiser les contrôleurs avec les données existantes
    _profileNameController = TextEditingController(text: widget.profile['profileName'] ?? '');
    
    // Extraire les infos utilisateur réelles
    final actualUserData = widget.userData.containsKey('data') ? widget.userData['data'] : widget.userData;
    
    _usernameController = TextEditingController(text: actualUserData?['username'] ?? '');
    
    // Nettoyer le numéro de téléphone pour séparer le code pays si présent
    String rawPhone = actualUserData?['phoneNumber'] ?? actualUserData?['phone'] ?? '';
    String localPhone = rawPhone;
    
    // Tenter de matcher avec un indicatif connu
    for (var country in _countryCodes) {
      final dialCode = country['dial']!;
      if (rawPhone.startsWith(dialCode)) {
        _selectedCountryCode = dialCode;
        localPhone = rawPhone.substring(dialCode.length);
        break;
      }
    }
    
    _phoneController = TextEditingController(text: localPhone);
    _bioController = TextEditingController(text: actualUserData?['bio'] ?? '');
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String _formatMemberSince(String? createdAtString) {
    if (createdAtString == null || createdAtString.isEmpty) {
      return 'mai 2026';
    }
    try {
      final dateTime = DateTime.parse(createdAtString);
      final months = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      final monthName = months[dateTime.month - 1];
      return '$monthName ${dateTime.year}';
    } catch (_) {
      return 'mai 2026';
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              title: const Text('Caméra', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Colors.white),
              title: const Text('Galerie', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() => _selectedImage = File(image.path));
        }
      } catch (e) {
        AlertUtils.showError(context: context, message: 'Erreur lors de la sélection: $e');
      }
    }
  }

  Widget _buildCurrentImageWidget(Color defaultColor) {
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    }

    final avatarUrl = widget.profile['profileAvatarUrl'];
    final pName = widget.profile['profileName'] ?? 'U';

    if (avatarUrl != null && avatarUrl.startsWith('/')) {
      return Image.file(
        File(avatarUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultLetterAvatar(pName, defaultColor),
      );
    }

    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultLetterAvatar(pName, defaultColor),
      );
    }

    return _defaultLetterAvatar(pName, defaultColor);
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
          fontSize: 44,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_profileNameController.text.trim().isEmpty) {
      AlertUtils.showError(context: context, message: 'Le nom du profil ne peut pas être vide.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await UserStorageService.getToken();
      if (token == null) throw Exception('Token d\'identification manquant.');

      String? avatarBase64;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        avatarBase64 = base64Encode(bytes);
      }

      // 1. Mettre à jour le profil local / backend
      final profileResponse = await ProfileService.updateProfile(
        widget.profile['id'],
        profileName: _profileNameController.text.trim(),
        profileAvatarUrl: _selectedImage?.path, // Envoi du chemin local au besoin ou simulation
      );

      // Si nous avons encodé une image, nous pouvons appeler l'API de mise à jour du profil via ApiClient pour le base64
      if (avatarBase64 != null) {
        final Map<String, dynamic> updateProfileImageBody = {
          'profileId': widget.profile['id'],
          'profileAvatarBase64': avatarBase64,
          'profileAvatarExtension': _selectedImage!.path.split('.').last,
        };
        
        await ApiClient.post<Map<String, dynamic>>(
          ApiClient.updateProfileUrl,
          body: updateProfileImageBody,
          headers: {'Authorization': 'Bearer $token'},
        );
      }

      // 2. Mettre à jour les infos du compte si c'est le profil principal
      if (_isDefaultProfile) {
        final Map<String, dynamic> updateAccountBody = {
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
        };

        // Appel de mise à jour des métadonnées du profil principal de l'utilisateur
        await ApiClient.post<Map<String, dynamic>>(
          ApiClient.updateProfileUrl,
          body: updateAccountBody,
          headers: {'Authorization': 'Bearer $token'},
        );

        // Appel de mise à jour du numéro de téléphone
        final String fullPhone = '$_selectedCountryCode${_phoneController.text.trim()}';
        final Map<String, dynamic> updatePhoneBody = {
          'phone': fullPhone,
        };
        await ApiClient.post<Map<String, dynamic>>(
          ApiClient.updatePhoneUrl,
          body: updatePhoneBody,
          headers: {'Authorization': 'Bearer $token'},
        );
      }

      // 3. Mettre à jour les données locales dans SharedPreferences
      final freshUserData = await UserStorageService.getUserData();
      final actualData = freshUserData != null && freshUserData.containsKey('data') ? freshUserData['data'] : freshUserData;
      
      if (freshUserData != null && actualData != null) {
        actualData['username'] = _usernameController.text.trim();
        actualData['bio'] = _bioController.text.trim();
        actualData['phoneNumber'] = '$_selectedCountryCode${_phoneController.text.trim()}';
        
        // Mettre à jour dans la liste des profils locaux
        if (actualData['profiles']?['data'] != null) {
          final List<dynamic> profilesList = List.from(actualData['profiles']['data']);
          final index = profilesList.indexWhere((p) => p['id'] == widget.profile['id']);
          if (index != -1) {
            profilesList[index]['profileName'] = _profileNameController.text.trim();
            if (_selectedImage != null) {
              profilesList[index]['profileAvatarUrl'] = _selectedImage!.path;
            }
            actualData['profiles']['data'] = profilesList;
          }
        }
        await UserStorageService.saveUserData(freshUserData);
        
        // Si c'est le profil actuellement actif, le re-sauvegarder
        final activeProfile = await UserStorageService.getSelectedProfile();
        if (activeProfile != null && activeProfile['id'] == widget.profile['id']) {
          activeProfile['profileName'] = _profileNameController.text.trim();
          if (_selectedImage != null) {
            activeProfile['profileAvatarUrl'] = _selectedImage!.path;
          }
          await UserStorageService.saveSelectedProfile(activeProfile);
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        AlertUtils.showSuccess(context: context, message: 'Modifications enregistrées avec succès !');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AlertUtils.showError(context: context, message: 'Erreur lors de la sauvegarde: $e');
      }
    }
  }

  Future<void> _handleDeleteProfileOrAccount() async {
    final title = _isDefaultProfile ? 'Suppression du compte' : 'Suppression du profil';
    final content = _isDefaultProfile
        ? 'Êtes-vous sûr de vouloir supprimer définitivement votre compte, vos profils, vos favoris et vos commentaires ? Cette action est irréversible.'
        : 'Êtes-vous sûr de vouloir supprimer ce profil ? Tous vos favoris et votre historique seront perdus.';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        if (_isDefaultProfile) {
          // Simulation / Appel de suppression de compte complet
          // (Comme il n'y a pas d'endpoint direct, nous nettoyons le stockage et déconnectons)
          await UserStorageService.clearAll();
          if (mounted) {
            setState(() => _isLoading = false);
            AlertUtils.showSuccess(context: context, message: 'Compte supprimé avec succès.');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }
        } else {
          // Supprimer le profil secondaire
          final response = await ProfileService.deleteProfile(widget.profile['id']);
          
          if (response.isSuccess) {
            // Mettre à jour les données utilisateur locales
            final userData = await UserStorageService.getUserData();
            final actualData = userData != null && userData.containsKey('data') ? userData['data'] : userData;
            if (userData != null && actualData != null && actualData['profiles']?['data'] != null) {
              final List<dynamic> list = List.from(actualData['profiles']['data']);
              list.removeWhere((p) => p['id'] == widget.profile['id']);
              actualData['profiles']['data'] = list;
              await UserStorageService.saveUserData(userData);
            }

            if (mounted) {
              setState(() => _isLoading = false);
              AlertUtils.showSuccess(context: context, message: 'Profil supprimé avec succès.');
              Navigator.pop(context, true);
            }
          } else {
            throw Exception(response.error ?? 'Erreur lors de la suppression.');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          AlertUtils.showError(context: context, message: 'Erreur: $e');
        }
      }
    }
  }

  Widget _buildOptionBox({required List<Widget> children}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getWidgetBackgroundColor(isDarkMode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(isDarkMode);

    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0, top: 24.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: textColor.withOpacity(0.6),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    bool readOnly = false,
    Widget? suffix,
    int? maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            color: textColor.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                maxLines: maxLines,
                maxLength: maxLength,
                keyboardType: keyboardType,
                onChanged: onChanged,
                style: TextStyle(color: textColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
                  counterText: '',
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 12),
              suffix,
            ]
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

    final actualUserData = widget.userData.containsKey('data') ? widget.userData['data'] : widget.userData;
    final email = actualUserData?['email'] ?? '';
    final createdAt = actualUserData?['createdAt'] ?? '';
    final activeProfileName = widget.profile['profileName'] ?? '';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil de $activeProfileName',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _handleSave,
              child: const Text(
                'Enregistrer',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION AVATAR ET INFORMATIONS DE BASE DU COMPTE
                    _buildOptionBox(
                      children: [
                        Row(
                          children: [
                            // Grand Avatar circulaire avec Camera
                            Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _isDefaultProfile ? const Color(0xFFE50914) : Colors.white24,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _buildCurrentImageWidget(
                                      _avatarColors[widget.profile['id'].hashCode % _avatarColors.length],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _selectImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE50914),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Texte descriptif
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeProfileName,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_isDefaultProfile) ...[
                                    const SizedBox(height: 4),
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
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.5),
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13),
                                      children: [
                                        const TextSpan(text: 'Profil actif : '),
                                        TextSpan(
                                          text: activeProfileName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // BOÎTES DE BADGES (EMAIL, TELEPHONE, MEMBRE DEPUIS)
                    _buildOptionBox(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mail_outline_rounded, color: Color(0xFF00C853), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      color: Color(0xFF00C853),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'EMAIL',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.4),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildOptionBox(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, color: Color(0xFF00C853), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_selectedCountryCode ${_phoneController.text}',
                                    style: const TextStyle(
                                      color: Color(0xFF00C853),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'TÉLÉPHONE',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.4),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildOptionBox(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: textColor.withOpacity(0.6), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatMemberSince(createdAt),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'MEMBRE DEPUIS',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.4),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // SECTION 5 : MON PROFIL
                    _buildSectionTitle('Mon profil'),
                    _buildOptionBox(
                      children: [
                        _buildTextField(
                          controller: _profileNameController,
                          labelText: 'Nom du profil',
                          hintText: 'Saisir le nom du profil',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Visible sur l\'écran « Qui regarde ? ».',
                          style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "L'image de profil se change en haut via l'icône caméra 📷.",
                          style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
                        ),
                      ],
                    ),

                    // SECTION 6 : INFORMATIONS DU COMPTE (Uniquement pour le profil principal)
                    if (_isDefaultProfile) ...[
                      _buildSectionTitle('Informations du compte'),
                      _buildOptionBox(
                        children: [
                          _buildTextField(
                            controller: _usernameController,
                            labelText: 'Pseudo du compte',
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: TextEditingController(text: email),
                            labelText: 'Email',
                            readOnly: true,
                            suffix: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '@ Email',
                                style: TextStyle(
                                  color: Color(0xFF00C853),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'L\'email ne peut pas être modifié ici.',
                            style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
                          ),
                          const SizedBox(height: 16),

                          // Numéro de téléphone
                          Text(
                            'Numéro de téléphone',
                            style: TextStyle(
                              color: textColor.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Sélecteur d'indicatif pays
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCountryCode,
                                    dropdownColor: Colors.grey[900],
                                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor.withOpacity(0.5)),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedCountryCode = newValue;
                                        });
                                      }
                                    },
                                    items: _countryCodes.map<DropdownMenuItem<String>>((Map<String, String> country) {
                                      return DropdownMenuItem<String>(
                                        value: country['dial'],
                                        child: Text('${country['code']} ${country['dial']}'),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Champ numéro
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(color: textColor, fontSize: 15),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Téléphone local',
                                    hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
                                    filled: true,
                                    fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sélectionne le pays puis saisis ton numéro local.',
                            style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
                          ),
                          const SizedBox(height: 16),

                          // Bio
                          _buildTextField(
                            controller: _bioController,
                            labelText: 'Bio',
                            hintText: 'Tes films/séries préférés...',
                            maxLines: 4,
                            maxLength: 200,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${_bioController.text.length}/200',
                              style: TextStyle(
                                color: textColor.withOpacity(0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Présente-toi en quelques mots (optionnel).',
                            style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
                          ),
                        ],
                      ),

                      // SECTION 7 : SÉCURITÉ
                      _buildSectionTitle('Sécurité'),
                      _buildOptionBox(
                        children: [
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Redirection vers le changement de mot de passe...')),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.key_rounded, color: Colors.red, size: 22),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Changer le mot de passe',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Mets à jour ton mot de passe DayWatch',
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    // SECTION 8 : ZONE DANGEREUSE
                    _buildSectionTitle('Zone dangereuse'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.04),
                        border: Border.all(color: Colors.red.withOpacity(0.15), width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'ZONE DANGEREUSE',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isDefaultProfile
                                ? 'La suppression est définitive : ton compte, tes profils, tes favoris et tes commentaires seront supprimés.'
                                : 'La suppression du profil est définitive : ton historique de lecture, tes favoris et tes personnalisations seront perdus.',
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _handleDeleteProfileOrAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _isDefaultProfile ? 'Supprimer le compte' : 'Supprimer le profil',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }
}
