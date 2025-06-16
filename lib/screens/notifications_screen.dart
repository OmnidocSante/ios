import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/app_dimensions.dart';
import '../styles/app_text_styles.dart';
import '../services/firebase_notification_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../api/user_api.dart';
import '../api/notification_api.dart';
import 'dart:async';
import '../widgets/common_widgets.dart';
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String? _userId;
  Timer? _refreshTimer;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isInitialized) {
        _loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    try {
      final userInfo = await UserApi.getUserInfo();
      if (!mounted) return;
      setState(() {
        _userId = userInfo['id'].toString();
        _isInitialized = true;
      });
      await _loadNotifications();
    } catch (e) {
      // Erreur silencieuse
    }
  }

  Future<void> _loadNotifications() async {
    if (!mounted || _userId == null || !_isInitialized) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final notifications = await NotificationApi.getNotifications();
      if (!mounted) return;
      final filteredNotifications = notifications.where((notification) {
        if (notification['user_id'] == null) return false;
        final notificationUserId = notification['user_id'].toString();
        if (notificationUserId != _userId) return false;
        if (notification['message'] == null || 
            notification['message'].toString().trim().isEmpty) return false;
        return true;
      }).toList();
      final notificationsCopy = filteredNotifications.map((notification) => 
        Map<String, dynamic>.from(notification)
      ).toList();
      notificationsCopy.sort((a, b) {
        DateTime dateA;
        DateTime dateB;
        try {
          dateA = a['created_at'] != null 
              ? DateTime.parse(a['created_at']) 
              : DateTime.now();
        } catch (e) {
          dateA = DateTime.now();
        }
        try {
          dateB = b['created_at'] != null 
              ? DateTime.parse(b['created_at']) 
              : DateTime.now();
        } catch (e) {
          dateB = DateTime.now();
        }
        return dateB.compareTo(dateA);
      });
      setState(() {
        _notifications = notificationsCopy;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // Erreur silencieuse
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    if (!mounted || _userId == null) return;
    try {
      final notificationIndex = _notifications.indexWhere((n) => n['id'].toString() == notificationId);
      if (notificationIndex == -1) return;
      final notification = _notifications[notificationIndex];
      if (notification['statut'] == 'lue') return;
      setState(() {
        _notifications[notificationIndex]['statut'] = 'lue';
      });
      try {
        String formattedDate;
        try {
          if (notification['date_notification'] != null) {
            final date = DateTime.parse(notification['date_notification']);
            formattedDate = DateFormat('yyyy-MM-dd').format(date);
          } else {
            formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          }
        } catch (e) {
          formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        }
        final updatedData = {
          'id': notification['id'],
          'user_id': notification['user_id'],
          'mission_id': notification['mission_id'],
          'message': notification['message'],
          'type': notification['type'],
          'statut': 'lue',
          'créé_le': notification['créé_le'],
          'date_notification': formattedDate,
        };
        await NotificationApi.updateNotification(
          notificationId,
          updatedData,
        );
      } catch (e) {
        // Erreur silencieuse
      }
    } catch (e) {
      // Erreur silencieuse
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = AppDimensions.isLargeScreen(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: CommonWidgets.buildAppBar(
        context: context,
        title: 'Notifications',
      ),
      body: !_isInitialized
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : Container(
                          constraints: isLargeScreen ? BoxConstraints(maxWidth: 800) : null,
                          margin: EdgeInsets.symmetric(
                            horizontal: AppDimensions.getContentPadding(context),
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.getSpacing(context),
                            ),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return _buildNotificationCard(
                                context: context,
                                notification: notification,
                              );
                            },
                          ),
                        ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: AppDimensions.getIconSize(context) * 3,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppDimensions.getSpacing(context)),
          Text(
            'Aucune notification',
            style: AppTextStyles.getTitle(context).copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: AppDimensions.getSpacing(context) / 2),
          Text(
            'Vous n\'avez pas encore de notifications',
            style: AppTextStyles.getBodyText(context).copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required Map<String, dynamic> notification,
  }) {
    final isUnread = notification['statut'] == 'nonlue';
    final date = notification['created_at'] != null
        ? DateTime.parse(notification['created_at'])
        : DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
    final message = notification['message']?.toString() ?? '';
    final title = notification['titre']?.toString() ?? 'Notification';
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.getSpacing(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.getCardRadius(context)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.getCardRadius(context)),
        onTap: () {
          if (isUnread) {
            _markNotificationAsRead(notification['id'].toString());
          }
        },
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnread ? AppColors.primaryColor : Colors.transparent,
                ),
              ),
              SizedBox(width: AppDimensions.getSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.getBodyText(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnread ? AppColors.primaryColor : null,
                      ),
                    ),
                    if (message.isNotEmpty) ...[
                      SizedBox(height: AppDimensions.getSpacing(context) / 2),
                      Text(
                        message,
                        style: AppTextStyles.getBodyText(context),
                      ),
                    ],
                    SizedBox(height: AppDimensions.getSpacing(context) / 2),
                    Text(
                      formattedDate,
                      style: AppTextStyles.getSmallText(context).copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
