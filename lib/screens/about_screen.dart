import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Impossible d\'ouvrir le lien : $urlString'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);
    final textSecondaryColor = AppColors.getTextSecondaryColor(isDarkMode);
    final surfaceColor = AppColors.getSurfaceColor(isDarkMode);
    final primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'À propos',
          style: AppTypography.title(textColor).copyWith(
            fontSize: AppTypography.fontSizeTitle + 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BLOC LOGO & INFOS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl, horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Icône "i" d'info stylisée
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.info_rounded,
                        color: primaryColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Nom de l'appli
                    Text(
                      'DayWatch',
                      style: AppTypography.header(textColor).copyWith(
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Slogan
                    Text(
                      'Le streaming nouvelle génération',
                      style: AppTypography.body(textSecondaryColor),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Badges Version et Build
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge('Version 1.0.0', isDarkMode),
                        const SizedBox(width: AppSpacing.md),
                        _buildBadge('Build 2026.05.15', isDarkMode),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // BLOC DESCRIPTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DayWatch est la plateforme de streaming pensée pour le Gabon et l\'Afrique : films, séries, TV en direct et sports live. Paiement Mobile Money pour rester proche de ses utilisateurs.',
                      style: AppTypography.body(textColor).copyWith(
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Conçue et développée à Libreville. Tous droits réservés © 2026.',
                      style: AppTypography.bodyMedium(textColor).copyWith(
                        color: textSecondaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // MENTIONS LÉGALES
              Text(
                'MENTIONS LÉGALES',
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // TUILES DE LIENS
              _buildLegalTile(
                context: context,
                icon: Icons.article_rounded,
                title: 'Conditions d\'utilisation',
                url: 'https://daywatch.online/terms',
                surfaceColor: surfaceColor,
                textColor: textColor,
                textSecondaryColor: textSecondaryColor,
              ),
              _buildLegalTile(
                context: context,
                icon: Icons.shield_outlined,
                title: 'Politique de confidentialité',
                url: 'https://daywatch.online/privacy',
                surfaceColor: surfaceColor,
                textColor: textColor,
                textSecondaryColor: textSecondaryColor,
              ),
              _buildLegalTile(
                context: context,
                icon: Icons.cookie_rounded,
                title: 'Cookies',
                url: 'https://daywatch.online/cookies',
                surfaceColor: surfaceColor,
                textColor: textColor,
                textSecondaryColor: textSecondaryColor,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegalTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String url,
    required Color surfaceColor,
    required Color textColor,
    required Color textSecondaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: surfaceColor == AppColors.surfaceLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: () => _openUrl(context, url),
        leading: Icon(
          icon,
          color: textColor,
          size: AppSpacing.iconSizeSmall + 4,
        ),
        title: Text(
          title,
          style: AppTypography.bodySemiBold(textColor).copyWith(
            fontSize: 15,
          ),
        ),
        trailing: Icon(
          Icons.launch_rounded,
          color: textSecondaryColor,
          size: 18,
        ),
      ),
    );
  }
}
