import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';
import '../widgets/daywatch_logo.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Liste des images de posters
    final List<String> posterImages = [
      'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
      'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
      'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
      'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
      'assets/poster/a540bacb454d0bcc68204ff72c60210d17f9679f.jpg',
      'assets/poster/d88c27338531793104f79107f3fdf1722a0e9fdc.jpg',
      'assets/poster/ee95c8d574be76182adb5fd79675435e550090e2.jpg',
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan avec grille d'images espacées
          Positioned.fill(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 4, // Espacement horizontal
                mainAxisSpacing: 4, // Espacement vertical
              ),
              itemCount: 15,
              itemBuilder: (context, index) {
                return Image.asset(
                  posterImages[index % posterImages.length],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // Cadre d'authentification descendu
          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.getAuthContainerColor(isDarkMode),
                    borderRadius: BorderRadius.circular(16),
                    border: AppColors.getAuthContainerBorder(isDarkMode),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Alignement à gauche
                    children: [
                      // Titre aligné à gauche
                      Text(
                        "C'est parti !",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton Se connecter
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Bouton S'inscrire (en blanc)
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
