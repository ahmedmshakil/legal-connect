import 'package:flutter/material.dart';

class AppColors {
  // ─── Light Theme (Clio-Inspired Palette) ───
  static const Color primaryLight = Color(0xFF0693E3);
  static const Color primaryDarkShade = Color(0xFF0578C7);
  static const Color secondaryLight = Color(0xFF8ED1FC);
  static const Color accentLight = Color(0xFF7BDCB5);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundSoftLight = Color(0xFFF5F7F8);
  static const Color surfaceLight = Color(0xFFF5F7F8);
  static const Color textLight = Color(0xFF000000);
  static const Color headingLight = Color(0xFF32373C);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFD6EEF9);

  // ─── Dark Theme ───
  static const Color primaryDark = Color(0xFF27374D);
  static const Color secondaryDark = Color(0xFF526D82);
  static const Color accentDark = Color(0xFF9DB2BF);
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color backgroundSoftDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color headingDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF9DB2BF);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color dividerDark = Color(0xFF333333);

  // ─── Semantic / Status Colors (Aligned with Web App) ───
  static const Color success = Color(0xFF00D084);
  static const Color warning = Color(0xFFFCB900);
  static const Color error = Color(0xFFCF2E2E);
  static const Color info = Color(0xFF40D9F1);

  // Case status
  static const Color inProgress = Color(0xFF0693E3);
  static const Color resolved = Color(0xFF00D084);

  // Verification status
  static const Color pending = Color(0xFFFCB900);
  static const Color approved = Color(0xFF00D084);
  static const Color rejected = Color(0xFFCF2E2E);

  // ─── Gradient Presets ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0693E3), Color(0xFF0578C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7BDCB5), Color(0xFF00D084)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF27374D), Color(0xFF1A1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFCB900), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
