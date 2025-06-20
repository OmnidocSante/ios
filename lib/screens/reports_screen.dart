import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../styles/card_styles.dart';
import '../styles/bottom_navigation_bar_styles.dart';
import '../styles/header_styles.dart';
import '../styles/icon_styles.dart';
import '../api/user_api.dart';
import '../api/mission_api.dart';
import '../api/patient_api.dart';
import '../widgets/intervention_card.dart';
import '../widgets/date_selector.dart';
import 'package:intl/intl.dart';
import '../styles/button_styles.dart';
import '../api/api_service.dart';
import '../services/firebase_notification_service.dart';
import 'package:provider/provider.dart';
import '../services/mission_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../api/vehicle_api.dart';
import 'package:flutter/services.dart';
import 'package:ftpconnect/ftpconnect.dart';
import '../services/methods/report_methods.dart';
import '../widgets/home/report_widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import '../api/material_api.dart';
import '../config/api_config.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 2;
  int _selectedDayIndex = 2;
  String userName = "";
  String userId = "";
  String userAvatar = "";
  String userEmail = "";
  String userPhone = "";
  String userGender = "";
  String userBirthDate = "";
  String userRole = "";
  String userStatus = "";
  List<Map<String, dynamic>> missions = [];
  bool _isFirstLoad = true;
  bool _isInitialized = false;

  // Cache pour les missions
  final Map<DateTime, List<Map<String, dynamic>>> _missionsCache = {};
  final Map<String, String> _userCache = {};

  // Ajout des constantes FTP
  final String ftpServerUrl = "68.221.30.42";
  final String ftpUsername = "admin";
  final String ftpPassword = "Omnidoc@2024";
  final String remoteFilePath = "/rapports/";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _loadUserInfo();
      await _loadMissions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'initialisation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des informations utilisateur'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMissions() async {
    try {
      final allMissions = await MissionApi.getAllMissions();
      final allMaterialsUsage = await MaterialApi.getAllMaterialsUsage();

      if (mounted) {
        setState(() {
          missions = allMissions.where((mission) {
            final missionAmbulancier = mission['ambulancier_id']?.toString() ?? 
                                     mission['ambulancier']?.toString() ?? '';
            final missionDocteur = mission['docteur_id']?.toString() ?? 
                                 mission['docteur']?.toString() ?? '';
            final missionInfermier = mission['infermier_id']?.toString() ?? 
                                   mission['infermier']?.toString() ?? '';
            final missionStatut = mission['statut']?.toString().toLowerCase() ?? '';
            
            final isInvolved = 
              (missionAmbulancier.isNotEmpty && missionAmbulancier == userId) || 
              (missionDocteur.isNotEmpty && missionDocteur == userId) || 
              (missionInfermier.isNotEmpty && missionInfermier == userId);
            
            final isTerminated = missionStatut == 'terminée' || missionStatut == 'terminé';

            if (userRole == 'administrateur' || userRole == 'médecin') {
              return isTerminated;
            }

            return isTerminated && isInvolved;
          }).toList();

          missions.sort((a, b) {
            final dateA = DateTime.parse(a['date_mission'] ?? DateTime.now().toIso8601String());
            final dateB = DateTime.parse(b['date_mission'] ?? DateTime.now().toIso8601String());
            return dateB.compareTo(dateA);
          });
        });

        for (var mission in missions) {
          if (mission['patient_id'] != null) {
            try {
              final patientInfo = await PatientApi.getPatientInfo(mission['patient_id']);
              mission['patient_info'] = patientInfo;
            } catch (e) {
              mission['patient_info'] = null;
            }
          } else {
            mission['patient_info'] = null;
          }

          final materials = allMaterialsUsage.where((mat) => mat['mission_id'] == mission['id']).toList();
          mission['materiels_utilises'] = materials;

          try {
          await _generateAndSaveReport(mission);
          } catch (e) {
            // Gérer l'erreur silencieusement
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des missions'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateAndSaveReport(Map<String, dynamic> mission) async {
    try {
      final fileName = 'mission_${mission['id']}.pdf';
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        return;
      }

      final logoImage = await _loadLogoImage();
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
            italic: pw.Font.helveticaOblique(),
          ),
          build: (pw.Context context) {
            return [
              if (logoImage.isNotEmpty)
                pw.Container(
                  alignment: pw.Alignment.center,
                  margin: pw.EdgeInsets.only(bottom: 20),
                  child: pw.Image(
                    pw.MemoryImage(logoImage),
                    width: 200,
                    height: 100,
                  ),
                ),

              pw.Header(
                level: 0,
                child: pw.Text('Rapport d\'intervention',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('ID Mission',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(mission['id'].toString())),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Type de mission',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              mission['type_mission'] ?? 'Non spécifié')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Date et heure',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              _formatDateForPdf(mission['date_mission']))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Adresse',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child:
                              pw.Text(mission['adresse'] ?? 'Non spécifiée')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Description',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              mission['description'] ?? 'Non spécifiée')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Statut',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(mission['statut'] ?? 'Non spécifié')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Urgence',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(mission['urgence'] == 1
                              ? 'Urgent'
                              : 'Non urgent')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('État de mission',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              mission['etat_mission'] ?? 'Non spécifié')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Demande de matériel',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              mission['demande_materiel'] ?? 'Non spécifiée')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Bon de commande',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              mission['bon_de_commande'] ?? 'Non spécifié')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Date de création',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child:
                              pw.Text(_formatDateForPdf(mission['créé_le']))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Dernière mise à jour',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              _formatDateForPdf(mission['mis_à_jour_le']))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Header(level: 1, child: pw.Text('Données complètes de la mission')),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  ...mission.entries.where((e) => e.key != 'patient_info' && e.key != 'materiels_utilises').map((entry) =>
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(entry.key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(entry.value?.toString() ?? ''),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Header(level: 1, child: pw.Text('Horaires et Temps')),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Heure de départ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              _formatTimeForPdf(mission['heure_depart']))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Heure d\'affectation',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              _formatTimeForPdf(mission['heure_affectation']))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Heure d\'arrivée',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              _formatTimeForPdf(mission['heure_arrivee']))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Heure de redépart',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                              _formatTimeForPdf(mission['heure_redepart']))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Heure de fin',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child:
                              pw.Text(_formatTimeForPdf(mission['heure_fin']))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: pw.EdgeInsets.all(10),
                margin: pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Récapitulatif des temps',
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: pw.Font.helveticaBold(),
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey400,
                        width: 0.5,
                      ),
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                          ),
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Text(
                                'Étape',
                                style: pw.TextStyle(
                                  font: pw.Font.helveticaBold(),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Text(
                                'Durée',
                                style: pw.TextStyle(
                                  font: pw.Font.helveticaBold(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildTimeRow('Départ -> Affectation', mission['temps_depart'] ?? 'Non calculé'),
                        _buildTimeRow('Affectation -> Arrivée', mission['temps_arrivee'] ?? 'Non calculé'),
                        _buildTimeRow('Arrivée -> Redépart', mission['temps_redepart'] ?? 'Non calculé'),
                        _buildTimeRow('Redépart -> Fin', mission['temps_fin'] ?? 'Non calculé'),
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue100,
                          ),
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Text(
                                'Temps total de la mission',
                                style: pw.TextStyle(
                                  font: pw.Font.helveticaBold(),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Text(
                                mission['temps_total'] ?? 'Non calculé',
                                style: pw.TextStyle(
                                  font: pw.Font.helveticaBold(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              if (mission['patient_info'] != null) ...[
                pw.Header(level: 1, child: pw.Text('Informations du patient')),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('ID Patient',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(mission['patient_info']['id'].toString())),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('Nom complet',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                                '${mission['patient_info']['nom']} ${mission['patient_info']['prenom']}')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('Téléphone',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                                mission['patient_info']['téléphone'] ?? 'Non spécifié')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('Email',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(mission['patient_info']['email'] ?? 'Non spécifié')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('Ville',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child:
                                pw.Text(mission['patient_info']['ville'] ?? 'Non spécifiée')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('Type de client',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                                mission['patient_info']['type_client'] ?? 'Non spécifié')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('Date de naissance',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                                _formatDateForPdf(mission['patient_info']['date_naissance']))),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],

              pw.Header(level: 1, child: pw.Text('Matériels utilisés')),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Matériel',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Quantité utilisée',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Date d\'utilisation',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (mission['materiels_utilises'] != null &&
                      mission['materiels_utilises'].isNotEmpty)
                    ...mission['materiels_utilises'].map<pw.TableRow>((mat) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(mat['item'] ?? 'Non spécifié'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                                mat['quantite_utilisee']?.toString() ?? '0'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                                _formatDateForPdf(mat['date_utilisation'])),
                          ),
                        ],
                      );
                    }).toList()
                  else
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Aucun matériel utilisé',
                              style:
                                  pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('-'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('-'),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                          'Date du rapport: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
                      pw.SizedBox(height: 50),
                      pw.Text('Signature de l\'ambulancier:'),
                      pw.Container(
                        width: 200,
                        height: 1,
                        color: PdfColors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      await file.writeAsBytes(await pdf.save());

    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  Future<void> _uploadFileToFtp(File file) async {
    try {
      final FTPConnect ftpConnect = FTPConnect(
        ftpServerUrl,
        user: ftpUsername,
        pass: ftpPassword,
        port: 21,
      );

      await ftpConnect.connect();

      await ftpConnect.createFolderIfNotExist(remoteFilePath);

      // Utiliser le nom du fichier original
      String fileName = file.path.split('/').last;
      String remotePath = '$remoteFilePath$fileName';

      bool res = await ftpConnect.uploadFileWithRetry(file, pRetryCount: 2);

      await ftpConnect.disconnect();

      if (res) {
        // Gérer le succès de l'upload
      } else {
        throw Exception('Échec de l\'envoi du fichier');
      }
    } catch (e) {
      rethrow;
    }
  }

  List<Map<String, dynamic>> _getMissionsForDate(DateTime date) {
    try {
      final dateKey = DateTime(date.year, date.month, date.day);

      // Vérifier si les données sont en cache
      if (_missionsCache.containsKey(dateKey)) {
        return _missionsCache[dateKey]!;
      }

      // Filtrer les missions pour la date sélectionnée
      final filteredMissions = missions.where((mission) {
        try {
          if (mission['date_mission'] == null) return false;

          final missionDate = DateTime.parse(mission['date_mission']);
          final missionDay = DateTime(missionDate.year, missionDate.month, missionDate.day);

          return missionDay.isAtSameMomentAs(dateKey);
        } catch (e) {
          return false;
        }
      }).toList();

      // Trier les missions filtrées par date décroissante
      filteredMissions.sort((a, b) {
        final dateA = DateTime.parse(a['date_mission'] ?? DateTime.now().toIso8601String());
        final dateB = DateTime.parse(b['date_mission'] ?? DateTime.now().toIso8601String());
        return dateB.compareTo(dateA); // Tri décroissant
      });

      // Mettre en cache les résultats
      _missionsCache[dateKey] = filteredMissions;

      return filteredMissions;
    } catch (e) {
      return [];
    }
  }

  String _formatDateForPdf(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Non spécifiée';
    }
    try {
      // Gérer les différents formats de date
      if (dateString.contains('T')) {
        // Format ISO 8601
        final date = DateTime.parse(dateString);
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      } else if (dateString.contains(' ')) {
        // Format avec espace
        final parts = dateString.split(' ');
        if (parts.length >= 2) {
          final date = DateTime.parse(parts[0]);
          return DateFormat('dd/MM/yyyy').format(date) + ' ' + parts[1];
        }
      } else if (dateString.contains('-')) {
        // Format simple avec tirets
        final date = DateTime.parse(dateString);
        return DateFormat('dd/MM/yyyy').format(date);
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  String _formatTimeForPdf(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return 'Non spécifiée';
    }
    try {
      if (timeString.contains('T')) {
        // Format ISO 8601
        final dateTime = DateTime.parse(timeString);
        return DateFormat('HH:mm').format(dateTime);
      } else if (timeString.contains(':')) {
        // Format simple avec deux points
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
        }
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  Future<Uint8List> _loadLogoImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      return data.buffer.asUint8List();
    } catch (e) {
      // Gérer l'erreur silencieusement
      // Retourner une image vide en cas d'erreur
      return Uint8List(0);
    }
  }

  Future<void> _logout() async {
    try {
      await UserApi.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final missionService = Provider.of<MissionService>(context);
    final selectedDate = missionService.selectedDate;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.015,
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
              bottom: screenHeight * 0.01,
            ),
            child: Text(
              'Rapports des missions terminées',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          _buildDateSelector(missions),
          Expanded(
            child: missions.isEmpty
                ? _buildEmptyState(screenWidth, screenHeight)
                : _buildMissionsList(selectedDate, screenWidth, screenHeight),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;

    return PreferredSize(
      preferredSize:
          Size.fromHeight(isPortrait ? maxHeight * 0.15 : maxHeight * 0.25),
      child: Container(
        decoration: HeaderStyles.headerDecoration,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: maxWidth * 0.04,
              vertical: maxWidth * 0.02,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: HeaderStyles.headerAvatarDecoration,
                          child: CircleAvatar(
                            radius: maxWidth * (isTablet ? 0.03 : 0.06),
                            backgroundImage: userAvatar.isNotEmpty
                                ? NetworkImage(userAvatar.startsWith('http')
                                    ? userAvatar
                                    : 'http://$userAvatar')
                                : NetworkImage(
                                        'https://omnidoc.ma/wp-content/uploads/2025/04/ambulance-tanger-flotte-vehicules-omnidoc-1.webp')
                                    as ImageProvider,
                          ),
                        ),
                        SizedBox(width: maxWidth * 0.02),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Bienvenue',
                                style: TextStyle(
                                  fontSize:
                                      maxWidth * (isTablet ? 0.02 : 0.035),
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize:
                                      maxWidth * (isTablet ? 0.025 : 0.045),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: IconStyles.iconNotifications,
                              iconSize: maxWidth * (isTablet ? 0.03 : 0.06),
                              padding: EdgeInsets.all(maxWidth * 0.01),
                              constraints: BoxConstraints(),
                              onPressed: () {
                                Navigator.pushNamed(context, '/notifications');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isPortrait || !isTablet) ...[
                      SizedBox(height: maxWidth * 0.02),
                      SizedBox(
                        height: maxWidth * 0.08,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            prefixIcon:
                                Icon(Icons.search, color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: maxWidth * 0.02,
                              vertical: maxWidth * 0.01,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(List<Map<String, dynamic>> missions) {
    final missionService = Provider.of<MissionService>(context);
    final selectedDate = missionService.selectedDate;
    final selectedDayIndex = selectedDate.difference(DateTime.now()).inDays + 2;

    return DateSelector(
      initialIndex: selectedDayIndex,
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
        return missions.where((mission) {
          final missionDate = parseMissionDate(mission['date_mission']);
          return missionDate.day == date.day &&
              missionDate.month == date.month &&
              missionDate.year == date.year;
        }).length;
      },
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: screenWidth * 0.15,
            color: Colors.grey[400],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'Aucune mission disponible',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: screenWidth * 0.045,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Vous n\'avez aucune mission planifiée pour le moment.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsList(
      DateTime selectedDate, double screenWidth, double screenHeight) {
    final missions = _getMissionsForDate(selectedDate);

    if (missions.isEmpty) {
      return _buildEmptyState(screenWidth, screenHeight);
    }

    return RefreshIndicator(
      onRefresh: _loadMissions,
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: missions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: Text(
                DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate),
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            );
          }

          final mission = missions[index - 1];
          return Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: Container(
              decoration: CardStyles.cardDecoration,
              child: Column(
                children: [
                  InterventionCard(
                    intervention: {
                      'title':
                          mission['type_mission'] ?? 'Mission non spécifiée',
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
                      'bon_de_commande':
                          mission['bon_de_commande'] ?? 'Non spécifié',
                      'cause': mission['cause'] ?? 'Non spécifiée',
                      'urgence':
                          mission['urgence'] == 1 ? 'Urgent' : 'Non urgent',
                      'statut': mission['statut']?.toString().toLowerCase() ??
                          'non spécifié',
                      'etat_mission':
                          mission['etat_mission']?.toString().toLowerCase() ??
                              'non spécifié',
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: ElevatedButton.icon(
                      onPressed: () => _openLocalReport(mission),
                      icon: Icon(Icons.visibility, color: Colors.white),
                      label: Text(
                        'Afficher le rapport',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openLocalReport(Map<String, dynamic> mission) async {
    try {
      final fileName = 'mission_${mission['id']}.pdf';
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Le rapport n\'est pas encore disponible'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final result = await OpenFile.open(file.path);

      if (result.type == ResultType.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'ouvrir le rapport: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ouverture du rapport'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBarStyles.buildBottomNavigationBar(
      context: context,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  pw.TableRow _buildTimeRow(String label, String time) {
    final modifiedLabel = label.replaceAll('→', '->');

    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(
            modifiedLabel,
            style: pw.TextStyle(
              font: pw.Font.helvetica(),
              fontSize: 10,
            ),
          ),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(
            time,
            style: pw.TextStyle(
              font: pw.Font.helvetica(),
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  DateTime parseMissionDate(String? dateString) {
    if (dateString == null) return DateTime.now();
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }
}
