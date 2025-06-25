import 'package:flutter/material.dart';

class AppTypography {
  // Tailles de police
  static const double fontSizeSmall = 10.0;
  static const double fontSizeMedium = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeTitle = 18.0;
  static const double fontSizeHeader = 24.0;

  // Poids de police
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Styles de texte
  static TextStyle header(Color color) => TextStyle(
    fontSize: fontSizeHeader,
    fontWeight: fontWeightBold,
    color: color,
  );

  static TextStyle title(Color color) => TextStyle(
    fontSize: fontSizeTitle,
    fontWeight: fontWeightBold,
    color: color,
  );

  static TextStyle subtitle(Color color) => TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: fontWeightSemiBold,
    color: color,
  );

  static TextStyle body(Color color) => TextStyle(
    fontSize: fontSizeRegular,
    fontWeight: fontWeightRegular,
    color: color,
  );

  static TextStyle bodyMedium(Color color) => TextStyle(
    fontSize: fontSizeRegular,
    fontWeight: fontWeightMedium,
    color: color,
  );

  static TextStyle bodySemiBold(Color color) => TextStyle(
    fontSize: fontSizeRegular,
    fontWeight: fontWeightSemiBold,
    color: color,
  );

  static TextStyle caption(Color color) => TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: fontWeightRegular,
    color: color,
  );

  static TextStyle captionMedium(Color color) => TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: fontWeightMedium,
    color: color,
  );

  static TextStyle small(Color color) => TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: fontWeightMedium,
    color: color,
  );

  static TextStyle linkText(Color color) => TextStyle(
    fontSize: fontSizeRegular,
    fontWeight: fontWeightSemiBold,
    color: color,
  );
}
