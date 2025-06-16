import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientInfoWidgets {
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String title,
    required VoidCallback onBackPressed,
    required VoidCallback? onChatPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final appBarHeight = isTablet ? 80.0 : 60.0;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.getCardRadius(context)),
            bottomRight: Radius.circular(AppDimensions.getCardRadius(context)),
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
                horizontal: AppDimensions.getContentPadding(context)),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBackPressed,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.getAppBarTitle(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onChatPressed != null)
                  IconButton(
                    icon: Icon(Icons.chat, color: Colors.white),
                    onPressed: onChatPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildWarningBanner({
    required BuildContext context,
    required String message,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = screenWidth * 0.04;
    final iconSize = screenWidth * 0.06;

    return Container(
      margin: EdgeInsets.all(contentPadding),
      padding: EdgeInsets.all(contentPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppDimensions.getCardRadius(context)),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: iconSize),
          SizedBox(width: contentPadding),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.getBodyText(context).copyWith(
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPatientInfoCard({
    required BuildContext context,
    required Map<String, dynamic> patientInfo,
    required bool isTablet,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * (isTablet ? 0.02 : 0.03);

    return Container(
      padding: EdgeInsets.all(padding * 1.2),
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
          _buildHeaderSection(context, patientInfo, isTablet),
          SizedBox(height: padding * 1.5),
          _buildInfoSection(context, patientInfo, isTablet),
        ],
      ),
    );
  }

  static Widget _buildHeaderSection(
      BuildContext context, Map<String, dynamic> patientInfo, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * (isTablet ? 0.02 : 0.03);

    return Container(
      padding: EdgeInsets.all(padding * 0.8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(AppDimensions.getCardRadius(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding * 0.6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(
                  AppDimensions.getCardRadius(context) * 0.8),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: screenWidth * (isTablet ? 0.03 : 0.05),
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${patientInfo['nom']} ${patientInfo['prenom']}',
                  style: AppTextStyles.getCardTitle(context),
                ),
                SizedBox(height: padding * 0.3),
                Text(
                  'ID: ${patientInfo['id']}',
                  style: AppTextStyles.getCardSubtitle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoSection(
      BuildContext context, Map<String, dynamic> patientInfo, bool isTablet) {
    return Column(
      children: [
        _buildInfoRow(
          context: context,
          icon: Icons.calendar_today,
          label: 'Date de naissance',
          value: _formatDate(patientInfo['date_naissance']),
          isTablet: isTablet,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.phone,
          label: 'Téléphone',
          value: patientInfo['téléphone'] ?? 'Non spécifié',
          isTablet: isTablet,
          isPhone: true,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.location_city,
          label: 'Ville',
          value: patientInfo['ville'] ?? 'Non spécifiée',
          isTablet: isTablet,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.category,
          label: 'Type de client',
          value: patientInfo['type_client'] ?? 'Non spécifié',
          isTablet: isTablet,
        ),
      ],
    );
  }

  static String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Non spécifiée';

    try {
      if (dateValue is String) {
        if (dateValue.isEmpty) return 'Non spécifiée';

        List<String> dateFormats = [
          'yyyy-MM-dd',
          'dd/MM/yyyy',
          'yyyy-MM-ddTHH:mm:ss',
          'yyyy-MM-dd HH:mm:ss',
        ];

        for (String format in dateFormats) {
          try {
            final date = DateFormat(format).parse(dateValue);
            return DateFormat('dd/MM/yyyy').format(date);
          } catch (e) {
            continue;
          }
        }
      }
      return 'Format de date invalide';
    } catch (e) {
      return 'Format de date invalide';
    }
  }

  static Widget buildMissionInfoCard({
    required BuildContext context,
    required Map<String, dynamic> missionInfo,
    required bool isTablet,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * (isTablet ? 0.02 : 0.03);

    return Container(
      padding: EdgeInsets.all(padding * 1.2),
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
          Container(
            padding: EdgeInsets.all(padding * 0.8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppDimensions.getCardRadius(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(padding * 0.6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.getCardRadius(context) * 0.8),
                  ),
                  child: Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: screenWidth * (isTablet ? 0.025 : 0.04),
                  ),
                ),
                SizedBox(width: padding * 0.5),
                Flexible(
                  child: Text(
                    'Détails de l\'intervention',
                    style: AppTextStyles.getCardTitle(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: padding * 1.5),
          _buildInfoRow(
            context: context,
            icon: Icons.warning,
            label: 'Urgence',
            value: missionInfo['urgence'] == 1 ? 'Oui' : 'Non',
            isTablet: isTablet,
          ),
          _buildInfoRow(
            context: context,
            icon: Icons.medical_services,
            label: 'Type',
            value: missionInfo['type_mission'] ?? 'Non spécifié',
            isTablet: isTablet,
          ),
          _buildInfoRow(
            context: context,
            icon: Icons.location_on,
            label: 'Adresse',
            value: missionInfo['adresse'] ?? 'Non spécifiée',
            isTablet: isTablet,
          ),
          _buildInfoRow(
            context: context,
            icon: Icons.location_on,
            label: 'Adresse de destination',
            value: missionInfo['adresse_destination'] ?? 'Non spécifiée',
            isTablet: isTablet,
          ),
          _buildInfoRow(
            context: context,
            icon: Icons.access_time,
            label: 'Date et heure',
            value:
                '${DateFormat('dd/MM/yyyy').format(DateTime.parse(missionInfo['date_mission'] ?? DateTime.now().toIso8601String()))} - ${missionInfo['heure_depart'] ?? 'Non spécifiée'}',
            isTablet: isTablet,
          ),
          _buildInfoRow(
            context: context,
            icon: Icons.attach_money,
            label: 'Prix',
            value: '${missionInfo['prix'] ?? 'Non spécifié'} DH',
            isTablet: isTablet,
          ),
          _buildInfoRow(
            context: context,
            icon: Icons.payment,
            label: 'Mode de paiement',
            value: missionInfo['paiement'] ?? 'Non spécifié',
            isTablet: isTablet,
          ),
          _buildInfoRow(
            context: context,
            icon: Icons.check_circle,
            label: 'Payé',
            value: missionInfo['paye'] == 1 ? 'Oui' : 'Non',
            isTablet: isTablet,
          ),
          _buildInfoRow(
            context: context,
            icon: Icons.location_city,
            label: 'Ville',
            value: missionInfo['ville'] ?? 'Non spécifiée',
            isTablet: isTablet,
          ),
          if (missionInfo['cause'] != null)
            _buildInfoRow(
              context: context,
              icon: Icons.medical_information,
              label: 'Cause',
              value: missionInfo['cause'],
              isTablet: isTablet,
            ),
          if (missionInfo['description'] != null)
            _buildInfoRow(
              context: context,
              icon: Icons.note,
              label: 'Description',
              value: missionInfo['description'],
              isTablet: isTablet,
            ),
          if (missionInfo['demande_materiel'] != null)
            _buildInfoRow(
              context: context,
              icon: Icons.medical_services,
              label: 'Demande de matériel',
              value: missionInfo['demande_materiel'],
              isTablet: isTablet,
            ),
          if (missionInfo['etat_mission'] != null)
            _buildInfoRow(
              context: context,
              icon: Icons.info,
              label: 'État de la mission',
              value: missionInfo['etat_mission'],
              isTablet: isTablet,
            ),
          if (missionInfo['statut'] != null)
            _buildInfoRow(
              context: context,
              icon: Icons.flag,
              label: 'Statut',
              value: missionInfo['statut'],
              isTablet: isTablet,
            ),
          if (missionInfo['bon_de_commande'] != null)
            _buildInfoRow(
              context: context,
              icon: Icons.receipt_long,
              label: 'Bon de commande',
              value: missionInfo['bon_de_commande'],
              isTablet: isTablet,
            ),
          if (missionInfo['créé_le'] != null)
            _buildInfoRow(
              context: context,
              icon: Icons.calendar_today,
              label: 'Créé le',
              value: DateFormat('dd/MM/yyyy HH:mm')
                  .format(DateTime.parse(missionInfo['créé_le'])),
              isTablet: isTablet,
            ),
        ],
      ),
    );
  }

  static Widget buildBottomBar({
    required BuildContext context,
    required VoidCallback onStartMission,
    required VoidCallback onLocationButton,
    required bool isTablet,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = screenWidth * 0.04;
    final buttonHeight = isTablet ? 50.0 : 45.0;

    return Container(
      padding: EdgeInsets.all(contentPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onStartMission,
        icon: Icon(
          Icons.check_circle_outline,
          color: Colors.white,
          size: isTablet ? 24 : 20,
        ),
        label: Text(
          'Accepter',
          style: AppTextStyles.getButtonText(context),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: buttonHeight / 2),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.getCardRadius(context)),
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
    bool isPhone = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * (isTablet ? 0.02 : 0.03);

    return Container(
      margin: EdgeInsets.only(bottom: padding * 1.2),
      padding: EdgeInsets.all(padding * 0.8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius:
            BorderRadius.circular(AppDimensions.getCardRadius(context)),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(padding * 0.6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                  AppDimensions.getCardRadius(context) * 0.8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: screenWidth * (isTablet ? 0.025 : 0.045),
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.getSmallText(context),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: padding * 0.3),
                if (isPhone && value != 'Non spécifié')
                  GestureDetector(
                    onTap: () async {
                      try {
                        String cleanNumber =
                            value.replaceAll(RegExp(r'[^\d+]'), '');
                        if (cleanNumber.startsWith('0')) {
                          cleanNumber = '+212${cleanNumber.substring(1)}';
                        }
                        final Uri uri = Uri.parse('tel:$cleanNumber');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        // Gérer l'erreur silencieusement
                      }
                    },
                    child: Text(
                      value,
                      style: AppTextStyles.getLinkText(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  Text(
                    value,
                    style: AppTextStyles.getBodyText(context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
