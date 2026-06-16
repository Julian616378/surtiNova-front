import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
  );
  static const subheading = TextStyle(
    fontSize: 16, color: AppColors.textSecondary,
  );
  static const button = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white,
  );
  static const label = TextStyle(
    fontSize: 14, color: AppColors.textPrimary,
  );
  static const error = TextStyle(
    fontSize: 13, color: AppColors.error,
  );
}