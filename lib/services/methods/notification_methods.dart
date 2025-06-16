import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../api/user_api.dart';
import '../../api/notification_api.dart';

class NotificationMethods {
  // Méthodes de gestion des données utilisateur
  static Future<String> fetchUserInfo() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      return userInfo['id'].toString();
    } catch (e) {
      return "";
    }
  }

 

  // Méthodes utilitaires
  static IconData getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'mission':
        return Icons.medical_services;
      case 'urgence':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  static String formatNotificationDate(String? dateString) {
    if (dateString == null) return 'Date non spécifiée';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return 'Format de date invalide';
    }
  }

  static String filterNotificationMessage(String message) {
    if (message.isEmpty || message.trim() == '') {
      return '';
    }

    final result = message
        .split('\n')
        .map((line) {
          final trimmedLine = line.trim();
          final lower = trimmedLine.toLowerCase();

          if (lower.isEmpty) return null;

          // Vérification des valeurs invalides
          if (lower.contains('n/a') ||
              lower.contains('null') ||
              lower.contains('-') ||
              lower.contains('undefined') ||
              lower.contains('vide') ||
              lower.contains('empty')) {
            return null;
          }

          // Vérification des lignes avec des clés-valeurs
          if (lower.contains(':')) {
            final parts = lower.split(':');
            if (parts.length < 2) return null;

            final value = parts[1].trim();
            if (value.isEmpty ||
                value == 'n/a' ||
                value == 'null' ||
                value == '-' ||
                value == 'undefined' ||
                value == 'vide' ||
                value == 'empty') {
              return null;
            }
          }

          return trimmedLine;
        })
        .where((line) => line != null && line.isNotEmpty)
        .toList();

    return result.join('\n');
  }
}
