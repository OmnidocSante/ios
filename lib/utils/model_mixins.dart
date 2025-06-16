import 'package:intl/intl.dart';
import 'model_utils.dart';

mixin PersonMixin {
  String get nom;
  String get prenom;
  String get telephone;
  String? get email;
  String? get genre;
  DateTime? get dateNaissance;
  String? get photo;

  String get fullName => ModelUtils.formatFullName(prenom, nom);
  
  Map<String, dynamic> toPersonJson() {
    return ModelUtils.personToJson(
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      email: email,
      genre: genre,
      dateNaissance: dateNaissance,
      photo: photo,
    );
  }
}

mixin BaseModelMixin {
  int get id;
  DateTime get createdAt;
  String get statut;

  Map<String, dynamic> toBaseJson() {
    return ModelUtils.baseToJson(
      id: id,
      createdAt: createdAt,
      statut: statut,
    );
  }
}

mixin MissionMixin {
  String get typeMission;
  DateTime get date;
  String get heureDepart;
  bool get isUrgent;
  String get description;
  String get adresse;
  String? get demandeMateriel;
  String get etatMission;
  String? get bonDeCommande;
  String? get cause;

  String get formattedType => ModelUtils.formatMissionType(typeMission);
  String get formattedStatus => ModelUtils.formatStatus(etatMission);
  
  Map<String, dynamic> toMissionJson() {
    return {
      'type_mission': typeMission,
      'date': date.toIso8601String(),
      'heure_depart': heureDepart,
      'urgence': isUrgent ? 1 : 0,
      'description': description,
      'adresse': adresse,
      'demande_materiel': demandeMateriel,
      'etat_mission': etatMission,
      'bon_de_commande': bonDeCommande,
      'cause': cause,
    };
  }
}

mixin NotificationMixin {
  String get message;
  DateTime get dateNotification;
  String get type;

  String get formattedType => ModelUtils.formatNotificationType(type);
  
  Map<String, dynamic> toNotificationJson() {
    return {
      'message': message,
      'date_notification': dateNotification.toIso8601String(),
      'type': type,
    };
  }
} 