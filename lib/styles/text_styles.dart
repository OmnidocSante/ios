import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Styles de titre
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle titleBold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: AppColors.textColor,
  );

  // Styles de sous-titre
  static const TextStyle subtitleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static const TextStyle subtitleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  // Styles de corps de texte
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textColor,
  );

  // Style de texte par défaut
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: AppColors.textColor,
  );

  // Style de sous-titre par défaut
  static const TextStyle subtitleText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  // Styles de texte secondaire
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    color: AppColors.textLight,
    letterSpacing: 1.5,
  );

  // Styles de bouton
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
  );

  // Styles pour les états
  static const TextStyle successText = TextStyle(
    fontSize: 14,
    color: AppColors.successColor,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    color: AppColors.errorColor,
  );

  static const TextStyle warningText = TextStyle(
    fontSize: 14,
    color: AppColors.warningColor,
  );

  static const TextStyle infoText = TextStyle(
    fontSize: 14,
    color: AppColors.infoColor,
  );

  static var buttonText;
}
