import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../api/user_api.dart';

class SecurityMethods {
  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      await ApiService.changePassword(oldPassword, newPassword);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mot de passe modifié avec succès')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors du changement de mot de passe: $e')),
        );
      }
    }
  }

  static Future<void> logout(BuildContext context) async {
    try {
      await UserApi.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
        );
      }
    }
  }
}
