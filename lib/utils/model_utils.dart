import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/patient_model.dart';
import '../models/mission_model.dart';
import '../models/notification_model.dart';
import '../enums/notification_type.dart';

class ModelUtils {
  static Map<String, dynamic> baseToJson({
    required int id,
    required DateTime createdAt,
    required String statut,
  }) {
    return {
      'id': id,
      'statut': statut,
      'créé_le': createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> personToJson({
    required String nom,
    required String prenom,
    required String telephone,
    String? email,
    String? genre,
    DateTime? dateNaissance,
    String? photo,
  }) {
    return {
      'nom': nom,
      'prenom': prenom,
      'téléphone': telephone,
      'email': email,
      'genre': genre,
      'date_naissance': dateNaissance?.toIso8601String(),
      'photo': photo,
    };
  }

  static String formatFullName(String prenom, String nom) {
    return '$prenom $nom';
  }

  static String formatStatus(String status) {
    return status.toLowerCase().replaceAll('_', ' ');
  }

  static String formatMissionType(String type) {
    return type.toLowerCase().replaceAll('_', ' ');
  }

  static String formatNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return 'Information';
      case 'success':
        return 'Succès';
      case 'warning':
        return 'Avertissement';
      case 'error':
        return 'Erreur';
      default:
        return 'Notification';
    }
  }

  static NotificationType parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return NotificationType.info;
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      default:
        return NotificationType.info;
    }
  }
}
