import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import '../config/firebase_config.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../styles/colors.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Dio _dio = Dio();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isPlaying = false;
  bool _isSoundEnabled = true;

  // Callback pour les notifications
  Function(RemoteMessage)? onNotificationReceived;
  Function(RemoteMessage)? onNotificationOpened;

  // Liste des notifications récupérées
  List<Map<String, dynamic>> notifications = [];

  FirebaseNotificationService() {
    // Configuration de Dio
    _dio.options.baseUrl = 'https://regulation.omnidoc.ma:5000';
    _dio.options.connectTimeout = Duration(seconds: 3);
    _dio.options.receiveTimeout = Duration(seconds: 2);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Configuration de l'audio player
    _audioPlayer.setSource(AssetSource('sounds/notification.mp3'));

    // Configuration des notifications locales
    _initializeLocalNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );

    final InitializationSettings initializationSettings =
        InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // print('[NOTIF] Notification cliquée: ${response.payload}');
      },
    );

    // Créer le canal de notification pour Android avec priorité maximale
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'transport_sante_channel',
              'Transport Santé',
              description: 'Notifications de l\'application Transport Santé',
              importance: Importance.max,
              enableVibration: true,
              playSound: false,
              showBadge: true,
              enableLights: true,
              sound: RawResourceAndroidNotificationSound('notification'),
            ),
          );
    }
  }

  Future<void> _showSystemNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'transport_sante_channel',
      'Transport Santé',
      channelDescription: 'Notifications de l\'application Transport Santé',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: false,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      visibility: NotificationVisibility.public,
      timeoutAfter: 86400000, // 24 heures en millisecondes
      styleInformation: BigTextStyleInformation(''),
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('id_1', 'OK'),
      ],
      additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT
      channelShowBadge: true,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
      interruptionLevel: InterruptionLevel.timeSensitive,
      threadIdentifier: 'transport_sante_thread',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'Nouvelle notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  Future<void> _playNotificationSound() async {
    if (!_isPlaying) {
      _isPlaying = true;
      try {
        await _audioPlayer.play(AssetSource('sounds/notification.mp3'));

        // Lecture en boucle continue jusqu'à ce que l'utilisateur clique sur OK
        _audioPlayer.onPlayerComplete.listen((_) {
          if (_isPlaying) {
            _audioPlayer.play(AssetSource('sounds/notification.mp3'));
          }
        });
    } catch (e) {
        _isPlaying = false;
      }
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    if (navigatorKey.currentContext != null) {
      try {
        // Démarrage du son en boucle
        _playNotificationSound();

        _showSystemNotification(message);

        // ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        //   SnackBar(
        //     content: Container(
        //       padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.circular(12),
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.black.withOpacity(0.1),
        //             blurRadius: 10,
        //             offset: Offset(0, 4),
        //           ),
        //         ],
        //       ),
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Row(
        //             children: [
        //               Icon(
        //                 Icons.notifications_active,
        //                 color: AppColors.primaryColor,
        //                 size: 24,
        //               ),
        //               SizedBox(width: 12),
        //               Expanded(
        //                 child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [
        //                     Text(
        //                       message.notification?.title ??
        //                           'Nouvelle notification',
        //                       style: TextStyle(
        //                         fontWeight: FontWeight.bold,
        //                         fontSize: 16,
        //                         color: AppColors.primaryColor,
        //                       ),
        //                     ),
        //                     SizedBox(height: 4),
        //                     Text(
        //                       message.notification?.body ?? '',
        //                       style: TextStyle(
        //                         fontSize: 14,
        //                         color: Colors.black87,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //           SizedBox(height: 12),
        //           Container(
        //             width: double.infinity,
        //             child: ElevatedButton(
        //               onPressed: () {
        //                 ScaffoldMessenger.of(navigatorKey.currentContext!)
        //                     .hideCurrentSnackBar();
        //                 _audioPlayer.stop();
        //                 _isPlaying = false;
        //               },
        //               style: ElevatedButton.styleFrom(
        //                 backgroundColor: Color(0xFF2E7D32),
        //                 foregroundColor: Colors.white,
        //                 padding: EdgeInsets.symmetric(vertical: 8),
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(8),
        //                 ),
        //                 elevation: 0,
        //               ),
        //               child: Text(
        //                 'OK',
        //                 style: TextStyle(
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     duration: Duration(
        //         days:
        //             1), // La notification reste jusqu'à ce que l'utilisateur clique sur OK
        //     backgroundColor: Colors.transparent,
        //     elevation: 0,
        //     behavior: SnackBarBehavior.floating,
        //     margin: EdgeInsets.all(8),
        //     padding: EdgeInsets.zero,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        // );
      } catch (e) {
        // Gestion silencieuse de l'erreur
      }
    }
  }

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: 'AIzaSyDIKdpuXfgqrave5sodRYhtC_dISZCt1tg',
          appId: '1:1017446732688:android:91e99d21e8250e26875915',
          messagingSenderId: '1017446732688',
          projectId: 'regulation-459709',
          storageBucket: 'regulation-459709.firebasestorage.app',
        ),
      );

      await _configureNotifications();
      await _verifyFcmToken();
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  Future<void> _configureNotifications() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        provisional: false,
        criticalAlert: true,
        announcement: true,
        );
        
      if (Platform.isAndroid) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      _setupMessageHandlers();
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print('[NOTIFICATION] id: \\${message.messageId} | titre: \\${message.notification?.title} | message: \\${message.notification?.body} | date: \\${DateTime.now().toIso8601String()} | data: \\${message.data}');
      _showSystemNotification(message);
      _showLocalNotification(message);
      if (onNotificationReceived != null) {
        onNotificationReceived!(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print('[DEBUG] NOTIF - Notification ouverte par l\'utilisateur: id=\\${message.messageId}');
      _audioPlayer.stop();
      _isPlaying = false;
      if (onNotificationOpened != null) {
        onNotificationOpened!(message);
      }
    });
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      // print('[DEBUG] NOTIF - Nouveau token FCM reçu: $token');
      _registerFcmToken(token: token);
    });
    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      // Traitement du message initial si nécessaire
    }
  }

  Future<void> _registerFcmToken({String? token}) async {
    try {
      String? fcmToken = token ?? await _firebaseMessaging.getToken();
      // print('[DEBUG] NOTIF - Token FCM récupéré: $fcmToken');
      if (fcmToken != null) {
      final prefs = await SharedPreferences.getInstance();
        final jwt = prefs.getString('token');
        if (jwt == null) {
          // print('[DEBUG] NOTIF - Aucun token JWT trouvé');
          return;
        }
        _dio.options.headers['Authorization'] = 'Bearer $jwt';
        final dataToSend = {
          'token': fcmToken,
          'device_type': Platform.operatingSystem,
        };
        // print('[DEBUG] NOTIF - Données envoyées (refresh): $dataToSend');
        final response = await _dio.post('/notification/register-token', data: dataToSend);
        // print('[DEBUG] NOTIF - Code réponse (refresh): \\${response.statusCode}');
        // print('[DEBUG] NOTIF - Réponse (refresh): \\${response.data}');
      }
    } catch (e, stack) {
      // print('[ERROR] NOTIF - Exception lors du refresh token: $e');
      // print('[ERROR] NOTIF - Stack: $stack');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  Future<void> sendTestNotification() async {
    try {
      RemoteMessage testMessage = RemoteMessage(
        notification: RemoteNotification(
          title: 'Test de notification',
          body: 'Ceci est une notification de test',
        ),
        data: {
          'type': 'test',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _showLocalNotification(testMessage);

      if (onNotificationReceived != null) {
        onNotificationReceived!(testMessage);
      }
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  Future<void> _verifyFcmToken() async {
    try {
      String? currentToken = await _firebaseMessaging.getToken();
      if (currentToken == null) return;

      NotificationSettings settings =
          await _firebaseMessaging.getNotificationSettings();

      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('token');

      if (jwt == null) return;

      _dio.options.headers['Authorization'] = 'Bearer $jwt';

      try {
        final response = await _dio.get(
          '/notification/verify-token',
          queryParameters: {'token': currentToken},
        );

        if (response.statusCode != 200) {
          await _registerFcmToken(token: currentToken);
        }
      } catch (e) {
        await _registerFcmToken(token: currentToken);
      }
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  Future<void> enableSound() async {
    _isSoundEnabled = true;
      final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_sound_enabled', true);
  }

  Future<void> disableSound() async {
    _isSoundEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_sound_enabled', false);
  }

  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
    return _isSoundEnabled;
  }

  // Récupérer les notifications depuis le backend
  Future<void> fetchNotifications() async {
    try {
      // print('[DEBUG] NOTIF - Début récupération des notifications depuis le backend');
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('token');
      if (jwt == null) {
        // print('[DEBUG] NOTIF - Aucun token JWT trouvé');
        return;
      }
      _dio.options.headers['Authorization'] = 'Bearer $jwt';
      final response = await _dio.get('/notification/list');
      // print('[DEBUG] NOTIF - Code réponse: \\${response.statusCode}');
      if (response.statusCode == 200 && response.data is List) {
        notifications = List<Map<String, dynamic>>.from(response.data);
        // print('[DEBUG] NOTIF - Notifications récupérées: \\${notifications.length}');
      } else {
        // print('[DEBUG] NOTIF - Réponse inattendue: \\${response.data}');
      }
    } catch (e, stack) {
      // print('[ERROR] NOTIF - Exception lors de la récupération: $e');
      // print('[ERROR] NOTIF - Stack: $stack');
    }
  }

  // Enregistrer le token FCM sur le serveur
  Future<void> registerDeviceWithServer(String token, int userId) async {
    try {
      // print('\n[DEBUG] NOTIF - 🔍 ===== DÉBUT ENREGISTREMENT TOKEN FCM =====');
      
      // 1. Récupération des données de base
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('token');
      // print('[DEBUG] NOTIF - 📱 Informations de base:');
      // print('  - User ID: $userId');
      // print('  - Device Type: ${Platform.operatingSystem}');
      // print('  - JWT Token présent: ${jwt != null}');
      
      if (jwt == null) {
        // print('[ERROR] NOTIF - ❌ Aucun token JWT trouvé');
        return;
      }
      
      // 2. Configuration de la requête
      // print('\n[DEBUG] NOTIF - ⚙️ Configuration de la requête:');
      // print('  - Base URL: ${_dio.options.baseUrl}');
      // print('  - Timeout: ${_dio.options.connectTimeout?.inSeconds}s');
      // print('  - Headers actuels:');
      _dio.options.headers['Authorization'] = 'Bearer $jwt';
      // print('\n[DEBUG] NOTIF - 🔑 Configuration du token JWT:');
      // print('  - JWT Token (début): ${jwt.substring(0, 20)}...');
      // print('  - Headers après ajout JWT:');
      _dio.options.headers.forEach((key, value) {
        // print('    $key: $value');
      });
      
      // 3. Vérification de l'utilisateur
      // print('\n[DEBUG] NOTIF - 👤 Vérification de l\'utilisateur:');
      // print('  - URL: ${_dio.options.baseUrl}/users/$userId');
      // print('  - Méthode: GET');
      try {
        final userResponse = await _dio.get('/users/$userId');
        // print('  - Status Code: ${userResponse.statusCode}');
        // print('  - Réponse: ${userResponse.data}');
    } catch (e) {
        // print('[ERROR] NOTIF - ❌ Erreur vérification utilisateur:');
        if (e is DioException) {
          // print('  - Type: ${e.type}');
          // print('  - Status: ${e.response?.statusCode}');
          // print('  - Message: ${e.message}');
          // print('  - Réponse: ${e.response?.data}');
        }
        return;
      }
      
      // 4. Préparation des données pour l'enregistrement
      // print('\n[DEBUG] NOTIF - 📦 Préparation des données:');
      final dataToSend = {
        'token': token,
        'user_id': userId,
        'device_type': Platform.operatingSystem,
      };
      // print('  - Données à envoyer:');
      // print('    - Token FCM: $token');
      // print('    - User ID: $userId');
      // print('    - Device Type: ${Platform.operatingSystem}');
      // print('  - JSON brut: ${json.encode(dataToSend)}');
      
      // 5. Envoi de la requête
      // print('\n[DEBUG] NOTIF - 🚀 Envoi de la requête:');
      // print('  - URL: ${_dio.options.baseUrl}/notification/register-token');
      // print('  - Méthode: POST');
      // print('  - Headers finaux:');
      _dio.options.headers.forEach((key, value) {
        // print('    $key: $value');
      });
      
      final response = await _dio.post('/notification/register-token', data: dataToSend);
      
      // 6. Traitement de la réponse
      // print('\n[DEBUG] NOTIF - ✅ Réponse reçue:');
      // print('  - Status Code: ${response.statusCode}');
      // print('  - Headers:');
      response.headers.forEach((name, values) {
        // print('    $name: ${values.join(", ")}');
      });
      // print('  - Corps de la réponse: ${response.data}');
      
      // print('\n[DEBUG] NOTIF - ✅ ===== FIN ENREGISTREMENT TOKEN FCM =====\n');
      
    } catch (e, stack) {
      // print('\n[ERROR] NOTIF - ❌ ERREUR DÉTAILLÉE:');
      // print('  - Type: ${e.runtimeType}');
      // print('  - Message: $e');
      
      if (e is DioException) {
        // print('  - DioError Type: ${e.type}');
        // print('  - DioError Message: ${e.message}');
        // print('  - DioError Status: ${e.response?.statusCode}');
        // print('  - DioError Headers:');
        // e.response?.headers.forEach((name, values) {
        //   print('    $name: ${values.join(", ")}');
        // });
        // print('  - DioError Data: ${e.response?.data}');
        
        if (e.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          // print('[DEBUG] NOTIF - 👋 Déconnexion de l\'utilisateur');
        }
      }
      
      // print('  - Stack Trace:');
      // print(stack);
      // print('\n[ERROR] NOTIF - ❌ ===== FIN ERREUR =====\n');
    }
  }
}
