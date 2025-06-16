import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_webservice/places.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../../api/user_api.dart';
import '../../api/mission_api.dart';
import '../../api/material_api.dart';
import '../../api/vehicle_api.dart';
import '../../api/chat_api.dart';

class MissionTrackingMethods {
  // =============== MÉTHODES DE GESTION DES UTILISATEURS ===============
  static Future<Map<String, dynamic>> fetchUserInfo() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      return userInfo;
    } catch (e) {
      return {};
    }
  }

  // =============== MÉTHODES DE GESTION DES MISSIONS ===============
  static Future<Map<String, dynamic>> fetchMissionDetails(int missionId) async {
    return await MissionApi.getMissionDetails(missionId);
  }

  static Future<void> updateMission(
      int missionId, Map<String, dynamic> data) async {
    await MissionApi.updateMission(missionId, data);
  }

  // =============== MÉTHODES DE GESTION DES MATÉRIELS ===============
  static Future<List<Map<String, dynamic>>> fetchMaterials(
      String ambulanceId) async {
    final allMaterials = await MaterialApi.getMaterials();
    return allMaterials
        .where((m) => m['ambulance_id'].toString() == ambulanceId)
        .toList();
  }

  static Future<void> updateMaterialQuantity(
      int materialId, int newQuantity) async {
    await MaterialApi.updateMaterialQuantity(materialId, newQuantity);
  }

  static Future<void> addMaterialUsage(Map<String, dynamic> usage) async {
    await MaterialApi.addMaterialUsage(usage);
  }

  // =============== MÉTHODES DE GESTION DES VÉHICULES ===============
  static Future<Map<String, dynamic>?> fetchVehicleByUserId(int userId) async {
    return await VehicleApi.getVehicleByUserId(userId);
  }

  static Future<void> updateVehicleStatus(int vehicleId, String status) async {
    await VehicleApi.updateVehicleStatus(vehicleId, status);
  }

  // =============== MÉTHODES DE GÉOLOCALISATION ===============
  static Future<geo.Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) return null;
      }
      if (permission == geo.LocationPermission.deniedForever) return null;
      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<List<geocoding.Location>> geocodeAddress(String address) async {
    return await geocoding.locationFromAddress('$address, Maroc');
  }

  static Future<List<String>> getAddressSuggestions(
      String input, String apiKey) async {
    final places = GoogleMapsPlaces(apiKey: apiKey);
    final response = await places.autocomplete(input,
        language: 'fr', components: [Component(Component.country, 'ma')]);
    if (response.isOkay) {
      return response.predictions.map((p) => p.description!).toList();
    }
    return [];
  }

  // =============== MÉTHODES DE FORMATAGE ===============
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

  // =============== MÉTHODES DE GESTION DU CHAT ===============
  static Future<void> initializeChat(String missionId,
      Function(Map<String, dynamic>) onMessageReceived) async {
    try {
      ChatApi.initializeSocket();
      ChatApi.socket?.on('message', (data) {
        if (data['mission_id'].toString() == missionId) {
          onMessageReceived(data);
        }
      });
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  static Future<List<Map<String, dynamic>>> getMessageHistory(
      String missionId) async {
    try {
      return (await ChatApi.getMessageHistory(missionId))
          .cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> sendMessage({
    required String sender,
    required String message,
    required String userId,
    required String missionId,
  }) async {
    try {
      await ChatApi.sendMessage(
        sender: sender,
        message: message,
        userId: userId,
        missionId: missionId,
      );
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }
}
