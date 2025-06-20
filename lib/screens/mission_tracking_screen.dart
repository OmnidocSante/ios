import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../api/mission_api.dart';
import '../api/user_api.dart';
import '../api/material_api.dart';
import '../api/vehicle_api.dart';
import '../api/chat_api.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../widgets/home/mission_tracking_widgets.dart';
import '../screens/chat_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/methods/mission_tracking_methods.dart';
import 'dart:async';

class MissionTrackingScreen extends StatefulWidget {
  final int missionId;
  final Map<String, dynamic> missionData;

  const MissionTrackingScreen({
    Key? key,
    required this.missionId,
    required this.missionData,
  }) : super(key: key);

  @override
  _MissionTrackingScreenState createState() => _MissionTrackingScreenState();
}

class _MissionTrackingScreenState extends State<MissionTrackingScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Map<String, dynamic> _missionData = {};
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isAmbulancier = false;
  String _currentStep = 'en_attente';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<Map<String, dynamic>> _selectedMaterialsTemp = [];
  List<Map<String, dynamic>> _selectedMaterialsSaved = [];
  List<Map<String, dynamic>> _availableMaterials = [];
  TextEditingController _quantityController = TextEditingController();
  Map<String, dynamic>? _selectedMaterial;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _missionData = widget.missionData;
    _setupAnimations();
    _initializeData();
    _loadDataInBackground();
    _loadUsedMaterials();
    _loadTempMaterialsLocally();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  void _initializeData() {
    _quantityController = TextEditingController(text: '1');
  }

  Future<void> _loadDataInBackground() async {
    if (!mounted) return;
    
    try {
      final userInfo = await UserApi.getUserInfo();
      if (!mounted) return;

      final isAmbulancier = userInfo['rôle'] == 'ambulancier';
      
      final results = await Future.wait([
        _loadMissionDataFromApi(),
        if (isAmbulancier) _loadMaterials(),
      ]);

      if (!mounted) return;

      setState(() {
        _isAmbulancier = isAmbulancier;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMissionDataFromApi() async {
    try {
      final missionData = await MissionApi.getMissionDetails(widget.missionId);
      if (missionData == null || !mounted) return;

      setState(() {
        _missionData = missionData;
        _currentStep = _missionData['statut'] ?? 'en_attente';
      });
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  String _getButtonText() {
    final userRole = Provider.of<UserService>(context, listen: false).userInfo['rôle'];
    final isAmbulancier = userRole == 'ambulancier';
    final isDoctorOrNurse = userRole == 'médecin' || userRole == 'medecin' || userRole == 'infirmier';

    String buttonText = '';
    if (isAmbulancier) {
      if (_missionData['heure_depart'] == null) {
        buttonText = 'Départ';
      } else if (_missionData['heure_arrivee'] == null) {
        buttonText = 'Arrivée';
      } else if (_missionData['heure_redepart'] == null) {
        buttonText = 'Redépart';
      } else if (_missionData['heure_fin'] == null) {
        buttonText = 'Fin';
      }
    } else if (isDoctorOrNurse) {
      if (_missionData['heure_depart'] == null) {
        buttonText = 'Départ';
      } else if (_missionData['heure_arrivee'] == null) {
        buttonText = 'Arrivée';
      } else if (_missionData['heure_fin'] == null) {
        buttonText = 'Fin';
      }
    }
    return buttonText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildMissionSteps(),
                const SizedBox(height: 16),
                _buildMissionHeader(),
                const SizedBox(height: 16),
                if (_missionData['heure_arrivee'] != null) ...[
                  _buildDestinationCard(),
                  const SizedBox(height: 16),
                ],
                if (_missionData['adresse'] != null) ...[
                  _buildLocationCard(),
                  const SizedBox(height: 16),
                ],
                if (_isAmbulancier) ...[
                  _buildMaterialsCard(),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final buttonText = _getButtonText();

    return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
            onPressed: _handleLocationButton,
              icon: Icon(
                Icons.location_on,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
            label: const Text(
                'Localiser',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          if (buttonText.isNotEmpty)
            Expanded(
              child: ElevatedButton(
              onPressed: _handleNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  buttonText,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        if (_isAmbulancier && _missionData['heure_fin'] != null)
            Expanded(
              child: ElevatedButton.icon(
              onPressed: _handleSaveMaterials,
                icon: Icon(
                  Icons.save,
                  size: MediaQuery.of(context).size.width * 0.06,
                ),
              label: const Text(
                  'Enregistrer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
              ),
            ),
        ],
    );
  }

  Widget _buildMissionSteps() {
    final userRole = Provider.of<UserService>(context, listen: false).userInfo['rôle'];
    final isAmbulancier = userRole == 'ambulancier';
    final isDoctorOrNurse = userRole == 'médecin' || userRole == 'medecin' || userRole == 'infirmier';

    List<StepInfo> steps = [];
    if (isAmbulancier) {
      steps = [
        StepInfo(
          Icons.check_circle,
          'Acceptation',
          _missionData['heure_affectation'] != null,
          _missionData['heure_affectation'] != null ? Colors.green : Colors.grey[300]!,
        ),
        StepInfo(
          Icons.directions_car,
          'Départ',
          _missionData['heure_depart'] != null,
          _missionData['heure_depart'] != null ? Colors.green : Colors.grey[300]!,
        ),
        StepInfo(
          Icons.location_on,
          'Arrivée',
          _missionData['heure_arrivee'] != null,
          _missionData['heure_arrivee'] != null ? Colors.green : Colors.grey[300]!,
        ),
        StepInfo(
          Icons.directions_car_filled,
          'Redépart',
          _missionData['heure_redepart'] != null,
          _missionData['heure_redepart'] != null ? Colors.green : Colors.grey[300]!,
        ),
        StepInfo(
          Icons.check_circle,
          'Fin',
          _missionData['heure_fin'] != null,
          _missionData['heure_fin'] != null ? Colors.green : Colors.grey[300]!,
        ),
      ];
    } else if (isDoctorOrNurse) {
      steps = [
        StepInfo(
          Icons.check_circle,
          'Acceptation',
          _missionData['heure_affectation'] != null,
          _missionData['heure_affectation'] != null ? Colors.green : Colors.grey[300]!,
        ),
        StepInfo(
          Icons.directions_car,
          'Départ',
          _missionData['heure_depart'] != null,
          _missionData['heure_depart'] != null ? Colors.green : Colors.grey[300]!,
        ),
        StepInfo(
          Icons.location_on,
          'Arrivée',
          _missionData['heure_arrivee'] != null,
          _missionData['heure_arrivee'] != null ? Colors.green : Colors.grey[300]!,
        ),
        StepInfo(
          Icons.check_circle,
          'Fin',
          _missionData['heure_fin'] != null,
          _missionData['heure_fin'] != null ? Colors.green : Colors.grey[300]!,
        ),
      ];
    }

    return Card(
      elevation: 8,
      shadowColor: AppColors.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Suivi des Étapes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 30),
            _buildStepsRow(steps),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionHeader() {
    return MissionTrackingWidgets.buildMissionHeader(context, _missionData);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Suivi de Mission'),
                backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.message, color: Colors.white),
          tooltip: 'Accéder au chat',
          onPressed: () {
            if (_missionData['id'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    missionId: _missionData['id'].toString(),
                  ),
                ),
              );
            }
          },
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }

  Widget _buildMaterialsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Matériaux utilisés',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                if (_isAmbulancier)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _showMaterialSelectionDialog();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedMaterialsTemp.isEmpty)
              const Text('Aucun matériau utilisé')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedMaterialsTemp.length,
                itemBuilder: (context, index) {
                  final material = _selectedMaterialsTemp[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.medical_services,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        material['item'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Quantité: ${material['quantite_utilisee']}'),
                      trailing: _isAmbulancier
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                setState(() {
                                  _selectedMaterialsTemp.removeAt(index);
                                });
                                await _saveTempMaterialsLocally();
                              },
                            )
                          : null,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showMaterialSelectionDialog() {
    final TextEditingController searchController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(text: '1');
    List<Map<String, dynamic>> filteredMaterials = List.from(_availableMaterials);
    Map<String, dynamic>? selectedMaterial;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) => Dialog(
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Sélectionner un matériel',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un matériel...',
                      prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      dialogSetState(() {
                        filteredMaterials = _availableMaterials
                            .where((material) =>
                                material['item'].toString().toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredMaterials.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aucun matériel trouvé',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: filteredMaterials.map((material) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.medical_services,
                                    color: AppColors.primaryColor,
                                  ),
                                  title: Text(
                                    material['item'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('Quantité disponible: ${material['quantite']}'),
                                  onTap: () {
                                    selectedMaterial = material;
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext quantityContext) => AlertDialog(
                                        title: const Text('Quantité utilisée'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              material['item'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Quantité disponible: ${material['quantite']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            TextField(
                                              controller: quantityController,
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Quantité',
                                                hintText: 'Entrez la quantité utilisée',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(quantityContext),
                                            child: const Text('Annuler'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final quantity = int.tryParse(quantityController.text) ?? 1;
                                              if (quantity > 0 && quantity <= material['quantite']) {
                                                setState(() {
                                                  _selectedMaterialsTemp.add({
                                                    ...material,
                                                    'quantite_utilisee': quantity,
                                                  });
                                                });
                                                await _saveTempMaterialsLocally();
                                                Navigator.pop(quantityContext);
                                                Navigator.pop(dialogContext);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Quantité invalide'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Ajouter'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSaveMaterials() async {
    print('🔵 MissionTrackingScreen: Début de la sauvegarde des matériaux');
    print('🔵 MissionTrackingScreen: Nombre de matériaux sélectionnés: ${_selectedMaterialsTemp.length}');
    
    if (_selectedMaterialsTemp.isEmpty) {
      print('🔵 MissionTrackingScreen: Aucun matériel sélectionné, continuation directe');
      await _saveMaterialUsage();
      return;
    }
    print('🔵 MissionTrackingScreen: Matériaux à sauvegarder: $_selectedMaterialsTemp');
    await _saveMaterialUsage();
  }

  Future<void> _saveMaterialUsage() async {
    try {
      print('🔵 MissionTrackingScreen: Début de l\'enregistrement des matériaux');
      final userInfo = await UserApi.getUserInfo();
      print('🔵 MissionTrackingScreen: Rôle utilisateur: ${userInfo['rôle']}');
      
      if (userInfo['rôle'] != 'ambulancier') {
        print('🔵 MissionTrackingScreen: Utilisateur n\'est pas ambulancier, arrêt');
        return;
      }

      final vehicle = await VehicleApi.getVehicleByUserId(userInfo['id']);
      if (vehicle == null) {
        print('🔵 MissionTrackingScreen: Aucun véhicule trouvé pour l\'utilisateur');
        return;
      }
      print('🔵 MissionTrackingScreen: Véhicule trouvé: ${vehicle['id']}');

      final ambulanceId = vehicle['id'];
      final token = await _getToken();

      if (_selectedMaterialsTemp.isNotEmpty) {
        print('🔵 MissionTrackingScreen: Mise à jour des quantités de matériaux');
        for (var material in _selectedMaterialsTemp) {
          final currentQuantity = material['quantite'] as int;
          final usedQuantity = material['quantite_utilisee'] as int;
          final newQuantity = currentQuantity - usedQuantity;
          print('🔵 MissionTrackingScreen: Matériel ${material['item']} - Quantité actuelle: $currentQuantity, Utilisée: $usedQuantity, Nouvelle quantité: $newQuantity');

          final updateData = {
            'id': material['id'],
            'item': material['item'],
            'quantite': newQuantity,
            'ambulance_id': ambulanceId
          };

          final updateResponse = await http.put(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.materialsEndpoint}/${material['id']}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(updateData),
          );

          if (updateResponse.statusCode != 200) {
            print('🔴 MissionTrackingScreen: Erreur lors de la mise à jour du matériel ${material['item']}');
            throw Exception('Échec de la mise à jour de la quantité');
          }
          print('🔵 MissionTrackingScreen: Matériel ${material['item']} mis à jour avec succès');
        }

        final items = _selectedMaterialsTemp.map((m) => m['item'] as String).toList();
        final quantities = _selectedMaterialsTemp.map((m) => m['quantite_utilisee'] as int).toList();
        print('🔵 MissionTrackingScreen: Enregistrement de l\'utilisation des matériaux');
        print('🔵 MissionTrackingScreen: Items: $items');
        print('🔵 MissionTrackingScreen: Quantités: $quantities');

        final usageData = {
          'ambulance_id': ambulanceId,
          'patient_id': _missionData['patient_id'],
          'item': items,
          'quantite_utilisee': quantities,
          'mission_id': widget.missionId,
          'date_utilisation': DateTime.now().toIso8601String(),
        };

        final usageResponse = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/utilisation_materiel'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(usageData),
        );

        if (usageResponse.statusCode != 200 && usageResponse.statusCode != 201) {
          print('🔴 MissionTrackingScreen: Erreur lors de l\'enregistrement de l\'utilisation');
          throw Exception('Échec de l\'enregistrement de l\'utilisation');
        }
        print('🔵 MissionTrackingScreen: Utilisation des matériaux enregistrée avec succès');

        await _loadUsedMaterials();
        setState(() {
          _selectedMaterialsTemp.clear();
        });
        await _clearTempMaterialsLocally();
        print('🔵 MissionTrackingScreen: Données temporaires nettoyées');
      } else {
        print('🔵 MissionTrackingScreen: Aucun matériel à enregistrer');
      }

      if (mounted) {
        print('🔵 MissionTrackingScreen: Redirection vers la page d\'accueil');
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      print('🔴 MissionTrackingScreen: Erreur lors de la sauvegarde des matériaux: $e');
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token d\'authentification non disponible');
      }
      return token;
    } catch (e) {
      throw Exception('Erreur d\'authentification: $e');
    }
  }

  Widget _buildStepIcon(IconData icon, String label, bool isCompleted, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Icon(
        icon,
        color: isCompleted ? Colors.white : Colors.grey[600],
        size: 24,
      ),
    );
  }

  Widget _buildStepConnector(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.symmetric(horizontal: 4),
        color: isCompleted ? Colors.green : Colors.grey[300],
      ),
    );
  }

  Widget _buildStepsRow(List<StepInfo> steps) {
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          steps.length * 2 - 1,
          (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
              if (stepIndex >= steps.length) {
                return const SizedBox.shrink();
              }
            return _buildStepIcon(
              steps[stepIndex].icon,
              steps[stepIndex].label,
              steps[stepIndex].isCompleted,
              steps[stepIndex].color,
            );
          } else {
            final previousStepIndex = index ~/ 2;
              if (previousStepIndex >= steps.length - 1) {
                return const SizedBox.shrink();
              }
            return _buildStepConnector(steps[previousStepIndex].isCompleted);
          }
          },
        ),
      ),
    );
  }

  Future<Map<String, double>?> _getCoordinates(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent('$address, Maroc');
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=AIzaSyBmnUN64iSMgThm_AwB4iYs-rYlQSX6jDw'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'],
            'lng': location['lng'],
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getStaticMapUrl() {
    String address = _missionData['heure_arrivee'] != null && _missionData['adresse_destination'] != null
        ? _missionData['adresse_destination']!
        : _missionData['adresse'] ?? '';
    
    // Encoder l'adresse pour l'URL
    final encodedAddress = Uri.encodeComponent('$address, Maroc');
    
    // Utiliser l'API Static Maps de Google avec le format correct
    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$encodedAddress'
        '&zoom=15'
        '&size=600x300'
        '&maptype=roadmap'
        '&markers=color:red%7C$encodedAddress'
        '&key=AIzaSyBmnUN64iSMgThm_AwB4iYs-rYlQSX6jDw';
  }

  Widget _buildLocationCard() {
    // Déterminer quelle adresse afficher
    String currentAddress;
    if (_missionData['heure_arrivee'] != null && _missionData['adresse_destination'] != null) {
      currentAddress = _missionData['adresse_destination']!;
    } else {
      currentAddress = _missionData['adresse'] ?? 'Aucune adresse disponible';
    }

    return Card(
      elevation: 8,
      shadowColor: AppColors.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Localisation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
                ),
                Text(
                  _missionData['heure_arrivee'] != null ? 'Destination' : 'Point de départ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FutureBuilder<Map<String, double>?>(
                  future: _getCoordinates(currentAddress),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
                              'Impossible de charger la carte',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
                          ],
                        ),
                      );
                    }

                    final coordinates = snapshot.data!;
                    final mapUrl = 'https://maps.googleapis.com/maps/api/staticmap?'
                        'center=${coordinates['lat']},${coordinates['lng']}'
                        '&zoom=15'
                        '&size=600x300'
                        '&maptype=roadmap'
                        '&markers=color:red%7C${coordinates['lat']},${coordinates['lng']}'
                        '&key=AIzaSyBmnUN64iSMgThm_AwB4iYs-rYlQSX6jDw';

                    return Image.network(
                      mapUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 48,
                                color: AppColors.primaryColor,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Impossible de charger la carte',
                  style: TextStyle(
                    color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentAddress,
                      style: TextStyle(
                        color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
              ),
          ],
      ),
            ),
          ],
          ),
        ),
      );
  }

  Future<void> _handleNextStep() async {
    try {
        if (mounted) {
        setState(() => _isLoading = true);
      }

      String timeField;
      final userRole = Provider.of<UserService>(context, listen: false).userInfo['rôle'];
      final isAmbulancier = userRole == 'ambulancier';
      final isDoctorOrNurse = userRole == 'médecin' || userRole == 'medecin' || userRole == 'infirmier';

      if (isAmbulancier) {
        if (_missionData['heure_depart'] == null) {
          timeField = 'heure_depart';
        } else if (_missionData['heure_arrivee'] == null) {
          timeField = 'heure_arrivee';
        } else if (_missionData['heure_redepart'] == null) {
          timeField = 'heure_redepart';
        } else if (_missionData['heure_fin'] == null) {
          timeField = 'heure_fin';
        } else {
          await _updateMission();
          return;
        }
      } else if (isDoctorOrNurse) {
        if (_missionData['heure_depart'] == null) {
          timeField = 'heure_depart';
        } else if (_missionData['heure_arrivee'] == null) {
          timeField = 'heure_arrivee';
        } else if (_missionData['heure_fin'] == null) {
          timeField = 'heure_fin';
          await _updateMissionTime(timeField);
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
          return;
        } else {
          await _updateMission();
          return;
        }
      } else {
        return;
      }

      await _updateMissionTime(timeField);
    } catch (e) {
      // Gérer l'erreur silencieusement
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLocationButton() async {
    try {
      String destinationAddress;
      
      if (_missionData['heure_arrivee'] != null) {
        if (_missionData['adresse_destination'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez d\'abord ajouter une adresse de destination'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        destinationAddress = _missionData['adresse_destination']!;
      } else {
        if (_missionData['adresse'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune adresse disponible'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        destinationAddress = _missionData['adresse']!;
      }

      destinationAddress = '$destinationAddress, Maroc';
      final encodedDestination = Uri.encodeComponent(destinationAddress);

      final Map<String, String> navigationApps = {
        'Google Maps': 'comgooglemaps://?daddr=$encodedDestination&directionsmode=driving',
        'Waze': 'waze://?q=$encodedDestination&navigate=yes',
      };

      if (mounted) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Choisir une application',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  ...navigationApps.entries.map((app) {
                    return ListTile(
                      leading: Icon(
                        app.key == 'Google Maps' ? Icons.map : Icons.navigation,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(app.key),
                      onTap: () async {
                        Navigator.pop(context);
                        final Uri uri = Uri.parse(app.value);

                        try {
      if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.platformDefault,
                            );
      } else {
                            if (app.key == 'Google Maps') {
                              final alternativeUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encodedDestination&travelmode=driving');
                              if (await canLaunchUrl(alternativeUri)) {
                                await launchUrl(alternativeUri, mode: LaunchMode.externalApplication);
                                return;
                              }
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Impossible d\'ouvrir ${app.key}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
        }
      }
    } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur lors de l\'ouverture de ${app.key}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ouverture de la navigation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateMissionTime(String timeField) async {
    try {
      if (_missionData[timeField] != null) {
        return;
      }

      final now = DateTime.now();
      final formattedTime = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(now);

      final updatedData = Map<String, dynamic>.from(_missionData);
      updatedData[timeField] = formattedTime;

      // Calculer les temps pour chaque étape
        switch (timeField) {
          case 'heure_depart':
            if (_missionData['heure_affectation'] != null) {
            final affectationTime = DateTime.parse(_missionData['heure_affectation']);
              final difference = now.difference(affectationTime);
            updatedData['temps_depart'] = _formatDuration(difference);
            updatedData['temps_attente'] = _formatDuration(difference);
            }
            break;
          case 'heure_arrivee':
            if (_missionData['heure_depart'] != null) {
              final departTime = DateTime.parse(_missionData['heure_depart']);
              final difference = now.difference(departTime);
            updatedData['temps_arrivee'] = _formatDuration(difference);
            updatedData['temps_trajet'] = _formatDuration(difference);
            }
            break;
          case 'heure_redepart':
            if (_missionData['heure_arrivee'] != null) {
              final arriveeTime = DateTime.parse(_missionData['heure_arrivee']);
              final difference = now.difference(arriveeTime);
            updatedData['temps_redepart'] = _formatDuration(difference);
            updatedData['temps_intervention'] = _formatDuration(difference);
            }
            break;
          case 'heure_fin':
          // Calculer le temps de fin
            if (_missionData['heure_redepart'] != null) {
            final redepartTime = DateTime.parse(_missionData['heure_redepart']);
              final difference = now.difference(redepartTime);
            updatedData['temps_fin'] = _formatDuration(difference);
            updatedData['temps_retour'] = _formatDuration(difference);
          } else if (_missionData['heure_arrivee'] != null) {
            final arriveeTime = DateTime.parse(_missionData['heure_arrivee']);
            final difference = now.difference(arriveeTime);
            updatedData['temps_fin'] = _formatDuration(difference);
            updatedData['temps_intervention'] = _formatDuration(difference);
          }

          // Calculer le temps total de la mission
              if (_missionData['heure_affectation'] != null) {
              final debutMission = DateTime.parse(_missionData['heure_affectation']);
                final difference = now.difference(debutMission);
              updatedData['temps_total'] = _formatDuration(difference);
            updatedData['temps_total_intervention'] = _formatDuration(difference);
            }
            break;
        }

      updatedData['statut'] = timeField == 'heure_fin' ? 'terminée' : 'en cours';

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/missions/${widget.missionId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          setState(() {
            _missionData = updatedData;
          });
        }
      }

      if (timeField == 'heure_fin' && _isAmbulancier) {
        final vehicle = await VehicleApi.getVehicleByUserId(
          (await UserApi.getUserInfo())['id'],
        );
          if (vehicle != null) {
            await VehicleApi.updateVehicleStatus(vehicle['id'], 'disponible');
          }
        await _showMaterialDialog();
        }
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    int totalHours = duration.inHours;
    int totalMinutes = duration.inMinutes.remainder(60);
    int totalSeconds = duration.inSeconds.remainder(60);

    if (duration.isNegative) {
      totalHours = duration.inHours.abs();
      totalMinutes = duration.inMinutes.remainder(60).abs();
      totalSeconds = duration.inSeconds.remainder(60).abs();

      totalHours = 24 - totalHours;
      if (totalMinutes > 0 || totalSeconds > 0) {
        totalHours = (totalHours - 1) % 24;
        totalMinutes = 60 - totalMinutes;
        totalSeconds = 60 - totalSeconds;
      }
    }

    if (totalSeconds >= 60) {
      totalMinutes += totalSeconds ~/ 60;
      totalSeconds = totalSeconds % 60;
    }

    if (totalMinutes >= 60) {
      totalHours += totalMinutes ~/ 60;
      totalMinutes = totalMinutes % 60;
    }

    return "${twoDigits(totalHours)}:${twoDigits(totalMinutes)}:${twoDigits(totalSeconds)}";
  }

  Future<void> _loadMaterials() async {
    try {
      final userInfo = await UserApi.getUserInfo();
      if (userInfo['rôle'] != 'ambulancier' || !mounted) return;

      final vehicle = await VehicleApi.getVehicleByUserId(userInfo['id']);
      if (vehicle == null || !mounted) return;

      final ambulanceId = vehicle['id'].toString();
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.materialsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final List<dynamic> allMaterials = json.decode(response.body);
        final filteredMaterials = allMaterials
            .where((material) =>
                material['ambulance_id'].toString() == ambulanceId &&
                (material['quantite'] ?? 0) > 0)
            .map((material) => Map<String, dynamic>.from(material))
            .toList();

          setState(() {
            _availableMaterials = filteredMaterials;
          });
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  Future<void> _updateMission() async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/missions/${widget.missionId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(_missionData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      if (mounted) {
        setState(() {
            _missionData['statut'] = 'terminée';
                });
              }
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  Widget _buildDestinationCard() {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adresse de destination',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.primaryColor),
                  onPressed: () async {
                    final TextEditingController addressController = TextEditingController(
                      text: _missionData['adresse_destination'] ?? '',
                    );
                    Timer? _debounce;
                    List<String> suggestions = [];
                    bool isLoading = false;
                    
                    final result = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => StatefulBuilder(
                        builder: (context, setState) => AlertDialog(
                          title: const Text('Modifier l\'adresse de destination'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: addressController,
                                  decoration: InputDecoration(
                                    hintText: 'Entrez la nouvelle adresse de destination',
                                    border: OutlineInputBorder(),
                                    suffixIcon: isLoading 
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                                          ),
                                        )
                                      : null,
                                  ),
                                  maxLines: 3,
                                  onChanged: (value) async {
                                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                                    _debounce = Timer(const Duration(milliseconds: 500), () async {
                                      if (value.length > 2) {
                                        setState(() => isLoading = true);
                                        try {
                                          suggestions = await MissionTrackingMethods.getAddressSuggestions(
                                            value,
                                            'AIzaSyBmnUN64iSMgThm_AwB4iYs-rYlQSX6jDw'
                                          );
                                          setState(() {});
                                        } catch (e) {
                                          print('🔴 Erreur lors de la recherche d\'adresses: $e');
                                        } finally {
                                          setState(() => isLoading = false);
                                        }
                                      } else {
                                        setState(() => suggestions = []);
                                      }
                                    });
                                  },
                                ),
                                if (suggestions.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 200,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: suggestions.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(suggestions[index]),
                                          onTap: () {
                                            addressController.text = suggestions[index];
                                            setState(() => suggestions = []);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (addressController.text.isNotEmpty) {
                                  Navigator.pop(context, addressController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Enregistrer'),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (result != null) {
                      try {
                        final updatedData = Map<String, dynamic>.from(_missionData);
                        updatedData['adresse_destination'] = result;

                        final response = await http.put(
                          Uri.parse('${ApiConfig.baseUrl}/missions/${widget.missionId}'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${await _getToken()}',
                          },
                          body: jsonEncode(updatedData),
                        );

                        if (response.statusCode == 200 || response.statusCode == 201) {
                          setState(() {
                            _missionData = updatedData;
                          });
                        }
                      } catch (e) {
                        print('🔴 Erreur lors de la mise à jour de l\'adresse: $e');
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _missionData['adresse_destination'] ?? 'Aucune adresse de destination',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadUsedMaterials() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/utilisation_materiel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final List<dynamic> allUsages = json.decode(response.body);
        final missionUsages = allUsages
            .where((usage) => usage['mission_id'] == widget.missionId)
            .map((usage) => Map<String, dynamic>.from(usage))
            .toList();

        setState(() {
          _selectedMaterialsSaved = missionUsages;
        });
      }
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Sauvegarde la sélection temporaire localement
  Future<void> _saveTempMaterialsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selected_materials_temp_${widget.missionId}';
    await prefs.setString(key, jsonEncode(_selectedMaterialsTemp));
  }

  // Charge la sélection temporaire locale
  Future<void> _loadTempMaterialsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selected_materials_temp_${widget.missionId}';
    final data = prefs.getString(key);
    if (data != null) {
      final List<dynamic> list = jsonDecode(data);
      setState(() {
        _selectedMaterialsTemp = list.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  // Supprime la sélection temporaire locale
  Future<void> _clearTempMaterialsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selected_materials_temp_${widget.missionId}';
    await prefs.remove(key);
  }

  Future<void> _showMaterialDialog() async {
    print('🔵 MissionTrackingScreen: Affichage du dialogue de matériaux');
    final List<Map<String, dynamic>> tempMaterials = List.from(_selectedMaterialsTemp);
    print('🔵 MissionTrackingScreen: Matériaux temporaires: $tempMaterials');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Dialog(
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Matériaux utilisés',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        print('🔵 MissionTrackingScreen: Fermeture du dialogue de matériaux');
                        Navigator.pop(dialogContext);
                        _saveMaterialUsage();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tempMaterials.isEmpty)
                        const Text('Aucun matériau sélectionné')
                      else
                        ...tempMaterials.asMap().entries.map((entry) {
                          final index = entry.key;
                          final material = entry.value;
                          print('🔵 MissionTrackingScreen: Affichage du matériel: ${material['item']}');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.medical_services,
                                color: AppColors.primaryColor,
                              ),
                              title: Text(
                                material['item'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('Quantité: ${material['quantite_utilisee']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  print('🔵 MissionTrackingScreen: Suppression du matériel: ${material['item']}');
                                  setState(() {
                                    tempMaterials.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          print('🔵 MissionTrackingScreen: Ouverture du dialogue de sélection de matériaux');
                          Navigator.pop(dialogContext);
                          _showMaterialSelectionDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Ajouter un matériau'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepInfo {
  final IconData icon;
  final String label;
  final bool isCompleted;
  final Color color;

  StepInfo(this.icon, this.label, this.isCompleted, this.color);
}

class _AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onAddressSelected;

  const _AddressAutocompleteField({
    required this.controller,
    required this.onAddressSelected,
  });

  @override
  State<_AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<_AddressAutocompleteField> {
  List<String> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _getSuggestions(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final suggestions = await MissionTrackingMethods.getAddressSuggestions(
        query,
        'AIzaSyBmnUN64iSMgThm_AwB4iYs-rYlQSX6jDw'
      );
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔴 Erreur lors de la recherche d\'adresses: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: 'Entrez la nouvelle adresse de destination',
            border: OutlineInputBorder(),
            suffixIcon: _isLoading 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                )
              : null,
          ),
          maxLines: 3,
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () async {
              if (value.length > 2) {
                setState(() => _isLoading = true);
                try {
                  _suggestions = await MissionTrackingMethods.getAddressSuggestions(
                    value,
                    'AIzaSyBmnUN64iSMgThm_AwB4iYs-rYlQSX6jDw'
                  );
                  if (_suggestions.isNotEmpty) {
                    final selectedAddress = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Sélectionnez une adresse'),
                        children: _suggestions.map((address) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, address),
                          child: Text(address),
                        )).toList(),
                      ),
                    );
                    
                    if (selectedAddress != null) {
                      widget.controller.text = selectedAddress;
                    }
                  }
                } catch (e) {
                  print('🔴 Erreur lors de la recherche d\'adresses: $e');
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            });
          },
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestions[index]),
                  onTap: () {
                    widget.controller.text = _suggestions[index];
                    widget.onAddressSelected(_suggestions[index]);
                    setState(() => _suggestions = []);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}