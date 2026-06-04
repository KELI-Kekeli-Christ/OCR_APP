import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF14141C);
  static const Color surfaceElevated = Color(0xFF1E1E2A);
  static const Color card = Color(0xFF1A1A26);
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7CF7);
  static const Color accent = Color(0xFF00D2FF);
  static const Color accentSecondary = Color(0xFFFD79A8);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFFB2BEC3);
  static const Color textMuted = Color(0xFF636E72);
  static const Color border = Color(0xFF2D3436);
  static const Color gradientStart = Color(0xFF6C5CE7);
  static const Color gradientEnd = Color(0xFF00D2FF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E2A), Color(0xFF14141C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
