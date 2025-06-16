import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class LoadScreen extends StatefulWidget {
  const LoadScreen({Key? key}) : super(key: key);

  @override
  _LoadScreenState createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // Start the animation
    _controller.forward();
    
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Attendre 2 secondes pour afficher l'écran de chargement
    await Future.delayed(const Duration(seconds: 4));

    // Vérifier si l'utilisateur est connecté
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (mounted) {
      if (token != null) {
        // Vérifier si la session doit être déconnectée
        if (await AuthService().shouldLogout()) {
          // Déconnecter l'utilisateur
          await AuthService().logout();
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }

        // Charger les informations utilisateur
        await Provider.of<UserService>(context, listen: false).loadUserInfo();

        // L'utilisateur est connecté, rediriger vers la page d'accueil
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // L'utilisateur n'est pas connecté, rediriger vers la page de connexion
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          
          // Animated Logo
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
