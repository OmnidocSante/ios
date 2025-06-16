import 'package:flutter/material.dart';

class AppDimensions {
  // Dimensions de base
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static bool isTablet(BuildContext context) => getScreenWidth(context) >= 600;
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  // Dimensions de l'AppBar
  static const double appBarHeight = 240.0;
  static const double appBarBorderRadius = 30.0;
  static const double appBarPadding = 16.0;
  static const double appBarTopPadding = 40.0;

  // Dimensions des textes
  static const double welcomeTextSize = 16.0;
  static const double userNameTextSize = 20.0;
  static const double titleTextSize = 18.0;
  static const double subtitleTextSize = 16.0;
  static const double bodyTextSize = 14.0;

  // Dimensions des icônes
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;
  static const double avatarBorderWidth = 2.0;

  // Dimensions de la barre de recherche
  static const double searchBarHeight = 48.0;
  static const double searchBarPadding = 12.0;

  // Espacements
  static const double spacing = 8.0;
  static const double contentPadding = 16.0;

  // Méthodes de dimensionnement adaptatif
  static double getContentPadding(BuildContext context) {
    if (isLargeScreen(context)) return 32.0;
    return isTablet(context) ? 24.0 : 16.0;
  }

  static double getSpacing(BuildContext context) {
    if (isLargeScreen(context)) return 24.0;
    return isTablet(context) ? 16.0 : 12.0;
  }

  static double getTitleSize(BuildContext context) {
    if (isLargeScreen(context)) return 32.0;
    return isTablet(context) ? 24.0 : 20.0;
  }

  static double getSubtitleSize(BuildContext context) {
    if (isLargeScreen(context)) return 24.0;
    return isTablet(context) ? 20.0 : 16.0;
  }

  static double getBodyTextSize(BuildContext context) {
    if (isLargeScreen(context)) return 18.0;
    return isTablet(context) ? 16.0 : 14.0;
  }

  static double getSmallTextSize(BuildContext context) {
    if (isLargeScreen(context)) return 16.0;
    return isTablet(context) ? 14.0 : 12.0;
  }

  static double getIconSize(BuildContext context) {
    if (isLargeScreen(context)) return 32.0;
    return isTablet(context) ? 28.0 : 24.0;
  }

  static double getSmallIconSize(BuildContext context) =>
      getScreenWidth(context) * (isTablet(context) ? 0.02 : 0.035);

  static double getCardRadius(BuildContext context) {
    if (isLargeScreen(context)) return 24.0;
    return isTablet(context) ? 16.0 : 12.0;
  }

  static double getButtonHeight(BuildContext context) {
    if (isLargeScreen(context)) return 56.0;
    return isTablet(context) ? 48.0 : 40.0;
  }

  static double getButtonPadding(BuildContext context) {
    if (isLargeScreen(context)) return 20.0;
    return isTablet(context) ? 16.0 : 12.0;
  }

  static double getButtonRadius(BuildContext context) {
    if (isLargeScreen(context)) return 16.0;
    return isTablet(context) ? 12.0 : 8.0;
  }

  static double getTextFieldHeight(BuildContext context) {
    if (isLargeScreen(context)) return 60.0;
    return isTablet(context) ? 50.0 : 45.0;
  }

  static double getTextFieldRadius(BuildContext context) {
    if (isLargeScreen(context)) return 16.0;
    return isTablet(context) ? 12.0 : 8.0;
  }

  static double getListItemHeight(BuildContext context) =>
      getScreenHeight(context) * (isTablet(context) ? 0.08 : 0.12);

  static double getListSpacing(BuildContext context) =>
      getScreenHeight(context) * (isTablet(context) ? 0.01 : 0.02);

  static double getBottomPadding(BuildContext context) {
    if (isLargeScreen(context)) return 32.0;
    return isTablet(context) ? 24.0 : 16.0;
  }

  static double getButtonTextSize(BuildContext context) {
    if (isLargeScreen(context)) return 18.0;
    return isTablet(context) ? 16.0 : 14.0;
  }

  static double getAvatarSize(BuildContext context) {
    return avatarSize;
  }

  static double getAppBarTitleSize(BuildContext context) =>
      getScreenWidth(context) * (isTablet(context) ? 0.025 : 0.05);

  static double getAppBarHeight(BuildContext context) => appBarHeight;
}
