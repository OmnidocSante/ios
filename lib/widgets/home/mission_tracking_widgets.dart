import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import 'package:intl/intl.dart';

/// Widgets réutilisables pour l'écran de suivi de mission
class MissionTrackingWidgets {
  // Textes statiques
  static const String _unspecifiedMission = 'Mission non spécifiée';
  static const String _unspecifiedStatus = 'Non spécifié';
  static const String _unspecifiedDate = 'Date non spécifiée';
  static const String _unspecifiedAddress = 'Adresse non spécifiée';
  static const String _destinationTitle = 'Adresse de destination';
  static const String _destinationPlaceholder = 'Cliquez pour ajouter une adresse de destination';

  // Styles constants
  static const _cardElevation = 8.0;
  static const _cardOpacity = 0.2;
  static const _statusOpacity = 0.1;

  /// Construit l'en-tête de la mission avec les informations principales
  static Widget buildMissionHeader(
      BuildContext context, Map<String, dynamic> missionData) {
    return Card(
      elevation: _cardElevation,
      shadowColor: AppColors.primaryColor.withOpacity(_cardOpacity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.getCardRadius(context)),
      ),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.getCardRadius(context)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x1A2196F3), // AppColors.primaryColor.withOpacity(0.1)
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    missionData['type_mission'] ?? _unspecifiedMission,
                    style: AppTextStyles.getCardTitle(context),
                  ),
                ),
                _buildStatusContainer(context, missionData['statut']),
              ],
            ),
            SizedBox(height: AppDimensions.getSpacing(context)),
            _buildInfoRow(
              context: context,
              icon: Icons.calendar_today,
              text: _formatDate(missionData['date_mission']),
            ),
            SizedBox(height: AppDimensions.getSpacing(context) * 0.5),
            _buildInfoRow(
              context: context,
              icon: Icons.location_on,
              text: missionData['adresse'] ?? _unspecifiedAddress,
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la carte d'adresse de destination
  static Widget buildDestinationCard(
    BuildContext context,
    Map<String, dynamic> missionData,
    VoidCallback onEdit,
  ) {
    return Card(
      elevation: _cardElevation,
      shadowColor: AppColors.primaryColor.withOpacity(_cardOpacity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.getCardRadius(context)),
      ),
      child: InkWell(
        onTap: onEdit,
        child: Container(
          padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _destinationTitle,
                    style: AppTextStyles.getCardTitle(context),
                  ),
                  Icon(
                    Icons.edit,
                    color: AppColors.primaryColor,
                    size: AppDimensions.getIconSize(context),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.getSpacing(context)),
              _buildDestinationAddress(context, missionData['adresse_destination']),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDestinationAddress(BuildContext context, String? address) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getContentPadding(context) * 0.8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppDimensions.getCardRadius(context)),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        address ?? _destinationPlaceholder,
        style: AppTextStyles.getBodyText(context).copyWith(
          color: address != null ? Colors.black87 : Colors.grey[600],
        ),
      ),
    );
  }

  static Widget _buildStatusContainer(BuildContext context, String? status) {
    final statusColor = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.getSpacing(context),
        vertical: AppDimensions.getSpacing(context) * 0.5,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(_statusOpacity),
        borderRadius: BorderRadius.circular(AppDimensions.getButtonRadius(context)),
      ),
      child: Text(
        status ?? _unspecifiedStatus,
        style: AppTextStyles.getSmallText(context).copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static String _formatDate(String? date) {
    if (date == null) return _unspecifiedDate;
    try {
      final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
      return formattedDate;
    } catch (e) {
      return _unspecifiedDate;
    }
  }

  /// Construit une ligne d'information avec une icône et du texte
  static Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor.withOpacity(0.7),
          size: AppDimensions.getIconSize(context),
        ),
        SizedBox(width: AppDimensions.getSpacing(context)),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.getBodyText(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Retourne la couleur appropriée en fonction du statut
  static Color _getStatusColor(String? status) {
    final color = switch (status?.toLowerCase()) {
      'en cours' => Colors.orange,
      'terminée' => Colors.green,
      'annulée' => Colors.red,
      _ => Colors.grey,
    };
    return color;
  }
}
