import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Heading styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );
  
  // Button styles
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );
  
  // Input styles
  static const TextStyle inputLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 1.5,
  );
  
  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    color: AppColors.textWhite,
  );
  
  // Link styles
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  
  // Footer styles
  static const TextStyle footer = TextStyle(
    fontSize: 13,
    color: AppColors.textWhite,
  );
}
