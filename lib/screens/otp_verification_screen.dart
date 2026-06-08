import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../widgets/daywatch_logo.dart';
import '../widgets/common/animated_poster_background.dart';
import 'profile_selection_screen.dart';
import '../services/api_client.dart';
import '../services/user_storage_service.dart';
import '../utils/alert_utils.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String password;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      final random = Random();
      final parts = List.generate(
        4,
        (_) => random.nextInt(1000000).toString().padLeft(6, '0'),
      );
      deviceId =
          'device_${DateTime.now().millisecondsSinceEpoch}_${parts.join('')}';
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  Future<void> _handleVerifyAndLogin() async {
    final otpCode = _controllers.map((c) => c.text.trim()).join();
    if (otpCode.length < 6) {
      AlertUtils.showError(
        context: context,
        message: 'Veuillez saisir le code de vérification à 6 chiffres.',
        debugDetails: 'Code incomplet: $otpCode',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Appeler l'API de vérification (verify-email)
      final verifyResponse = await ApiClient.verifyEmail<Map<String, dynamic>>(
        body: {
          'email': widget.email,
          'code': otpCode,
        },
      );

      if (!mounted) return;

      if (!verifyResponse.isSuccess) {
        setState(() => _isLoading = false);
        AlertUtils.showError(
          context: context,
          message: verifyResponse.error ?? 'Code de vérification invalide.',
          debugDetails: 'Échec de vérification OTP: ${verifyResponse.error}',
        );
        return;
      }

      // 2. Connexion automatique après vérification réussie
      final deviceId = await _getOrCreateDeviceId();
      if (!mounted) return;

      String deviceName = 'Appareil Mobile';
      try {
        deviceName = Platform.localHostname;
      } catch (_) {}

      String deviceType = 'Mobile';
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        deviceType = 'Desktop';
      }

      final loginBody = {
        'email': widget.email,
        'password': widget.password,
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
        'operatingSystem': Platform.operatingSystemVersion,
        'appVersion': '1.0.0',
      };

      final loginResponse = await ApiClient.loginUser<Map<String, dynamic>>(
        body: loginBody,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (loginResponse.isSuccess && loginResponse.data != null) {
        // Sauvegarder les données utilisateur
        await UserStorageService.saveUserData(loginResponse.data!);

        if (!mounted) return;

        // Afficher le message de succès
        AlertUtils.showSuccess(
          context: context,
          message: 'Vérification réussie et connexion établie !',
          debugDetails: 'Utilisateur connecté après OTP: ${widget.email}',
        );

        // Naviguer vers l'écran de sélection de profil en remplaçant toute la pile
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSelectionScreen()),
          (route) => false,
        );
      } else {
        AlertUtils.showError(
          context: context,
          message:
              loginResponse.error ?? 'Erreur lors de la connexion automatique.',
          debugDetails: 'Échec de login post-OTP: ${loginResponse.error}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AlertUtils.showError(
        context: context,
        message: 'Une erreur inattendue est survenue.',
        debugDetails: 'Exception post-OTP: $e',
      );
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.resendVerification<Map<String, dynamic>>(
        body: {'email': widget.email},
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (response.isSuccess) {
        AlertUtils.showSuccess(
          context: context,
          message:
              'Code de vérification renvoyé ! Veuillez vérifier votre boîte mail.',
          debugDetails: 'Succès renvoi OTP à ${widget.email}',
        );
      } else {
        AlertUtils.showError(
          context: context,
          message: response.error ?? 'Impossible de renvoyer le code.',
          debugDetails: 'Échec renvoi OTP: ${response.error}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AlertUtils.showError(
        context: context,
        message: 'Erreur lors du renvoi du code de vérification.',
        debugDetails: 'Exception renvoi OTP: $e',
      );
    }
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

          // Contenu principal - Vérification OTP
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
                  'Vérification\nOTP',
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
                  'Entrez le code à 6 chiffres envoyé sur votre adresse e-mail',
                  style: TextStyle(fontSize: 14, color: subtleTextColor),
                ),
                const SizedBox(height: 32),

                // Champs OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      height: 55,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.getAuthFieldFillColor(
                            isDarkMode,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSmall,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.getAuthFieldBorderColor(
                                isDarkMode,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSmall,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.getAuthFieldBorderColor(
                                isDarkMode,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSmall,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(0),
                        ),
                        onChanged: (value) => _onOtpChanged(value, index),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Bouton Vérifier
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerifyAndLogin,
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
                            'Vérifier',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Renvoyer le code
                Center(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handleResendOtp,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Vous n'avez pas reçu le code ? ",
                            style: TextStyle(
                              color: subtleTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'Renvoyer',
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
