import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/user_api.dart';
import '../../api/patient_api.dart';
import '../../api/mission_api.dart';
import '../../api/chat_api.dart';
import '../../api/vehicle_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart' as geo;

class PatientInfoMethods {
  // Méthodes de gestion des données utilisateur
  static Future<Map<String, dynamic>> fetchUserInfo() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      return userInfo;
    } catch (e) {
      return {};
    }
  }

  // Méthodes de gestion des données patient
  static Future<Map<String, dynamic>> fetchPatientInfo(int patientId) async {
    try {
      return await PatientApi.getPatientInfo(patientId);
    } catch (e) {
      return {};
    }
  }

  // Méthodes de gestion des missions
  static Future<Map<String, dynamic>> fetchMissionInfo(int missionId) async {
    try {
      return await MissionApi.getMission(missionId);
    } catch (e) {
      return {};
    }
  }

  // Méthodes de gestion du chat
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

  // Méthodes de gestion de la localisation
  static Future<geo.Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return null;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return null;
      }

      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  // Méthodes de formatage
  static String formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) {
      return 'Non spécifiée';
    }
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date.toString()));
    } catch (e) {
      return 'Format invalide';
    }
  }

  static String formatDateTime(dynamic dateTime) {
    if (dateTime == null || dateTime.toString().isEmpty) {
      return 'Non spécifiée';
    }
    try {
      return DateFormat('dd/MM/yyyy HH:mm')
          .format(DateTime.parse(dateTime.toString()));
    } catch (e) {
      return 'Format invalide';
    }
  }

  // Méthodes de gestion des appels téléphoniques
  static Future<void> makePhoneCall(String phoneNumber) async {
    try {
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleanNumber.startsWith('0')) {
        cleanNumber = '+212${cleanNumber.substring(1)}';
      }
      final Uri uri = Uri.parse('tel:$cleanNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  // Méthodes de gestion des véhicules
  static Future<Map<String, dynamic>?> getVehicleByUserId(int userId) async {
    try {
      return await VehicleApi.getVehicleByUserId(userId);
    } catch (e) {
      return null;
    }
  }
}
