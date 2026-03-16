import 'package:flutter/material.dart';

/// SkillTrack.AI color system with gradients and glass overlays.
class AppColors {
  const AppColors._();

  // ── Brand Primary ──
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  // ── Brand Secondary ──
  static const Color secondary = Color(0xFF00D2FF);
  static const Color secondaryLight = Color(0xFF4DE8FF);
  static const Color secondaryDark = Color(0xFF00A8CC);

  // ── Accent ──
  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentLight = Color(0xFFFF9DBF);
  static const Color accentDark = Color(0xFFDB4478);

  // ── Success / Warning / Error ──
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB40);
  static const Color error = Color(0xFFFF5252);

  // ── Dark Theme Surfaces ──
  static const Color darkBg = Color(0xFF0A0E21);
  static const Color darkSurface = Color(0xFF111633);
  static const Color darkCard = Color(0xFF1A1F42);
  static const Color darkElevated = Color(0xFF222752);

  // ── Light Theme Surfaces ──
  static const Color lightBg = Color(0xFFF5F7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F2FF);
  static const Color lightElevated = Color(0xFFE8ECFF);

  // ── Text Colors ──
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B3C9);
  static const Color textTertiaryDark = Color(0xFF6B6F8E);

  static const Color textPrimaryLight = Color(0xFF1A1F42);
  static const Color textSecondaryLight = Color(0xFF5A5E7A);
  static const Color textTertiaryLight = Color(0xFF9498B3);

  // ── Glass ──
  static const Color glassWhite = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassOverlayDark = Color(0x1A111633);
  static const Color glassOverlayLight = Color(0x1AF0F2FF);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [darkBg, Color(0xFF0D1234)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardShimmer = LinearGradient(
    colors: [
      Color(0x00FFFFFF),
      Color(0x15FFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1, -0.3),
    end: Alignment(1, 0.3),
  );

  // ── Skill Level Colors ──
  static const List<Color> skillLevelColors = [
    Color(0xFF66BB6A), // Beginner
    Color(0xFF42A5F5), // Intermediate
    Color(0xFFAB47BC), // Advanced
    Color(0xFFFF7043), // Expert
    Color(0xFFFFD700), // Master
  ];

  // ── Chart Colors ──
  static const List<Color> chartColors = [
    primary,
    secondary,
    accent,
    success,
    warning,
    Color(0xFF7C4DFF),
    Color(0xFF18FFFF),
    Color(0xFFFF4081),
  ];
}
