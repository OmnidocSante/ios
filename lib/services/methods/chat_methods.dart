import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../api/chat_api.dart';
import '../../api/user_api.dart';

class ChatMethods {
  static IO.Socket? _socket;
  static final Map<String, String> _userNameCache = {};
  static final Map<String, String> _userPhotoCache = {};
  static final Set<String> _loadingImages = {};
  static bool _shouldAnimateScroll = true;
  static Timer? _refreshTimer;
  static bool _isAppActive = true;
  static int _currentPage = 1;
  static const int _messagesPerPage = 20;
  static bool _isLoadingMore = false;

  static Future<void> initializeChat(
    String? missionId,
    Function(Map<String, dynamic>) onNewMessage,
  ) async {
    if (missionId == null) return;

    ChatApi.initializeSocket();
    _socket = ChatApi.socket;

    _socket?.on('message', (data) async {
      if (data['mission_id'].toString() == missionId) {
        onNewMessage(data);
      }
    });

    _socket?.onConnect((_) {
      _isAppActive = true;
    });

    _socket?.onDisconnect((_) {
      _isAppActive = false;
      if (_socket != null) {
        Future.delayed(Duration(seconds: 2), () {
          _socket!.connect();
        });
      }
    });

    _startRefreshTimer();
  }

  static void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isAppActive) {
        _socket?.connect();
      }
    });
  }

  static void updateAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == AppLifecycleState.resumed;
  }

  static Future<List<Map<String, dynamic>>> loadMessageHistory(
    String? missionId,
  ) async {
    if (missionId == null) return [];

    try {
      final messages = await ChatApi.getMessagesByMissionId(
        missionId,
        page: _currentPage,
        pageSize: _messagesPerPage,
      );

      // Préchargement des informations utilisateurs
      final userIds =
          messages.map((msg) => msg['sender_id'].toString()).toSet();
      await Future.wait([
        ...userIds.map((userId) => _preloadUserInfo(userId)),
      ]);

      return messages;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _preloadUserInfo(String userId) async {
    try {
      final userInfo = await UserApi.getUserInfo();
      if (userInfo != null) {
        // Mise en cache du nom
        final name =
            '${userInfo['nom'] ?? ''} ${userInfo['prenom'] ?? ''}'.trim();
        if (name.isNotEmpty) {
          _userNameCache[userId] = name;
        }

        // Mise en cache de la photo
        if (userInfo['photo_url'] != null && userInfo['photo_url'].isNotEmpty) {
          _userPhotoCache[userId] = userInfo['photo_url'];
        }
      }
    } catch (e) {
    }
  }

  static Future<String> getUserName(String userId, String defaultName) async {
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }

    try {
      final userInfo = await UserApi.getUserInfo();
      if (userInfo == null) {
        return defaultName;
      }
      final name =
          '${userInfo['nom'] ?? ''} ${userInfo['prenom'] ?? ''}'.trim();
      if (name.isEmpty) {
        return defaultName;
      }
      _userNameCache[userId] = name;
      return name;
    } catch (e) {
      return defaultName;
    }
  }

  static Future<String?> getUserPhoto(String userId) async {
    if (_userPhotoCache.containsKey(userId)) {
      return _userPhotoCache[userId];
    }

    try {
      final userInfo = await UserApi.getUserInfo();
      if (userInfo != null &&
          userInfo['photo_url'] != null &&
          userInfo['photo_url'].isNotEmpty) {
        _userPhotoCache[userId] = userInfo['photo_url'];
        return userInfo['photo_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String formatMessageTime(dynamic timestamp) {
    try {
      if (timestamp != null) {
        return DateTime.parse(timestamp.toString())
            .toString()
            .substring(11, 16);
      }
      return DateTime.now().toString().substring(11, 16);
    } catch (e) {
      return DateTime.now().toString().substring(11, 16);
    }
  }

  static Future<void> sendMessage({
    required String sender,
    required String message,
    required String userId,
    required String missionId,
  }) async {
    try {
      await ChatApi.sendMessage(
        sender: sender,
        message: message,
        userId: userId,
        missionId: missionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> sendImage(
    String missionId,
    String userId,
    String userName,
  ) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        final fileUrl = await ChatApi.uploadFile(image.path);
        await ChatApi.sendMessage(
          sender: userName,
          message: 'Image envoyée',
          userId: userId,
          missionId: missionId,
          imageUrl: fileUrl,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> takePhoto(
    String missionId,
    String userId,
    String userName,
  ) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        final fileUrl = await ChatApi.uploadFile(image.path);
        await ChatApi.sendMessage(
          sender: userName,
          message: 'Photo prise avec la caméra',
          userId: userId,
          missionId: missionId,
          imageUrl: fileUrl,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static void handleImageLoaded(String imageUrl) {
    _loadingImages.remove(imageUrl);
  }

  static void dispose() {
    _refreshTimer?.cancel();
    ChatApi.disconnectSocket();
    _socket = null;
    _userNameCache.clear();
    _userPhotoCache.clear();
    _loadingImages.clear();
  }

  static bool get isLoadingMore => _isLoadingMore;
  static set isLoadingMore(bool value) => _isLoadingMore = value;

  static int get currentPage => _currentPage;
  static set currentPage(int value) => _currentPage = value;

  static bool get isAppActive => _isAppActive;
}