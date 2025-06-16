import 'package:flutter/material.dart';
import 'dart:io';
import '../styles/colors.dart';
import '../styles/text_styles.dart' as old_styles;
import '../styles/icon_styles.dart';
import '../styles/app_dimensions.dart';
import '../styles/app_text_styles.dart';
import '../enums/notification_type.dart';

class CommonWidgets {
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color backgroundColor = AppColors.primaryColor,
    double elevation = 0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 1000;
    final double appBarHeight = isLargeScreen ? 80 : (isTablet ? 70 : 56);
    final double titleFontSize = isLargeScreen ? 28 : (isTablet ? 24 : 20);
    final double iconSize = isLargeScreen ? 32 : (isTablet ? 28 : 24);

    // Forcer la couleur blanche sur toutes les icônes de l'AppBar
    Widget? fixedLeading = leading;
    if (leading is IconButton) {
      fixedLeading = IconButton(
        icon: Icon(
          (leading.icon as Icon).icon,
          size: iconSize,
          color: Colors.white,
        ),
        onPressed: leading.onPressed,
        tooltip: leading.tooltip,
      );
    }

    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.getTitle(context).copyWith(
          color: Colors.white,
          fontSize: titleFontSize,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: fixedLeading,
      actions: actions?.map((w) {
        if (w is IconButton) {
          return IconButton(
            icon: Icon(
              (w.icon as Icon).icon,
              size: iconSize,
              color: Colors.white,
            ),
            onPressed: w.onPressed,
            tooltip: w.tooltip,
          );
        }
        return w;
      }).toList(),
      toolbarHeight: appBarHeight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.getCardRadius(context)),
          bottomRight: Radius.circular(AppDimensions.getCardRadius(context)),
        ),
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
    bool obscureText = false,
    int? maxLines = 1,
  }) {
    return Container(
      height: AppDimensions.getTextFieldHeight(context),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: AppDimensions.getIconSize(context)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                AppDimensions.getTextFieldRadius(context)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.getContentPadding(context),
            vertical: AppDimensions.getSpacing(context),
          ),
        ),
        style: TextStyle(fontSize: AppDimensions.getBodyTextSize(context)),
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
      ),
    );
  }

  static Widget buildErrorDialog({
    required BuildContext context,
    required String errorMessage,
  }) {
    return AlertDialog(
      title: Text(
        'Erreur',
        style: AppTextStyles.getTitle(context),
      ),
      content: Text(
        errorMessage,
        style: AppTextStyles.getBodyText(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'OK',
            style: AppTextStyles.getButtonText(context).copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildSaveButton({
    required BuildContext context,
    required VoidCallback onPressed,
    String text = 'Enregistrer',
    required double screenWidth,
  }) {
    return Container(
      width: AppDimensions.isLargeScreen(context)
          ? screenWidth * 0.4
          : (AppDimensions.isTablet(context)
              ? screenWidth * 0.6
              : screenWidth * 0.8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: AppDimensions.getButtonPadding(context),
            horizontal: AppDimensions.getButtonPadding(context) * 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.getButtonRadius(context)),
          ),
          minimumSize: Size(
            double.infinity,
            AppDimensions.getButtonHeight(context),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.getButtonText(context),
        ),
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

  static Widget buildBottomNavigationBar({
    required BuildContext context,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: 'Interventions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
      ],
    );
  }
}

class NotificationPopup extends StatelessWidget {
  final String title;
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const NotificationPopup({
    Key? key,
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: Text('OK'),
        ),
      ],
    );
  }
}
