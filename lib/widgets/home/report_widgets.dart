import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../styles/card_styles.dart';
import '../../styles/header_styles.dart';
import '../../styles/icon_styles.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/intervention_card.dart';
import 'package:provider/provider.dart';
import '../../services/mission_service.dart';
import '../../services/methods/report_methods.dart';
import 'package:intl/intl.dart';
import '../../styles/app_dimensions.dart';

class ReportWidgets {
  static PreferredSizeWidget buildAppBar({
    required String userName,
    required String userAvatar,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PreferredSize(
      preferredSize: Size.fromHeight(
          isLandscape ? screenHeight * 0.2 : screenHeight * 0.15),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.appBarBorderRadius),
            bottomRight: Radius.circular(AppDimensions.appBarBorderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.01,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: isTablet ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Hero(
                            tag: 'user_avatar_report',
                            child: CircleAvatar(
                              radius: isTablet
                                  ? screenWidth * 0.04
                                  : screenWidth * 0.06,
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
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: isTablet
                                      ? screenWidth * 0.02
                                      : screenWidth * 0.04,
                                  color: Colors.white70,
                                ),
                                child: Text('Bienvenue'),
                              ),
                              AnimatedDefaultTextStyle(
                                duration: Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: isTablet
                                      ? screenWidth * 0.025
                                      : screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                child: Text(
                                  userName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              child: IconButton(
                                icon: Icon(Icons.notifications,
                                    color: Colors.white,
                                    size: isTablet
                                        ? screenWidth * 0.03
                                        : screenWidth * 0.06),
                                padding: EdgeInsets.all(screenWidth * 0.01),
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/notifications');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Padding(
      padding: EdgeInsets.only(
        top: screenHeight * 0.02,
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize:
                      isTablet ? screenWidth * 0.025 : screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
                child: Text('Rapports'),
              ),
              GestureDetector(
                onTap: () {
                  // Action pour "Voir tout"
                },
                child: AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize:
                        isTablet ? screenWidth * 0.02 : screenWidth * 0.035,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  child: Text('Voir tout'),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: DateSelector(
              key: ValueKey<int>(selectedDayIndex),
              initialIndex: selectedDayIndex,
              onDateSelected: onDateSelected,
              getMissionCount: getMissionCount,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyState(double screenWidth, double screenHeight) {
    final isTablet = screenWidth > 600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: 1.0,
            child: Icon(
              Icons.calendar_today_outlined,
              size: isTablet ? screenWidth * 0.08 : screenWidth * 0.15,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: isTablet ? screenWidth * 0.025 : screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            child: Text('Aucune mission disponible'),
          ),
          SizedBox(height: screenHeight * 0.01),
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: isTablet ? screenWidth * 0.02 : screenWidth * 0.035,
              color: Colors.grey[500],
            ),
            child: Text(
              'Vous n\'avez aucune mission planifiée pour le moment.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildMissionsList({
    required DateTime selectedDate,
    required List<Map<String, dynamic>> missions,
    required Function(Map<String, dynamic>) onGenerateReport,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final missionService = Provider.of<MissionService>(context);

    // Utiliser directement les missions filtrées
    final filteredMissions = missions.where((mission) {
      try {
        final missionDate = DateTime.parse(mission['date_mission'] ?? '');
        return missionDate.year == selectedDate.year &&
            missionDate.month == selectedDate.month &&
            missionDate.day == selectedDate.day;
      } catch (e) {
        return false;
      }
    }).toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.getContentPadding(context),
                right: AppDimensions.getContentPadding(context),
                top: AppDimensions.getContentPadding(context),
                bottom: AppDimensions.getSpacing(context) / 2,
              ),
              child: Text(
                'Missions du jour',
                style: TextStyle(
                  fontSize: AppDimensions.getTitleSize(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            );
          }

          if (filteredMissions.isEmpty) {
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
                      style: TextStyle(
                        fontSize: AppDimensions.getBodyTextSize(context),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final mission = filteredMissions[index - 1];
          final patientInfo = mission['patient_info'] ?? {};
          final materials = mission['materiels_utilises'] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
                child: Text(
                  DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate),
                  style: TextStyle(
                    fontSize: AppDimensions.getTitleSize(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: AppDimensions.getContentPadding(context),
                  vertical: AppDimensions.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.getCardRadius(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InterventionCard(
                      intervention: {
                        'title': mission['type_mission'] ?? 'Mission non spécifiée',
                        'date_mission': mission['date_mission'],
                        'isMaterialRequest': mission['type_mission'] == 'demande de matériel',
                        'isUrgent': mission['urgence'] == 1 || mission['etat_mission'] == 'urgente',
                        'createdAt': mission['created_at'],
                        'adresse': mission['adresse'] ?? 'Adresse non spécifiée',
                        'prix': mission['prix'] ?? '0.00',
                        'paiement': mission['paiement'] ?? 'Non spécifié',
                        'paye': mission['paye'] == 1 ? 'Oui' : 'Non',
                        'bon_de_commande': mission['bon_de_commande'] ?? 'Non spécifié',
                        'cause': mission['cause'] ?? 'Non spécifiée',
                        'urgence': mission['urgence'] == 1 ? 'Urgent' : 'Non urgent',
                        'statut': mission['statut']?.toString().toLowerCase() ?? 'non spécifié',
                        'etat_mission': mission['etat_mission']?.toString().toLowerCase() ?? 'non spécifié',
                      },
                    ),
                    if (patientInfo.isNotEmpty) ...[
                      Divider(),
                      Padding(
                        padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations Patient',
                              style: TextStyle(
                                fontSize: AppDimensions.getTitleSize(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: AppDimensions.getSpacing(context)),
                            _buildInfoRow('Nom', '${patientInfo['nom']} ${patientInfo['prenom']}'),
                            _buildInfoRow('Téléphone', patientInfo['téléphone'] ?? 'Non spécifié'),
                            _buildInfoRow('Email', patientInfo['email'] ?? 'Non spécifié'),
                            _buildInfoRow('Ville', patientInfo['ville'] ?? 'Non spécifiée'),
                            _buildInfoRow('Type de client', patientInfo['type_client'] ?? 'Non spécifié'),
                          ],
                        ),
                      ),
                    ],
                    if (materials.isNotEmpty) ...[
                      Divider(),
                      Padding(
                        padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Matériaux utilisés',
                              style: TextStyle(
                                fontSize: AppDimensions.getTitleSize(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: AppDimensions.getSpacing(context)),
                            ...materials.map((material) => _buildMaterialRow(material)),
                          ],
                        ),
                      ),
                    ],
                    Padding(
                      padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
                      child: ElevatedButton.icon(
                        onPressed: () => onGenerateReport(mission),
                        icon: Icon(Icons.download, color: Colors.white),
                        label: Text(
                          'Télécharger le rapport',
                          style: TextStyle(
                            fontSize: AppDimensions.getBodyTextSize(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.getContentPadding(context),
                            vertical: AppDimensions.getSpacing(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.getCardRadius(context)),
                          ),
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        childCount: filteredMissions.isEmpty ? 1 : filteredMissions.length + 1,
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMaterialRow(Map<String, dynamic> material) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.medical_services, size: 20, color: AppColors.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '${material['item']} (${material['quantite_utilisee']})',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
