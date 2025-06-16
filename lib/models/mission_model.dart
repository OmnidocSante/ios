import '../utils/model_mixins.dart';
import '../utils/json_mixin.dart';
import '../utils/json_utils.dart';
import 'package:flutter/foundation.dart';
import '../utils/json_convertible.dart';

class MissionModel with BaseModelMixin, MissionMixin, JsonConvertible {
  @override
  final int id;
  @override
  final String typeMission;
  @override
  final DateTime date;
  @override
  final String heureDepart;
  @override
  final bool isUrgent;
  @override
  final String description;
  @override
  final String adresse;
  @override
  final String? demandeMateriel;
  @override
  final String etatMission;
  @override
  final String statut;
  @override
  final String? bonDeCommande;
  @override
  final String? cause;
  final int patientId;
  final int? medecinId;
  final int? infirmierId;
  @override
  final DateTime createdAt;
  final String? heureDebut;
  final String? heureFin;
  final String? heureArrivee;
  final String? heureRedepart;

  MissionModel({
    required this.id,
    required this.typeMission,
    required this.date,
    required this.heureDepart,
    required this.isUrgent,
    required this.description,
    required this.adresse,
    this.demandeMateriel,
    required this.etatMission,
    required this.statut,
    this.bonDeCommande,
    this.cause,
    required this.patientId,
    this.medecinId,
    this.infirmierId,
    required this.createdAt,
    this.heureDebut,
    this.heureFin,
    this.heureArrivee,
    this.heureRedepart,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'],
      typeMission: json['type_mission'] ?? '',
      date: DateTime.parse(json['date']),
      heureDepart: json['heure_depart'] ?? '',
      isUrgent: json['is_urgent'] ?? false,
      description: json['description'] ?? '',
      adresse: json['adresse'] ?? '',
      demandeMateriel: json['demande_materiel'],
      etatMission: json['etat_mission'] ?? '',
      statut: json['statut'] ?? '',
      bonDeCommande: json['bon_de_commande'],
      cause: json['cause'],
      patientId: json['patient_id'],
      medecinId: json['medecin_id'],
      infirmierId: json['infirmier_id'],
      createdAt: DateTime.parse(json['created_at']),
      heureDebut: json['heure_debut'],
      heureFin: json['heure_fin'],
      heureArrivee: json['heure_arrivee'],
      heureRedepart: json['heure_redepart'],
    );
  }

  static List<MissionModel> fromJsonList(List<dynamic> jsonList) {
    return JsonConvertible.fromJsonList(jsonList, MissionModel.fromJson);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...toBaseJson(),
      ...toMissionJson(),
      'patient_id': patientId,
      'medecin_id': medecinId,
      'infirmier_id': infirmierId,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'heure_arrivee': heureArrivee,
      'heure_redepart': heureRedepart,
    };
  }
}
