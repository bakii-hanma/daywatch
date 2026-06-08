import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/subscription_card.dart';
import '../widgets/common/subscription_circular_progress.dart';
import '../services/plan_service.dart';
import '../models/plan_model.dart';
import '../models/subscription_status_model.dart';
import 'payment_screen.dart';
import 'devices_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<PlanApiModel> _plans = [];
  UserSubscriptionStatusModel? _subStatus;
  int selectedIndex = 0;
  bool _isLoading = true;
  bool _showPlanSelector = false; // Permet aux abonnés actifs d'afficher le sélecteur pour changer d'offre

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final plans = await PlanService.getPlans();
      final subStatus = await PlanService.getSubscriptionStatus();
      setState(() {
        _plans = plans.where((p) => p.price > 0).toList();
        _subStatus = subStatus;
        _isLoading = false;
        
        // Sélectionner par défaut le premier plan
        if (selectedIndex >= _plans.length) {
          selectedIndex = 0;
        }
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des offres et du statut: $e');
      setState(() => _isLoading = false);
    }
  }

  bool _isActivePaidSub() {
    if (_subStatus == null) return false;
    if (_subStatus!.isTrialPeriod) return false;
    final status = _subStatus!.status?.toUpperCase() ?? '';
    return ['ACTIVE', 'SUBSCRIPTION_ENDING_SOON', 'SUBSCRIPTION_ENDING_CRITICAL'].contains(status);
  }

  bool _isTrial() {
    if (_subStatus == null) return false;
    if (_subStatus!.isTrialPeriod) return true;
    final status = _subStatus!.status?.toUpperCase() ?? '';
    return status.startsWith('TRIAL');
  }

  String _fallbackPosterFor(String name) {
    final fallbackPosters = [
      'https://image.tmdb.org/t/p/w780/voHUmluYmKyleFkTu3lOXQG702u.jpg',
      'https://image.tmdb.org/t/p/w780/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
      'https://image.tmdb.org/t/p/w780/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      'https://image.tmdb.org/t/p/w780/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg',
      'https://image.tmdb.org/t/p/w780/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
      'https://image.tmdb.org/t/p/w780/b0Ej6fnXAP8fK75hlyi2jKqdhHz.jpg',
      'https://image.tmdb.org/t/p/w780/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
      'https://image.tmdb.org/t/p/w780/9Ycz7yYRf9V4jk3YXwcZhFtbNcF.jpg',
    ];
    int sum = 0;
    for (int i = 0; i < name.length; i++) {
      sum += name.codeUnitAt(i);
    }
    return fallbackPosters[sum % fallbackPosters.length];
  }

  List<Map<String, dynamic>> _getBenefits(String planName) {
    final name = planName.toLowerCase();
    final isFamily = name.contains('family') || name.contains('famille');
    final isPremium = name.contains('premium');
    final isStandard = name.contains('standard');

    if (isFamily) {
      return [
        {'icon': Icons.people_rounded, 'label': '5 profils'},
        {'icon': Icons.phone_android_rounded, 'label': '5 appareils simultanés'},
        {'icon': Icons.verified_user_rounded, 'label': 'Sans publicité'},
        {'icon': Icons.download_rounded, 'label': 'Téléchargements illimités'},
        {'icon': Icons.hd_rounded, 'label': 'Qualité 4K UHD'},
        {'icon': Icons.tv_rounded, 'label': 'IPTV + Sports inclus'},
      ];
    }
    if (isPremium) {
      return [
        {'icon': Icons.people_rounded, 'label': '4 profils'},
        {'icon': Icons.phone_android_rounded, 'label': '4 appareils simultanés'},
        {'icon': Icons.verified_user_rounded, 'label': 'Sans publicité'},
        {'icon': Icons.download_rounded, 'label': 'Téléchargements'},
        {'icon': Icons.hd_rounded, 'label': 'Qualité 4K UHD'},
        {'icon': Icons.tv_rounded, 'label': 'IPTV inclus'},
      ];
    }
    if (isStandard) {
      return [
        {'icon': Icons.people_rounded, 'label': '3 profils'},
        {'icon': Icons.phone_android_rounded, 'label': '2 appareils simultanés'},
        {'icon': Icons.verified_user_rounded, 'label': 'Sans publicité'},
        {'icon': Icons.hd_rounded, 'label': 'Qualité Full HD'},
        {'icon': Icons.tv_rounded, 'label': 'IPTV inclus'},
      ];
    }
    return [
      {'icon': Icons.people_rounded, 'label': '2 profils'},
      {'icon': Icons.phone_android_rounded, 'label': '1 appareil'},
      {'icon': Icons.hd_rounded, 'label': 'Qualité HD'},
      {'icon': Icons.check_circle_rounded, 'label': 'Accès au catalogue'},
    ];
  }

  Map<String, String> _buildSubscriptionMap(PlanApiModel plan, int index) {
    // Déterminer une description/durée agréable
    String durationText = 'Engagement ${plan.duration}';
    if (plan.duration.toLowerCase() == 'monthly' || plan.duration.toLowerCase() == 'mois') {
      durationText = 'Mensuel';
    } else if (plan.duration.toLowerCase() == 'yearly' || plan.duration.toLowerCase() == 'an') {
      durationText = 'Annuel';
    }

    String deviceLimitText = '${plan.maxDevices} Appareils max';
    if (plan.maxConcurrentStreams > 1) {
      deviceLimitText += ' • ${plan.maxConcurrentStreams} Écrans simultanés';
    }

    final poster = _fallbackPosterFor(plan.name);

    return {
      'id': plan.id.toString(),
      'title': plan.name,
      'price': plan.price.toStringAsFixed(0),
      'duration': '$durationText ($deviceLimitText)',
      'description': plan.description ?? 
          'Accès complet ${plan.hasMovies ? "Films" : ""} ${plan.hasShows ? "• Séries" : ""} ${plan.hasIPTV ? "• Chaînes TV" : ""}. ${plan.allowDownloads ? "Téléchargement inclus." : ""} ${plan.hasAds ? "Avec publicités." : "Sans publicités."}',
      'lightImage': poster,
      'darkImage': poster,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);

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
          'Abonnement',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isActivePaidSub() && !_showPlanSelector
                ? _buildActiveSubDashboard(textColor, isDarkMode)
                : _buildPlanSelector(textColor, isDarkMode),
      ),
    );
  }

  // ÉCRAN 1: Tableau de bord d'un abonnement actif
  Widget _buildActiveSubDashboard(Color textColor, bool isDarkMode) {
    final plan = _subStatus!.plan;
    final planName = plan?.name ?? 'Premium';
    final backdropUrl = _fallbackPosterFor(planName);
    
    final daysRemaining = _subStatus!.daysRemaining;
    final totalDays = _subStatus!.totalDays;
    
    // Déterminer la couleur de l'anneau
    final status = _subStatus!.status?.toUpperCase() ?? '';
    final isCritical = daysRemaining <= 3 || status == 'SUBSCRIPTION_ENDING_CRITICAL';
    final isWarning = daysRemaining <= 7 || status == 'SUBSCRIPTION_ENDING_SOON';
    final ringColor = isCritical 
        ? const Color(0xFFEF4444) 
        : isWarning 
            ? const Color(0xFFF59E0B) 
            : AppColors.primary;

    // Parser la date d'échéance de fin
    String endDateLabel = '—';
    if (_subStatus!.endDate != null) {
      try {
        final date = DateTime.parse(_subStatus!.endDate!);
        final monthsList = [
          'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
          'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
        ];
        endDateLabel = '${date.day} ${monthsList[date.month - 1]} ${date.year}';
      } catch (_) {}
    }

    final benefits = _getBenefits(planName);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Card cinéma
          Container(
            height: 380,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Image arrière-plan nette
                  Positioned.fill(
                    child: Image.network(
                      backdropUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                    ),
                  ),
                  // Gradients (Cinéma style)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Ring jours restants (Top-Right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SubscriptionCircularProgress(
                      daysRemaining: daysRemaining,
                      totalDays: totalDays,
                      ringColor: ringColor,
                    ),
                  ),

                  // Contenu textuel et actions (Bas-Gauche)
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge d'état
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 6),
                              const Text(
                                'ABONNEMENT ACTIF',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Titre du plan
                        Text(
                          planName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Date d'échéance
                        Text(
                          'Jusqu\'au $endDateLabel',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Message d'état s'il y en a un
                        if (_subStatus!.message != null && _subStatus!.message!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isCritical 
                                  ? Colors.red.withOpacity(0.2) 
                                  : Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCritical 
                                    ? Colors.red.withOpacity(0.3) 
                                    : Colors.amber.withOpacity(0.25)
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: isCritical ? Colors.red[300] : Colors.amber[300],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _subStatus!.message!,
                                    style: TextStyle(
                                      color: isCritical ? Colors.red[100] : Colors.amber[100],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Bouton principal
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showPlanSelector = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: AppColors.primary.withOpacity(0.4),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Renouveler / Changer de plan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Avantages du plan
          Text(
            'AVANTAGES DE VOTRE PLAN',
            style: TextStyle(
              color: textColor.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: textColor.withOpacity(0.1)),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: benefits.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
              ),
              itemBuilder: (context, idx) {
                final item = benefits[idx];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // 3. Détails de facturation
          Text(
            'FACTURATION',
            style: TextStyle(
              color: textColor.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: textColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _buildBillingRow(Icons.payment_rounded, 'Mode de paiement', 'E-Billing (Mobile Money)', textColor),
                const Divider(height: 20),
                _buildBillingRow(
                  Icons.receipt_long_rounded, 
                  'Montant', 
                  '${plan?.price != null ? plan!.price.toStringAsFixed(0) : "—"} Fcfa / mois', 
                  textColor
                ),
                const Divider(height: 20),
                _buildBillingRow(Icons.calendar_month_rounded, 'Prochaine échéance', endDateLabel, textColor),
                const Divider(height: 20),
                _buildBillingRow(Icons.autorenew_rounded, 'Renouvellement', 'Manuel', textColor),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Actions rapides
          Text(
            'ACTIONS RAPIDES',
            style: TextStyle(
              color: textColor.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: textColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _buildQuickActionTile(
                  Icons.star_rounded,
                  'Renouveler / Changer de plan',
                  'Sélectionnez un nouveau plan',
                  textColor,
                  onTap: () {
                    setState(() {
                      _showPlanSelector = true;
                    });
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildQuickActionTile(
                  Icons.people_rounded,
                  'Gérer les profils',
                  'Ajouter ou modifier les profils',
                  textColor,
                  onTap: () {
                    // Message informatif comme sur le web
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rends-toi dans les paramètres de profil pour gérer tes profils.')),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildQuickActionTile(
                  Icons.phone_android_rounded,
                  'Appareils connectés',
                  'Voir et déconnecter vos appareils',
                  textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DevicesScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBillingRow(IconData icon, String label, String value, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: textColor.withOpacity(0.7), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile(
    IconData icon, 
    String title, 
    String subtitle, 
    Color textColor,
    {required VoidCallback onTap}
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textColor.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  // ÉCRAN 2: Sélecteur d'offres / liste des plans
  Widget _buildPlanSelector(Color textColor, bool isDarkMode) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Bannière d'essai si applicable
              if (_isTrial()) _buildTrialBanner(),

              // Titre de section
              Text(
                _isTrial() ? 'Passez à un abonnement complet' : 'Sélectionnez votre offre d\'abonnement',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (_plans.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      'Nos offres seront disponibles très prochainement. Reviens dans un instant !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _plans.length,
                  itemBuilder: (context, index) {
                    final plan = _plans[index];
                    final subscription = _buildSubscriptionMap(plan, index);
                    return SubscriptionCard(
                      title: subscription['title']!,
                      price: subscription['price']!,
                      duration: subscription['duration']!,
                      description: subscription['description']!,
                      lightImagePath: subscription['lightImage']!,
                      darkImagePath: subscription['darkImage']!,
                      isSelected: selectedIndex == index,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
            ],
          ),
        ),

        // Bouton de validation
        if (_plans.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isActivePaidSub() && _showPlanSelector)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showPlanSelector = false;
                      });
                    },
                    child: Text(
                      'Retour au tableau de bord',
                      style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final planSelected = _plans[selectedIndex];
                      
                      // Navigation vers l'écran de paiement
                      final paid = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            selectedSubscription: _buildSubscriptionMap(planSelected, selectedIndex),
                            planId: planSelected.id,
                            monthlyPrice: planSelected.price,
                            planName: planSelected.name,
                            description: planSelected.description ?? '',
                            existingEndDate: _subStatus?.endDate,
                          ),
                        ),
                      );

                      if (paid == true) {
                        // Recharger les données pour refléter l'abonnement
                        _loadData();
                        setState(() {
                          _showPlanSelector = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirmer l\'abonnement',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTrialBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Essai gratuit · ${_subStatus?.daysRemaining ?? 0} jour${(_subStatus?.daysRemaining ?? 0) > 1 ? 's' : ''} restant${(_subStatus?.daysRemaining ?? 0) > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Choisissez un abonnement maintenant pour ne pas perdre l\'accès à la fin de l\'essai.',
            style: TextStyle(
              color: Colors.amber.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
