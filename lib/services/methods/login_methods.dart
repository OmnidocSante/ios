import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/user_api.dart';
import '../firebase_notification_service.dart';
import '../auth_service.dart';
import '../api_service.dart';

class LoginMethods {
  static Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final data = await ApiService.login(email, password);

      // Stocker le token et les informations utilisateur
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userId', data['user']['id'].toString());
      await prefs.setString('userRole', data['user']['rôle']);

      // Mettre à jour la date de dernière connexion
      await AuthService().updateLastLoginDate();

      // Rediriger vers la page principale
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      _handleLoginError(context, 'Email ou mot de passe incorrect');
    }
  }

  static void _handleLoginError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static Future<void> logout(BuildContext context) async {
    try {
      await UserApi.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _handleLoginError(context, 'Erreur lors de la déconnexion');
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    // Vérifier si la session doit être déconnectée
    if (await AuthService().shouldLogout()) {
      // Déconnecter sans redirection
      await UserApi.logout();
      return false;
    }

    return true;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }
}
