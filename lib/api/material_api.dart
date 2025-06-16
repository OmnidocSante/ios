import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart';

class MaterialApi {
  static Future<String?> _getToken() async {
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

  // Récupérer tous les matériels
  static Future<List<Map<String, dynamic>>> getMaterials() async {
    try {
      final token = await _getToken();

      final url = '${ApiConfig.baseUrl}${ApiConfig.materialsEndpoint}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Erreur lors de la récupération des matériels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des matériels: $e');
    }
  }

  // Ajouter un matériel utilisé
  static Future<void> addMaterialUsage(
      Map<String, dynamic> materialUsage) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final Map<String, dynamic> requestData =
          Map<String, dynamic>.from(materialUsage);

      // Conversion des types
      if (requestData['ambulance_id'] is String) {
        requestData['ambulance_id'] = int.parse(requestData['ambulance_id']);
      }
      if (requestData['mission_id'] is String) {
        requestData['mission_id'] = int.parse(requestData['mission_id']);
      }
      if (requestData['patient_id'] is String) {
        requestData['patient_id'] = int.parse(requestData['patient_id']);
      }
      if (requestData['quantite_utilisee'] is String) {
        requestData['quantite_utilisee'] =
            int.parse(requestData['quantite_utilisee']);
      }

      // Conversion en tableaux pour item et quantite_utilisee
      if (requestData['item'] != null && !(requestData['item'] is List)) {
        requestData['item'] = [requestData['item']];
      }

      if (requestData['quantite_utilisee'] != null &&
          !(requestData['quantite_utilisee'] is List)) {
        requestData['quantite_utilisee'] = [requestData['quantite_utilisee']];
      }

      // Suppression des champs inutiles
      requestData.remove('patient');
      requestData.remove('quantite');

      final url = '${ApiConfig.baseUrl}${ApiConfig.materialsEndpoint}/usage';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Erreur lors de l\'ajout de l\'utilisation du matériel: ${response.statusCode} - ${response.body}');
      }

    } catch (e) {
      throw Exception(
          'Erreur lors de l\'ajout de l\'utilisation du matériel: $e');
    }
  }

  // Mettre à jour la quantité d'un matériel
  static Future<void> updateMaterialQuantity(
      int materialId, int newQuantity) async {
    try {
      final token = await _getToken();

      final url =
          '${ApiConfig.baseUrl}${ApiConfig.materialsEndpoint}/$materialId';

      final getResponse = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (getResponse.statusCode != 200) {
        throw Exception(
            'Erreur lors de la récupération du matériel: ${getResponse.statusCode}');
      }

      final currentMaterial = json.decode(getResponse.body);

      final updateData = {
        ...currentMaterial,
        'quantite': newQuantity,
      };

      final updateResponse = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      if (updateResponse.statusCode != 200) {
        throw Exception(
            'Erreur lors de la mise à jour de la quantité: ${updateResponse.statusCode}');
      }

    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la quantité: $e');
    }
  }

  static Future<List<dynamic>> getMaterialsUsedForMission(int missionId) async {
    final token = await _getToken();
    final url = '${ApiConfig.baseUrl}/utilisation_materiel/$missionId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return [];
    }
  }

  static Future<List<dynamic>> getAllMaterialsUsage() async {
    final token = await _getToken();
    final url = '${ApiConfig.baseUrl}/utilisation_materiel';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return [];
    }
  }
}
