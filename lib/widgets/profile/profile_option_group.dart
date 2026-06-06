import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

class ProfileOptionGroup extends StatelessWidget {
  final List<Widget> children;

  const ProfileOptionGroup({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getWidgetBackgroundColor(isDarkMode);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
