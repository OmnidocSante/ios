import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../styles/colors.dart';
import '../styles/text_styles.dart' as old_styles;
import '../styles/card_styles.dart';
import '../styles/header_styles.dart';
import '../styles/button_styles.dart';
import '../styles/icon_styles.dart';
import '../api/user_api.dart';
import '../api/patient_api.dart';
import '../api/mission_api.dart';
import '../api/chat_api.dart';
import '../api/vehicle_api.dart';
import 'package:intl/intl.dart';
import '../services/firebase_notification_service.dart';
import 'mission_tracking_screen.dart';
import 'chat_screen.dart';
import '../styles/app_dimensions.dart';
import '../styles/app_text_styles.dart';
import '../widgets/common_widgets.dart';
import '../widgets/patient_info_widgets.dart';
import 'dart:async';

class PatientInfoScreen extends StatefulWidget {
  final int? patientId;
  final int? missionId;

  const PatientInfoScreen({
    Key? key,
    this.patientId,
    this.missionId,
  }) : super(key: key);

  @override
  _PatientInfoScreenState createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? patientInfo;
  Map<String, dynamic>? missionInfo;
  bool isLoading = false;
  double? latitude;
  double? longitude;
  List<Map<String, dynamic>> messages = [];
  TextEditingController messageController = TextEditingController();
  String? currentUserId;
  String? currentUserName;
  String? currentUserRole;
  bool isChatExpanded = false;
  bool _isInitialized = false;
  StreamController<Map<String, dynamic>> _missionStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  StreamController<Map<String, dynamic>> _patientStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Timer? _updateTimer;
  DateTime? _lastUpdateTime;
  static const Duration _updateInterval = Duration(seconds: 30);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _startPeriodicUpdates();
  }

  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(_updateInterval, (timer) {
      if (mounted && _shouldUpdate()) {
        _loadData();
      }
    });
  }

  bool _shouldUpdate() {
    if (_lastUpdateTime == null) return true;
    return DateTime.now().difference(_lastUpdateTime!) >= _updateInterval;
  }

  Future<void> _initializeScreen() async {
    if (!_isInitialized) {
      try {
        final userInfo = await UserApi.getUserInfo();
        if (!mounted) return;
        
        setState(() {
          currentUserRole = userInfo['rôle']?.toString().toLowerCase();
        });
      
      await Future.wait([
        _loadData(),
        _initializeChat(),
        ], eagerError: true);

        if (mounted) {
          setState(() {
      _isInitialized = true;
          });
        }
      } catch (e) {
        // Gérer l'erreur silencieusement
      }
    }
  }

  Future<void> _initializeChat() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      if (!mounted) {
        return;
      }

      setState(() {
        currentUserId = userInfo['id'].toString();
        currentUserName = '${userInfo['nom']} ${userInfo['prenom']}';
      });

      if (widget.missionId != null) {
        ChatApi.initializeSocket();

        ChatApi.socket?.on('message', (data) {
          if (data['mission_id'].toString() == widget.missionId.toString()) {
            if (mounted) {
              setState(() {
                messages.insert(0, {
                  'sender': data['sender'] ?? 'Inconnu',
                  'time': DateTime.now().toString().substring(11, 16),
                  'message': data['message'] ?? '',
                  'image': data['image_url'] ?? '',
                  'isCurrentUser': data['sender_id'] == currentUserId,
                });
              });
            }
          }
        });

        try {
          final history =
              await ChatApi.getMessageHistory(widget.missionId.toString());

          if (!mounted) {
            return;
          }

          setState(() {
            messages = history.map((msg) {
              String time = '';
              try {
                if (msg['timestamp'] != null) {
                  time = DateTime.parse(msg['timestamp'].toString())
                      .toString()
                      .substring(11, 16);
                } else {
                  time = DateTime.now().toString().substring(11, 16);
                }
              } catch (e) {
                time = DateTime.now().toString().substring(11, 16);
              }

              return {
                'sender': msg['sender'] ?? 'Inconnu',
                'time': time,
                'message': msg['message'] ?? '',
                'image': msg['image_url'] ?? '',
                'isCurrentUser': msg['sender_id'] == currentUserId,
              };
            }).toList();
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors du chargement des messages'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'initialisation du chat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }
    if (widget.missionId == null) {
      return;
    }
    if (currentUserId == null || currentUserName == null) {
      return;
    }

    try {
      await ChatApi.sendMessage(
        sender: currentUserName!,
        message: messageController.text,
        userId: currentUserId!,
        missionId: widget.missionId.toString(),
      );
      messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi du message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _missionStreamController.close();
    _patientStreamController.close();
    ChatApi.disconnectSocket();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted || isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (widget.patientId != null && widget.patientId! > 0) {
        final patient = await PatientApi.getPatientInfo(widget.patientId!);
        if (mounted) {
          setState(() {
            patientInfo = patient;
          });
          _patientStreamController.add(patient);
        }
      }

      if (widget.missionId != null) {
        final mission = await MissionApi.getMission(widget.missionId!);

        if ((patientInfo == null ||
                widget.patientId == null ||
                widget.patientId! <= 0) &&
            mission['patient_id'] != null &&
            mission['patient_id'] > 0) {
          final patient =
              await PatientApi.getPatientInfo(mission['patient_id']);
          if (mounted) {
            setState(() {
              patientInfo = patient;
            });
            _patientStreamController.add(patient);
          }
        }

        if (mounted) {
          setState(() {
            missionInfo = mission;
            _lastUpdateTime = DateTime.now();
          });
          _missionStreamController.add(mission);
        }
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _generateAndShareReport() async {
    try {
      final String reportContent = '''
=== RAPPORT D'INTERVENTION ===

INFORMATIONS PATIENT:
ID: ${patientInfo!['id']}
Nom: ${patientInfo!['nom']} ${patientInfo!['prenom']}
Date de naissance: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(patientInfo!['date_naissance']))}
Téléphone: ${patientInfo!['téléphone'] ?? 'Non spécifié'}
Ville: ${patientInfo!['ville'] ?? 'Non spécifiée'}
Type de client: ${patientInfo!['type_client'] ?? 'Non spécifié'}

DÉTAILS DE L'INTERVENTION:
Type: ${missionInfo!['type_mission'] ?? 'Non spécifié'}
Date et heure: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(missionInfo!['date_mission'] ?? DateTime.now().toIso8601String()))} - ${missionInfo!['heure_depart'] ?? 'Non spécifiée'}
Urgence: ${missionInfo!['urgence'] == 1 ? 'Oui' : 'Non'}
Description: ${missionInfo!['description'] ?? 'Non spécifiée'}
Adresse: ${missionInfo!['adresse'] ?? 'Non spécifiée'}
Adresse de destination: ${missionInfo!['adresse_destination'] ?? 'Non spécifiée'}
Cause: ${missionInfo!['cause'] ?? 'Non spécifiée'}
Demande de matériel: ${missionInfo!['demande_materiel'] ?? 'Non spécifiée'}
État de la mission: ${missionInfo!['etat_mission'] ?? 'Non spécifié'}
Statut: ${missionInfo!['statut'] ?? 'Non spécifié'}
Prix: ${missionInfo!['prix'] ?? 'Non spécifié'} DH
Mode de paiement: ${missionInfo!['paiement'] ?? 'Non spécifié'}
Payé: ${missionInfo!['paye'] == 1 ? 'Oui' : 'Non'}
Ville: ${missionInfo!['ville'] ?? 'Non spécifiée'}
Bon de commande: ${missionInfo!['bon_de_commande'] ?? 'Non spécifié'}
Créé le: ${missionInfo!['créé_le'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(missionInfo!['créé_le'])) : 'Non spécifié'}
''';

      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'rapport_intervention_${patientInfo!['id']}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final File file = File('${directory.path}/$fileName');
      await file.writeAsString(reportContent);

      // Implementation of _generateAndShareReport method
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  Future<void> _cancelMission() async {
    try {
      if (missionInfo != null) {
        // Afficher une boîte de dialogue de confirmation
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmer l\'annulation'),
              content: Text('Voulez-vous vraiment annuler cette mission ?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Non'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Oui'),
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          Map<String, dynamic> missionData = {...missionInfo!};
          missionData['statut'] = 'annulée';

          await MissionApi.updateMission(missionInfo!['id'], missionData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mission annulée avec succès'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Retourner à l'écran précédent
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation de la mission'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final contentPadding = screenWidth * 0.04;
    final isDoctor = currentUserRole == 'médecin' || currentUserRole == 'medecin';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: PatientInfoWidgets.buildAppBar(
        context: context,
        title: missionInfo != null
            ? 'Détails de la mission'
            : 'Information Patient',
        onBackPressed: () => Navigator.pop(context),
        onChatPressed: widget.missionId != null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      missionId: widget.missionId.toString(),
                    ),
                  ),
                )
            : null,
      ),
      floatingActionButton: missionInfo != null && missionInfo!['statut']?.toLowerCase() != 'annulée'
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isDoctor)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: FloatingActionButton.extended(
                      heroTag: 'cancel_mission_button',
                      onPressed: _cancelMission,
                      backgroundColor: Colors.red,
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text(
                        'Annuler la mission',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                FloatingActionButton.extended(
                  heroTag: 'accept_mission_button',
                  onPressed: () async {
                    try {
                      if (missionInfo != null) {
                        if (missionInfo!['heure_affectation'] != null) {
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MissionTrackingScreen(
                                  missionId: missionInfo!['id'],
                                  missionData: missionInfo!,
                                ),
                              ),
                            );
                          }
                          return;
                        }

                        final now = DateTime.now().toIso8601String();
                        Map<String, dynamic> missionData = {...missionInfo!};
                        missionData['heure_affectation'] = now;
                        missionData['statut'] = 'en cours';

                        await MissionApi.updateMission(missionInfo!['id'], missionData);

                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MissionTrackingScreen(
                                missionId: missionInfo!['id'],
                                missionData: missionData,
                              ),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Gérer l'erreur silencieusement
                    }
                  },
                  backgroundColor: Colors.green,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text(
                    'Accepter',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            if (missionInfo != null && missionInfo!['patient_id'] == 0)
              SliverToBoxAdapter(
                child: PatientInfoWidgets.buildWarningBanner(
                  context: context,
                  message:
                      'Cette mission n\'a pas de patient associé. Veuillez contacter l\'administrateur.',
                ),
              ),
            if (patientInfo != null)
              SliverToBoxAdapter(
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: _patientStreamController.stream,
                  initialData: patientInfo,
                  builder: (context, snapshot) {
                    return Padding(
                      padding: EdgeInsets.all(contentPadding),
                      child: PatientInfoWidgets.buildPatientInfoCard(
                        context: context,
                        patientInfo: snapshot.data ?? patientInfo!,
                        isTablet: isTablet,
                      ),
                    );
                  },
                ),
              ),
            if (missionInfo != null)
              SliverToBoxAdapter(
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: _missionStreamController.stream,
                  initialData: missionInfo,
                  builder: (context, snapshot) {
                    return Padding(
                      padding: EdgeInsets.all(contentPadding),
                      child: PatientInfoWidgets.buildMissionInfoCard(
                        context: context,
                        missionInfo: snapshot.data ?? missionInfo!,
                        isTablet: isTablet,
                      ),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: 100), // Espace pour les boutons flottants
            ),
          ],
        ),
      ),
    );
  }
}
