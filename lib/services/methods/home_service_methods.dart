import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../api/user_api.dart';
import '../../api/mission_api.dart';
import '../../api/api_service.dart';
import '../../api/notification_api.dart';
import '../mission_service.dart';
// import '../notification_receiver_service.dart'; // supprimé car le fichier n'existe pas
// import '../push_notification_service.dart'; // supprimé car le fichier n'existe pas

class HomeServiceMethods {
  // Méthodes de notification
  static Future<void> checkNotifications(
      BuildContext context, String userId) async {
    try {
      final notifications = await NotificationApi.getNotifications();
      if (notifications.isNotEmpty) {
        for (var notification in notifications) {
          if (notification['status'] == 'nonlue') {
            // Traitement des notifications non lues
          }
        }
      }
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }

  // Méthodes de statut utilisateur
  static Future<void> updateUserStatus(String status) async {
    try {
      final userInfo = await UserApi.getUserInfo();
      final userId = userInfo['id'].toString();
      await UserApi.updateUserStatus(userId, status);
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }

  // Méthodes d'information utilisateur
  static Future<Map<String, dynamic>> fetchUserInfo() async {
    try {
      return await UserApi.getUserInfo();
    } catch (e) {
      return {};
    }
  }

  // Méthodes de mission
  static Future<Map<String, dynamic>?> determineNextMission(
      List<Map<String, dynamic>> missions, String userId) async {
    if (missions.isEmpty) return null;
    try {
      // Filtrer les missions pour l'utilisateur (ambulancier, médecin, infirmier)
      final userMissions = missions.where((mission) {
        return mission['ambulancier_id']?.toString() == userId ||
            mission['doctor_id']?.toString() == userId ||
            mission['nurse_id']?.toString() == userId;
      }).toList();
      if (userMissions.isEmpty) return null;
      // Trier les missions par date
      userMissions.sort((a, b) {
        final dateA = DateTime.parse(a['date_mission']);
        final dateB = DateTime.parse(b['date_mission']);
        return dateA.compareTo(dateB);
      });
      return userMissions.first;
    } catch (e) {
      return null;
    }
  }

  static Future<void> checkAndUpdateMissions(
      BuildContext context, String userId) async {
    try {
      final missionService =
          Provider.of<MissionService>(context, listen: false);
      await missionService.fetchMissions();
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }

  // Méthodes de cache
  static Future<void> saveToCache(List<Map<String, dynamic>> missions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('missions_cache', jsonEncode(missions));
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }

  static Future<List<Map<String, dynamic>>?> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final missionsJson = prefs.getString('missions_cache');
      if (missionsJson != null) {
        final List<dynamic> decoded = jsonDecode(missionsJson);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
    return null;
  }

  // Méthodes de formatage
  static String formatDate(String? dateString) {
    if (dateString == null) return 'Date non spécifiée';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Format de date invalide';
    }
  }

  static String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '--:--';
    }

    try {
      if (timeString.contains('T')) {
        final dateTime = DateTime.parse(timeString);
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
        }
      }
    } catch (e) {
      // Ignorer l'erreur
    }

    return '--:--';
  }
}
