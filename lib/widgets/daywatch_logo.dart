import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';

enum LogoSize { small, medium, large, xlarge }

class DaywatchLogo extends StatelessWidget {
  final LogoSize size;
  final bool isDarkMode;
  final Color? customColor;

  const DaywatchLogo({
    Key? key,
    this.size = LogoSize.medium,
    required this.isDarkMode,
    this.customColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final logoColor =
        customColor ?? AppColors.primary; // Toujours en rouge par défaut

    return Container(
      width: dimensions.width,
      height: dimensions.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Image.asset(
        'assets/logo/daywatch_logo.png',
        width: dimensions.width,
        height: dimensions.height,
        fit: BoxFit.contain,
        color: logoColor,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }

  _LogoDimensions _getDimensions() {
    switch (size) {
      case LogoSize.small:
        return _LogoDimensions(width: 120, height: 60);
      case LogoSize.medium:
        return _LogoDimensions(width: 200, height: 100);
      case LogoSize.large:
        return _LogoDimensions(width: 300, height: 150);
      case LogoSize.xlarge:
        return _LogoDimensions(width: 400, height: 200);
    }
  }
}

class _LogoDimensions {
  final double width;
  final double height;

  _LogoDimensions({required this.width, required this.height});
}
