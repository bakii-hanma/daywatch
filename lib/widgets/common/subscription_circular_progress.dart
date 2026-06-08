import 'package:flutter/material.dart';

class SubscriptionCircularProgress extends StatelessWidget {
  final int daysRemaining;
  final int totalDays;
  final Color ringColor;

  const SubscriptionCircularProgress({
    super.key,
    required this.daysRemaining,
    required this.totalDays,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    // Éviter division par zéro
    final double pct = totalDays > 0 
        ? (daysRemaining / totalDays).clamp(0.0, 1.0) 
        : 0.0;

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle de fond
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black.withOpacity(0.4)),
            ),
          ),
          // Cercle de progression
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: pct,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(ringColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Texte intérieur
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$daysRemaining',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                daysRemaining > 1 ? 'JOURS' : 'JOUR',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
