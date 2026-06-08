import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/typography.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  int _messageCharCount = 0;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateCharCount);
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateCharCount);
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _updateCharCount() {
    setState(() {
      _messageCharCount = _messageController.text.length;
    });
  }

  void _submitForm() {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner le sujet.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez rédiger un message.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Succès de l'envoi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Votre message a été envoyé avec succès !'),
        backgroundColor: Colors.green,
      ),
    );

    // Réinitialiser les champs
    _subjectController.clear();
    _messageController.clear();
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
          'Support technique',
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
              // EN-TÊTE SUPPORT (Casque + Info réponse)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.headset_mic_rounded,
                        color: primaryColor,
                        size: AppSpacing.iconSize,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        'On est là pour toi 7j/7.\nRéponse moyenne sous 24h.',
                        style: AppTypography.bodySemiBold(textColor).copyWith(
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // SECTION CONTACTS DIRECTS
              Text(
                'CONTACTS DIRECTS',
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // CARTES DE CONTACT
              _buildContactCard(
                icon: Icons.mail_outline_rounded,
                title: 'EMAIL',
                value: 'support@daywatch.online',
                surfaceColor: surfaceColor,
                textColor: textColor,
                textSecondaryColor: textSecondaryColor,
                primaryColor: primaryColor,
              ),
              _buildContactCard(
                icon: Icons.phone_rounded,
                title: 'TÉLÉPHONE',
                value: '+241 77 00 00 00',
                surfaceColor: surfaceColor,
                textColor: textColor,
                textSecondaryColor: textSecondaryColor,
                primaryColor: primaryColor,
              ),
              _buildContactCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'WHATSAPP',
                value: '+241 77 00 00 00',
                surfaceColor: surfaceColor,
                textColor: textColor,
                textSecondaryColor: textSecondaryColor,
                primaryColor: primaryColor,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // SECTION ENVOYER UN MESSAGE
              Text(
                'ENVOYER UN MESSAGE',
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // FORMULAIRE
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SUJET
                    Text(
                      'Sujet',
                      style: AppTypography.bodySemiBold(textColor),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: _subjectController,
                        style: AppTypography.body(textColor),
                        decoration: InputDecoration(
                          hintText: 'Décris ton problème en quelques mots',
                          hintStyle: AppTypography.body(textSecondaryColor.withOpacity(0.6)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.lg,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // MESSAGE
                    Text(
                      'Message',
                      style: AppTypography.bodySemiBold(textColor),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: _messageController,
                        style: AppTypography.body(textColor),
                        maxLength: 2000,
                        maxLines: 8,
                        minLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Donne le maximum de détails (appareil, navigateur, étapes pour reproduire...)',
                          hintStyle: AppTypography.body(textSecondaryColor.withOpacity(0.6)),
                          border: InputBorder.none,
                          counterText: '', // On cache le compteur par défaut pour faire notre design personnalisé
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.lg,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // COMPTEUR DE CARACTÈRES
                    Text(
                      '$_messageCharCount/2000 caractères',
                      style: AppTypography.caption(textSecondaryColor.withOpacity(0.8)),
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    // BOUTON ENVOYER
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Envoyer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required Color surfaceColor,
    required Color textColor,
    required Color textSecondaryColor,
    required Color primaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: surfaceColor == AppColors.surfaceLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: AppSpacing.iconSizeSmall + 4,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTypography.bodySemiBold(textColor).copyWith(
                    fontSize: 15,
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
