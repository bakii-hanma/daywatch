import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/subscription_card.dart';
import '../services/plan_service.dart';
import '../models/plan_model.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<PlanApiModel> _plans = [];
  int selectedIndex = 0;
  bool _isLoading = true;

  final List<Map<String, String>> planImages = const [
    {
      'lightImage': 'assets/abonnement/light/ecabd90aaa6195318fd67aa0761c5f36b2387adf.png',
      'darkImage': 'assets/abonnement/dark/092bca144d4cad18a23c04e125bc19aae31bac8e.png',
    },
    {
      'lightImage': 'assets/abonnement/light/4cb73f59459e9ab0a7110da5ad0a17f9cd91caef.png',
      'darkImage': 'assets/abonnement/dark/e335b06463380149e37faf3c5e40cdcde82dffb7.png',
    },
    {
      'lightImage': 'assets/abonnement/light/cf9d1835a4a8a5a6b4cfc705342eee21e1107a9b.png',
      'darkImage': 'assets/abonnement/dark/571d99f5e969d5b11f5f5645bb341af10e52ea76.png',
    },
    {
      'lightImage': 'assets/abonnement/light/277d255c39774b03ecf35db39b8b59631c8dd078.png',
      'darkImage': 'assets/abonnement/dark/bae9daa246c621567bf89085212c6ae22dfbf8cd.png',
    },
    {
      'lightImage': 'assets/abonnement/light/dfcbbca85f225eaa93102c402f889a528a3401ad.png',
      'darkImage': 'assets/abonnement/dark/12d5a9259ee3f1b5d153c3a16f11ed954d8b8e4e.png',
    },
    {
      'lightImage': 'assets/abonnement/light/f86c5246879d32f2c537af3525c83a1b8abcd4aa.png',
      'darkImage': 'assets/abonnement/dark/ede6df0f56fa0968a12abb741528a84af926d4dc.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final plans = await PlanService.getPlans();
      setState(() {
        _plans = plans;
        _isLoading = false;
        // S'assurer que selectedIndex est toujours valide
        if (selectedIndex >= _plans.length) {
          selectedIndex = 0;
        }
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des plans: $e');
      setState(() => _isLoading = false);
    }
  }

  Map<String, String> _buildSubscriptionMap(int index) {
    if (index < 0 || index >= _plans.length) return {};
    
    final plan = _plans[index];
    final imageIndex = index % planImages.length;
    final lightImage = planImages[imageIndex]['lightImage']!;
    final darkImage = planImages[imageIndex]['darkImage']!;
    
    // Déterminer une description/durée agréable
    String durationText = 'Engagement ${plan.duration}';
    if (plan.duration.toLowerCase() == 'monthly' || plan.duration.toLowerCase() == 'mois') {
      durationText = 'Mensuel';
    } else if (plan.duration.toLowerCase() == 'yearly' || plan.duration.toLowerCase() == 'an') {
      durationText = 'Annuel';
    }

    String deviceLimitText = '${plan.maxDevices} Appareils maximum';
    if (plan.maxConcurrentStreams > 1) {
      deviceLimitText += ' • ${plan.maxConcurrentStreams} Écrans simultanés';
    }

    return {
      'title': plan.name,
      'price': plan.price.toStringAsFixed(0),
      'duration': '$durationText ($deviceLimitText)',
      'description': plan.description ?? 
          'Accès complet ${plan.hasMovies ? "Films" : ""} ${plan.hasShows ? "• Séries" : ""} ${plan.hasIPTV ? "• Chaînes TV" : ""}. ${plan.allowDownloads ? "Téléchargement inclus." : ""} ${plan.hasAds ? "Avec publicités." : "Sans publicités."}',
      'lightImage': lightImage,
      'darkImage': darkImage,
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
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _plans.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_membership_rounded,
                            size: 64,
                            color: textColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune offre d\'abonnement n\'est disponible pour le moment.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadPlans,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Réessayer',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Titre de section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sélectionnez votre offre d\'abonnement',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Liste des abonnements
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _plans.length,
                          itemBuilder: (context, index) {
                            final subscription = _buildSubscriptionMap(index);
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
                      ),

                      // Bouton de confirmation
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigation vers la page de paiement
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentScreen(
                                    selectedSubscription: _buildSubscriptionMap(selectedIndex),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
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
                      ),
                    ],
                  ),
      ),
    );
  }
}
