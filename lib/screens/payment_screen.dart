import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design_system/colors.dart';
import '../widgets/common/subscription_card.dart';
import '../services/plan_service.dart';
import '../services/user_storage_service.dart';
import '../utils/alert_utils.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, String> selectedSubscription;
  final int planId;
  final double monthlyPrice;
  final String planName;
  final String description;
  final String? existingEndDate;

  const PaymentScreen({
    super.key,
    required this.selectedSubscription,
    required this.planId,
    required this.monthlyPrice,
    required this.planName,
    required this.description,
    this.existingEndDate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedDurationMonths = 1;
  int _selectedPaymentMethod = 0; // 0 = Airtel Money / Moov (E-Billing), 1 = PayPal
  
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _isSubmitting = false;
  bool _isSimulating = false;

  final List<Map<String, dynamic>> _durations = const [
    {'months': 1, 'label': '1 mois', 'badge': null},
    {'months': 3, 'label': '3 mois', 'badge': '-0%'},
    {'months': 6, 'label': '6 mois', 'badge': '-0%'},
    {'months': 12, 'label': '1 an', 'badge': '-0%'},
  ];

  @override
  void initState() {
    super.initState();
    phoneController.text = '076527007'; // Fallback par défaut de test
    _loadUserPhone();
  }

  Future<void> _loadUserPhone() async {
    try {
      final userData = await UserStorageService.getUserData();
      final phone = userData?['phoneNumber'] ?? userData?['phone'] ?? userData?['phoneNumber'];
      if (phone != null && phone.toString().isNotEmpty) {
        // Nettoyer pour extraire les chiffres
        String digits = phone.toString().replaceAll(RegExp(r'\D'), '');
        // On attend un format local à 9 chiffres (ex: 074xxxxxx ou 06xxxxxxx)
        if (digits.length >= 9) {
          String localNum = digits.substring(digits.length - 9);
          // Si ça ne commence pas par un 0 local, on force le 0 local
          if (!localNum.startsWith('0') && localNum.length == 8) {
            localNum = '0$localNum';
          }
          setState(() {
            phoneController.text = localNum;
          });
        }
      }
      final email = userData?['email'];
      if (email != null && email.toString().isNotEmpty) {
        setState(() {
          emailController.text = email.toString();
        });
      }
    } catch (_) {}
  }

  double _getTotalPrice() {
    return widget.monthlyPrice * _selectedDurationMonths;
  }

  String _formatPrice(double val) {
    return '${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} Fcfa';
  }

  String? _getStackStartLabel() {
    if (widget.existingEndDate == null) return null;
    try {
      final end = DateTime.parse(widget.existingEndDate!);
      if (end.isBefore(DateTime.now())) return null;

      final monthsList = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return '${end.day} ${monthsList[end.month - 1]} ${end.year}';
    } catch (_) {}
    return null;
  }

  // Effectuer le paiement réel (E-Billing / PayPal)
  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 0) {
      // Validation Mobile Money
      final phone = phoneController.text.trim();
      final phoneRegex = RegExp(r'^0[67][0-9]{7}$');
      if (!phoneRegex.hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéro Mobile Money invalide (9 chiffres, ex: 074xxxxxx ou 06xxxxxxx).'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      // Validation PayPal
      final email = emailController.text.trim();
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez entrer une adresse email PayPal valide.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final String methodStr = _selectedPaymentMethod == 0 ? 'MOBILE_MONEY' : 'PAYPAL';
      final String? phoneVal = _selectedPaymentMethod == 0 ? phoneController.text.trim() : null;
      final String? paypalEmailVal = _selectedPaymentMethod == 1 ? emailController.text.trim() : null;

      final res = await PlanService.initPayment(
        planId: widget.planId,
        months: _selectedDurationMonths,
        paymentMethod: methodStr,
        phoneNumber: phoneVal,
        paypalEmail: paypalEmailVal,
      );

      setState(() => _isSubmitting = false);

      if (res.isSuccess && res.data != null) {
        final portalUrl = res.data!['portalUrl']?.toString();
        if (portalUrl != null && portalUrl.isNotEmpty) {
          final Uri uri = Uri.parse(portalUrl);
          
          AlertUtils.showSuccess(
            context: context,
            message: 'Redirection vers le portail de paiement...',
          );

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            
            // Afficher une boîte de confirmation manuelle du retour de paiement
            if (mounted) {
              _showPaymentPendingDialog(res.data!['paymentId']);
            }
          } else {
            throw Exception('Impossible d\'ouvrir l\'adresse de paiement.');
          }
        } else {
          AlertUtils.showError(
            context: context,
            message: 'Le portail de paiement est indisponible. Veuillez réessayer.',
          );
        }
      } else {
        AlertUtils.showError(
          context: context,
          message: res.error ?? 'Erreur lors de l\'initialisation du paiement.',
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      AlertUtils.showError(
        context: context,
        message: 'Erreur de connexion: $e',
      );
    }
  }

  // Simulation en mode test
  Future<void> _processSimulation() async {
    setState(() => _isSimulating = true);
    try {
      final res = await PlanService.simulatePlan(
        planId: widget.planId,
        months: _selectedDurationMonths,
      );
      setState(() => _isSimulating = false);

      if (res.isSuccess) {
        if (mounted) {
          AlertUtils.showSuccess(
            context: context,
            message: 'Paiement simulé avec succès ! Votre abonnement est activé.',
          );
          Navigator.pop(context, true); // Retourner true pour forcer le rechargement
        }
      } else {
        if (mounted) {
          AlertUtils.showError(
            context: context,
            message: res.error ?? 'Erreur lors de la simulation.',
          );
        }
      }
    } catch (e) {
      setState(() => _isSimulating = false);
      if (mounted) {
        AlertUtils.showError(
          context: context,
          message: 'Erreur réseau lors de la simulation: $e',
        );
      }
    }
  }

  void _showPaymentPendingDialog(dynamic paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Paiement initié',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Une fenêtre externe a été ouverte pour le paiement.\n\nUne fois le paiement validé sur votre mobile, appuyez sur OK.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fermer dialog
              Navigator.pop(this.context, true); // retourner au plan et recharger
            },
            child: const Text(
              'J\'AI PAYÉ',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ANNULER', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);
    final cardColor = isDarkMode ? AppColors.surfaceDark : Colors.white;

    final stackStart = _getStackStartLabel();

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
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Récapitulatif du plan sélectionné
              SubscriptionCard(
                title: widget.planName,
                price: widget.monthlyPrice.toStringAsFixed(0),
                duration: widget.selectedSubscription['duration']!,
                description: widget.description,
                lightImagePath: widget.selectedSubscription['lightImage']!,
                darkImagePath: widget.selectedSubscription['darkImage']!,
                isSelected: false,
              ),
              const SizedBox(height: 20),

              // 2. Sélecteur de durée
              Text(
                'Choisissez la durée',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _durations.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.8,
                ),
                itemBuilder: (context, idx) {
                  final duration = _durations[idx];
                  final isSelected = _selectedDurationMonths == duration['months'];
                  final int monthsCount = duration['months'] as int;
                  final double totalPrice = widget.monthlyPrice * monthsCount;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDurationMonths = monthsCount;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary.withOpacity(0.1) 
                            : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : textColor.withOpacity(0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                duration['label'] as String,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatPrice(totalPrice),
                                style: TextStyle(
                                  color: textColor.withOpacity(0.6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 3. Notice Stacking
              if (stackStart != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Vous avez un abonnement en cours. Le nouvel abonnement démarrera automatiquement le $stackStart.',
                          style: TextStyle(
                            color: isDarkMode ? Colors.blue[100] : Colors.blue[900],
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Récapitulatif Total à payer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: textColor.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total à payer',
                      style: TextStyle(
                        color: textColor.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatPrice(_getTotalPrice()),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Modes de paiement
              Text(
                'Choisissez votre mode de paiement',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Airtel / Moov Money (E-Billing)
                  Expanded(
                    child: _buildPaymentMethodButton(
                      0,
                      'E-Billing',
                      'Mobile Money & CB',
                      'https://ebillingsite.billing-easy.net/images/logo.png',
                      textColor,
                      cardColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // PayPal
                  Expanded(
                    child: _buildPaymentMethodButton(
                      1,
                      'PayPal',
                      'Paiement International',
                      'https://upload.wikimedia.org/wikipedia/commons/b/b5/PayPal.svg',
                      textColor,
                      cardColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 6. Formulaires conditionnels
              if (_selectedPaymentMethod == 0)
                _buildEBillingForm(textColor, cardColor, isDarkMode)
              else
                _buildPayPalForm(textColor, cardColor, isDarkMode),
              const SizedBox(height: 32),

              // 7. Boutons d'action
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _isSimulating) ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Payer ${_formatPrice(_getTotalPrice())}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Simulation de test
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: (_isSubmitting || _isSimulating) ? null : _processSimulation,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.amber, style: BorderStyle.solid),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSimulating
                      ? const CircularProgressIndicator(color: Colors.amber)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on_rounded, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text(
                              '⚡ Simuler le paiement (test)',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              
              Center(
                child: Text(
                  'En continuant, vous acceptez les conditions d\'abonnement DayWatch.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withOpacity(0.4),
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(
    int idx, 
    String label, 
    String tagline, 
    String logoUrl,
    Color textColor,
    Color cardColor,
  ) {
    final isSelected = _selectedPaymentMethod == idx;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = idx;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : textColor.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.payment, color: textColor.withOpacity(0.6), size: 36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.grey[800] : textColor.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEBillingForm(Color textColor, Color cardColor, bool isDarkMode) {
    final List<Map<String, String>> ebillingFeatures = const [
      {'label': 'Airtel Money', 'sub': '#airtelmoney'},
      {'label': 'Moov Money', 'sub': '#moovmoney'},
      {'label': 'Visa', 'sub': 'Carte bancaire'},
      {'label': 'Mastercard', 'sub': 'Carte bancaire'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Features Mobile Money
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.red.withOpacity(0.05) : cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Paiement instantané',
                    style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ebillingFeatures.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3.0,
                ),
                itemBuilder: (context, idx) {
                  final f = ebillingFeatures[idx];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: textColor.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                f['label']!,
                                style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                f['sub']!,
                                style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.lock_rounded, color: Colors.green, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Aucune information bancaire ne transite par DayWatch.',
                    style: TextStyle(color: Colors.green[300], fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Champ numéro Mobile Money
        Text(
          'Numéro Mobile Money débiteur',
          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 9,
          style: TextStyle(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: '074xxxxxx (Airtel) ou 06xxxxxxx (Moov)',
            hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
            counterText: '',
            filled: true,
            fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '9 chiffres au format local (Gabon). Le numéro est requis par E-Billing pour initier le paiement.',
          style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildPayPalForm(Color textColor, Color cardColor, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_rounded, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Paiement PayPal',
                    style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Sécurisé et international. Permet de payer avec votre compte PayPal ou par carte.',
                style: TextStyle(color: Colors.blue, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Champ Email PayPal
        Text(
          'Email de votre compte PayPal',
          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'email@exemple.com',
            hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
