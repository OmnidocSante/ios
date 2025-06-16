import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../styles/card_styles.dart';
import '../styles/header_styles.dart';
import '../styles/icon_styles.dart';
import '../api/user_api.dart';
import '../services/auth_service.dart';
import '../styles/button_styles.dart';
import '../services/firebase_notification_service.dart';
import '../services/methods/profile_methods.dart';
import '../widgets/home/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  File? _imageFile;
  String? _userPhotoUrl;
  final ImagePicker _picker = ImagePicker();

  TextEditingController _nomController = TextEditingController();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _genreController = TextEditingController();
  TextEditingController _dateNaissanceController = TextEditingController();
  TextEditingController _roleController = TextEditingController();
  TextEditingController _statutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _initializeData() async {
    try {
      await ProfileMethods.setUserActive();
      await _loadUserData();
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  @override
  void dispose() {
    _handleLogout();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    try {
      await ProfileMethods.setUserInactive();
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userInfo = await ProfileMethods.fetchUserInfo();

      setState(() {
        _nomController.text = userInfo['nom'] ?? '';
        _prenomController.text = userInfo['prenom'] ?? '';
        _emailController.text = userInfo['email'] ?? '';
        _phoneController.text = userInfo['téléphone'] ?? '';
        _genreController.text = userInfo['genre'] ?? '';
        _dateNaissanceController.text = userInfo['date_naissance'] ?? '';
        _roleController.text = userInfo['rôle'] ?? '';
        _statutController.text = userInfo['statut'] ?? '';
        _userPhotoUrl = userInfo['photo'];
      });
    } catch (e) {
      // Gestion silencieuse de l'erreur
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Récupérer les données actuelles
      final currentUserInfo = await ProfileMethods.fetchUserInfo();

      // Créer un Map avec uniquement les champs qui ont été modifiés
      final Map<String, dynamic> changedFields = {};

      // Vérifier chaque champ et ajouter uniquement ceux qui ont changé
      if (_nomController.text.isNotEmpty &&
          _nomController.text != currentUserInfo['nom']) {
        changedFields['nom'] = _nomController.text;
      }
      if (_prenomController.text.isNotEmpty &&
          _prenomController.text != currentUserInfo['prenom']) {
        changedFields['prenom'] = _prenomController.text;
      }
      if (_emailController.text.isNotEmpty &&
          _emailController.text != currentUserInfo['email']) {
        changedFields['email'] = _emailController.text;
      }
      if (_phoneController.text.isNotEmpty &&
          _phoneController.text != currentUserInfo['téléphone']) {
        changedFields['téléphone'] = _phoneController.text;
      }
      if (_genreController.text.isNotEmpty &&
          _genreController.text != currentUserInfo['genre']) {
        changedFields['genre'] = _genreController.text;
      }
      if (_dateNaissanceController.text.isNotEmpty &&
          _dateNaissanceController.text != currentUserInfo['date_naissance']) {
        changedFields['date_naissance'] = _dateNaissanceController.text;
      }

      // Si aucun champ n'a été modifié, ne pas envoyer de requête
      if (changedFields.isEmpty) {
        return;
      }

      // Mettre à jour le profil
      await ProfileMethods.updateProfile(changedFields);

      // Recharger les données pour afficher les modifications
      await _loadUserData();

      // Retourner à l'écran précédent
      Navigator.pop(context, true);
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  Future<void> _pickImage() async {
    try {
      final File? pickedFile = await ProfileMethods.pickImage();
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        await _uploadImage();
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      await ProfileMethods.uploadImage(_imageFile!.path);
      await _loadUserData(); // Recharger les données utilisateur
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  Future<void> _deletePhoto() async {
    try {
      // Mettre à jour l'interface avant la suppression
      setState(() {
        _imageFile = null;
        _userPhotoUrl = null;
      });

      await ProfileMethods.deletePhoto();

      // Recharger les données utilisateur
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo de profil supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: ProfileWidgets.buildAppBar(
        context: context,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                ProfileWidgets.buildProfileImage(
                  context: context,
                  userPhotoUrl: _userPhotoUrl,
                  imageFile: _imageFile,
                  initial: _nomController.text,
                  onDelete: _deletePhoto,
                  onPickImage: _pickImage,
                ),
                SizedBox(height: 30),
                ProfileWidgets.buildTextField(
                  context: context,
                  controller: _nomController,
                  label: 'Nom',
                  icon: Icons.person,
                  validator: ProfileMethods.validateRequired,
                ),
                SizedBox(height: 16),
                ProfileWidgets.buildTextField(
                  context: context,
                  controller: _prenomController,
                  label: 'Prénom',
                  icon: Icons.person_outline,
                  validator: ProfileMethods.validateRequired,
                ),
                SizedBox(height: 16),
                ProfileWidgets.buildTextField(
                  context: context,
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: ProfileMethods.validateEmail,
                ),
                SizedBox(height: 16),
                ProfileWidgets.buildTextField(
                  context: context,
                  controller: _phoneController,
                  label: 'Téléphone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: ProfileMethods.validatePhone,
                ),
                SizedBox(height: 16),
                ProfileWidgets.buildTextField(
                  context: context,
                  controller: _genreController,
                  label: 'Genre',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 16),
                ProfileWidgets.buildTextField(
                  context: context,
                  controller: _dateNaissanceController,
                  label: 'Date de naissance',
                  icon: Icons.calendar_today,
                ),
                SizedBox(height: 16),
                ProfileWidgets.buildTextField(
                  context: context,
                  controller: _statutController,
                  label: 'Statut',
                  icon: Icons.info_outline,
                ),
                SizedBox(height: 32),
                ProfileWidgets.buildSaveButton(
                  context: context,
                  onPressed: _updateProfile,
                  screenWidth: screenWidth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
