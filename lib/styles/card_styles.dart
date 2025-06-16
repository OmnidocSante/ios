import 'package:flutter/material.dart';
import 'colors.dart';

class CardStyles {
  // Style de carte principal
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surfaceColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Style de carte avec bordure
  static BoxDecoration borderedCardDecoration = BoxDecoration(
    color: AppColors.surfaceColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.borderColor,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Style de carte avec accent
  static BoxDecoration accentCardDecoration = BoxDecoration(
    color: AppColors.surfaceColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.primaryColor,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Style de carte avec ombre prononcée
  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: AppColors.surfaceColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColorDark,
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  // Style de carte avec fond coloré
  static BoxDecoration coloredCardDecoration = BoxDecoration(
    color: AppColors.primaryLight,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Style de carte avec fond de succès
  static BoxDecoration successCardDecoration = BoxDecoration(
    color: AppColors.successColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.successColor,
      width: 1,
    ),
  );

  // Style de carte avec fond d'erreur
  static BoxDecoration errorCardDecoration = BoxDecoration(
    color: AppColors.errorColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.errorColor,
      width: 1,
    ),
  );

  // Style de carte avec fond d'avertissement
  static BoxDecoration warningCardDecoration = BoxDecoration(
    color: AppColors.warningColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.warningColor,
      width: 1,
    ),
  );

  // Style de carte avec fond d'information
  static BoxDecoration infoCardDecoration = BoxDecoration(
    color: AppColors.infoColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.infoColor,
      width: 1,
    ),
  );

  // Forme de la carte
  static BorderRadiusGeometry cardShape = BorderRadius.circular(12);
}
