import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/subscription_card.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedIndex = 0; // Premier élément sélectionné par défaut

  final List<Map<String, String>> subscriptions = [
    {
      'title': 'Offre Basique',
      'price': '250',
      'duration': '1 Film ou 1 Episode',
      'description':
          'Brève description de cette offre Brève description de cette offre',
      'lightImage':
          'assets/abonnement/light/ecabd90aaa6195318fd67aa0761c5f36b2387adf.png',
      'darkImage':
          'assets/abonnement/dark/092bca144d4cad18a23c04e125bc19aae31bac8e.png',
    },
    {
      'title': 'Offre Standard',
      'price': '250',
      'duration': '1 Film ou 1 Episode',
      'description':
          'Brève description de cette offre Brève description de cette offre',
      'lightImage':
          'assets/abonnement/light/4cb73f59459e9ab0a7110da5ad0a17f9cd91caef.png',
      'darkImage':
          'assets/abonnement/dark/e335b06463380149e37faf3c5e40cdcde82dffb7.png',
    },
    {
      'title': 'Offre Premium',
      'price': '250',
      'duration': '1 Film ou 1 Episode',
      'description':
          'Brève description de cette offre Brève description de cette offre',
      'lightImage':
          'assets/abonnement/light/cf9d1835a4a8a5a6b4cfc705342eee21e1107a9b.png',
      'darkImage':
          'assets/abonnement/dark/571d99f5e969d5b11f5f5645bb341af10e52ea76.png',
    },
    {
      'title': 'Offre Famille',
      'price': '250',
      'duration': '1 Film ou 1 Episode',
      'description':
          'Brève description de cette offre Brève description de cette offre',
      'lightImage':
          'assets/abonnement/light/277d255c39774b03ecf35db39b8b59631c8dd078.png',
      'darkImage':
          'assets/abonnement/dark/bae9daa246c621567bf89085212c6ae22dfbf8cd.png',
    },
    {
      'title': 'Offre Étudiant',
      'price': '250',
      'duration': '1 Film ou 1 Episode',
      'description':
          'Brève description de cette offre Brève description de cette offre',
      'lightImage':
          'assets/abonnement/light/dfcbbca85f225eaa93102c402f889a528a3401ad.png',
      'darkImage':
          'assets/abonnement/dark/12d5a9259ee3f1b5d153c3a16f11ed954d8b8e4e.png',
    },
    {
      'title': 'Offre Annuelle',
      'price': '250',
      'duration': '1 Film ou 1 Episode',
      'description':
          'Brève description de cette offre Brève description de cette offre',
      'lightImage':
          'assets/abonnement/light/f86c5246879d32f2c537af3525c83a1b8abcd4aa.png',
      'darkImage':
          'assets/abonnement/dark/ede6df0f56fa0968a12abb741528a84af926d4dc.png',
    },
  ];

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
        child: Column(
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
                itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = subscriptions[index];
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
                          selectedSubscription: subscriptions[selectedIndex],
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
