import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';

class LoginWidgets {
  static Widget buildLoginForm({
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required bool obscurePassword,
    required VoidCallback onTogglePassword,
    required VoidCallback onLogin,
    required bool isLoading,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Image.asset(
          'assets/images/logo.png',
          width: 200,
          height: 200,
        ),
        SizedBox(height: 24),
        Text(
          'Connexion',
          style: AppTextStyles.titleLarge,
        ),
        SizedBox(height: 32),
        // Champ Email
        TextField(
          controller: emailController,
          style: TextStyle(
            color: AppColors.textColor,
          ),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              color: AppColors.textColor,
            ),
            prefixIcon: Icon(
              Icons.person,
              color: AppColors.primaryColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        // Champ Mot de passe
        TextField(
          controller: passwordController,
          style: TextStyle(
            color: AppColors.textColor,
          ),
          obscureText: obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            labelStyle: TextStyle(
              color: AppColors.textColor,
            ),
            prefixIcon: Icon(
              Icons.lock,
              color: AppColors.primaryColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primaryColor,
              ),
              onPressed: onTogglePassword,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        // Bouton de connexion
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    'Se connecter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  static Widget buildLoginScreen({
    required Widget loginForm,
  }) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          // Formulaire de connexion
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 350,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: loginForm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
