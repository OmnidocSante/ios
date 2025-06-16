import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:geolocator/geolocator.dart';
import '../config/api_config.dart';

class UserApi {
  static String getAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return '';
    }

    if (avatarPath.startsWith('http')) {
      return avatarPath;
    }

    final String url = avatarPath.startsWith('/')
        ? '${ApiConfig.baseUrl}$avatarPath'
        : '${ApiConfig.baseUrl}/$avatarPath';

    return url;
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'Échec de la récupération des informations utilisateur');
      }
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des informations utilisateur: $e');
    }
  }

  static Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (token == null || userId == null) {
        throw Exception('Token ou ID utilisateur non trouvé');
      }

      // Récupérer les informations actuelles de l'utilisateur
      final currentUserInfo = await getUserInfo();

      // Créer une copie des données actuelles
      final Map<String, dynamic> updatedData =
          Map<String, dynamic>.from(currentUserInfo);

      // Extraire le statut des données à mettre à jour
      String? newStatus = userData['statut'];
      userData.remove('statut');

      // Mettre à jour uniquement les champs qui ont été modifiés
      userData.forEach((key, value) {
        // Pour la photo, utiliser une chaîne vide pour la suppression
        if (key == 'photo' && value == null) {
          updatedData[key] = '';
        }
        // Pour les autres champs, mettre à jour si la valeur est différente
        else if (value != null && value != currentUserInfo[key]) {
          updatedData[key] = value;
        }
      });

      // Première requête : mise à jour des données utilisateur
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        // Si un nouveau statut a été fourni, le mettre à jour séparément
        if (newStatus != null) {
          // Récupérer à nouveau les données actuelles
          final currentData = await getUserInfo();
          final statusData = Map<String, dynamic>.from(currentData);
          statusData['statut'] = newStatus;

          final statusResponse = await http.put(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(statusData),
          );

          if (statusResponse.statusCode == 200) {
            // Récupérer les données finales
            return await getUserInfo();
          } else {
            throw Exception(
                'Erreur lors de la mise à jour du statut: ${statusResponse.body}');
          }
        }

        // Récupérer les données finales
        return await getUserInfo();
      } else {
        throw Exception('Erreur lors de la mise à jour: ${response.body}');
      }
    } catch (e) {
      throw Exception(
          'Erreur lors de la mise à jour des informations utilisateur: $e');
    }
  }

  static Future<void> changePassword(
      String currentPassword, String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    if (token == null || userId == null) {
      throw Exception('Token ou userId manquant');
    }

    final response = await http.put(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId/password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du changement de mot de passe');
    }
  }

  static Future<void> updateAvatar(String avatarPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    if (token == null || userId == null) {
      throw Exception('Token ou userId manquant');
    }

    final response = await http.put(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId/avatar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'avatar': avatarPath,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de l\'avatar');
    }
  }

  static Future<void> deleteAvatar() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userId = prefs.getString('userId');

      if (token == null || userId == null) {
        throw Exception('Token ou userId manquant');
      }
      // Récupérer les informations actuelles de l'utilisateur
      final currentUserInfo = await getUserInfo();

      // Créer une copie des données actuelles
      final Map<String, dynamic> updatedData =
          Map<String, dynamic>.from(currentUserInfo);

      // Mettre la photo à null
      updatedData['photo'] = null;

      // Mettre à jour les informations utilisateur
      await updateUserInfo(updatedData);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> updateUserStatus(String userId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token manquant');
      }

      // Récupérer les informations actuelles de l'utilisateur
      final currentUserInfo = await getUserInfo();

      // Créer une copie des données actuelles
      final Map<String, dynamic> updatedData =
          Map<String, dynamic>.from(currentUserInfo);

      // Mettre à jour uniquement le statut
      updatedData['statut'] = status;

      // Envoyer la mise à jour à l'API
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la mise à jour du statut: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  static Position? _lastPosition;
  static const double _minDistanceMeters = 50.0;

  static Future<void> updateUserLocation() async {
    try {
      // Vérifier les permissions de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      // Obtenir la position actuelle
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Si c'est la première position, l'enregistrer et mettre à jour
      if (_lastPosition == null) {
        _lastPosition = currentPosition;
        await _sendLocationToServer(currentPosition);
        return;
      }

      // Calculer la distance parcourue
      double distanceInMeters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      // Si la distance est supérieure à 50 mètres, mettre à jour la localisation
      if (distanceInMeters >= _minDistanceMeters) {
        _lastPosition = currentPosition;
        await _sendLocationToServer(currentPosition);
      } else {
        // Ne rien faire
      }
    } catch (e) {
      // Erreur silencieuse
    }
  }

  static Future<void> _sendLocationToServer(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (token == null || userId == null) {
        return;
      }

      // Récupérer les données actuelles de l'utilisateur
      final currentUserInfo = await getUserInfo();
      final Map<String, dynamic> updatedData =
          Map<String, dynamic>.from(currentUserInfo);

      // Mettre à jour uniquement la localisation
      updatedData['loc'] = '${position.latitude},${position.longitude}';

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode != 200) {
        // Erreur silencieuse
      }
    } catch (e) {
      // Erreur silencieuse
    }
  }
}
