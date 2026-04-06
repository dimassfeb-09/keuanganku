import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Colors.indigo;
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFFC5CAE9);
  static const Color accent = Colors.indigoAccent;

  // Background colors
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Colors.white;
  
  // Text colors
  static const Color textMain = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;

  // Semantic colors
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}
