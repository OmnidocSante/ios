import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class NotificationApi {
  static const Duration timeout = Duration(seconds: 10);

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (token == null || userId == null) {
        throw Exception('Token ou userId manquant');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationsEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final userNotifications = data.where((notification) {
          return notification['user_id']?.toString() == userId &&
              notification['message'] != null &&
              notification['message'].toString().isNotEmpty;
        }).toList();
        return userNotifications.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur lors de la récupération des notifications');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Délai d\'attente dépassé lors de la récupération des notifications');
      }
      throw Exception('Erreur lors de la récupération des notifications: $e');
    }
  }

  static Future<Map<String, dynamic>> getNotificationDetails(String notificationId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationsEndpoint}/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final details = json.decode(response.body);
        return details;
      } else {
        throw Exception('Erreur de récupération');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Délai d\'attente dépassé lors de la récupération des détails');
      }
      rethrow;
    }
  }

  static Future<void> updateNotification(String notificationId, Map<String, dynamic> data) async {
    try {
      final token = await ApiService.getToken();
      final url = '${ApiConfig.baseUrl}${ApiConfig.notificationsEndpoint}/$notificationId';

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(data),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw Exception('Erreur de mise à jour');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Délai d\'attente dépassé lors de la mise à jour');
      }
      rethrow;
    }
  }
}
