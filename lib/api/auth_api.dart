import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthApi {
  static const String baseUrl = 'R';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      
      // Décoder le token pour obtenir l'ID de l'utilisateur
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['userId'];

      // Sauvegarder le token et l'ID de l'utilisateur
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', userId);

      return data;
    } else {
      throw Exception('Erreur lors de la connexion');
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    if (token == null) return false;
    
    try {
      // Vérifier si le token est expiré
      bool isExpired = JwtDecoder.isExpired(token);
      return !isExpired;
    } catch (e) {
      return false;
    }
  }
} 