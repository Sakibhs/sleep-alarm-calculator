import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background layers
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color cardBackground = Color(0xFF1A2235);
  static const Color cardBorder = Color(0xFF243047);

  // Brand gradient
  static const Color primaryStart = Color(0xFF6C63FF);
  static const Color primaryEnd = Color(0xFF3B82F6);

  // Accent
  static const Color accent = Color(0xFF818CF8);
  static const Color accentGlow = Color(0x336C63FF);

  // Cycle quality tiers
  static const Color cycleOptimal = Color(0xFF10B981);   // 5-6 cycles – ideal
  static const Color cycleBest = Color(0xFF6C63FF);      // 7 cycles – best
  static const Color cycleWarning = Color(0xFFF59E0B);   // 4 cycles – minimum
  static const Color cycleCritical = Color(0xFFEF4444);  // <4 cycles

  // Text
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

  // Toggle
  static const Color toggleActive = Color(0xFF6C63FF);
  static const Color toggleInactive = Color(0xFF1E293B);

  // Button
  static const Color buttonPrimary = Color(0xFF6C63FF);
  static const Color buttonPressed = Color(0xFF4F46E5);

  // Misc
  static const Color divider = Color(0xFF1E293B);
  static const Color moonGlow = Color(0xFFFFD700);
  static const Color starColor = Color(0xFFE2E8F0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2235), Color(0xFF141C2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient optimalGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bestGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
