import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class HeaderStyles {
  // Style d'en-tête principal
  static const BoxDecoration headerDecoration = BoxDecoration(
    color: AppColors.primaryColor,
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  // Style de titre d'en-tête
  static const TextStyle headerTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
  );

  // Style de sous-titre d'en-tête
  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 16,
    color: AppColors.textOnPrimary,
  );

  // Style de texte de corps d'en-tête
  static const TextStyle headerBody = TextStyle(
    fontSize: 14,
    color: AppColors.textOnPrimary,
  );

  // Style de bouton d'en-tête
  static final ButtonStyle headerButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: AppColors.textOnPrimary,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
  );

  // Style de champ de recherche d'en-tête
  static InputDecoration headerSearchField = InputDecoration(
    hintText: 'Rechercher...',
    hintStyle: TextStyle(color: AppColors.textOnPrimary.withOpacity(0.7)),
    prefixIcon: Icon(Icons.search, color: AppColors.textOnPrimary),
    filled: true,
    fillColor: AppColors.primaryDark,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: AppColors.primaryLight),
    ),
  );

  // Style d'avatar d'en-tête
  static const BoxDecoration headerAvatarDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.fromBorderSide(
      BorderSide(
        color: AppColors.textOnPrimary,
        width: 2,
      ),
    ),
  );

  // Style de badge de notification
  static const BoxDecoration notificationBadgeDecoration = BoxDecoration(
    color: AppColors.errorColor,
    shape: BoxShape.circle,
  );

  // Style de texte de badge
  static const TextStyle notificationBadgeText = TextStyle(
    color: AppColors.textOnPrimary,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static var bodyText;

  static var subtitleText;
}
