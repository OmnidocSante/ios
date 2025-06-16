import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF29BACD); // Bleu turquoise principal
  static const Color primaryLight = Color(0xFF7BD5E1); // Version claire du bleu turquoise
  static const Color primaryDark = Color(0xFF1A8A9A); // Version foncée du bleu turquoise

  // Couleurs de fond
  static const Color backgroundColor = Color(0xFFF5F5F5); // Fond principal
  static const Color surfaceColor = Color(0xFFFFFFFF); // Fond des cartes et surfaces
  static const Color scaffoldBackgroundColor = Color(0xFFFFFFFF); // Fond de l'écran

  // Couleurs de texte
  static const Color textColor = Color(0xFF333333); // Texte principal
  static const Color textSecondary = Color(0xFF757575); // Texte secondaire
  static const Color textLight = Color(0xFF9E9E9E); // Texte clair
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Texte sur fond coloré

  // Couleurs d'état
  static const Color successColor = Color(0xFF4CAF50); // Vert pour succès
  static const Color errorColor = Color(0xFFE57373); // Rouge pour erreur
  static const Color warningColor = Color(0xFFFFB74D); // Orange pour avertissement
  static const Color infoColor = Color(0xFF64B5F6); // Bleu pour information

  // Couleurs de bordure et séparation
  static const Color borderColor = Color(0xFFE0E0E0); // Couleur des bordures
  static const Color dividerColor = Color(0xFFEEEEEE); // Couleur des séparateurs

  // Couleurs d'ombre
  static const Color shadowColor = Color(0x1A000000); // Ombre légère
  static const Color shadowColorDark = Color(0x33000000); // Ombre plus prononcée

  // Couleurs de la barre de navigation
  static const Color bottomNavBackground = Color(0xCEFFFFFF); // Fond de la barre de navigation
  static const Color bottomNavSelected = primaryColor; // Élément sélectionné
  static const Color bottomNavUnselected = Color(0xFF9E9E9E); // Élément non sélectionné

  // Couleurs de bouton
  static const Color buttonPrimary = primaryColor;
  static const Color buttonSecondary = Color(0xFFE0E0E0);
  static const Color buttonText = textOnPrimary;
  static const Color buttonDisabled = Color(0xFFBDBDBD);

  // Couleurs de champ de formulaire
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusBorder = primaryColor;

  // Couleurs pour le mode sombre
  static const Color darkPrimaryColor = Color(0xFF1A8A9A);
  static const Color darkSecondaryColor = Color(0xFF7BD5E1);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFE0E0E0);
  static const Color darkAccentColor = Color(0xFF29BACD);
}