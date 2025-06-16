import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class ButtonStyles {
  // Bouton principal
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonPrimary,
    foregroundColor: AppColors.buttonText,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );

  // Bouton secondaire
  static final ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonSecondary,
    foregroundColor: AppColors.textColor,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 1,
  );

  // Bouton texte
  static final ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: AppColors.primaryColor,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Bouton outlined
  static final ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryColor,
    side: BorderSide(color: AppColors.primaryColor),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Bouton désactivé
  static final ButtonStyle disabledButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonDisabled,
    foregroundColor: AppColors.textLight,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
  );

  // Bouton de succès
  static final ButtonStyle successButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.successColor,
    foregroundColor: AppColors.buttonText,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );

  // Bouton d'erreur
  static final ButtonStyle errorButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.errorColor,
    foregroundColor: AppColors.buttonText,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );

  // Bouton d'avertissement
  static final ButtonStyle warningButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.warningColor,
    foregroundColor: AppColors.textColor,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );

  // Bouton d'information
  static final ButtonStyle infoButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.infoColor,
    foregroundColor: AppColors.buttonText,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );
}