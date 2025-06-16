import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/user_api.dart';
import '../../api/mission_api.dart';
import '../mission_service.dart';
import 'package:intl/intl.dart';

class InterventionMethods {
  // Méthodes de gestion des données utilisateur
  static Future<Map<String, dynamic>> fetchUserInfo() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      // Mise en cache des données utilisateur
      final userData = {
        'userName': '${userInfo['nom']} ${userInfo['prenom']}',
        'userId': userInfo['id'].toString(),
        'userAvatar': userInfo['photo'] ?? '',
        'userEmail': userInfo['email'] ?? '',
        'userPhone': userInfo['téléphone'] ?? '',
        'userGender': userInfo['genre'] ?? '',
        'userBirthDate': userInfo['date_naissance'] ?? '',
        'userRole': userInfo['rôle'] ?? '',
        'userStatus': userInfo['statut'] ?? '',
      };
      return userData;
    } catch (e) {
      return {};
    }
  }

  // Méthodes de gestion des missions
  static Future<void> fetchMissions(BuildContext context) async {
    try {
      final missionService =
          Provider.of<MissionService>(context, listen: false);
      // Optimisation du chargement des missions
      await Future.wait([
        missionService.fetchMissions(),
        Future.delayed(Duration(
            milliseconds: 100)), // Petit délai pour éviter le blocage UI
      ]);
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }

  // Méthodes de formatage
  static String formatDate(String? dateString) {
    if (dateString == null) return 'Date non spécifiée';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Format de date invalide';
    }
  }

  static String formatTime(String? timeString) {
    if (timeString == null) return '--:--';
    try {
      if (timeString.length == 8) {
        return timeString.substring(0, 5);
      }
      if (timeString.length == 5) {
        return timeString;
      }
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return '--:--';
    } catch (e) {
      return '--:--';
    }
  }

  // Méthodes de gestion du cache
  static void updateStatusCountCache(
      Map<String, int> statusCountCache, List<Map<String, dynamic>> missions) {
    statusCountCache.clear();
    statusCountCache['completed'] = missions
        .where((mission) =>
            mission['statut']?.toString().toLowerCase() == 'terminée' ||
            mission['statut']?.toString().toLowerCase() == 'terminé')
        .length;

    statusCountCache['rejected'] = missions
        .where((mission) =>
            mission['statut']?.toString().toLowerCase() == 'annulée' ||
            mission['statut']?.toString().toLowerCase() == 'annulé')
        .length;

    statusCountCache['in_progress'] = missions
        .where((mission) =>
            mission['statut']?.toString().toLowerCase() == 'en cours')
        .length;
  }

  static List<Map<String, dynamic>> getMissionsForDate(
      DateTime date,
      List<Map<String, dynamic>> allMissions,
      Map<DateTime, List<Map<String, dynamic>>> missionsCache) {
    final dateKey = DateTime(date.year, date.month, date.day);

    // Vérification du cache avec expiration
    if (missionsCache.containsKey(dateKey)) {
      final cachedMissions = missionsCache[dateKey]!;
      final cacheTime = DateTime.now().difference(dateKey);
      if (cacheTime.inMinutes < 5) {
        // Cache valide pendant 5 minutes
        return cachedMissions;
      }
    }

    final filteredMissions = allMissions.where((mission) {
      final missionDate = DateTime.parse(
          mission['date_mission'] ?? DateTime.now().toIso8601String());
      final missionDay =
          DateTime(missionDate.year, missionDate.month, missionDate.day);
      return missionDay.isAtSameMomentAs(dateKey);
    }).toList();

    // Tri optimisé des missions
    filteredMissions.sort((a, b) {
      final dateA = a['created_at'] != null
          ? DateTime.parse(a['created_at'])
          : DateTime.parse(
              a['date_mission'] ?? DateTime.now().toIso8601String());
      final dateB = b['created_at'] != null
          ? DateTime.parse(b['created_at'])
          : DateTime.parse(
              b['date_mission'] ?? DateTime.now().toIso8601String());
      return dateB.compareTo(dateA);
    });

    missionsCache[dateKey] = filteredMissions;
    return filteredMissions;
  }
}
