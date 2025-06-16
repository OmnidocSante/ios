import 'package:flutter/material.dart';
import 'package:regulation_assiste/screens/load_screen.dart';
import 'package:regulation_assiste/screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/interventions_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/security_screen.dart';
import 'screens/patient_info_screen.dart';
import 'screens/profile_screen.dart';

// Définition des routes
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => LoadScreen(), // Page de chargement
  '/login': (context) => LoginScreen(), // Page de connexion
  '/home': (context) => HomeScreen(), // Accueil
  '/interventions': (context) => InterventionsScreen(), // Interventions
  '/reports': (context) => ReportsScreen(), // Rapports
  '/settings': (context) => SettingsScreen(), // Paramètres
  '/notifications': (context) => NotificationsScreen(), // Notifications
  '/chat': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return ChatScreen(missionId: args is String ? args : '0');
  }, // Chat
  '/security': (context) => SecurityScreen(), // Sécurité
  '/patient_info': (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return PatientInfoScreen(
      patientId: args?['patientId'] as int?,
      missionId: args?['missionId'] as int?,
    );
  },
  '/mission_details': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final missionId = args is int ? args : null;
    return PatientInfoScreen(
      patientId: null,
      missionId: missionId,
    );
  }, // Détails de la mission
  '/profile': (context) => ProfileScreen(), // Profil
};
