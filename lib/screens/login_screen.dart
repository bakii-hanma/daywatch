import 'package:flutter/material.dart';
import 'dart:ui';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/daywatch_logo.dart';
import '../widgets/common/animated_poster_background.dart';
import '../utils/alert_utils.dart';
import 'otp_verification_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../services/api_client.dart';
import '../services/user_storage_service.dart';
import 'home_screen.dart';
import '../widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      AlertUtils.showError(
        context: context,
        message: 'Veuillez remplir tous les champs.',
        debugDetails:
            'Tentative de connexion avec des champs vides: username=${username.isEmpty}, password=${password.isEmpty}',
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.loginUser<Map<String, dynamic>>(
        body: {'email': username, 'password': password},
      );
      setState(() => _isLoading = false);
      if (response.isSuccess && response.data != null) {
        // Sauvegarder les données utilisateur
        await UserStorageService.saveUserData(response.data!);

        // Connexion réussie, naviguer vers l'écran d'accueil
        AlertUtils.showSuccess(
          context: context,
          message: 'Connexion réussie !',
          debugDetails:
              'Utilisateur connecté: $username, données: ${response.data}',
        );

        // Naviguer vers l'écran d'accueil en remplaçant toute la pile de navigation
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        AlertUtils.showError(
          context: context,
          message: response.error ?? 'Erreur de connexion.',
          debugDetails: 'Échec de connexion pour $username: ${response.error}',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      AlertUtils.showError(
        context: context,
        message: 'Une erreur est survenue lors de la connexion.',
        debugDetails: 'Exception lors de la connexion pour $username: $e',
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(isDarkMode);
    final subtleTextColor = textColor.withOpacity(0.7);
    final overlayColors = AppColors.getAuthOverlayColors(isDarkMode);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Arrière-plan avec widget animé
          const Positioned.fill(child: AnimatedPosterBackground()),

          // Overlay avec dégradé
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: overlayColors,
                  stops: const [0.0, 0.15, 0.2, 0.3, 1.0],
                ),
              ),
            ),
          ),

          // Barre de statut en haut
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '9:30',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.getAuthStatusBarColor(isDarkMode),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        color: textColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.wifi, color: textColor, size: 16),
                      const SizedBox(width: 4),
                      Icon(Icons.battery_full, color: textColor, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bouton retour
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.getAuthStatusBarColor(isDarkMode),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.arrow_back, color: textColor, size: 20),
              ),
            ),
          ),

          // Logo DAYWATCH
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: DaywatchLogo(
                  size: LogoSize.xlarge,
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
          ),

          // Contenu principal
          Positioned(
            left: 20,
            right: 20,
            bottom: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre principal
                Text(
                  'Content de vous revoir\nDayWatcher',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Connectez-vous pour continuer',
                  style: TextStyle(fontSize: 14, color: subtleTextColor),
                ),
                const SizedBox(height: 32),

                // Champ Nom d'utilisateur
                CustomTextField(
                  controller: _usernameController,
                  label: 'Nom d\'utilisateur',
                  hintText: 'Votre nom d\'utilisateur',
                  isDarkMode: isDarkMode,
                ),

                const SizedBox(height: 20),

                // Champ Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hintText: 'Votre mot de passe',
                  isDarkMode: isDarkMode,
                ),

                const SizedBox(height: 16),

                // Lien mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: AppTypography.linkText(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton Se connecter
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSmall,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Lien
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Pas encore DayWatcher ? ',
                            style: TextStyle(
                              color: subtleTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'S\'inscrire',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
