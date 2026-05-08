import 'package:flutter/material.dart';

class SyncColors {
  // Primary Palette
  static const Color background = Color(0xFF1A0A10); // Deep Rose-Black
  static const Color surface = Color(0xFF2D1B24);
  
  // Accents
  static const Color coral = Color(0xFFFF6B6B);
  static const Color coralLight = Color(0xFFFF8E8E);
  static const Color violet = Color(0xFFC084FC);
  
  // Text
  static const Color textPrimary = Color(0xFFF5F0F0);
  static const Color textSecondary = Color(0xFFA89FA0);
  
  // Gradients
  static const LinearGradient coralGradient = LinearGradient(
    colors: [coral, coralLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient romanticGradient = LinearGradient(
    colors: [coral, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Glassmorphism
  static Color glassSurface = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);
}
