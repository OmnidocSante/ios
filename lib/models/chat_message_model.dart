import 'package:flutter/material.dart';
import '../api/user_api.dart';

class ChatMessage {
  final String sender;
  final String message;
  final String timestamp;
  final String? imageUrl;
  final bool isCurrentUser;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    this.imageUrl,
    required this.isCurrentUser,
  });

  factory ChatMessage.fromJson(
      Map<String, dynamic> json, String currentUserId) {
    return ChatMessage(
      sender: json['sender'] ?? 'Inconnu',
      message: json['message'] ?? '',
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toString(),
      imageUrl: json['image_url'],
      isCurrentUser: json['sender_id']?.toString() == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
      'image_url': imageUrl,
      'isCurrentUser': isCurrentUser,
    };
  }
}
