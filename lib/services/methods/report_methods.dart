import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../api/user_api.dart';
import '../../api/mission_api.dart';
import '../mission_service.dart';
import '../../api/patient_api.dart';
import '../../api/material_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportMethods {
  // Cache pour les données utilisateur
  static Map<String, dynamic>? _userCache;
  static DateTime? _lastUserFetch;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Méthodes de gestion des données utilisateur
  static Future<Map<String, dynamic>> fetchUserInfo() async {
    try {
      // Vérifier si le cache est valide
      if (_userCache != null && _lastUserFetch != null) {
        final cacheAge = DateTime.now().difference(_lastUserFetch!);
        if (cacheAge < _cacheDuration) {
          return _userCache!;
        }
      }

      final userInfo = await UserApi.getUserInfo();
      _userCache = userInfo;
      _lastUserFetch = DateTime.now();
      return userInfo;
    } catch (e) {
      return _userCache ?? {};
    }
  }

  // Cache pour les missions
  static List<Map<String, dynamic>>? _missionsCache;
  static DateTime? _lastMissionsFetch;
  static const Duration _missionsCacheDuration = Duration(minutes: 10);

  // Méthodes de gestion des missions
  static Future<List<Map<String, dynamic>>> fetchMissions() async {
    try {
      print('\n🔵 DÉBUT DE LA RÉCUPÉRATION DES MISSIONS');
      
      // Vérifier si le cache est valide
      if (_missionsCache != null && _lastMissionsFetch != null) {
        final cacheAge = DateTime.now().difference(_lastMissionsFetch!);
        if (cacheAge < _missionsCacheDuration) {
          print('📦 Utilisation du cache (âge: ${cacheAge.inMinutes} minutes)');
          return _missionsCache!;
        }
      }

      print('🔄 Récupération de toutes les missions...');
      final allMissions = await MissionApi.getAllMissions();
      print('✅ ${allMissions.length} missions récupérées au total');

      print('🔄 Récupération des informations utilisateur...');
      final userInfo = await UserApi.getUserInfo();
      final userId = userInfo['id'].toString();
      final userRole = userInfo['rôle']?.toString().toLowerCase() ?? '';
      print('👤 Informations utilisateur:');
      print('   - ID: $userId');
      print('   - Rôle: $userRole');

      print('\n🔍 Filtrage des missions...');
      // Récupérer les données complètes pour chaque mission
      final userMissions = await Future.wait(allMissions.where((mission) {
        final missionStatut = mission['statut']?.toString().toLowerCase() ?? '';
        final isTerminated = missionStatut == 'terminée' || missionStatut == 'terminé';

        // Vérifier si l'utilisateur est impliqué dans la mission
        final isInvolved = 
          mission['ambulancier_id']?.toString() == userId ||
          mission['docteur_id']?.toString() == userId ||
          mission['infermier_id']?.toString() == userId;

        print('\n📋 Mission ID: ${mission['id']}');
        print('   - Statut: $missionStatut');
        print('   - Ambulancier ID: ${mission['ambulancier_id']}');
        print('   - Docteur ID: ${mission['docteur_id']}');
        print('   - Infirmier ID: ${mission['infermier_id']}');
        print('   - Est terminée: $isTerminated');
        print('   - Utilisateur impliqué: $isInvolved');

        // Si l'utilisateur est un administrateur, il voit toutes les missions terminées
        if (userRole == 'administrateur') {
          print('   - Administrateur: affichage de toutes les missions terminées');
          return isTerminated;
        }

        // Sinon, il ne voit que ses missions terminées
        final shouldShow = isTerminated && isInvolved;
        print('   - Mission à afficher: $shouldShow');
        return shouldShow;
      }).map((mission) async {
        print('\n🔄 Enrichissement de la mission ${mission['id']}...');
        
        // Récupérer les données du patient
        if (mission['patient_id'] != null) {
          try {
            print('   - Récupération des informations du patient ${mission['patient_id']}...');
            final patientInfo = await PatientApi.getPatientInfo(mission['patient_id']);
            mission['patient_info'] = patientInfo;
            print('   ✅ Informations patient récupérées');
          } catch (e) {
            print('   ⚠️ Erreur lors de la récupération des informations du patient: $e');
          }
        } else {
          print('   ℹ️ Aucun patient associé à cette mission');
        }

        // Récupérer les données des matériaux utilisés
        try {
          print('   - Récupération des matériaux utilisés...');
          final token = await _getToken();
          
          final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.materialsEndpoint}/usage/${mission['id']}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> materials = json.decode(response.body);
            mission['materiels_utilises'] = materials;
            print('   ✅ ${materials.length} matériaux récupérés');
          } else {
            print('   ⚠️ Erreur HTTP ${response.statusCode} lors de la récupération des matériaux');
          }
        } catch (e) {
          print('   ⚠️ Erreur lors de la récupération des matériaux utilisés: $e');
        }

        return mission;
      }));

      print('\n📊 Résumé du filtrage:');
      print('   - Missions totales: ${allMissions.length}');
      print('   - Missions filtrées: ${userMissions.length}');

      // Tri optimisé des missions
      userMissions.sort((a, b) {
        final dateA = DateTime.parse(
            a['date_mission'] ?? DateTime.now().toIso8601String());
        final dateB = DateTime.parse(
            b['date_mission'] ?? DateTime.now().toIso8601String());
        return dateB.compareTo(dateA);
      });
      print('   ✅ Missions triées par date');

      _missionsCache = userMissions;
      _lastMissionsFetch = DateTime.now();
      print('💾 Cache mis à jour');
      
      print('✅ FIN DE LA RÉCUPÉRATION DES MISSIONS\n');
      return userMissions;
    } catch (e) {
      print('❌ ERREUR CRITIQUE lors de la récupération des missions:');
      print('   - Message: $e');
      print('   - Stack trace: ${StackTrace.current}');
      return _missionsCache ?? [];
    }
  }

  // Méthodes de formatage optimisées avec cache
  static final Map<String, String> _dateCache = {};
  static String formatDateForPdf(String dateStr) {
    try {
      if (_dateCache.containsKey(dateStr)) {
        return _dateCache[dateStr]!;
      }

      final date = DateTime.parse(dateStr);
      final formattedDate = DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
      _dateCache[dateStr] = formattedDate;
      return formattedDate;
    } catch (e) {
      return dateStr;
    }
  }

  static final Map<String, String> _timeCache = {};
  static String formatTimeForPdf(String timeStr) {
    try {
      if (_timeCache.containsKey(timeStr)) {
        return _timeCache[timeStr]!;
      }

      final time = DateFormat('HH:mm:ss').parse(timeStr);
      final formattedTime = DateFormat('HH:mm', 'fr_FR').format(time);
      _timeCache[timeStr] = formattedTime;
      return formattedTime;
    } catch (e) {
      return timeStr;
    }
  }

  // Méthodes de gestion du cache optimisées
  static final Map<DateTime, List<Map<String, dynamic>>> _missionsDateCache =
      {};
  static List<Map<String, dynamic>> getMissionsForDate(
      List<Map<String, dynamic>> missions, DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);

    if (_missionsDateCache.containsKey(dateKey)) {
      return _missionsDateCache[dateKey]!;
    }

    final filteredMissions = missions.where((mission) {
      try {
        final missionDate = DateTime.parse(mission['date_mission'] ?? '');
        return missionDate.year == date.year &&
            missionDate.month == date.month &&
            missionDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();

    _missionsDateCache[dateKey] = filteredMissions;
    return filteredMissions;
  }

  // Méthode pour nettoyer le cache
  static void clearCache() {
    _userCache = null;
    _lastUserFetch = null;
    _missionsCache = null;
    _lastMissionsFetch = null;
    _dateCache.clear();
    _timeCache.clear();
    _missionsDateCache.clear();
  }

  // Méthode pour précharger les données
  static Future<void> preloadData() async {
    try {
      await Future.wait([
        fetchUserInfo(),
        fetchMissions(),
      ]);
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  // Méthode pour mettre à jour le cache en arrière-plan
  static Future<void> updateCacheInBackground() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      final allMissions = await MissionApi.getAllMissions();

      _userCache = userInfo;
      _lastUserFetch = DateTime.now();

      final userId = userInfo['id'].toString();
      final userMissions = allMissions.where((mission) {
        final missionAmbulancier = mission['ambulancier_id']?.toString() ?? '';
        final missionStatut = mission['statut']?.toString().toLowerCase() ?? '';
        return missionAmbulancier == userId &&
            (missionStatut == 'terminée' || missionStatut == 'terminé');
      }).toList();

      userMissions.sort((a, b) {
        final dateA = DateTime.parse(
            a['date_mission'] ?? DateTime.now().toIso8601String());
        final dateB = DateTime.parse(
            b['date_mission'] ?? DateTime.now().toIso8601String());
        return dateB.compareTo(dateA);
      });

      _missionsCache = userMissions;
      _lastMissionsFetch = DateTime.now();
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  // Méthode pour charger les données de manière progressive
  static Stream<List<Map<String, dynamic>>> streamMissions() async* {
    try {
      // D'abord, retourner les données en cache si disponibles
      if (_missionsCache != null) {
        yield _missionsCache!;
      }

      // Ensuite, charger les nouvelles données
      final allMissions = await MissionApi.getAllMissions();
      final userInfo = await UserApi.getUserInfo();
      final userId = userInfo['id'].toString();

      final userMissions = allMissions.where((mission) {
        final missionAmbulancier = mission['ambulancier_id']?.toString() ?? '';
        final missionStatut = mission['statut']?.toString().toLowerCase() ?? '';
        return missionAmbulancier == userId &&
            (missionStatut == 'terminée' || missionStatut == 'terminé');
      }).toList();

      userMissions.sort((a, b) {
        final dateA = DateTime.parse(
            a['date_mission'] ?? DateTime.now().toIso8601String());
        final dateB = DateTime.parse(
            b['date_mission'] ?? DateTime.now().toIso8601String());
        return dateB.compareTo(dateA);
      });

      _missionsCache = userMissions;
      _lastMissionsFetch = DateTime.now();
      yield userMissions;
    } catch (e) {
      if (_missionsCache != null) {
        yield _missionsCache!;
      } else {
        yield [];
      }
    }
  }

  // Méthode pour charger les données utilisateur de manière progressive
  static Stream<Map<String, dynamic>> streamUserInfo() async* {
    try {
      // D'abord, retourner les données en cache si disponibles
      if (_userCache != null) {
        yield _userCache!;
      }

      // Ensuite, charger les nouvelles données
      final userInfo = await UserApi.getUserInfo();
      _userCache = userInfo;
      _lastUserFetch = DateTime.now();
      yield userInfo;
    } catch (e) {
      if (_userCache != null) {
        yield _userCache!;
      } else {
        yield {};
      }
    }
  }

  static Future<String> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token d\'authentification non disponible');
      }
      return token;
    } catch (e) {
      throw Exception('Erreur d\'authentification: $e');
    }
  }
}
