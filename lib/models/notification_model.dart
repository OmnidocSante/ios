import '../utils/model_mixins.dart';

class NotificationModel with BaseModelMixin, NotificationMixin {
  @override
  final int id;
  final int userId;
  final int? missionId;
  @override
  final String message;
  @override
  final DateTime dateNotification;
  @override
  final String type;
  @override
  final String statut;
  @override
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.missionId,
    required this.message,
    required this.dateNotification,
    required this.type,
    required this.statut,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      missionId: json['mission_id'],
      message: json['message'] ?? '',
      dateNotification: DateTime.parse(json['date_notification']),
      type: json['type'] ?? '',
      statut: json['statut'] ?? 'nonlue',
      createdAt: DateTime.parse(json['créé_le']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...toBaseJson(),
      'user_id': userId,
      'mission_id': missionId,
      ...toNotificationJson(),
    };
  }
}
