import '../utils/model_mixins.dart';
import '../utils/json_mixin.dart';
import '../utils/json_utils.dart';
import '../utils/json_convertible.dart';
import 'package:flutter/foundation.dart';

class PatientModel with BaseModelMixin, PersonMixin, JsonConvertible {
  @override
  final int id;
  @override
  final String nom;
  @override
  final String prenom;
  @override
  final String telephone;
  @override
  final String adresse;
  @override
  final String? email;
  @override
  final DateTime? dateNaissance;
  @override
  final String? genre;
  @override
  final String? photo;
  final String? antecedents;
  final String? allergies;
  final String? traitementEnCours;
  @override
  final DateTime createdAt;
  @override
  final String statut;

  PatientModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.adresse,
    this.email,
    this.dateNaissance,
    this.genre,
    this.photo,
    this.antecedents,
    this.allergies,
    this.traitementEnCours,
    required this.createdAt,
    required this.statut,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['téléphone'] as String,
      adresse: json['adresse'] as String,
      email: json['email'] as String?,
      dateNaissance: DateTime.parse(json['date_naissance'] as String),
      genre: json['genre'] as String?,
      photo: json['photo'] as String?,
      antecedents: json['antecedents'] as String?,
      allergies: json['allergies'] as String?,
      traitementEnCours: json['traitement_en_cours'] as String?,
      createdAt: DateTime.parse(json['créé_le'] as String),
      statut: json['statut'] as String,
    );
  }

  static List<PatientModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => PatientModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'téléphone': telephone,
      'adresse': adresse,
      'email': email,
      'date_naissance': dateNaissance?.toIso8601String(),
      'genre': genre,
      'photo': photo,
      'antecedents': antecedents,
      'allergies': allergies,
      'traitement_en_cours': traitementEnCours,
      'créé_le': createdAt.toIso8601String(),
      'statut': statut,
    };
  }

  String get fullName => '$prenom $nom';
}
