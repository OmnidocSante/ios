import 'package:flutter/material.dart';
import 'colors.dart';
import 'app_dimensions.dart';

class AppTextStyles {
  static TextStyle getTitle(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getTitleSize(context),
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      );

  static TextStyle getSubtitle(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getSubtitleSize(context),
        fontWeight: FontWeight.w600,
        color: AppColors.textColor,
      );

  static TextStyle getBodyText(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getBodyTextSize(context),
        color: AppColors.textColor,
      );

  static TextStyle getSmallText(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getSmallTextSize(context),
        color: AppColors.textColor.withOpacity(0.7),
      );

  static TextStyle getButtonText(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getBodyTextSize(context),
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle getErrorText(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getSmallTextSize(context),
        color: AppColors.errorColor,
      );

  static TextStyle getSuccessText(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getSmallTextSize(context),
        color: AppColors.successColor,
      );

  static TextStyle getLinkText(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getBodyTextSize(context),
        color: AppColors.primaryColor,
        decoration: TextDecoration.underline,
      );

  static TextStyle getCardTitle(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getSubtitleSize(context),
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
      );

  static TextStyle getCardSubtitle(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getBodyTextSize(context),
        color: AppColors.textColor.withOpacity(0.7),
      );

  static TextStyle getInputLabel(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getBodyTextSize(context),
        color: AppColors.textColor,
      );

  static TextStyle getInputText(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getBodyTextSize(context),
        color: AppColors.textColor,
      );

  static TextStyle getAppBarTitle(BuildContext context) => TextStyle(
        fontSize: AppDimensions.getAppBarTitleSize(context),
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}
