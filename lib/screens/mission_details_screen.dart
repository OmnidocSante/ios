import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/app_dimensions.dart';
import '../styles/app_text_styles.dart';
import 'package:intl/intl.dart';
import '../widgets/common_widgets.dart';

class MissionDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final mission = args['mission'];
    final formattedTime = args['formattedTime'];
    final createdDate = args['createdDate'];
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final contentPadding = AppDimensions.getContentPadding(context);
    final spacing = AppDimensions.getSpacing(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: CommonWidgets.buildAppBar(
        context: context,
        title: 'Détails de la mission',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMissionHeader(context, mission, formattedTime, createdDate,
                contentPadding, spacing),
            SizedBox(height: spacing),
            _buildMainInfoSection(context, mission, contentPadding, spacing),
            SizedBox(height: spacing),
            _buildPaymentInfoSection(context, mission, contentPadding, spacing),
            SizedBox(height: spacing),
            _buildAdditionalInfoSection(
                context, mission, contentPadding, spacing),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionHeader(
      BuildContext context,
      Map<String, dynamic> mission,
      String formattedTime,
      String createdDate,
      double contentPadding,
      double spacing) {
    return Container(
      padding: EdgeInsets.all(contentPadding),
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
          Text(
            mission['type_mission'] ?? 'Mission non spécifiée',
            style: AppTextStyles.getCardTitle(context),
          ),
          SizedBox(height: spacing),
          _buildInfoRow(
            context: context,
            icon: Icons.access_time,
            label: 'Heure',
            value: formattedTime,
            iconColor: AppColors.primaryColor,
          ),
          SizedBox(height: spacing * 0.5),
          _buildInfoRow(
            context: context,
            icon: Icons.calendar_today,
            label: 'Date de création',
            value: createdDate,
            iconColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoSection(BuildContext context,
      Map<String, dynamic> mission, double contentPadding, double spacing) {
    return _buildSection(
      context: context,
      title: 'Informations principales',
      spacing: spacing,
      children: [
        _buildInfoRow(
          context: context,
          icon: Icons.location_on,
          label: 'Adresse',
          value: mission['adresse'] ?? 'Non spécifiée',
          iconColor: AppColors.primaryColor,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.medical_information,
          label: 'Cause',
          value: mission['cause'] ?? 'Non spécifiée',
          iconColor: AppColors.primaryColor,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.receipt,
          label: 'Bon de commande',
          value: mission['bon_de_commande'] ?? 'Non spécifié',
          iconColor: AppColors.primaryColor,
        ),
        _buildInfoRow(
          context: context,
          icon: mission['urgence'] == 1 ? Icons.warning : Icons.check_circle,
          label: 'Urgence',
          value: mission['urgence'] == 1 ? 'Urgent' : 'Non urgent',
          iconColor: mission['urgence'] == 1 ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildPaymentInfoSection(BuildContext context,
      Map<String, dynamic> mission, double contentPadding, double spacing) {
    return _buildSection(
      context: context,
      title: 'Informations de paiement',
      spacing: spacing,
      children: [
        _buildInfoRow(
          context: context,
          icon: Icons.attach_money,
          label: 'Prix',
          value: '${mission['prix'] ?? '0.00'} DH',
          iconColor: AppColors.primaryColor,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.payment,
          label: 'Mode de paiement',
          value: mission['paiement'] ?? 'Non spécifié',
          iconColor: AppColors.primaryColor,
        ),
        _buildInfoRow(
          context: context,
          icon: mission['paye'] == 1 ? Icons.check_circle : Icons.pending,
          label: 'Statut de paiement',
          value: mission['paye'] == 1 ? 'Payé' : 'Non payé',
          iconColor: mission['paye'] == 1 ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context,
      Map<String, dynamic> mission, double contentPadding, double spacing) {
    return _buildSection(
      context: context,
      title: 'Informations supplémentaires',
      spacing: spacing,
      children: [
        _buildInfoRow(
          context: context,
          icon: Icons.info_outline,
          label: 'État de la mission',
          value: mission['etat_mission'] ?? 'Non spécifié',
          iconColor: AppColors.primaryColor,
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.flag,
          label: 'Statut',
          value: mission['statut'] ?? 'Non spécifié',
          iconColor: AppColors.primaryColor,
        ),
        if (mission['description'] != null && mission['description'].isNotEmpty)
          _buildInfoRow(
            context: context,
            icon: Icons.description,
            label: 'Description',
            value: mission['description'],
            iconColor: AppColors.primaryColor,
          ),
        if (mission['demande_materiel'] != null &&
            mission['demande_materiel'].isNotEmpty)
          _buildInfoRow(
            context: context,
            icon: Icons.medical_services,
            label: 'Matériel demandé',
            value: mission['demande_materiel'],
            iconColor: AppColors.primaryColor,
          ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    required double spacing,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
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
          Text(
            title,
            style: AppTextStyles.getSubtitle(context),
          ),
          SizedBox(height: spacing),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: AppDimensions.getSpacing(context) * 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppDimensions.getIconSize(context),
            color: iconColor ?? AppColors.textSecondary,
          ),
          SizedBox(width: AppDimensions.getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.getSmallText(context),
                ),
                SizedBox(height: AppDimensions.getSpacing(context) * 0.2),
                Text(
                  value,
                  style: AppTextStyles.getBodyText(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
