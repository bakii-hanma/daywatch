import 'package:daywatch/screens/device_selection_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/daywatch_logo.dart';
import '../widgets/common/animated_poster_background.dart';
import '../widgets/common/custom_text_field.dart';
import '../utils/alert_utils.dart';
import 'otp_verification_screen.dart';
import 'login_screen.dart';
import '../services/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
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
                  stops: const [0.0, 0.15, 0.4, 0.6, 1.0],
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

          // Contenu principal avec défilement
          Positioned.fill(
            top: 100,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo DAYWATCH
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: DaywatchLogo(
                        size: LogoSize.xlarge,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Formulaire d'inscription
                // Titre principal
                Text(
                  'Ravis de vous\nrencontrer !',
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
                  'Créez votre compte pour commencer',
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
                const SizedBox(height: 16),

                // Champ Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'votre@email.com',
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Champ Numéro de téléphone
                CustomTextField(
                  controller: _phoneNumberController,
                  label: 'Numéro de téléphone',
                  hintText: 'Votre numéro de téléphone',
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                // Champ Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hintText: 'Votre mot de passe',
                  isDarkMode: isDarkMode,
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Bouton S'inscrire
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Vérifier que les champs ne sont pas vides
                      if (_usernameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        AlertUtils.showError(
                          context: context,
                          message: 'Veuillez remplir tous les champs',
                          debugDetails: 'Tentative d\'inscription avec des champs vides: ' +
                              'username=${_usernameController.text.isEmpty}, ' +
                              'email=${_emailController.text.isEmpty}, ' +
                              'password=${_passwordController.text.isEmpty}, ' +
                              'phone=${_phoneNumberController.text.isEmpty}',
                        );
                        return;
                      }

                      // Afficher un indicateur de chargement
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      // Préparer les données d'inscription
                      final userData = {
                        'username': _usernameController.text,
                        'email': _emailController.text,
                        'phoneNumber': _phoneNumberController.text,
                        'password': _passwordController.text,
                      };

                      try {
                        // Appeler l'API d'inscription
                        final response = await ApiClient.registerUser(
                          body: userData,
                        );

                        // Fermer le dialogue de chargement
                        Navigator.pop(context);

                        if (response.isSuccess) {
                          // Afficher un message de succès
                          AlertUtils.showSuccess(
                            context: context,
                            message: 'Inscription réussie !',
                            debugDetails: 'Utilisateur inscrit avec succès: ' +
                                'username=${_usernameController.text}, ' +
                                'email=${_emailController.text}, ' +
                                'réponse API=${response.data}',
                          );

                          // Naviguer vers l'écran de vérification OTP
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OtpVerificationScreen(),
                            ),
                          );
                        } else {
                          // Afficher le message d'erreur
                          AlertUtils.showError(
                            context: context,
                            message: response.error ?? 'Erreur d\'inscription',
                            debugDetails: 'Échec d\'inscription: ' +
                                'username=${_usernameController.text}, ' +
                                'email=${_emailController.text}, ' +
                                'erreur API=${response.error}',
                          );
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const DeviceSelectionScreen(),
                          ));
                        }
                      } catch (e) {
                        // Fermer le dialogue de chargement
                        Navigator.pop(context);
                        
                        // Afficher l'erreur
                        AlertUtils.showError(
                          context: context,
                          message: 'Une erreur est survenue lors de l\'inscription',
                          debugDetails: 'Exception lors de l\'inscription: ' +
                              'username=${_usernameController.text}, ' +
                              'email=${_emailController.text}, ' +
                              'exception=$e',
                        );
                      }
                    },
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
                    child: const Text(
                      'S\'inscrire',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Lien vers connexion
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Déjà DayWatcher ? ',
                            style: TextStyle(
                              color: subtleTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'Se connecter',
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
                
                // Espace supplémentaire en bas pour le défilement
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
