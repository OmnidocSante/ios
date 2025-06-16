import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../styles/button_styles.dart';
import '../styles/bottom_navigation_bar_styles.dart';
import '../styles/header_styles.dart';
import '../styles/icon_styles.dart';
import '../styles/card_styles.dart';
import '../widgets/intervention_card.dart';
import '../widgets/date_selector.dart';
import '../widgets/intervention_banner.dart';
import './profile_screen.dart';
import '../api/user_api.dart';
import '../api/mission_api.dart';
import '../api/api_service.dart';
import './patient_info_screen.dart';
import '../services/mission_service.dart';
import '../services/firebase_notification_service.dart';
import '../services/methods/home_service_methods.dart';
import '../widgets/home/home_widget_methods.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  // Cache et optimisation
  final Map<String, List<Map<String, dynamic>>> _missionsCache = {};
  final Map<DateTime, int> _missionCountCache = {};
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isAppActive = true;
  Timer? _refreshTimer;
  Timer? _notificationTimer;

  // État
  String userName = "";
  String userId = "";
  String userAvatar = "";
  String userEmail = "";
  String userPhone = "";
  String userGender = "";
  String userBirthDate = "";
  String userRole = "";
  String userStatus = "";
  int _selectedDayIndex = 2;
  int _selectedIndex = 0;
  Map<String, dynamic>? _nextMission;
  int? _ambulanceId;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Services
  late final FirebaseNotificationService _notificationService;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialiser le service de notification
    _notificationService = FirebaseNotificationService();
    
    if (!_isInitialized) {
      _initializeData();
      _setupTimers();
      _isInitialized = true;
    }
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    
    _initializeNotifications();
  }

  void _setupTimers() {
    // Annuler les timers existants si nécessaire
    _refreshTimer?.cancel();
    _notificationTimer?.cancel();

    // Rafraîchissement toutes les 2 secondes
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted && _isAppActive) {
        _checkAndUpdateMissions();
      }
    });

    _notificationTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted && _isAppActive) {
        _checkNotifications();
      }
    });
  }

  @override
  void dispose() {
    _updateUserStatus('inactif');
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _notificationTimer?.cancel();
    _clearCache();
    super.dispose();
  }

  void _clearCache() {
    _missionsCache.clear();
    _missionCountCache.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _isAppActive = true;
      _updateUserStatus('actif');
      _checkNotifications();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _isAppActive = false;
      _updateUserStatus('inactif');
    }
  }

  Future<void> _checkNotifications() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      final userId = userInfo['id'].toString();
      await HomeServiceMethods.checkNotifications(context, userId);
    } catch (e) {
      // Suppression du message d'erreur
    }
  }

  Future<void> _updateUserStatus(String status) async {
    if (!mounted) return;
    try {
    await HomeServiceMethods.updateUserStatus(status);
    } catch (e) {
      // Suppression du message d'erreur
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      final userInfo = await HomeServiceMethods.fetchUserInfo();
      setState(() {
        userName = '${userInfo['nom']} ${userInfo['prenom']}';
        userId = userInfo['id'].toString();
        userAvatar = userInfo['photo'] ?? '';
        userEmail = userInfo['email'] ?? '';
        userPhone = userInfo['téléphone'] ?? '';
        userGender = userInfo['genre'] ?? '';
        userBirthDate = userInfo['date_naissance'] ?? '';
        userRole = userInfo['rôle'] ?? '';
        userStatus = userInfo['statut'] ?? '';
        _ambulanceId = userInfo['ambulance_id'];
      });
    } catch (e) {
      // Suppression du message d'erreur
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    try {
      // Charger d'abord depuis le cache si disponible
      await _loadFromCache();

      // Charger les informations utilisateur en parallèle
      final userInfoFuture = _fetchUserInfo();
      final missionService =
          Provider.of<MissionService>(context, listen: false);
      missionService.setUserId(userId);

      // Exécuter les requêtes en parallèle
      await Future.wait([
        userInfoFuture,
        missionService.fetchMissions(),
        _checkNotifications(),
        _updateUserStatus('actif')
      ]);

      if (missionService.missions.isNotEmpty) {
        await _determineNextMission(missionService.missions);
      }

      // Sauvegarder dans le cache
      await _saveToCache(missionService.missions);
    } catch (e) {
      // En cas d'erreur, utiliser les données du cache
      await _loadFromCache();
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _determineNextMission(
      List<Map<String, dynamic>> missions) async {
    if (missions.isEmpty) {
      setState(() {
        _nextMission = null;
      });
      return;
    }

    try {
      final userInfo = await UserApi.getUserInfo();
      final userId = userInfo['id'].toString();
      final userRole = userInfo['rôle']?.toString().toLowerCase() ?? '';

      // Filtrer les missions selon le rôle et le statut
      final userMissions = missions.where((mission) {
        // Vérifier si l'utilisateur est assigné selon son rôle
        bool isAssigned = false;
        if (userRole == 'ambulancier') {
          isAssigned = mission['ambulancier_id']?.toString() == userId;
        } else if (userRole == 'médecin' || userRole == 'medecin') {
          isAssigned = mission['doctor_id']?.toString() == userId;
        } else if (userRole == 'infirmier') {
          isAssigned = mission['nurse_id']?.toString() == userId;
        }

        // Vérifier le statut de la mission
        final status = mission['statut']?.toString().toLowerCase() ?? '';
        final isValidStatus = status != 'terminée' && 
                            status != 'terminé' && 
                            status != 'annulée';

        return isAssigned && isValidStatus;
      }).toList();

      // Trier les missions par date
      userMissions.sort((a, b) {
        final dateA = parseMissionDate(a['date_mission']);
        final dateB = parseMissionDate(b['date_mission']);
        return dateA.compareTo(dateB);
      });

      // Prendre la première mission non terminée
      final nextMission = userMissions.isNotEmpty ? userMissions.first : null;

      if (mounted) {
        setState(() {
          _nextMission = nextMission;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nextMission = null;
        });
      }
    }
  }

  Future<void> _checkAndUpdateMissions() async {
    if (!mounted) return;

    try {
      final missionService =
          Provider.of<MissionService>(context, listen: false);
      final userInfo = await UserApi.getUserInfo();
      final userId = userInfo['id'].toString();

      await HomeServiceMethods.checkAndUpdateMissions(context, userId);
      // Rafraîchir la prochaine mission après chaque mise à jour
      setState(() {});
      await _determineNextMission(missionService.missions);
    } catch (e) {
      // Erreur silencieuse
    }
  }

  List<Map<String, dynamic>> _getUserMissions(List<Map<String, dynamic>> missions) {
    // Filtrer les missions de l'utilisateur
    final userMissions = missions.where((mission) {
      final isUserMission = mission['ambulancier_id']?.toString() == userId ||
          mission['doctor_id']?.toString() == userId ||
          mission['nurse_id']?.toString() == userId;
      
      return isUserMission; // Afficher toutes les missions de l'utilisateur
    }).toList();

    // Trier les missions par date (la plus récente en premier)
    userMissions.sort((a, b) {
      final dateA = parseMissionDate(a['date_mission']);
      final dateB = parseMissionDate(b['date_mission']);
      return dateB.compareTo(dateA); // Ordre décroissant
    });

    return userMissions;
  }

  Future<int> _getMissionCount(DateTime date) async {
    final dateKey = DateTime(date.year, date.month, date.day);
    if (_missionCountCache.containsKey(dateKey)) {
      return _missionCountCache[dateKey]!;
    }
    final missionService = Provider.of<MissionService>(context, listen: false);
    final userMissions = _getUserMissions(missionService.missions);
    final count = userMissions.where((mission) {
      final missionDate = parseMissionDate(mission['date_mission']);
      return missionDate.year == date.year &&
          missionDate.month == date.month &&
          missionDate.day == date.day;
    }).length;
    _missionCountCache[dateKey] = count;
    return count;
  }

  List<Map<String, dynamic>> _getFilteredMissions(DateTime selectedDate) {
    final dateKey = selectedDate.toString().split(' ')[0];
    if (_missionsCache.containsKey(dateKey)) {
      return _missionsCache[dateKey]!;
    }
    final missionService = Provider.of<MissionService>(context, listen: false);
    final userMissions = _getUserMissions(missionService.missions);
    final filteredMissions = userMissions.where((mission) {
      final missionDate = parseMissionDate(mission['date_mission']);
      final missionDay =
          DateTime(missionDate.year, missionDate.month, missionDate.day);
      final selectedDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      return missionDay.isAtSameMomentAs(selectedDay);
    }).toList();
    filteredMissions.sort((a, b) {
      final dateA = a['created_at'] != null
          ? DateTime.parse(a['created_at'])
          : parseMissionDate(a['date_mission']);
      final dateB = b['created_at'] != null
          ? DateTime.parse(b['created_at'])
          : parseMissionDate(b['date_mission']);
      return dateB.compareTo(dateA);
    });
    _missionsCache[dateKey] = filteredMissions;
    return filteredMissions;
  }

  // Ajouter cette méthode pour formater les dates
  String _formatDate(String? dateString) {
    return HomeServiceMethods.formatDate(dateString);
  }

  // Modifier cette méthode pour n'afficher que les heures et minutes
  String _formatTime(String? timeString) {
    return HomeServiceMethods.formatTime(timeString);
  }

  DateTime parseMissionDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      DateTime parsedDate;
      if (dateStr.contains('T')) {
        // Format ISO
        parsedDate = DateTime.parse(dateStr);
      } else if (dateStr.contains('/')) {
        // Format dd/MM/yyyy
        final parts = dateStr.split('/');
        parsedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        parsedDate = DateTime.parse(dateStr);
      }
      return parsedDate;
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final isTablet = maxWidth > 600;
        final isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackgroundColor,
          extendBody: false,
          extendBodyBehindAppBar: false,
          appBar: HomeWidgetMethods.buildAppBar(
            maxWidth,
            maxHeight,
            isTablet,
            isPortrait,
            userName: userName,
            userAvatar: userAvatar,
            context: context,
            searchController: _searchController,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildBody(maxWidth, maxHeight, isTablet, isPortrait),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              BottomNavigationBarStyles.buildBottomNavigationBar(
            context: context,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(
      double maxWidth, double maxHeight, bool isTablet, bool isPortrait) {
    final contentPadding = maxWidth * 0.02;
    final missionService = Provider.of<MissionService>(context);
    final missions = missionService.missions;
    final mediaQuery = MediaQuery.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        try {
          await missionService.fetchMissions();
          await _determineNextMission(missions);
        } catch (e) {
          // Erreur silencieuse
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(contentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTablet && !isPortrait) SizedBox.shrink(),
                    Text(
                      'Prochaine intervention',
                      style: TextStyle(
                        fontSize: maxWidth * (isTablet ? 0.025 : 0.045),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: contentPadding),
                    HomeWidgetMethods.buildNextMissionWidget(
                        _nextMission, maxWidth, contentPadding,
                        userId: userId),
                    SizedBox(height: contentPadding * 2),
                    _buildDateSelector(missions),
                    SizedBox(height: contentPadding * 2),
                    HomeWidgetMethods.buildMissionsHeader(
                        maxWidth, isTablet, userId),
                    SizedBox(height: contentPadding),
                  ],
                ),
              ),
              _buildMissionsList(contentPadding, maxWidth, maxHeight, missions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(List<Map<String, dynamic>> missions) {
    final userMissions = _getUserMissions(missions);
    final missionService = Provider.of<MissionService>(context);
    final selectedDate = missionService.selectedDate;
    final selectedDayIndex = selectedDate.difference(DateTime.now()).inDays + 2;

    return DateSelector(
      initialIndex: selectedDayIndex,
      onDateSelected: (index) async {
        final newDate = DateTime.now().add(Duration(days: index - 2));
        final missionService =
            Provider.of<MissionService>(context, listen: false);
        missionService.setSelectedDate(newDate);
        await missionService.fetchMissions();
        if (mounted) {
          setState(() {});
        }
      },
      getMissionCount: (date) {
        return userMissions.where((mission) {
          final missionDate = parseMissionDate(mission['date_mission']);
          return missionDate.day == date.day &&
              missionDate.month == date.month &&
              missionDate.year == date.year;
        }).length;
      },
    );
  }

  Widget _buildMissionsList(double contentPadding, double maxWidth,
      double maxHeight, List<Map<String, dynamic>> missions) {
    final missionService = Provider.of<MissionService>(context);
    final selectedDate = missionService.selectedDate;
    final userMissions = _getUserMissions(missions);
    
    // Filtrer les missions pour la date sélectionnée
    var missionsForSelectedDate = userMissions.where((mission) {
      final missionDate = parseMissionDate(mission['date_mission']);
      final missionDay = DateTime(missionDate.year, missionDate.month, missionDate.day);
      final selectedDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      return missionDay.isAtSameMomentAs(selectedDay);
    }).toList();

    // Trier les missions par date (la plus récente en premier)
    missionsForSelectedDate.sort((a, b) {
      final dateA = parseMissionDate(a['date_mission']);
      final dateB = parseMissionDate(b['date_mission']);
      return dateB.compareTo(dateA); // Tri décroissant
    });

    // Appliquer le filtre de recherche si nécessaire
    if (_searchQuery.isNotEmpty) {
      missionsForSelectedDate = missionsForSelectedDate.where((mission) {
        final searchableFields = [
          mission['type_mission']?.toString().toLowerCase() ?? '',
          mission['adresse']?.toString().toLowerCase() ?? '',
          mission['statut']?.toString().toLowerCase() ?? '',
          mission['cause']?.toString().toLowerCase() ?? '',
          mission['etat_mission']?.toString().toLowerCase() ?? '',
          mission['patient_id']?.toString().toLowerCase() ?? '',
        ];
        return searchableFields.any((field) => field.contains(_searchQuery));
      }).toList();
    }

    if (missionsForSelectedDate.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: contentPadding),
        child: HomeWidgetMethods.buildNoMissionsCard(maxWidth, contentPadding),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...missionsForSelectedDate.map((mission) {
          final title = mission['type_mission']?.toString() ?? 'Mission non spécifiée';
          final etatMission = mission['etat_mission']?.toString() ?? 'Non spécifié';
          final missionData = {
            ...mission,
            'title': '$title - État: $etatMission',
          };
          
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: contentPadding,
              vertical: contentPadding / 2,
            ),
            child: InterventionCard(
              intervention: missionData,
            ),
          );
        }).toList(),
        SizedBox(height: maxHeight * 0.1),
      ],
    );
  }

  Future<void> _saveToCache(List<Map<String, dynamic>> missions) async {
    try {
    await HomeServiceMethods.saveToCache(missions);
    } catch (e) {
      // Suppression du message d'erreur
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final missions = await HomeServiceMethods.loadFromCache();
      if (missions != null) {
        final missionService =
            Provider.of<MissionService>(context, listen: false);
        missionService.updateMissionsFromCache(missions);

        if (missions.isNotEmpty) {
          await _determineNextMission(missions);
        }
      }
    } catch (e) {
      // Suppression du message d'erreur
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      await safeRegisterFcmToken();
    } catch (e, stack) {
      // Erreur silencieuse
    }
  }

  Future<void> safeRegisterFcmToken() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (Platform.isIOS) {
        String? apnsToken;
        for (int i = 0; i < 5; i++) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(Duration(seconds: 2));
        }
        if (apnsToken == null) {
          return;
        }
      }
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null && fcmToken != null) {
        await _notificationService.registerDeviceWithServer(
          fcmToken,
          int.parse(userId),
        );
      } else {
        // Erreur silencieuse
      }
    } else {
      // Erreur silencieuse
    }
  }
}