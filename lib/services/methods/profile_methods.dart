import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../api/user_api.dart';
import '../../services/auth_service.dart';


class ProfileMethods {
  static final ImagePicker _picker = ImagePicker();

  // Méthodes de gestion des données utilisateur
  static Future<Map<String, dynamic>> fetchUserInfo() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      return userInfo;
    } catch (e) {
      return {};
    }
  }

  // Méthodes de gestion de l'image de profil
  static Future<File?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> uploadImage(String imagePath) async {
    try {
      await UserApi.updateAvatar(imagePath);
    } catch (e) {
    }
  }

  static Future<void> deletePhoto() async {
    try {
      await UserApi.deleteAvatar();
    } catch (e) {
    }
  }

  // Méthodes de mise à jour du profil
  static Future<void> updateProfile(Map<String, dynamic> changedFields) async {
    try {
      if (changedFields.isEmpty) {
        throw Exception('Aucune modification à enregistrer');
      }

      // Toujours mettre à jour le statut si des modifications sont faites
      changedFields['statut'] = 'actif';

      await UserApi.updateUserInfo(changedFields);
    } catch (e) {
    }
  }

  // Méthodes de gestion de l'état utilisateur
  static Future<void> setUserActive() async {
    try {
      final authService = AuthService();
      await authService.setUserActive();
    } catch (e) {
    }
  }

  static Future<void> setUserInactive() async {
    try {
      final authService = AuthService();
      await authService.setUserInactive();
    } catch (e) {
    }
  }

  // Méthodes de validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer une adresse email valide';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }
}
