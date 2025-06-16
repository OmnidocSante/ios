import 'package:flutter/material.dart';
import '../api/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoading = false;
  String? _error;
  String? _userId;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Méthode pour obtenir l'ID de l'utilisateur
  String? getUserId() {
    return _userId;
  }

  // Méthode pour initialiser l'ID de l'utilisateur
  Future<void> initializeUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
    } catch (e) {
    }
  }

  // Méthode pour vérifier si la session doit être déconnectée
  Future<bool> shouldLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginDate = prefs.getString('lastLoginDate');

      if (lastLoginDate == null) return true;

      final lastLogin = DateTime.parse(lastLoginDate);
      final now = DateTime.now();

      // Vérifier si plus d'un mois s'est écoulé
      return now.difference(lastLogin).inDays > 30;
    } catch (e) {
      return true;
    }
  }

  // Méthode pour mettre à jour la date de dernière connexion
  Future<void> updateLastLoginDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastLoginDate', DateTime.now().toIso8601String());
    } catch (e) {
    }
  }

  Future<void> updateUserStatus(String status) async {
    _setLoading(true);
    _setError(null);

    try {
      // Récupérer les informations actuelles de l'utilisateur
      final userInfo = await UserApi.getUserInfo();

      // Créer un Map avec les données existantes
      final Map<String, dynamic> userData = {
        'id': userInfo['id'],
        'nom': userInfo['nom'],
        'prenom': userInfo['prenom'],
        'email': userInfo['email'],
        'téléphone': userInfo['téléphone'],
        'genre': userInfo['genre'],
        'date_naissance': userInfo['date_naissance'],
        'rôle': userInfo['rôle'],
        'photo': userInfo['photo'],
        'statut': status, // Mettre à jour uniquement le statut
      };

      // Mettre à jour le statut via l'API
      await UserApi.updateUserInfo(userData);
    } catch (e) {
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setUserActive() async {
    await updateUserStatus('actif');
  }

  Future<void> setUserInactive() async {
    await updateUserStatus('inactif');
  }

  Future<void> logout() async {
    try {
      await setUserInactive();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _userId = null;
    } catch (e) {
    }
  }
}
