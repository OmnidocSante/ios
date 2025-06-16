import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart';

class VehicleApi {
  static Future<Map<String, dynamic>?> getVehicleByUserId(int userId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification non disponible');
      }
      // Récupérer tous les véhicules
      final url = '${ApiConfig.baseUrl}${ApiConfig.vehiclesEndpoint}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> vehicles = json.decode(response.body);

        // Filtrer le véhicule par utilisateur
        final userVehicle = vehicles.firstWhere(
          (vehicle) => vehicle['user_id'] == userId,
          orElse: () => null,
        );

        if (userVehicle != null) {
          return userVehicle;
        } else {
          return null;
        }
      } else {
        throw Exception(
            'Erreur lors de la récupération des véhicules: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateVehicleStatus(int vehicleId, String status) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification non disponible');
      }

      // D'abord, récupérer les données actuelles du véhicule
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.vehiclesEndpoint}/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la récupération des données du véhicule: ${response.statusCode}');
      }

      // Récupérer les données existantes
      final Map<String, dynamic> existingData = json.decode(response.body);

      // Mettre à jour uniquement le statut
      final updatedData = Map<String, dynamic>.from(existingData);
      updatedData['statut'] = status;

      // Envoyer la mise à jour
      final updateResponse = await http.put(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.vehiclesEndpoint}/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedData),
      );

      if (updateResponse.statusCode != 200) {
        throw Exception(
            'Erreur lors de la mise à jour du statut du véhicule: ${updateResponse.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
