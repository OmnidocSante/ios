import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/bottom_navigation_bar_styles.dart';
import '../styles/app_dimensions.dart';
import '../styles/app_text_styles.dart';
import '../widgets/home/settings_widgets.dart';
import '../widgets/home/profile_widgets.dart';
import '../services/methods/settings_methods.dart';
import '../api/user_api.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = "";
  String userAvatar = "";
  String userEmail = "";
  int _selectedIndex = 3;
  int notificationCount =
      3; // exemple statique, à remplacer par la vraie valeur

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    SettingsMethods.handleLogout(context);
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await SettingsMethods.initializeData(context);
      final userInfo = await SettingsMethods.fetchUserInfo(context);
      setState(() {
        userName = '${userInfo['nom']} ${userInfo['prenom']}';
        userAvatar = userInfo['photo'] ?? '';
        userEmail = userInfo['email'] ?? '';
      });
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = AppDimensions.getContentPadding(context);
    final spacing = AppDimensions.getSpacing(context);

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: contentPadding, vertical: spacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: userAvatar.isNotEmpty
                        ? NetworkImage(userAvatar)
                        : NetworkImage(
                                'https://omnidoc.ma/wp-content/uploads/2025/04/ambulance-tanger-flotte-vehicules-omnidoc-1.webp')
                            as ImageProvider,
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bienvenue',
                            style: AppTextStyles.getSmallText(context)
                                .copyWith(color: Colors.white)),
                        Text(userName,
                            style: AppTextStyles.getTitle(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.white),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/notifications'),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$notificationCount',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Bannière Paramètre
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: contentPadding, vertical: spacing),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.settings,
                            color: AppColors.primaryColor, size: 28),
                        SizedBox(width: 12),
                        Text('Parametre',
                            style: AppTextStyles.getTitle(context)
                                .copyWith(color: AppColors.primaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Liste d'options
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacing * 2),
                    _buildSettingsOption(
                      context,
                      icon: Icons.person,
                      label: 'Informations Personnelles',
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    _buildSettingsOption(
                      context,
                      icon: Icons.notifications,
                      label: 'Notifications',
                      onTap: () =>
                          Navigator.pushNamed(context, '/notifications'),
                    ),
                    _buildSettingsOption(
                      context,
                      icon: Icons.search,
                      label: 'Confidentialité et Partage',
                      onTap: () {},
                    ),
                    Spacer(),
                    Divider(color: Colors.white.withOpacity(0.4)),
                    Padding(
                      padding: EdgeInsets.only(
                          left: contentPadding, top: spacing, bottom: spacing),
                      child: InkWell(
                        onTap: () => SettingsMethods.handleLogout(context),
                        child: Row(
                          children: [
                            Icon(Icons.exit_to_app, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Se déconnecter',
                                style: AppTextStyles.getBodyText(context)
                                    .copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarStyles.buildBottomNavigationBar(
        context: context,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    final spacing = AppDimensions.getSpacing(context);
    return InkWell(
      onTap: () {
        try {
          onTap();
        } catch (e) {
          // Gérer l'erreur silencieusement
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.getContentPadding(context),
            vertical: spacing),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(width: 18),
            Text(label,
                style: AppTextStyles.getBodyText(context)
                    .copyWith(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
