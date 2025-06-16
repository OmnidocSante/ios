import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../styles/header_styles.dart';
import 'package:intl/intl.dart';

class NotificationWidgets {
  static Widget buildAppBar({
    required BuildContext context,
    required double maxWidth,
    required double contentPadding,
    required double iconSize,
    required int unreadCount,
    required int readCount,
    required VoidCallback onRefresh,
    required VoidCallback onMarkAllRead,
    required VoidCallback onDeleteAll,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(maxWidth * 0.2),
      child: Container(
        decoration: HeaderStyles.headerDecoration,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: contentPadding,
              vertical: contentPadding / 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: AppColors.textOnPrimary),
                      iconSize: iconSize,
                      padding: EdgeInsets.all(contentPadding / 2),
                      constraints: BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: contentPadding),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: maxWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textOnPrimary,
                        size: iconSize,
                      ),
                      padding: EdgeInsets.all(contentPadding / 2),
                      onSelected: (value) {
                        if (value == 'mark_all_read') {
                          onMarkAllRead();
                        } else if (value == 'delete_all') {
                          onDeleteAll();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'mark_all_read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read),
                              SizedBox(width: contentPadding),
                              Text('Tout marquer comme lu'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete_all',
                          child: Row(
                            children: [
                              Icon(Icons.delete_forever),
                              SizedBox(width: contentPadding),
                              Text('Supprimer tout'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: AppColors.textOnPrimary,
                        size: iconSize,
                      ),
                      padding: EdgeInsets.all(contentPadding / 2),
                      constraints: BoxConstraints(),
                      onPressed: onRefresh,
                    ),
                  ],
                ),
                SizedBox(height: contentPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$unreadCount non lues',
                      style: TextStyle(
                        fontSize: maxWidth * 0.04,
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: contentPadding * 2),
                    Text(
                      '$readCount lues',
                      style: TextStyle(
                        fontSize: maxWidth * 0.04,
                        color: AppColors.textOnPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildEmptyState(double maxWidth, double maxHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: maxWidth * 0.2,
            color: Colors.grey[400],
          ),
          SizedBox(height: maxHeight * 0.02),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: maxWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: maxHeight * 0.01),
          Text(
            'Vous n\'avez aucune notification pour le moment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: maxWidth * 0.035,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildNotificationCard({
    required BuildContext context,
    required Map<String, dynamic> notification,
    required double maxWidth,
    required double padding,
    required double fontSize,
    required bool isUnread,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }) {
    final message = notification['message'] ?? '';
    final date = DateTime.parse(
        notification['date'] ?? DateTime.now().toIso8601String());
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: padding),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white, size: maxWidth * 0.06),
      ),
      onDismissed: (direction) => onDelete(),
      child: Card(
        margin: EdgeInsets.only(bottom: padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(padding),
          side: isUnread
              ? BorderSide(color: AppColors.primaryColor, width: 2)
              : BorderSide.none,
        ),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getNotificationIcon(notification['type']),
                      color: isUnread
                          ? AppColors.primaryColor
                          : AppColors.textSecondary,
                      size: maxWidth * 0.06,
                    ),
                    SizedBox(width: padding),
                    Expanded(
                      child: Text(
                        notification['type'] == 'mission'
                            ? 'Nouvelle mission'
                            : 'Notification',
                        style: TextStyle(
                          color: isUnread
                              ? AppColors.primaryColor
                              : AppColors.textColor,
                          fontSize: maxWidth * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: maxWidth * 0.02,
                        height: maxWidth * 0.02,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: padding),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: fontSize * 1.2,
                  ),
                ),
                SizedBox(height: padding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: maxWidth * 0.04,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: padding / 2),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: maxWidth * 0.045,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'mission':
        return Icons.medical_services;
      case 'urgence':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
