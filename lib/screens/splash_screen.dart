import 'package:flutter/material.dart';
import '../widgets/daywatch_logo.dart';
import '../design_system/colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Animation d'échelle plus prononcée
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Animation de rebond finale
    _bounceAnimation = Tween<double>(begin: 1.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.bounceOut),
      ),
    );

    _animationController.forward();

    // Naviguer vers la page principale après 3.5 secondes
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Combinaison des animations d'échelle
          double currentScale = _animationController.value <= 0.6
              ? _scaleAnimation.value
              : _bounceAnimation.value;

          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: currentScale,
                child: DaywatchLogo(
                  size: LogoSize.xlarge, // Taille augmentée
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
