import 'package:flutter/material.dart';
import 'routes.dart'; // Import routes from routes.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'styles/colors.dart';
import 'screens/load_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/interventions_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/security_screen.dart';
import 'package:provider/provider.dart';
import 'services/mission_service.dart';
import 'services/user_service.dart';
import 'screens/patient_info_screen.dart';
import 'screens/mission_details_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/firebase_notification_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  // Initialiser Firebase
  try {
    await Firebase.initializeApp();
  } catch (e, stack) {
  }

  final notificationService = FirebaseNotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseNotificationService>(
          create: (_) => notificationService,
        ),
        ChangeNotifierProvider(create: (_) => MissionService()),
        ChangeNotifierProvider(create: (_) => UserService()),
      ],
      child: MyApp(
        isDarkMode: isDarkMode,
        notificationService: notificationService,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final FirebaseNotificationService notificationService;

  MyApp({Key? key, required this.isDarkMode, required this.notificationService})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.omnidoc.regulation/notification');

  @override
  void initState() {
    super.initState();
    _setupNotificationChannel();
  }

  void _setupNotificationChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'openScreen') {
        final Map<dynamic, dynamic> data = call.arguments;
        if (data['type'] == 'mission') {
          widget.notificationService.navigatorKey.currentState?.pushNamed(
            '/mission_details',
            arguments: data['missionId'],
          );
        } else if (data['type'] == 'chat') {
          widget.notificationService.navigatorKey.currentState?.pushNamed(
            '/chat',
            arguments: data['chatId'],
          );
        } else {
          widget.notificationService.navigatorKey.currentState?.pushNamed(
            '/notifications',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.notificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Transport Santé',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
        cardColor: AppColors.surfaceColor,
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryColor,
          secondary: AppColors.primaryLight,
          error: AppColors.errorColor,
          background: AppColors.scaffoldBackgroundColor,
          surface: AppColors.surfaceColor,
          onPrimary: AppColors.textOnPrimary,
          onSecondary: AppColors.textOnPrimary,
          onBackground: AppColors.textColor,
          onSurface: AppColors.textColor,
          onError: AppColors.textOnPrimary,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackgroundColor,
        cardColor: AppColors.darkCardColor,
        primaryColor: AppColors.darkPrimaryColor,
        colorScheme: ColorScheme.dark(
          primary: AppColors.darkPrimaryColor,
          secondary: AppColors.darkSecondaryColor,
          error: AppColors.errorColor,
          background: AppColors.darkBackgroundColor,
          surface: AppColors.darkCardColor,
          onPrimary: AppColors.textOnPrimary,
          onSecondary: AppColors.textOnPrimary,
          onBackground: AppColors.darkTextColor,
          onSurface: AppColors.darkTextColor,
          onError: AppColors.textOnPrimary,
        ),
      ),
      themeMode: widget.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // home: LoadScreen(), // SUPPRIMÉ pour éviter le conflit avec la route '/'
      routes: appRoutes,
    );
  }
}