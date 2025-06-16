import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/card_styles.dart';
import '../styles/bottom_navigation_bar_styles.dart';
import '../styles/header_styles.dart';
import '../styles/icon_styles.dart';
import '../widgets/date_selector.dart';
import '../widgets/intervention_card.dart';
import '../api/user_api.dart';
import 'package:provider/provider.dart';
import '../services/mission_service.dart';
import 'package:intl/intl.dart';
import '../styles/app_dimensions.dart';
import '../styles/app_text_styles.dart';
import '../widgets/common_widgets.dart';
import '../widgets/home/intervention_widgets.dart';
import '../screens/mission_details_screen.dart';

class InterventionsScreen extends StatefulWidget {
  @override
  _InterventionsScreenState createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends State<InterventionsScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedDayIndex = 2;
  int _selectedIndex = 1;
  String userName = "";
  String userId = "";
  String userAvatar = "";
  String userEmail = "";
  String userPhone = "";
  String userGender = "";
  String userBirthDate = "";
  String userRole = "";
  String userStatus = "";

  // Cache et optimisation
  final Map<DateTime, List<Map<String, dynamic>>> _missionsCache = {};
  final Map<String, int> _statusCountCache = {};
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isFirstLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!_isInitialized) {
        await _initializeData();
        _isInitialized = true;
      }
    });
  }

  Future<void> _initializeData() async {
    try {
      await _fetchUserInfo();
      final missionService =
          Provider.of<MissionService>(context, listen: false);
      missionService.setUserId(userId);
      await missionService.fetchMissions();
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      final userInfo = await UserApi.getUserInfo();
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
      });
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final missionService = Provider.of<MissionService>(context);
    final missions = missionService.missions;
    final selectedDate = missionService.selectedDate;
    final isLoading = missionService.isLoading;

    // Calculer l'index du jour sélectionné
    final selectedDayIndex = selectedDate.difference(DateTime.now()).inDays + 2;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          InterventionWidgets.buildAppBar(
            userName: userName,
            userAvatar: userAvatar,
            context: context,
            avatarRadius: AppDimensions.getAvatarSize(context) / 2,
          ),
          InterventionWidgets.buildDateSelector(
            selectedDayIndex: selectedDayIndex,
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
              final missions = missionService.missions;
              final activeMissions = missions.where((mission) {
                final statut =
                    mission['statut']?.toString().toLowerCase() ?? '';
                final isTerminee = statut == 'terminée' || statut == 'annulée';

                final missionDate = DateTime.parse(mission['date_mission'] ??
                    DateTime.now().toIso8601String());
                final missionDay = DateTime(
                    missionDate.year, missionDate.month, missionDate.day);
                final targetDay = DateTime(date.year, date.month, date.day);
                final isSelectedDay = missionDay.isAtSameMomentAs(targetDay);

                return !isTerminee && isSelectedDay;
              }).toList();

              return activeMissions.length;
            },
            context: context,
          ),
          _buildMissionsList(
            date: selectedDate,
            missions: missions,
            context: context,
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: AppDimensions.getBottomPadding(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarStyles.buildBottomNavigationBar(
        context: context,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildStatusCard(
      String title, String type, Color color, IconData icon) {
    final missionService = Provider.of<MissionService>(context);
    final missions = missionService.allMissions;

    int missionCount = 0;
    if (title == 'Complété') {
      missionCount = missions
          .where((mission) =>
              mission['statut']?.toString().toLowerCase() == 'terminée' ||
              mission['statut']?.toString().toLowerCase() == 'terminé')
          .length;
    } else if (title == 'Rejeté') {
      missionCount = missions
          .where((mission) =>
              mission['statut']?.toString().toLowerCase() == 'annulée' ||
              mission['statut']?.toString().toLowerCase() == 'annulé')
          .length;
    } else if (title == 'En cours') {
      missionCount = missions
          .where((mission) =>
              mission['statut']?.toString().toLowerCase() == 'en cours')
          .length;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth /
            (AppDimensions.isLargeScreen(context) ? 4 : 3.5);

        return Container(
          width: cardWidth,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.getSpacing(context),
            vertical: AppDimensions.getSpacing(context) * 0.8,
          ),
          margin: EdgeInsets.symmetric(
              horizontal: AppDimensions.getSpacing(context) / 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(AppDimensions.getCardRadius(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: AppTextStyles.getSmallText(context).copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppDimensions.getSpacing(context) / 4),
                  Icon(icon,
                      color: color,
                      size: AppDimensions.getIconSize(context) * 0.8),
                ],
              ),
              SizedBox(height: AppDimensions.getSpacing(context) / 4),
              Text(
                missionCount.toString(),
                style: AppTextStyles.getBodyText(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionsList({
    required DateTime date,
    required List<Map<String, dynamic>> missions,
    required BuildContext context,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final missionService = Provider.of<MissionService>(context);
          final selectedDate = missionService.selectedDate;
          var missionsForSelectedDate = missions.where((mission) {
            final missionDate = DateTime.parse(
                mission['date_mission'] ?? DateTime.now().toIso8601String());
            final missionDay =
                DateTime(missionDate.year, missionDate.month, missionDate.day);
            final selectedDay = DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day);
            return missionDay.isAtSameMomentAs(selectedDay);
          }).toList();

          // Trier les missions par date (la plus récente en premier)
          missionsForSelectedDate.sort((a, b) {
            final dateA = DateTime.parse(a['date_mission'] ?? DateTime.now().toIso8601String());
            final dateB = DateTime.parse(b['date_mission'] ?? DateTime.now().toIso8601String());
            return dateB.compareTo(dateA); // Tri décroissant
          });

          if (missionsForSelectedDate.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: AppDimensions.getIconSize(context) * 2,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: AppDimensions.getSpacing(context)),
                    Text(
                      'Aucune mission pour cette date',
                      style: AppTextStyles.getBodyText(context).copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    EdgeInsets.all(AppDimensions.getContentPadding(context)),
                child: Text(
                  DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate),
                  style: AppTextStyles.getTitle(context).copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              ...missionsForSelectedDate.map((mission) {
                final missionDate = DateTime.parse(mission['date_mission'] ??
                    DateTime.now().toIso8601String());
                final formattedTime = DateFormat('HH:mm').format(missionDate);
                final createdDate = mission['créé_le'] != null
                    ? DateFormat('dd/MM/yyyy HH:mm')
                        .format(DateTime.parse(mission['créé_le']))
                    : 'Date de création non disponible';

                return Padding(
                  padding: EdgeInsets.only(
                    left: AppDimensions.getContentPadding(context),
                    right: AppDimensions.getContentPadding(context),
                    bottom: AppDimensions.getSpacing(context),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.getCardRadius(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MissionDetailsScreen(),
                            settings: RouteSettings(
                              arguments: {
                                'mission': {
                                  'type_mission': mission['type_mission'],
                                  'date_mission': mission['date_mission'],
                                  'heure_depart': mission['heure_depart'],
                                  'heure_arrivee': mission['heure_arrivee'],
                                  'heure_redepart': mission['heure_redepart'],
                                  'heure_fin': mission['heure_fin'],
                                  'heure_affectation':
                                      mission['heure_affectation'],
                                  'adresse': mission['adresse'],
                                  'cause': mission['cause'],
                                  'urgence': mission['urgence'],
                                  'etat_mission': mission['etat_mission'],
                                  'statut': mission['statut'],
                                  'prix': mission['prix'],
                                  'paiement': mission['paiement'],
                                  'paye': mission['paye'],
                                  'bon_de_commande': mission['bon_de_commande'],
                                  'description': mission['description'],
                                  'demande_materiel':
                                      mission['demande_materiel'],
                                  'patient_id': mission['patient_id'],
                                  'id': mission['id'],
                                },
                                'formattedTime': formattedTime,
                                'createdDate': createdDate,
                              },
                            ),
                          ),
                        );
                      },
                      child: InterventionCard(
                        intervention: {
                          'title': mission['type_mission'] ??
                              'Mission non spécifiée',
                          'date_mission': mission['date_mission'],
                          'isMaterialRequest':
                              mission['type_mission'] == 'demande de matériel',
                          'isUrgent': mission['urgence'] == 1 ||
                              mission['etat_mission'] == 'urgente',
                          'createdAt': mission['created_at'],
                          'adresse':
                              mission['adresse'] ?? 'Adresse non spécifiée',
                          'prix': mission['prix'] ?? '0.00',
                          'paiement': mission['paiement'] ?? 'Non spécifié',
                          'paye': mission['paye'] == 1 ? 'Oui' : 'Non',
                          'bon_de_commande': mission['bon_de_commande'] ??
                              'Bon de commande non spécifié',
                          'cause': mission['cause'] ?? 'Cause non spécifiée',
                          'urgence':
                              mission['urgence'] == 1 ? 'Urgent' : 'Non urgent',
                          'statut':
                              mission['statut']?.toString().toLowerCase() ??
                                  'non spécifié',
                          'etat_mission': mission['etat_mission']
                                  ?.toString()
                                  .toLowerCase() ??
                              'non spécifié',
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
        childCount: 1,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
