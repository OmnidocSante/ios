import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://regulation.omnidoc.ma:5000';
  static const String apiVersion = '/api/v1';

  static final Dio _dio = Dio();

  // Méthode pour obtenir le token d'authentification
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Méthode pour rafraîchir le token
  static Future<String?> refreshToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentToken = prefs.getString('token');
      String? userId = prefs.getString('userId');

      if (currentToken == null || userId == null) {
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
        body: json.encode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['token'];
        await prefs.setString('token', newToken);
        return newToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Méthode pour obtenir l'ID de l'utilisateur
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Méthode pour vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    String? token = await getToken();
    if (token == null) return false;

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['exp'] * 1000 > DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      return false;
    }
  }

  // Méthode pour récupérer les informations de l'utilisateur
  static Future<Map<String, dynamic>> getUserInfo() async {
    String? token = await getToken();
    String? userId = await getUserId();

    if (token == null || userId == null) {
      throw Exception('Token ou userId manquant');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Erreur lors de la récupération des informations utilisateur');
    }
  }

  // Méthode pour se connecter
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: json.encode({
        'email': email,
        'mot_de_passe': password,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['token']);
      prefs.setString('userId', data['user']['id'].toString());
      prefs.setString('userRole', data['user']['rôle']);
      return data;
    } else {
      throw Exception('Email ou mot de passe incorrect');
    }
  }

  // Méthode pour se déconnecter
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Méthode pour récupérer les interventions
  static Future<List<dynamic>> getInterventions() async {
    String? token = await getToken();
    String? userId = await getUserId();

    if (token == null || userId == null) {
      throw Exception('Token ou userId manquant');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/interventions/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des interventions');
    }
  }

  // Méthode pour récupérer les détails d'une intervention
  static Future<Map<String, dynamic>> getInterventionDetails(
      String interventionId) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token manquant');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/interventions/$interventionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Erreur lors de la récupération des détails de l\'intervention');
    }
  }

  // Méthode pour mettre à jour le statut d'une intervention
  static Future<void> updateInterventionStatus(
      String interventionId, String status) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token manquant');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/interventions/$interventionId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Erreur lors de la mise à jour du statut de l\'intervention');
    }
  }

  // Méthode pour récupérer les notifications
  static Future<List<dynamic>> getNotifications() async {
    try {
      String? token = await getToken();
      String? userId = await getUserId();

      if (token == null || userId == null) {
        throw Exception('Token ou userId manquant');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> allNotifications = json.decode(response.body);

        // Filtrer les notifications pour l'utilisateur connecté
        final List<dynamic> userNotifications =
            allNotifications.where((notification) {
          return notification['user_id'].toString() == userId;
        }).toList();

        return userNotifications;
      } else {
        throw Exception(
            'Erreur de réponse: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notifications: $e');
    }
  }

  // Méthode pour marquer une notification comme lue
  static Future<void> markNotificationAsRead(String notificationId) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token manquant');
    }

    // Récupérer d'abord la notification pour obtenir toutes les données
    final notificationResponse = await http.get(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (notificationResponse.statusCode != 200) {
      throw Exception('Erreur lors de la récupération de la notification');
    }

    final notificationData = json.decode(notificationResponse.body);

    // Formater la date en format MySQL compatible
    final originalDate = DateTime.parse(notificationData['date_notification']);
    final formattedDate =
        '${originalDate.year}-${originalDate.month.toString().padLeft(2, '0')}-${originalDate.day.toString().padLeft(2, '0')} ${originalDate.hour.toString().padLeft(2, '0')}:${originalDate.minute.toString().padLeft(2, '0')}:${originalDate.second.toString().padLeft(2, '0')}';

    // Créer une copie des données avec le nouveau statut et la date formatée
    final updatedData = Map<String, dynamic>.from(notificationData);
    updatedData['statut'] = 'lue';
    updatedData['date_notification'] = formattedDate;

    // Envoyer la mise à jour complète
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Erreur lors de la mise à jour du statut de la notification: ${response.body}');
    }
  }

  // Méthode pour enregistrer le token de l'appareil pour les notifications push
  static Future<void> registerDeviceToken(String deviceToken) async {
    String? token = await getToken();
    String? userId = await getUserId();

    if (token == null || userId == null) {
      throw Exception('Token ou userId manquant');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/notifications/register-device'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': userId,
        'deviceToken': deviceToken,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Erreur lors de l\'enregistrement du token de l\'appareil');
    }
  }

  static Future<void> changePassword(
      String oldPassword, String newPassword) async {
    final token = await getToken();
    final userId = await getUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du changement de mot de passe');
    }
  }

  static Future<Map<String, dynamic>?> getMissionDetails(
      String missionId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return null;
      }

      final response = await _dio.get(
        '$baseUrl/interventions/$missionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getPatientName(String patientId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return null;
      }

      final response = await _dio.get(
        '$baseUrl/patients/$patientId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['nom'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getPatientAddress(String patientId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return null;
      }

      final response = await _dio.get(
        '$baseUrl/patients/$patientId/address',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['adresse'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getMissionType(String missionId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return null;
      }

      final response = await _dio.get(
        '$baseUrl/interventions/$missionId/type',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['type_mission'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Méthode pour enregistrer le token FCM
  static Future<void> registerFCMToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/fcm-token'),
        headers: {
          'Authorization': 'Bearer ${await getToken()}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fcm_token': token,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'enregistrement du token FCM');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement du token FCM');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(
          headers: await _getHeaders(),
        ),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
