import 'package:flutter/material.dart';
import 'package:transport_sante/api/chat_api.dart';
import '../styles/card_styles.dart';
import '../styles/colors.dart';
import '../styles/app_text_styles.dart';
import '../styles/button_styles.dart';
import '../screens/patient_info_screen.dart';
import 'package:intl/intl.dart';
import '../../api/user_api.dart';
import '../styles/app_dimensions.dart';

class InterventionBanner extends StatefulWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isUrgent;
  final String? description;
  final String? adresse;
  final String? demandeMateriel;
  final String? etatMission;
  final String? statut;
  final String? bonDeCommande;
  final String? cause;
  final int? patientId;
  final int? missionId;
  final String? heureDepart;
  final String? heureArrivee;
  final String? heureAffectation;
  final String? heureFin;
  final VoidCallback? onClose;
  final bool isEnCours;
  final String? prix;
  final String? paiement;
  final String? paye;
  final int? doctorId;
  final int? nurseId;

  const InterventionBanner({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isUrgent = false,
    this.description,
    this.adresse,
    this.demandeMateriel,
    this.etatMission,
    this.statut,
    this.bonDeCommande,
    this.cause,
    this.patientId,
    this.missionId,
    this.heureDepart,
    this.heureArrivee,
    this.heureAffectation,
    this.heureFin,
    this.onClose,
    this.isEnCours = false,
    this.prix,
    this.paiement,
    this.paye,
    this.doctorId,
    this.nurseId,
  }) : super(key: key);

  @override
  _InterventionBannerState createState() => _InterventionBannerState();
}

class _InterventionBannerState extends State<InterventionBanner> {
  Future<String>? _doctorNameFuture;
  Future<String>? _nurseNameFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (widget.doctorId != null) {
      _doctorNameFuture = getUserNameById(widget.doctorId);
    }
    if (widget.nurseId != null) {
      _nurseNameFuture = getUserNameById(widget.nurseId);
    }
  }

  @override
  void didUpdateWidget(InterventionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.doctorId != oldWidget.doctorId && widget.doctorId != null) {
      setState(() {
      _doctorNameFuture = getUserNameById(widget.doctorId);
      });
    }
    if (widget.nurseId != oldWidget.nurseId && widget.nurseId != null) {
      setState(() {
      _nurseNameFuture = getUserNameById(widget.nurseId);
      });
  }
  }

  @override
  Widget build(BuildContext context) {
    final banner = GestureDetector(
          onTap: () {
            if (widget.patientId != null && widget.missionId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientInfoScreen(
                    patientId: widget.patientId,
                    missionId: widget.missionId,
                  ),
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensions.getContentPadding(context)),
            decoration: BoxDecoration(
              color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.getCardRadius(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(
            color: _isUrgentOrToday() ? Colors.red : Colors.grey.withOpacity(0.15),
                width: _isUrgentOrToday() ? 2 : 0.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo1.jpg',
                    width: AppDimensions.getAvatarSize(context),
                    height: AppDimensions.getAvatarSize(context),
                    fit: BoxFit.cover,
                  ),
                ),
            SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                          style: AppTextStyles.getCardTitle(context).copyWith(
                                color: _isUrgentOrToday() ? Colors.red : null,
                              ),
                            ),
                          ),
                          if (_isUrgentOrToday())
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: AppDimensions.getIconSize(context),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                  _buildInfoRow(),
                  if (widget.adresse != null && widget.adresse!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Adresse : ${widget.adresse!}',
                        style: AppTextStyles.getBodyText(context),
                      ),
                    ),
                  if (widget.cause != null && widget.cause!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        'Cause : ${widget.cause!}',
                        style: AppTextStyles.getBodyText(context),
                      ),
                    ),
                  if (widget.demandeMateriel != null && widget.demandeMateriel!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        'Matériel demandé : ${widget.demandeMateriel!}',
                        style: AppTextStyles.getBodyText(context),
                      ),
                    ),
                  _buildPersonnelInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return banner;
  }

  Widget _buildInfoRow() {
    return Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: AppDimensions.getIconSize(context) * 0.7,
                              color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.subtitle,
                              style: AppTextStyles.getCardSubtitle(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.access_time,
                              size: AppDimensions.getIconSize(context) * 0.7,
                              color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
          DateFormat('HH:mm').format(DateTime.parse(widget.time)),
                            style: AppTextStyles.getCardSubtitle(context),
                          ),
                        ],
    );
  }

  Widget _buildPersonnelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                      if (widget.doctorId != null)
                        FutureBuilder<String>(
                          future: _doctorNameFuture,
                          builder: (context, snapshot) {
                              return Text(
                'Médecin : ${snapshot.data ?? 'Chargement...'}',
                              style: AppTextStyles.getBodyText(context),
                            );
                          },
                        ),
                      if (widget.nurseId != null)
                        FutureBuilder<String>(
                          future: _nurseNameFuture,
                          builder: (context, snapshot) {
                              return Text(
                'Infirmier : ${snapshot.data ?? 'Chargement...'}',
                              style: AppTextStyles.getBodyText(context),
                            );
                          },
                        ),
                    ],
        );
  }

  bool _isUrgentOrToday() {
    if (widget.isUrgent) return true;
    try {
      final missionDate = DateTime.parse(widget.time);
      final today = DateTime.now();
      return missionDate.year == today.year &&
          missionDate.month == today.month &&
          missionDate.day == today.day;
    } catch (e) {
      return false;
    }
  }
}

final Map<int, String> _userNameCache = {};

Future<String> getUserNameById(int? id) async {

  
  if (id == null) {
    return 'Non attribué';
  }

  try {
  final user = await ChatApi.getUserInfo(id.toString());
  if (user == null) {
    return 'Inconnu';
  }
    
  final nom = user['nom'] ?? '';
  final prenom = user['prenom'] ?? '';
    final fullName = (nom + ' ' + prenom).trim();
    
    return fullName.isEmpty ? 'Inconnu' : fullName;
  } catch (e) {

    return 'Erreur';
  } finally {

  }
}
