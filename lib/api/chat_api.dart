import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

class ChatApi {
  static const String baseUrl = 'https://regulation.omnidoc.ma:5000';
  static IO.Socket? socket;

  // Initialiser la connexion Socket.IO
  static void initializeSocket() {
    if (socket == null) {
      ApiService.getToken().then((token) {
        socket = IO.io(baseUrl, <String, dynamic>{
          'transports': ['websocket', 'polling'],
          'autoConnect': true,
          'forceNew': true,
          'reconnection': true,
          'reconnectionAttempts': 10,
          'reconnectionDelay': 1000,
          'timeout': 30000,
          'pingTimeout': 30000,
          'pingInterval': 25000,
          'extraHeaders':
              token != null ? {'Authorization': 'Bearer $token'} : {},
        });

        socket!.onConnect((_) {});

        socket!.onDisconnect((_) {
          Future.delayed(Duration(seconds: 2), () {
            if (socket != null) {
              socket!.connect();
            }
          });
        });

        socket!.onError((error) {
          Future.delayed(Duration(seconds: 3), () {
            if (socket != null) {
              socket!.connect();
            }
          });
        });

        socket!.onConnectError((error) {
          Future.delayed(Duration(seconds: 3), () {
            if (socket != null) {
              socket!.connect();
            }
          });
        });

        socket!.on('message', (data) {});

        socket!.connect();
      });
    } else {
      socket!.connect();
    }
  }

  // Récupérer tous les messages
  static Future<List<dynamic>> getAllMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'Authorization': 'Bearer ${await ApiService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des messages');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages');
    }
  }

  // Récupérer les messages filtrés par mission_id
  static Future<List<Map<String, dynamic>>> getMessagesByMissionId(
    String missionId, {
    int? page,
    int? pageSize,
  }) async {
    try {
      String url = '$baseUrl/messages/$missionId';
      if (page != null && pageSize != null) {
        url += '?page=$page&pageSize=$pageSize';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Envoyer un message
  static Future<void> sendMessage({
    required String sender,
    required String message,
    required String userId,
    required String missionId,
    String? imageUrl,
  }) async {
    try {
      final token = await ApiService.getToken();

      if (token == null) {
        final newToken = await ApiService.refreshToken();
        if (newToken == null) {
          throw Exception('Impossible d\'obtenir un token valide');
        }
      }

      if (socket == null || !socket!.connected) {
        initializeSocket();
        await Future.delayed(Duration(seconds: 2));
      }

      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await ApiService.getToken()}',
        },
        body: json.encode({
          'sender': sender,
          'message': message,
          'user_id': userId,
          'mission_id': missionId,
          if (imageUrl != null) 'image_url': imageUrl,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'envoi du message');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  // Récupérer l'historique des messages d'une mission
  static Future<List<dynamic>> getMessageHistory(String missionId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/messages/mission/$missionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        final newToken = await ApiService.refreshToken();
        if (newToken != null) {
          return getMessageHistory(missionId);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Marquer un message comme lu
  static Future<void> markMessageAsRead(String messageId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/messages/$messageId/read'),
        headers: {
          'Authorization': 'Bearer ${await ApiService.getToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du marquage du message comme lu');
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage du message comme lu');
    }
  }

  // Envoyer un fichier (image, document, etc.)
  static Future<String> uploadFile(String filePath) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Token manquant');
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.headers['Authorization'] = 'Bearer $token';

      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['url'] != null) {
            return jsonResponse['url'];
          } else {
            throw Exception('URL du fichier manquante dans la réponse');
          }
        } catch (e) {
          throw Exception('Réponse invalide du serveur');
        }
      } else {
        throw Exception('Erreur lors de l\'upload: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir la liste des utilisateurs en ligne
  static Future<List<dynamic>> getOnlineUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/online-users'),
        headers: {
          'Authorization': 'Bearer ${await ApiService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Erreur lors de la récupération des utilisateurs en ligne');
      }
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des utilisateurs en ligne');
    }
  }

  // Déconnecter le socket
  static void disconnectSocket() {
    if (socket != null) {
      socket!.disconnect();
      socket = null;
    }
  }

  static Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await ApiService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}