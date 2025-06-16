import 'package:flutter/material.dart';
import '../../api/user_api.dart';
import '../../services/auth_service.dart';



class SettingsMethods {
  static Future<void> initializeData(BuildContext context) async {
    try {
      final authService = AuthService();
      await authService.setUserActive();
      await fetchUserInfo(context);
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  static Future<Map<String, dynamic>> fetchUserInfo(
      BuildContext context) async {
    try {
      final userInfo = await UserApi.getUserInfo();
      return userInfo;
    } catch (e) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return {};
    }
  }

  static Future<void> handleLogout(BuildContext context) async {
    try {
      final authService = AuthService();
      await authService.setUserInactive();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  static Future<void> navigateToProfile(BuildContext context) async {
    try {
      final result = await Navigator.pushNamed(context, '/profile');
      if (result == true && context.mounted) {
        await fetchUserInfo(context);
      }
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  static Future<void> navigateToNotifications(BuildContext context) async {
    try {
      await Navigator.pushNamed(context, '/notifications');
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  static Future<void> navigateToSecurity(BuildContext context) async {
    try {
      await Navigator.pushNamed(context, '/security');
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  static Future<void> navigateToHelp(BuildContext context) async {
    try {
      // Implémenter la navigation vers l'aide
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  static Future<void> navigateToTerms(BuildContext context) async {
    try {
      // Implémenter la navigation vers les conditions d'utilisation
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  static Future<void> navigateToPrivacy(BuildContext context) async {
    try {
      // Implémenter la navigation vers la politique de confidentialité
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  static Future<void> showAppVersion(BuildContext context) async {
    try {
      // Implémenter l'affichage de la version de l'application
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }
}
