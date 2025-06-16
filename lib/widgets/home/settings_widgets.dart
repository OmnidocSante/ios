import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../widgets/common_widgets.dart';
import '../../api/user_api.dart';

class SettingsWidgets {
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String userName,
    required String userAvatar,
    required VoidCallback onProfileTap,
    required double screenWidth,
    required double screenHeight,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.appBarBorderRadius),
            bottomRight: Radius.circular(AppDimensions.appBarBorderRadius),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.appBarPadding,
              vertical: AppDimensions.spacing,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: AppDimensions.avatarBorderWidth,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: AppDimensions.avatarSize / 2,
                      backgroundImage: userAvatar.isNotEmpty
                          ? NetworkImage(UserApi.getAvatarUrl(userAvatar))
                          : NetworkImage(
                                  'https://omnidoc.ma/wp-content/uploads/2025/04/ambulance-tanger-flotte-vehicules-omnidoc-1.webp')
                              as ImageProvider,
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacing),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue',
                        style: TextStyle(
                          fontSize: AppDimensions.welcomeTextSize,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: AppDimensions.userNameTextSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.notifications,
                      color: Colors.white, size: AppDimensions.iconSize),
                  padding: EdgeInsets.all(AppDimensions.spacing / 2),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                SizedBox(width: AppDimensions.spacing / 2),
                IconButton(
                  icon: Icon(Icons.message,
                      color: Colors.white, size: AppDimensions.iconSize),
                  padding: EdgeInsets.all(AppDimensions.spacing / 2),
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildSettingsCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius:
            BorderRadius.circular(AppDimensions.getCardRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon,
            color: AppColors.primaryColor,
            size: AppDimensions.getIconSize(context)),
        title: Text(title, style: AppTextStyles.getBodyText(context)),
        trailing: Icon(Icons.chevron_right,
            color: AppColors.textColor,
            size: AppDimensions.getIconSize(context)),
        onTap: onTap,
      ),
    );
  }

  static Widget buildLogoutButton({
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorColor,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.getContentPadding(context) * 2,
            vertical: AppDimensions.getSpacing(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.getButtonRadius(context)),
          ),
        ),
        child: Text(
          'Déconnexion',
          style: AppTextStyles.getButtonText(context),
        ),
      ),
    );
  }

  static Widget buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.getTitle(context),
    );
  }

  static Widget buildSettingsSection({
    required String title,
    required List<Widget> children,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(title, context),
        SizedBox(height: AppDimensions.getSpacing(context)),
        ...children,
      ],
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
    return CommonWidgets.buildTextField(
      context: context,
      controller: controller,
      label: label,
      icon: icon,
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  static Widget buildSaveButton({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return CommonWidgets.buildSaveButton(
      context: context,
      onPressed: onPressed,
      screenWidth: MediaQuery.of(context).size.width,
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

  static Widget buildQuickAccessRow({
    required BuildContext context,
    required VoidCallback onNotificationsTap,
    required VoidCallback onProfileTap,
  }) {
    final double iconSize = AppDimensions.getIconSize(context) * 1.2;
    final double buttonSize = 56;
    final double spacing = AppDimensions.getSpacing(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickButton(
          context: context,
          icon: Icons.notifications,
          label: 'Notifications',
          color: AppColors.primaryColor,
          iconColor: Colors.white,
          onTap: onNotificationsTap,
          iconSize: iconSize,
          buttonSize: buttonSize,
        ),
        _buildQuickButton(
          context: context,
          icon: Icons.person,
          label: 'Profil',
          color: AppColors.primaryColor,
          iconColor: Colors.white,
          onTap: onProfileTap,
          iconSize: iconSize,
          buttonSize: buttonSize,
        ),
      ],
    );
  }

  static Widget _buildQuickButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    required double iconSize,
    required double buttonSize,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: color,
            padding: EdgeInsets.all(0),
            elevation: 4,
            minimumSize: Size(buttonSize, buttonSize),
            maximumSize: Size(buttonSize, buttonSize),
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.getSmallText(context)
              .copyWith(color: AppColors.primaryColor),
        ),
      ],
    );
  }
}
