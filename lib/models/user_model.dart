import '../utils/model_mixins.dart';
import '../utils/json_mixin.dart';
import '../utils/json_utils.dart';
import 'package:flutter/foundation.dart';
import '../utils/json_convertible.dart';

class UserModel with BaseModelMixin, PersonMixin, JsonConvertible {
  @override
  final int id;
  @override
  final String nom;
  @override
  final String prenom;
  @override
  final String email;
  @override
  final String telephone;
  @override
  final String genre;
  @override
  final DateTime dateNaissance;
  final String role;
  @override
  final String statut;
  @override
  final String? photo;
  @override
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.genre,
    required this.dateNaissance,
    required this.role,
    required this.statut,
    this.photo,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['téléphone'] as String,
      genre: json['genre'] as String,
      dateNaissance: DateTime.parse(json['date_naissance'] as String),
      role: json['rôle'] as String,
      statut: json['statut'] as String,
      photo: json['photo'] as String?,
      createdAt: DateTime.parse(json['créé_le'] as String),
    );
  }

  static List<UserModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'téléphone': telephone,
      'genre': genre,
      'date_naissance': dateNaissance.toIso8601String(),
      'rôle': role,
      'statut': statut,
      'photo': photo,
      'créé_le': createdAt.toIso8601String(),
    };
  }

  String get fullName => '$prenom $nom';
}
