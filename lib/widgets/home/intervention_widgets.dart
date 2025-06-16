import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/intervention_card.dart';
import 'package:provider/provider.dart';
import '../../services/mission_service.dart';
import 'package:intl/intl.dart';

class InterventionWidgets {
  static Widget buildAppBar({
    required String userName,
    required String userAvatar,
    required BuildContext context,
    required double avatarRadius,
  }) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      stretch: true,
      snap: true,
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.appBarBorderRadius),
          bottomRight: Radius.circular(AppDimensions.appBarBorderRadius),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        stretchModes: [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppDimensions.appBarBorderRadius),
              bottomRight: Radius.circular(AppDimensions.appBarBorderRadius),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.appBarTopPadding,
                    left: AppDimensions.appBarPadding,
                    right: AppDimensions.appBarPadding,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: AppDimensions.avatarBorderWidth,
                          ),
                        ),
                        child: Hero(
                          tag: 'user_avatar',
                          child: CircleAvatar(
                            radius: AppDimensions.avatarSize / 2,
                            backgroundImage: userAvatar.isNotEmpty
                                ? NetworkImage(userAvatar.startsWith('http')
                                    ? userAvatar
                                    : 'http://$userAvatar')
                                : NetworkImage(
                                        'https://omnidoc.ma/wp-content/uploads/2025/04/ambulance-tanger-flotte-vehicules-omnidoc-1.webp')
                                    as ImageProvider,
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bienvenue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppDimensions.welcomeTextSize,
                                )),
                            Text(userName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppDimensions.userNameTextSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications,
                                color: Colors.white,
                                size: AppDimensions.iconSize),
                            onPressed: () {
                              Navigator.pushNamed(context, '/notifications');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.appBarPadding,
                    vertical: AppDimensions.spacing / 2,
                  ),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Wrap(
                      spacing: 1.0,
                      runSpacing: 4.0,
                      children: [
                        buildStatusCard(
                            'Complété', 'completed', Colors.green, Icons.check),
                        buildStatusCard(
                            'Rejeté', 'rejected', Colors.red, Icons.close),
                        buildStatusCard('En cours', 'in_progress', Colors.blue,
                            Icons.timer),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildDateSelector({
    required int selectedDayIndex,
    required Function(int) onDateSelected,
    required int Function(DateTime) getMissionCount,
    required BuildContext context,
  }) {
    final missionService = Provider.of<MissionService>(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.getContentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppDimensions.getSpacing(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Interventions à venir',
                    style: AppTextStyles.getTitle(context)),
                GestureDetector(
                  onTap: () {
                    // Action pour "Voir tout"
                  },
                  child: Text(
                    'Voir tout',
                    style: AppTextStyles.getLinkText(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.getSpacing(context)),
            DateSelector(
              initialIndex: selectedDayIndex,
              onDateSelected: onDateSelected,
              getMissionCount: getMissionCount,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildMissionsList({
    required DateTime date,
    required List<Map<String, dynamic>> missions,
    required BuildContext context,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final missionService = Provider.of<MissionService>(context);
          final selectedDate = missionService.selectedDate;
          final missionsForSelectedDate = missions;

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
                        Navigator.pushNamed(
                          context,
                          '/mission_details',
                          arguments: {
                            'mission': mission,
                            'formattedTime': formattedTime,
                            'createdDate': createdDate,
                          },
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

  static Widget buildStatusCard(
      String title, String type, Color color, IconData icon) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth /
            (AppDimensions.isLargeScreen(context) ? 4 : 3.5);
        final missionService = Provider.of<MissionService>(context);
        final count = missionService.missions.where((mission) {
          final statut = mission['statut']?.toString().toLowerCase() ?? '';
          switch (type) {
            case 'completed':
              return statut == 'terminée' || statut == 'terminé';
            case 'rejected':
              return statut == 'annulée' || statut == 'annulé';
            case 'in_progress':
              return statut == 'en cours';
            default:
              return false;
          }
        }).length;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                count.toString(),
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
}
