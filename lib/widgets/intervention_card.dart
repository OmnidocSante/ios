import 'package:flutter/material.dart';
import '../styles/app_text_styles.dart';
import '../styles/card_styles.dart';
import '../styles/colors.dart';
import 'package:intl/intl.dart';
import '../styles/app_dimensions.dart';

class InterventionCard extends StatelessWidget {
  final Map<String, dynamic> intervention;
  final bool isMaterialRequest;
  final bool isUrgent;

  InterventionCard._({
    Key? key,
    required this.intervention,
    required this.isMaterialRequest,
    required this.isUrgent,
  }) : super(key: key);

  factory InterventionCard({
    Key? key,
    required Map<String, dynamic> intervention,
  }) {
    return InterventionCard._(
      key: key,
      intervention: intervention,
      isMaterialRequest: intervention['isMaterialRequest'] ?? false,
      isUrgent: intervention['isUrgent'] ?? false,
    );
  }

  String _getInterventionIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'téléconsultation':
        return '👨‍⚕️';
      case 'consultation a domicile':
        return '🏠';
      case 'acte infirmier':
        return '💉';
      case 'ambulance':
        return '🚑';
      default:
        return '🚑';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) {
      return 'Heure non spécifiée';
    }
    try {
      // Extraire l'heure de la chaîne de date
      final timePart = dateString.split('T')[1];
      // Formater l'heure
      final formattedTime = timePart.substring(0, 5); // Prendre seulement HH:mm

      return formattedTime;
    } catch (e) {
      return 'Format invalide';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en cours':
        return Colors.blue;
      case 'terminée':
      case 'terminé':
        return Colors.green;
      case 'annulée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'en cours':
        return Icons.pending;
      case 'terminée':
      case 'terminé':
        return Icons.check_circle;
      case 'annulée':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseFontSize = screenWidth * 0.035;

    return Container(
      padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: isMaterialRequest
                      ? Colors.orange.withOpacity(0.1)
                      : AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      AppDimensions.getCardRadius(context)),
                ),
                child: isMaterialRequest
                    ? Icon(
                        Icons.medical_services,
                        color: Colors.orange,
                        size: AppDimensions.getIconSize(context),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.getCardRadius(context)),
                        child: Image.asset(
                          'assets/images/logo1.jpg',
                          width: AppDimensions.getAvatarSize(context),
                          height: AppDimensions.getAvatarSize(context),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            intervention['title']?.toString() ?? intervention['type_mission']?.toString() ?? 'Mission non spécifiée',
                            style: AppTextStyles.getCardTitle(context).copyWith(
                              color: isMaterialRequest
                                  ? Colors.orange
                                  : AppColors.primaryColor,
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Heure: ${_formatDate(intervention['date_mission'])}',
                      style: AppTextStyles.getCardSubtitle(context)
                          .copyWith(color: Colors.grey[600]),
                    ),
                    if (intervention['created_at'] != null)
                      Text(
                        'Créée le: ${_formatDate(intervention['created_at'])}',
                        style: AppTextStyles.getSmallText(context).copyWith(
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(intervention['statut']?.toString().toLowerCase() ?? '').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(intervention['statut']?.toString().toLowerCase() ?? ''),
                      color: _getStatusColor(intervention['statut']?.toString().toLowerCase() ?? ''),
                      size: AppDimensions.getIconSize(context) * 0.9,
                    ),
                    SizedBox(width: 4),
                    Text(
                      intervention['statut']?.toString() ?? 'Statut inconnu',
                      style: TextStyle(
                        color: _getStatusColor(intervention['statut']?.toString().toLowerCase() ?? ''),
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimensions.getBodyTextSize(context) * 0.95,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (intervention['description'] != null) ...[
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Icon(
                  Icons.description,
                  size: baseFontSize * 1.1,
                  color: Colors.grey[600],
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    intervention['description']?.toString() ??
                        'Aucune description',
                    style: AppTextStyles.getBodyText(context).copyWith(
                      fontSize: baseFontSize * 0.9,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (intervention['adresse'] != null) ...[
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: baseFontSize * 1.1,
                  color: Colors.grey[600],
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    intervention['adresse']?.toString() ??
                        'Adresse non spécifiée',
                    style: AppTextStyles.getBodyText(context).copyWith(
                      fontSize: baseFontSize * 0.9,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (intervention['cause'] != null) ...[
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Icon(
                  Icons.medical_information,
                  size: baseFontSize * 1.1,
                  color: Colors.grey[600],
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    'Cause: ${intervention['cause']?.toString() ?? 'Cause non spécifiée'}',
                    style: AppTextStyles.getBodyText(context).copyWith(
                      fontSize: baseFontSize * 0.9,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (intervention['demande_materiel'] != null) ...[
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  size: baseFontSize * 1.1,
                  color: Colors.grey[600],
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    'Matériel: ${intervention['demande_materiel']?.toString() ?? 'Aucune demande de matériel'}',
                    style: AppTextStyles.getBodyText(context).copyWith(
                      fontSize: baseFontSize * 0.9,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (intervention['prix'] != null) ...[
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: baseFontSize * 1.1,
                  color: Colors.grey[600],
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    'Prix: ${intervention['prix']} DH',
                    style: AppTextStyles.getBodyText(context).copyWith(
                      fontSize: baseFontSize * 0.9,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (intervention['paiement'] != null) ...[
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Icon(
                  Icons.payment,
                  size: AppDimensions.getIconSize(context) * 1.1,
                  color: Colors.grey[600],
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    'Mode de paiement: '
                    '${(intervention['paiement']?.toString().toLowerCase() == 'cache') ? 'cash' : intervention['paiement']}',
                    style: AppTextStyles.getBodyText(context).copyWith(
                      fontSize: baseFontSize * 0.9,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (intervention['paye'] != null) ...[
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: baseFontSize * 1.1,
                  color: Colors.grey[600],
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    'Statut de paiement: ${intervention['paye'] == 1 ? 'Payé' : 'Non payé'}',
                    style: AppTextStyles.getBodyText(context).copyWith(
                      fontSize: baseFontSize * 0.9,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
