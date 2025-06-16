import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';

class MissionApi {
  static Future<List<Map<String, dynamic>>> getAllMissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.missionsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Échec de la récupération des missions');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des missions: $e');
    }
  }

  static Future<Map<String, dynamic>> getMission(int missionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.missionsEndpoint}/$missionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Échec de la récupération de la mission');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la mission: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserMissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.missionsEndpoint}/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Échec de la récupération des missions');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des missions: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUpcomingMissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.missionsEndpoint}/upcoming/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Échec de la récupération des missions à venir');
      }
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des missions à venir: $e');
    }
  }

  static Future<Map<String, dynamic>> updateMission(
      int missionId, Map<String, dynamic> missionData) async {
    try {
      final timeFields = [
        'heure_depart',
        'heure_affectation',
        'heure_arrivee',
        'heure_redepart',
        'heure_fin'
      ];

      for (var field in timeFields) {
        if (missionData[field] != null) {
          try {
            final dateTime = DateTime.parse(missionData[field]);
            final formatted =
                DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(dateTime);
            missionData[field] = formatted;
          } catch (e) {
            // Ignorer les erreurs de formatage
          }
        }
      }

      if (missionData['heure_depart'] != null) {
        final departTime = DateTime.parse(missionData['heure_depart']);

        if (missionData['heure_affectation'] != null) {
          final affectationTime =
              DateTime.parse(missionData['heure_affectation']);
          final difference = affectationTime.difference(departTime);
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          final seconds = difference.inSeconds.remainder(60);
          missionData['temps_depart'] =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        }

        if (missionData['heure_affectation'] != null &&
            missionData['heure_arrivee'] != null) {
          final affectationTime =
              DateTime.parse(missionData['heure_affectation']);
          final arriveeTime = DateTime.parse(missionData['heure_arrivee']);
          final difference = arriveeTime.difference(affectationTime);
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          final seconds = difference.inSeconds.remainder(60);
          missionData['temps_arrivee'] =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        }

        if (missionData['heure_arrivee'] != null &&
            missionData['heure_redepart'] != null) {
          final arriveeTime = DateTime.parse(missionData['heure_arrivee']);
          final redepartTime = DateTime.parse(missionData['heure_redepart']);
          final difference = redepartTime.difference(arriveeTime);
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          final seconds = difference.inSeconds.remainder(60);
          missionData['temps_redepart'] =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        }

        if (missionData['heure_redepart'] != null &&
            missionData['heure_fin'] != null) {
          final redepartTime = DateTime.parse(missionData['heure_redepart']);
          final finTime = DateTime.parse(missionData['heure_fin']);
          final difference = finTime.difference(redepartTime);
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          final seconds = difference.inSeconds.remainder(60);
          missionData['temps_fin'] =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        }

        Duration tempsTotal = Duration.zero;
        final timeFieldsForTotal = [
          'temps_depart',
          'temps_arrivee',
          'temps_redepart',
          'temps_fin'
        ];

        for (var field in timeFieldsForTotal) {
          if (missionData[field] != null && missionData[field] is String) {
            final parts = missionData[field].split(':');
            if (parts.length == 3) {
              final duration = Duration(
                  hours: int.parse(parts[0]),
                  minutes: int.parse(parts[1]),
                  seconds: int.parse(parts[2]));
              tempsTotal += duration;
            }
          }
        }

        final totalHours = tempsTotal.inHours;
        final totalMinutes = tempsTotal.inMinutes.remainder(60);
        final totalSeconds = tempsTotal.inSeconds.remainder(60);
        missionData['temps_total'] =
            '${totalHours.toString().padLeft(2, '0')}:${totalMinutes.toString().padLeft(2, '0')}:${totalSeconds.toString().padLeft(2, '0')}';
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.put(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.missionsEndpoint}/$missionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(missionData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
            'Erreur lors de la mise à jour de la mission: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static void debugApiResponse(http.Response response, {String? endpoint}) {}

  static Future<Map<String, dynamic>> getMissionDetails(int missionId) async {
    try {
      final token = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.missionsEndpoint}/$missionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final mission = json.decode(response.body);
        return mission;
      } else {
        throw Exception(
            'Erreur lors de la récupération des détails de la mission: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
