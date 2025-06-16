import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/app_dimensions.dart';
import '../styles/app_text_styles.dart';
import '../widgets/common_widgets.dart';
import 'package:intl/intl.dart';
import '../widgets/intervention_banner.dart';
import '../api/mission_api.dart';

class MissionWidgets {
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String title,
    required VoidCallback onBack,
    List<Widget>? actions,
  }) {
    return CommonWidgets.buildAppBar(
      context: context,
      title: title,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBack,
      ),
      actions: actions,
    );
  }

  static Widget buildMissionCard({
    required Map<String, dynamic> mission,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final missionDate = DateTime.parse(
        mission['date_mission'] ?? DateTime.now().toIso8601String());
    final formattedTime = DateFormat('HH:mm').format(missionDate);
    final isUrgent =
        mission['urgence'] == 1 || mission['etat_mission'] == 'urgente';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.getContentPadding(context),
        vertical: AppDimensions.getSpacing(context) / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(AppDimensions.getCardRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(AppDimensions.getCardRadius(context)),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          AppDimensions.getSpacing(context) * 0.8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            AppDimensions.getCardRadius(context)),
                      ),
                      child: Icon(
                        Icons.medical_services,
                        color: AppColors.primaryColor,
                        size: AppDimensions.getIconSize(context),
                      ),
                    ),
                    SizedBox(width: AppDimensions.getSpacing(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission['type_mission'] ?? 'Mission non spécifiée',
                            style: AppTextStyles.getBodyText(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                              height: AppDimensions.getSpacing(context) / 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(missionDate),
                            style: AppTextStyles.getSmallText(context).copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUrgent)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.getSpacing(context),
                          vertical: AppDimensions.getSpacing(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.getCardRadius(context)),
                        ),
                        child: Text(
                          'Urgent',
                          style: AppTextStyles.getSmallText(context).copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppDimensions.getSpacing(context)),
                _buildInfoRow(
                  context,
                  Icons.location_on,
                  'Adresse',
                  mission['adresse'] ?? 'Non spécifiée',
                ),
                _buildInfoRow(
                  context,
                  Icons.access_time,
                  'Heure',
                  formattedTime,
                ),
                if (mission['statut'] != null)
                  _buildInfoRow(
                    context,
                    Icons.flag,
                    'Statut',
                    mission['statut'],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildMissionDetails({
    required Map<String, dynamic> mission,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(AppDimensions.getCardRadius(context)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailHeader(context, mission),
          SizedBox(height: AppDimensions.getSpacing(context)),
          _buildDetailSection(
            context,
            'Informations générales',
            [
              _buildDetailRow(context, 'Type', mission['type_mission']),
              _buildDetailRow(
                  context,
                  'Date',
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(mission['date_mission']))),
              _buildDetailRow(
                  context, 'Heure', mission['heure_depart'] ?? 'Non spécifiée'),
              _buildDetailRow(
                  context, 'Urgence', mission['urgence'] == 1 ? 'Oui' : 'Non'),
            ],
          ),
          SizedBox(height: AppDimensions.getSpacing(context)),
          _buildDetailSection(
            context,
            'Détails',
            [
              _buildDetailRow(context, 'Adresse', mission['adresse']),
              _buildDetailRow(context, 'Cause', mission['cause']),
              _buildDetailRow(context, 'Description', mission['description']),
            ],
          ),
          if (mission['demande_materiel'] != null)
            _buildDetailSection(
              context,
              'Matériel',
              [
                _buildDetailRow(
                    context, 'Demande', mission['demande_materiel']),
              ],
            ),
        ],
      ),
    );
  }

  static Widget _buildDetailHeader(
      BuildContext context, Map<String, dynamic> mission) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getSpacing(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppDimensions.getCardRadius(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.getSpacing(context) * 0.8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius:
                  BorderRadius.circular(AppDimensions.getCardRadius(context)),
            ),
            child: Icon(
              Icons.medical_services,
              color: Colors.white,
              size: AppDimensions.getIconSize(context),
            ),
          ),
          SizedBox(width: AppDimensions.getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission['type_mission'] ?? 'Mission non spécifiée',
                  style: AppTextStyles.getTitle(context),
                ),
                SizedBox(height: AppDimensions.getSpacing(context) / 4),
                Text(
                  'ID: ${mission['id']}',
                  style: AppTextStyles.getSmallText(context).copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.getSubtitle(context).copyWith(
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: AppDimensions.getSpacing(context) / 2),
        ...children,
      ],
    );
  }

  static Widget _buildDetailRow(
      BuildContext context, String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.getSpacing(context) / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.getBodyText(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Non spécifié',
              style: AppTextStyles.getBodyText(context),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.getSpacing(context) / 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.getIconSize(context) * 0.8,
            color: Colors.grey[600],
          ),
          SizedBox(width: AppDimensions.getSpacing(context) / 2),
          Expanded(
            child: Text(
              '$label: $value',
              style: AppTextStyles.getSmallText(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: AppDimensions.getIconSize(context) * 3,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppDimensions.getSpacing(context)),
          Text(
            'Aucune mission',
            style: AppTextStyles.getTitle(context).copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: AppDimensions.getSpacing(context) / 2),
          Text(
            'Vous n\'avez pas encore de missions',
            style: AppTextStyles.getBodyText(context).copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          SizedBox(height: AppDimensions.getSpacing(context)),
          Text(
            'Chargement des missions...',
            style: AppTextStyles.getBodyText(context).copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class NextMissionBanner extends StatefulWidget {
  const NextMissionBanner({Key? key}) : super(key: key);

  @override
  _NextMissionBannerState createState() => _NextMissionBannerState();
}

class _NextMissionBannerState extends State<NextMissionBanner> {
  bool _isLoading = true;
  Map<String, dynamic>? _nextMission;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNextMission();
  }

  Future<void> _loadNextMission() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final missions = await MissionApi.getAllMissions();
      final now = DateTime.now();
      final futureMissions = missions.where((mission) {
        try {
          final missionDate = DateTime.parse(mission['date_mission']);
          return missionDate.isAfter(now) && mission['statut'] == 'créée';
        } catch (e) {
          return false;
        }
      }).toList();

      futureMissions.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['date_mission']);
          final dateB = DateTime.parse(b['date_mission']);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

      if (futureMissions.isNotEmpty) {
        setState(() {
          _nextMission = futureMissions.first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _nextMission = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement de la prochaine mission: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (_nextMission == null) {
      return Center(
        child: Text(
          'Aucune mission à venir',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    try {
      final missionDate = DateTime.parse(_nextMission!['date_mission']);
      final formattedDate = DateFormat('dd/MM/yyyy').format(missionDate);
      final formattedTime = DateFormat('HH:mm').format(missionDate);

      return InterventionBanner(
        title: _nextMission!['type_mission'] ?? 'Mission',
        subtitle: formattedDate,
        time: formattedTime,
        isUrgent: _nextMission!['urgence'] == 1,
        description: _nextMission!['description'],
        adresse: _nextMission!['adresse'],
        demandeMateriel: _nextMission!['demande_materiel'],
        etatMission: _nextMission!['etat_mission'],
        statut: _nextMission!['statut'],
        bonDeCommande: _nextMission!['bon_de_commande'],
        cause: _nextMission!['cause'],
        patientId: _nextMission!['patient_id'],
        missionId: _nextMission!['id'],
        heureDepart: _nextMission!['heure_depart'],
        heureArrivee: _nextMission!['heure_arrivee'],
        heureAffectation: _nextMission!['heure_affectation'],
        heureFin: _nextMission!['heure_fin'],
      );
    } catch (e) {
      return Center(
        child: Text(
          'Erreur de format de date: $e',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }
}
