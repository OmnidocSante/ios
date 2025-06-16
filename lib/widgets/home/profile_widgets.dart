import 'package:flutter/material.dart';
import 'dart:io';
import '../../styles/colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../common_widgets.dart';

class ProfileWidgets {
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required double screenWidth,
    required double screenHeight,
  }) {
    return CommonWidgets.buildAppBar(
      context: context,
      title: 'Profil',
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: Colors.white, size: AppDimensions.getIconSize(context)),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  static Widget buildProfileImage({
    required BuildContext context,
    required String? userPhotoUrl,
    required File? imageFile,
    required String initial,
    required VoidCallback onDelete,
    required VoidCallback onPickImage,
  }) {
    return Container(
      width: AppDimensions.getAvatarSize(context) * 2,
      height: AppDimensions.getAvatarSize(context) * 2,
      child: Stack(
        children: [
          CircleAvatar(
            radius: AppDimensions.getAvatarSize(context),
            backgroundImage: imageFile != null
                ? FileImage(imageFile)
                : (userPhotoUrl != null && userPhotoUrl.isNotEmpty
                    ? NetworkImage(userPhotoUrl)
                    : null) as ImageProvider?,
            child: (imageFile == null &&
                    (userPhotoUrl == null || userPhotoUrl.isEmpty))
                ? Text(
                    initial.isNotEmpty ? initial[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: AppDimensions.getTitleSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: AppColors.primaryColor,
                    size: AppDimensions.getIconSize(context),
                  ),
                  onPressed: onPickImage,
                ),
                if (userPhotoUrl != null || imageFile != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: AppDimensions.getIconSize(context),
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppDimensions.getSpacing(context) / 2,
        horizontal: AppDimensions.getContentPadding(context),
      ),
      child: CommonWidgets.buildTextField(
        context: context,
        controller: controller,
        label: label,
        icon: icon,
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  static Widget buildSaveButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required double screenWidth,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppDimensions.getSpacing(context),
        horizontal: AppDimensions.getContentPadding(context),
      ),
      child: CommonWidgets.buildSaveButton(
        context: context,
        onPressed: onPressed,
        screenWidth: screenWidth,
      ),
    );
  }

  static Widget buildErrorDialog({
    required BuildContext context,
    required String errorMessage,
  }) {
    return CommonWidgets.buildErrorDialog(
      context: context,
      errorMessage: errorMessage,
    );
  }

  static Widget buildPatientInfoHeader({
    required BuildContext context,
    required String userName,
    required String userAvatar,
    required String userEmail,
    required VoidCallback onProfileTap,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(AppDimensions.getCardRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: AppDimensions.avatarSize,
              backgroundImage: userAvatar.isNotEmpty
                  ? NetworkImage(userAvatar)
                  : NetworkImage(
                          'https://omnidoc.ma/wp-content/uploads/2025/04/ambulance-tanger-flotte-vehicules-omnidoc-1.webp')
                      as ImageProvider,
            ),
          ),
          SizedBox(width: AppDimensions.getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.getTitle(context),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDimensions.getSpacing(context) * 0.2),
                Text(
                  userEmail,
                  style: AppTextStyles.getBodyText(context)
                      .copyWith(color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primaryColor),
            onPressed: onProfileTap,
            tooltip: 'Modifier le profil',
          ),
        ],
      ),
    );
  }
}
