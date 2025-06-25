import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../widgets/common/subscription_card.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, String> selectedSubscription;

  const PaymentScreen({Key? key, required this.selectedSubscription})
    : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedPaymentMethod = 0; // 0 = Airtel Money, 1 = Moov Money
  final TextEditingController phoneController = TextEditingController();

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
          'Paiement',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte d'abonnement sélectionné (compacte)
                _buildSelectedSubscriptionCard(),

                const SizedBox(height: 24),

                // Titre pour les méthodes de paiement
                Text(
                  'Choisissez le mode de paiement que vous souhaitez utiliser',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                // Options de paiement
                Row(
                  children: [
                    // Airtel Money
                    Expanded(
                      child: _buildPaymentOption(
                        0,
                        'assets/logo/airtel money.png',
                        isDarkMode,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Moov Money
                    Expanded(
                      child: _buildPaymentOption(
                        1,
                        'assets/logo/moov money.png',
                        isDarkMode,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Champ numéro de téléphone
                Text(
                  'Entrez le numéro de téléphone débiteur',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Numéro de téléphone',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 8),

                // Champ de saisie
                TextField(
                  controller: phoneController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Placeholder',
                    hintStyle: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                // Message d'information
                Text(
                  'Vous serez invité à rentrer le mot de passe de votre compte mobile Money',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Veuillez vous rassurer que votre téléphone est déverrouillé et près de vous',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton de paiement
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (phoneController.text.isNotEmpty) {
                        _processPayment();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Veuillez entrer votre numéro de téléphone',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Payer maintenant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSubscriptionCard() {
    return SubscriptionCard(
      title: widget.selectedSubscription['title']!,
      price: widget.selectedSubscription['price']!,
      duration: widget.selectedSubscription['duration']!,
      description: widget.selectedSubscription['description']!,
      lightImagePath: widget.selectedSubscription['lightImage']!,
      darkImagePath: widget.selectedSubscription['darkImage']!,
      isSelected: false, // Pas de bordure rouge ici
    );
  }

  Widget _buildPaymentOption(int index, String logoPath, bool isDarkMode) {
    final isSelected = selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = index;
        });
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.red, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              logoPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[600],
                  child: const Icon(Icons.payment, color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _processPayment() {
    final paymentMethod = selectedPaymentMethod == 0
        ? 'Airtel Money'
        : 'Moov Money';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paiement en cours'),
        content: Text(
          'Paiement de ${widget.selectedSubscription['price']} Fcfa via $paymentMethod\n'
          'Numéro: ${phoneController.text}\n\n'
          'Veuillez suivre les instructions sur votre téléphone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Retour à l'écran des abonnements
              Navigator.of(context).pop(); // Retour à l'écran de profil
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
