import 'package:flutter/material.dart';

class KickKoraColors {
  // Primary Gradient Colors
  static const Color primaryDark = Color(0xFF0A0E27);
  static const Color primaryMid = Color(0xFF1B2555);
  static const Color accentGreen = Color(0xFF0F4C3A);

  // Accent Colors
  static final Color cyan = Colors.cyan.shade300;
  static final Color cyanLight = Colors.cyan.shade100;
  static final Color blue = Colors.blue.shade600;
  static final Color blueLight = Colors.blue.shade100;

  // Status Colors
  static const Color liveRed = Color(0xFFFF3B30);
  static const Color successGreen = Color(0xFF34C759);
  static const Color warningOrange = Color(0xFFFF9500);

  // Dark Theme
  static const Color darkBg = Color(0xFF080808);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E);

  // Light Theme
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF2F2F2);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primaryMid, accentGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient cyanGradient = LinearGradient(
    colors: [Colors.cyan.shade400, Colors.blue.shade600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient amberGradient = LinearGradient(
    colors: [Colors.amber.shade400, Colors.orange.shade600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient redGradient = LinearGradient(
    colors: [Colors.red.shade400, Colors.pink.shade600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow Effects
  static BoxShadow cyanGlow = BoxShadow(
    color: Colors.cyan.withValues(alpha: 0.3),
    blurRadius: 20,
    spreadRadius: 5,
  );

  static BoxShadow blueGlow = BoxShadow(
    color: Colors.blue.withValues(alpha: 0.2),
    blurRadius: 15,
    spreadRadius: 3,
  );

  // Border Colors
  static Color borderLight(bool isDark) =>
      isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE0E0E0);

  static Color borderLighter(bool isDark) =>
      isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.05);
}
