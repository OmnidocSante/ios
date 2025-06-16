import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class BottomNavigationBarStyles {
  static Widget buildBottomNavigationBar({
    required int currentIndex,
    required Function(int) onTap,
    required BuildContext context,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bottomNavBackground,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                onTap(index);
                _navigateToScreen(context, index);
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.bottomNavSelected,
              unselectedItemColor: AppColors.bottomNavUnselected,
              selectedLabelStyle: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: AppTextStyles.caption,
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: [
                _buildNavigationBarItem(
                  icon: Icons.home,
                  label: 'Accueil',
                  isSelected: currentIndex == 0,
                ),
                _buildNavigationBarItem(
                  icon: Icons.medical_services,
                  label: 'Interventions',
                  isSelected: currentIndex == 1,
                ),
                _buildNavigationBarItem(
                  icon: Icons.report,
                  label: 'Rapports',
                  isSelected: currentIndex == 2,
                ),
                _buildNavigationBarItem(
                  icon: Icons.menu,
                  label: 'Menu',
                  isSelected: currentIndex == 3,
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 20,
          color: Colors.transparent,
        ),
      ],
    );
  }

  static void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (ModalRoute.of(context)?.settings.name != '/home') {
          Navigator.pushReplacementNamed(context, '/home');
        }
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/interventions');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/reports');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
      default:
        break;
    }
  }

  static BottomNavigationBarItem _buildNavigationBarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? AppColors.bottomNavSelected
              : AppColors.bottomNavUnselected,
        ),
      ),
      label: label,
    );
  }
}
