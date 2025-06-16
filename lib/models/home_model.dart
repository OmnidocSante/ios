import 'package:flutter/material.dart';

class MissionModel {
  final int id;
  final int? patientId;
  final String? etatMission;
  final String? statut;
  final String? dateMission;
  final String? heureDepart;
  final String? heureArrivee;
  final String? heureAffectation;
  final String? heureRedepart;
  final String? heureFin;
  final int? urgence;
  final String? creeLe;
  final String? typeMission;
  final String? cause;
  final String? bonDeCommande;
  final String? demandeMateriel;
  final int? ambulancierId;
  final String? adresse;
  final String? adresseDestination;
  final int? doctorId;
  final int? nurseId;
  final String? prix;
  final String? paiement;
  final int? paye;
  final String? ville;
  final String? tempsDepart;
  final String? tempsArrivee;
  final String? tempsTotal;
  final String? tempsRedepart;
  final String? tempsFin;

  MissionModel({
    required this.id,
    this.patientId,
    this.etatMission,
    this.statut,
    this.dateMission,
    this.heureDepart,
    this.heureArrivee,
    this.heureAffectation,
    this.heureRedepart,
    this.heureFin,
    this.urgence,
    this.creeLe,
    this.typeMission,
    this.cause,
    this.bonDeCommande,
    this.demandeMateriel,
    this.ambulancierId,
    this.adresse,
    this.adresseDestination,
    this.doctorId,
    this.nurseId,
    this.prix,
    this.paiement,
    this.paye,
    this.ville,
    this.tempsDepart,
    this.tempsArrivee,
    this.tempsTotal,
    this.tempsRedepart,
    this.tempsFin,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] ?? 0,
      patientId: json['patient_id'],
      etatMission: json['etat_mission'],
      statut: json['statut'],
      dateMission: json['date_mission'],
      heureDepart: json['heure_depart'],
      heureArrivee: json['heure_arrivee'],
      heureAffectation: json['heure_affectation'],
      heureRedepart: json['heure_redepart'],
      heureFin: json['heure_fin'],
      urgence: json['urgence'],
      creeLe: json['créé_le'],
      typeMission: json['type_mission'],
      cause: json['cause'],
      bonDeCommande: json['bon_de_commande'],
      demandeMateriel: json['demande_materiel'],
      ambulancierId: json['ambulancier_id'],
      adresse: json['adresse'],
      adresseDestination: json['adresse_destination'],
      doctorId: json['doctor_id'],
      nurseId: json['nurse_id'],
      prix: json['prix'],
      paiement: json['paiement'],
      paye: json['paye'],
      ville: json['ville'],
      tempsDepart: json['temps_depart'],
      tempsArrivee: json['temps_arrivee'],
      tempsTotal: json['temps_total'],
      tempsRedepart: json['temps_redepart'],
      tempsFin: json['temps_fin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'etat_mission': etatMission,
      'statut': statut,
      'date_mission': dateMission,
      'heure_depart': heureDepart,
      'heure_arrivee': heureArrivee,
      'heure_affectation': heureAffectation,
      'heure_redepart': heureRedepart,
      'heure_fin': heureFin,
      'urgence': urgence,
      'créé_le': creeLe,
      'type_mission': typeMission,
      'cause': cause,
      'bon_de_commande': bonDeCommande,
      'demande_materiel': demandeMateriel,
      'ambulancier_id': ambulancierId,
      'adresse': adresse,
      'adresse_destination': adresseDestination,
      'doctor_id': doctorId,
      'nurse_id': nurseId,
      'prix': prix,
      'paiement': paiement,
      'paye': paye,
      'ville': ville,
      'temps_depart': tempsDepart,
      'temps_arrivee': tempsArrivee,
      'temps_total': tempsTotal,
      'temps_redepart': tempsRedepart,
      'temps_fin': tempsFin,
    };
  }
}

class HomeModel {
  final String userName;
  final String userId;
  final String userAvatar;
  final String userEmail;
  final String userPhone;
  final String userGender;
  final String userBirthDate;
  final String userRole;
  final String userStatus;
  final MissionModel? nextMission;
  final int? ambulanceId;
  final bool isLoading;

  HomeModel({
    required this.userName,
    required this.userId,
    required this.userAvatar,
    required this.userEmail,
    required this.userPhone,
    required this.userGender,
    required this.userBirthDate,
    required this.userRole,
    required this.userStatus,
    this.nextMission,
    this.ambulanceId,
    this.isLoading = false,
  });

  HomeModel copyWith({
    String? userName,
    String? userId,
    String? userAvatar,
    String? userEmail,
    String? userPhone,
    String? userGender,
    String? userBirthDate,
    String? userRole,
    String? userStatus,
    MissionModel? nextMission,
    int? ambulanceId,
    bool? isLoading,
  }) {
    return HomeModel(
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      userAvatar: userAvatar ?? this.userAvatar,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userGender: userGender ?? this.userGender,
      userBirthDate: userBirthDate ?? this.userBirthDate,
      userRole: userRole ?? this.userRole,
      userStatus: userStatus ?? this.userStatus,
      nextMission: nextMission ?? this.nextMission,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
