import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../styles/button_styles.dart';
import '../styles/header_styles.dart';
import '../styles/icon_styles.dart';
import '../styles/card_styles.dart';

class ScreenUtils {
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getResponsiveWidth(BuildContext context, double percentage) {
    return getScreenSize(context).width * percentage;
  }

  static double getResponsiveHeight(BuildContext context, double percentage) {
    return getScreenSize(context).height * percentage;
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    double horizontal = 0.04,
    double vertical = 0.02,
  }) {
    return EdgeInsets.symmetric(
      horizontal: getResponsiveWidth(context, horizontal),
      vertical: getResponsiveHeight(context, vertical),
    );
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    return getResponsiveWidth(context, baseSize);
  }

  static Widget buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: getResponsivePadding(context),
      decoration: CardStyles.cardDecoration,
      child: Column(
        children: [
          Icon(
            icon,
            size: getResponsiveWidth(context, 0.15),
            color: Colors.grey[400],
          ),
          SizedBox(height: getResponsiveHeight(context, 0.02)),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: getResponsiveFontSize(context, 0.045),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: getResponsiveHeight(context, 0.01)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getResponsiveFontSize(context, 0.035),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: getResponsiveFontSize(context, 0.045),
      ),
    );
  }

  static Widget buildActionButton(BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyles.textButton,
      child: Text(
        label,
        style: TextStyle(
          fontSize: getResponsiveFontSize(context, 0.035),
        ),
      ),
    );
  }
} 