import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Méthodes d'authentification
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
      body: json.encode({
        'email': email,
        'mot_de_passe': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de la connexion');
    }
  }

  // Méthodes pour les missions
  static Future<Map<String, dynamic>> getMissionDetails(int missionId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.missionsEndpoint}/$missionId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de la récupération des détails de la mission');
    }
  }

  static Future<void> updateMission(
      int missionId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.missionsEndpoint}/$missionId'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Échec de la mise à jour de la mission');
    }
  }

  // Méthodes pour les matériels
  static Future<List<Map<String, dynamic>>> getMaterials() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.materialsEndpoint}'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Échec de la récupération des matériels');
    }
  }

  static Future<void> updateMaterial(
      int materialId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.materialsEndpoint}/$materialId'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Échec de la mise à jour du matériel');
    }
  }

  static Future<void> addMaterialUsage(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.materialsEndpoint}/usage'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Échec de l\'ajout de l\'utilisation du matériel');
    }
  }

  // Méthodes pour les véhicules
  static Future<Map<String, dynamic>?> getVehicleByUserId(int userId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.vehiclesEndpoint}/user/$userId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Échec de la récupération du véhicule');
    }
  }

  static Future<void> updateVehicleStatus(int vehicleId, String status) async {
    final response = await http.put(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.vehiclesEndpoint}/$vehicleId/status'),
      headers: await _getHeaders(),
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Échec de la mise à jour du statut du véhicule');
    }
  }
}
