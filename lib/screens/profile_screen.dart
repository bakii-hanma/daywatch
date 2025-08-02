import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../design_system/colors.dart';
import '../widgets/profile/edit_profile_modal.dart';
import '../widgets/profile/user_info_section.dart';
import '../widgets/profile/profile_options_section.dart';
import '../services/user_storage_service.dart';
import '../services/api_client.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _mainProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserStorageService.getUserData();
      final mainProfile = await UserStorageService.getMainProfile();

      setState(() {
        _userData = userData;
        _mainProfile = mainProfile;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des données utilisateur: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showEditProfileModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileModal(
        initialUsername:
            _mainProfile?['profileName'] ?? _userData?['username'] ?? '',
        currentAvatarUrl: _mainProfile?['profileAvatarUrl'],
        onSave: _saveProfileChanges,
      ),
    );
  }

  Future<void> _saveProfileChanges(String newUsername, File? newImage) async {
    try {
      if (_userData == null || _mainProfile == null) {
        throw Exception('Données utilisateur manquantes');
      }

      final Map<String, dynamic> updateData = {
        'profileId': _mainProfile!['id'],
      };

      // Nom d'utilisateur
      if (newUsername.isNotEmpty &&
          newUsername != _mainProfile!['profileName']) {
        updateData['profileName'] = newUsername;
        updateData['username'] = newUsername;
      }

      // Image
      if (newImage != null) {
        final bytes = await newImage.readAsBytes();
        updateData['profileAvatarBase64'] = base64Encode(bytes);
        updateData['profileAvatarExtension'] = newImage.path.split('.').last;
      }

      final token = await UserStorageService.getToken();
      if (token == null) throw Exception('Token manquant');

      final response = await ApiClient.post<Map<String, dynamic>>(
        ApiClient.updateProfileUrl,
        body: updateData,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        await _updateLocalData(updateData, response.data, newImage);
        _showSnackBar('Profil mis à jour avec succès !', Colors.green);
      } else {
        throw Exception(response.error ?? 'Erreur de mise à jour');
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    }
  }

  Future<void> _updateLocalData(
    Map<String, dynamic> updateData,
    Map<String, dynamic>? apiData,
    File? newImage,
  ) async {
    final updatedUserData = Map<String, dynamic>.from(_userData!);
    final updatedProfile = Map<String, dynamic>.from(_mainProfile!);

    // Mise à jour depuis l'API ou les données locales
    if (apiData != null) {
      if (apiData.containsKey('user')) updatedUserData.addAll(apiData['user']);
      if (apiData.containsKey('profile'))
        updatedProfile.addAll(apiData['profile']);
    } else {
      if (updateData.containsKey('profileName')) {
        updatedProfile['profileName'] = updateData['profileName'];
        updatedUserData['username'] = updateData['username'];
      }
      if (newImage != null) {
        updatedProfile['profileAvatarUrl'] =
            apiData?['profileAvatarUrl'] ?? newImage.path;
      }
    }

    // Mise à jour de la liste des profils
    if (updatedUserData['profiles']?['data'] != null) {
      final profilesList = List.from(updatedUserData['profiles']['data']);
      final index = profilesList.indexWhere(
        (p) => p['id'] == updatedProfile['id'],
      );
      if (index != -1) {
        profilesList[index] = updatedProfile;
        updatedUserData['profiles']['data'] = profilesList;
      }
    }

    await UserStorageService.saveUserData(updatedUserData);
    setState(() {
      _userData = updatedUserData;
      _mainProfile = updatedProfile;
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await UserStorageService.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
              // Header
              Text(
                'Profil',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Section utilisateur
              UserInfoSection(
                userData: _userData,
                mainProfile: _mainProfile,
                textColor: textColor,
                onEditProfile: _showEditProfileModal,
              ),

              const SizedBox(height: 32),

              // Section Options
              ProfileOptionsSection(
                isDarkMode: isDarkMode,
                textColor: textColor,
              ),

              const SizedBox(height: 40),

              // Bouton de déconnexion
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _handleLogout,
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
