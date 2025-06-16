import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../styles/header_styles.dart';
import '../../styles/icon_styles.dart';

class SecurityWidgets {
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required double screenWidth,
    required double screenHeight,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(screenHeight * 0.12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.01,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Colors.white, size: screenWidth * 0.06),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Sécurité',
                  style: HeaderStyles.headerTitle.copyWith(
                    fontSize: screenWidth * 0.06,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: IconStyles.iconNotifications,
                  iconSize: screenWidth * 0.06,
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                IconButton(
                  icon: IconStyles.iconMessage,
                  iconSize: screenWidth * 0.06,
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

  static Widget buildSecurityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall,
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildChangePasswordDialog({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController oldPasswordController,
    required TextEditingController newPasswordController,
    required TextEditingController confirmPasswordController,
    required VoidCallback onConfirm,
  }) {
    return AlertDialog(
      title: Text('Changer le mot de passe'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: oldPasswordController,
              decoration: InputDecoration(
                labelText: 'Ancien mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre ancien mot de passe';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: newPasswordController,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nouveau mot de passe';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez confirmer votre mot de passe';
                }
                if (value != newPasswordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Confirmer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildLogoutDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Déconnexion'),
      content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text('Déconnexion'),
        ),
      ],
    );
  }
}
