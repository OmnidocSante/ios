import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../styles/card_styles.dart';
import '../styles/header_styles.dart';
import '../styles/button_styles.dart';
import '../styles/icon_styles.dart';
import '../api/api_service.dart';
import '../services/methods/security_methods.dart';
import '../widgets/home/security_widgets.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: SecurityWidgets.buildAppBar(
        context: context,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres de sécurité',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            SecurityWidgets.buildSecurityCard(
              title: 'Changer le mot de passe',
              subtitle: 'Modifier votre mot de passe actuel',
              icon: Icons.lock_outline,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      SecurityWidgets.buildChangePasswordDialog(
                    context: context,
                    formKey: _formKey,
                    oldPasswordController: _oldPasswordController,
                    newPasswordController: _newPasswordController,
                    confirmPasswordController: _confirmPasswordController,
                    onConfirm: () async {
                      if (_formKey.currentState!.validate()) {
                        await SecurityMethods.changePassword(
                          oldPassword: _oldPasswordController.text,
                          newPassword: _newPasswordController.text,
                          context: context,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            SecurityWidgets.buildSecurityCard(
              title: 'Déconnexion',
              subtitle: 'Se déconnecter de votre compte',
              icon: Icons.logout,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      SecurityWidgets.buildLogoutDialog(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
