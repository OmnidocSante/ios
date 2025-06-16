import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../styles/button_styles.dart';
import '../../styles/header_styles.dart';
import '../../styles/icon_styles.dart';
import '../../styles/card_styles.dart';
import '../intervention_card.dart';
import '../date_selector.dart';
import '../intervention_banner.dart';
import 'package:intl/intl.dart';
import '../../styles/app_dimensions.dart';
import '../../../screens/notifications_screen.dart';

class HomeWidgetMethods {
  // Méthodes de construction de widgets
  static PreferredSizeWidget buildAppBar(
      double maxWidth, double maxHeight, bool isTablet, bool isPortrait,
      {required String userName,
      required String userAvatar,
      required BuildContext context,
      required TextEditingController searchController,
      required ValueChanged<String> onSearchChanged,
      List<Widget>? actions}) {
    final headerHeight = isPortrait
        ? maxHeight * (isTablet ? 0.15 : 0.2)
        : maxHeight * (isTablet ? 0.25 : 0.3);

    return PreferredSize(
      preferredSize: Size.fromHeight(headerHeight),
      child: buildHeader(maxWidth, headerHeight, isTablet, isPortrait,
          userName: userName,
          userAvatar: userAvatar,
          context: context,
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          actions: actions),
    );
  }

  static Widget buildHeader(
      double maxWidth, double headerHeight, bool isTablet, bool isPortrait,
      {required String userName,
      required String userAvatar,
      required BuildContext context,
      required TextEditingController searchController,
      required ValueChanged<String> onSearchChanged,
      List<Widget>? actions}) {
    final iconSize = maxWidth * (isTablet ? 0.03 : 0.06);
    final avatarRadius = maxWidth * (isTablet ? 0.04 : 0.08);
    final contentPadding = maxWidth * 0.04;

    return Container(
      decoration: HeaderStyles.headerDecoration,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: contentPadding,
            vertical: contentPadding / 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: buildUserInfoRow(
                        maxWidth, avatarRadius, iconSize, contentPadding, isTablet,
                        userName: userName, userAvatar: userAvatar, context: context),
                  ),
                  if (actions != null) ...actions,
                ],
              ),
              SizedBox(height: contentPadding),
              // Barre de recherche dans l'AppBar
              TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Rechercher une mission...',
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: contentPadding,
                    vertical: contentPadding / 2,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildUserInfoRow(double maxWidth, double avatarRadius,
      double iconSize, double contentPadding, bool isTablet,
      {required String userName,
      required String userAvatar,
      required BuildContext context}) {
    return Row(
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
              Text(
                'Bienvenue',
                style: TextStyle(
                  fontSize: AppDimensions.welcomeTextSize,
                  color: Colors.white70,
                ),
              ),
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
        IconButton(
          icon: Icon(Icons.notifications,
              color: Colors.white, size: AppDimensions.iconSize),
          padding: EdgeInsets.all(AppDimensions.spacing / 2),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsScreen()),
            );
          },
        ),
      ],
    );
  }

  static Widget buildNextMissionWidget(
      Map<String, dynamic>? nextMission, double maxWidth, double contentPadding,
      {String? userId}) {
    if (nextMission != null && nextMission['id'] != null) {
      if (userId != null &&
          nextMission['ambulancier_id']?.toString() != userId &&
          nextMission['doctor_id']?.toString() != userId &&
          nextMission['nurse_id']?.toString() != userId) {
        return buildNoMissionCard(maxWidth, contentPadding);
      }

      // Vérifier si la mission est urgente ou d'aujourd'hui
      final isUrgent = nextMission['urgence'] == 1 ||
          nextMission['etat_mission'] == 'urgente';
      final missionDate = DateTime.tryParse(nextMission['date_mission'] ?? '');
      final isToday = missionDate != null &&
          missionDate.year == DateTime.now().year &&
          missionDate.month == DateTime.now().month &&
          missionDate.day == DateTime.now().day;

      return GestureDetector(
        onTap: () {},
        child: InterventionBanner(
          title: nextMission['type_mission'] ?? 'Mission non spécifiée',
          subtitle: 'Date: ${formatDate(nextMission['date_mission'])}',
          time: nextMission['date_mission'] ?? '',
          isUrgent: isUrgent || isToday,
          adresse: nextMission['adresse'] ?? 'Adresse non spécifiée',
          prix: nextMission['prix'] ?? '0.00',
          paiement: nextMission['paiement'] ?? 'Non spécifié',
          paye: nextMission['paye'] == 1 ? 'Oui' : 'Non',
          cause: nextMission['cause'] ?? 'Cause non spécifiée',
          patientId: nextMission['patient_id'],
          missionId: nextMission['id'],
          demandeMateriel: nextMission['demande_materiel'],
          doctorId: nextMission['doctor_id'] is int
              ? nextMission['doctor_id']
              : int.tryParse(nextMission['doctor_id']?.toString() ?? ''),
          nurseId: nextMission['nurse_id'] is int
              ? nextMission['nurse_id']
              : int.tryParse(nextMission['nurse_id']?.toString() ?? ''),
        ),
      );
    }
    return buildNoMissionCard(maxWidth, contentPadding);
  }

  static Widget buildNoMissionCard(double maxWidth, double padding) {
    return Container(
      padding: EdgeInsets.all(padding * 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: maxWidth * 0.1,
            color: Colors.grey[400],
          ),
          SizedBox(height: padding),
          Text(
            'Aucune mission disponible',
            style: TextStyle(
              fontSize: maxWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: padding / 2),
          Text(
            'Vous n\'avez pas de mission active pour le moment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: maxWidth * 0.035,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildNoMissionsCard(double maxWidth, double padding) {
    return Container(
      padding: EdgeInsets.all(padding * 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: maxWidth * 0.1,
            color: Colors.grey[400],
          ),
          SizedBox(height: padding),
          Text(
            'Aucune mission planifiée',
            style: TextStyle(
              fontSize: maxWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: padding / 2),
          Text(
            'Vous n\'avez aucune mission planifiée pour cette date',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: maxWidth * 0.035,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildMissionsHeader(
      double maxWidth, bool isTablet, String userId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Toutes les Missions',
          style: TextStyle(
            fontSize: maxWidth * (isTablet ? 0.025 : 0.045),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('Voir tout'),
        ),
      ],
    );
  }

  static Widget buildMissionCard(
      Map<String, dynamic> mission, double contentPadding, String userId) {
    if (mission['ambulancier_id']?.toString() == userId ||
        mission['doctor_id']?.toString() == userId ||
        mission['nurse_id']?.toString() == userId) {
      return Padding(
        padding: EdgeInsets.only(bottom: contentPadding * 0.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InterventionCard(
            intervention: {
              'title': mission['type_mission'] ?? 'Mission non spécifiée',
              'date_mission': mission['date_mission'],
              'isMaterialRequest':
                  mission['type_mission'] == 'demande de matériel',
              'isUrgent': mission['urgence'] == 1 ||
                  mission['etat_mission'] == 'urgente',
              'createdAt': mission['created_at'],
              'adresse': mission['adresse'] ?? 'Adresse non spécifiée',
              'prix': mission['prix'] ?? '0.00',
              'paiement': mission['paiement'] ?? 'Non spécifié',
              'paye': mission['paye'] == 1 ? 'Oui' : 'Non',
              'bon_de_commande': mission['bon_de_commande'] ?? 'Non spécifié',
              'cause': mission['cause'] ?? 'Cause non spécifiée',
              'urgence': mission['urgence'] == 1 ? 'Urgent' : 'Non urgent',
              'statut':
                  mission['statut']?.toString().toLowerCase() ?? 'non spécifié',
              'etat_mission':
                  mission['etat_mission']?.toString().toLowerCase() ??
                      'non spécifié',
            },
          ),
        ),
      );
    }
    return Container();
  }

  // Méthodes de formatage
  static String formatDate(String? dateString) {
    if (dateString == null) return 'Date non spécifiée';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Format de date invalide';
    }
  }

  static String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '--:--';
    }

    try {
      if (timeString.contains('T')) {
        final dateTime = DateTime.parse(timeString);
        return DateFormat('HH:mm').format(dateTime);
      } else if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
        }
      }
    } catch (e) {
      // Ignorer l'erreur
    }

    return '--:--';
  }
}
