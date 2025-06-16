import 'package:flutter/material.dart';
import 'colors.dart';

class IconStyles {
  // Icônes principales
  static const Icon iconHome = Icon(
    Icons.home,
    color: AppColors.primaryColor,
    size: 24,
  );

  static const Icon iconInfo = Icon(
    Icons.info_outline,
    color: AppColors.primaryColor,
    size: 24,
  );

  static const Icon iconMessage = Icon(
    Icons.message,
    color: AppColors.textOnPrimary,
    size: 24,
  );

  static const Icon iconNotifications = Icon(
    Icons.notifications,
    color: AppColors.textOnPrimary,
    size: 24,
  );

  static const Icon iconSearch = Icon(
    Icons.search,
    color: AppColors.textOnPrimary,
    size: 24,
  );

  // Icônes d'action
  static const Icon iconAdd = Icon(
    Icons.add,
    color: AppColors.primaryColor,
    size: 24,
  );

  static const Icon iconEdit = Icon(
    Icons.edit,
    color: AppColors.primaryColor,
    size: 24,
  );

  static const Icon iconDelete = Icon(
    Icons.delete,
    color: AppColors.errorColor,
    size: 24,
  );

  static const Icon iconSave = Icon(
    Icons.save,
    color: AppColors.successColor,
    size: 24,
  );

  // Icônes de navigation
  static const Icon iconBack = Icon(
    Icons.arrow_back,
    color: AppColors.textColor,
    size: 24,
  );

  static const Icon iconForward = Icon(
    Icons.arrow_forward,
    color: AppColors.textColor,
    size: 24,
  );

  static const Icon iconMenu = Icon(
    Icons.menu,
    color: AppColors.textColor,
    size: 24,
  );

  // Icônes d'état
  static const Icon iconSuccess = Icon(
    Icons.check_circle,
    color: AppColors.successColor,
    size: 24,
  );

  static const Icon iconError = Icon(
    Icons.error,
    color: AppColors.errorColor,
    size: 24,
  );

  static const Icon iconWarning = Icon(
    Icons.warning,
    color: AppColors.warningColor,
    size: 24,
  );

  static const Icon iconInfoCircle = Icon(
    Icons.info,
    color: AppColors.infoColor,
    size: 24,
  );

  // Icônes de statut
  static const Icon iconStatusActive = Icon(
    Icons.circle,
    color: AppColors.successColor,
    size: 12,
  );

  static const Icon iconStatusInactive = Icon(
    Icons.circle,
    color: AppColors.textLight,
    size: 12,
  );

  static const Icon iconStatusPending = Icon(
    Icons.circle,
    color: AppColors.warningColor,
    size: 12,
  );
}
