import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../services/methods/chat_methods.dart';
import '../../widgets/common_widgets.dart';

class ChatWidgets {
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String title,
    required VoidCallback onBackPressed,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(AppDimensions.getAppBarHeight(context)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.getCardRadius(context)),
            bottomRight: Radius.circular(AppDimensions.getCardRadius(context)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.getContentPadding(context),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBackPressed,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.getAppBarTitle(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildMessageBubble({
    required BuildContext context,
    required Map<String, dynamic> message,
    required bool isMe,
    Key? key,
  }) {
    final hasImage = message['image'] != null && message['image'].isNotEmpty;
    final hasMessage = message['message']?.isNotEmpty ?? false;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = AppDimensions.isLargeScreen(context);
    final isTablet = AppDimensions.isTablet(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppDimensions.getSpacing(context),
        left: isMe ? AppDimensions.getSpacing(context) * 2 : 0,
        right: isMe ? 0 : AppDimensions.getSpacing(context) * 2,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(context, message),
          SizedBox(width: AppDimensions.getSpacing(context)),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen
                        ? screenWidth * 0.5
                        : (isTablet ? screenWidth * 0.6 : screenWidth * 0.7),
                  ),
                  padding:
                      EdgeInsets.all(AppDimensions.getContentPadding(context)),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.getCardRadius(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['sender'],
                        style: AppTextStyles.getSmallText(context).copyWith(
                          color: isMe ? Colors.white : AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasImage) ...[
                        SizedBox(height: AppDimensions.getSpacing(context)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.getCardRadius(context)),
                          child: Image.network(
                            message['image'],
                            width: isLargeScreen
                                ? screenWidth * 0.3
                                : (isTablet
                                    ? screenWidth * 0.4
                                    : screenWidth * 0.5),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ],
                      if (hasMessage) ...[
                        SizedBox(height: AppDimensions.getSpacing(context)),
                        Text(
                          message['message'],
                          style: AppTextStyles.getBodyText(context).copyWith(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                      SizedBox(height: AppDimensions.getSpacing(context) * 0.5),
                      Text(
                        message['time'],
                        style: AppTextStyles.getSmallText(context).copyWith(
                          color: isMe ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            SizedBox(width: AppDimensions.getSpacing(context)),
            _buildAvatar(context, message),
          ],
        ],
      ),
    );
  }

  static Widget _buildAvatar(
      BuildContext context, Map<String, dynamic> message) {
    final bool isMe = message['isCurrentUser'] ?? false;
    final avatarSize = AppDimensions.getAvatarSize(context);

    return FutureBuilder<String?>(
      future: ChatMethods.getUserPhoto(message['sender_id']?.toString() ?? ''),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(avatarSize / 2),
              child: Image.network(
                snapshot.data!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(context, message, isMe),
              ),
            ),
          );
        }
        return _buildDefaultAvatar(context, message, isMe);
      },
    );
  }

  static Widget _buildDefaultAvatar(
      BuildContext context, Map<String, dynamic> message, bool isMe) {
    final avatarSize = AppDimensions.getAvatarSize(context);
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryColor : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          (message['sender'] as String).characters.first.toUpperCase(),
          style: AppTextStyles.getBodyText(context).copyWith(
            color: isMe ? Colors.white : AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget buildMessageInput({
    required BuildContext context,
    required TextEditingController controller,
    required VoidCallback onSend,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.attach_file,
              color: AppColors.primaryColor,
              size: AppDimensions.getIconSize(context),
            ),
            onSelected: (value) {
              switch (value) {
                case 'camera':
                  onCamera();
                  break;
                case 'gallery':
                  onGallery();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'camera',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: AppColors.primaryColor),
                    SizedBox(width: AppDimensions.getSpacing(context)),
                    Text('Prendre une photo'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'gallery',
                child: Row(
                  children: [
                    Icon(Icons.photo_library, color: AppColors.primaryColor),
                    SizedBox(width: AppDimensions.getSpacing(context)),
                    Text('Choisir une photo'),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppDimensions.getSpacing(context)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(
                    AppDimensions.getTextFieldRadius(context)),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Tapez votre message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.getContentPadding(context),
                    vertical: AppDimensions.getSpacing(context),
                  ),
                ),
                style: AppTextStyles.getBodyText(context),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: AppDimensions.getIconSize(context),
              ),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyChat(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: AppDimensions.getIconSize(context) * 3,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppDimensions.getSpacing(context)),
          Text(
            'Aucun message',
            style: AppTextStyles.getBodyText(context).copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: AppDimensions.getSpacing(context) / 2),
          Text(
            'Commencez la conversation en envoyant un message',
            style: AppTextStyles.getSmallText(context).copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
