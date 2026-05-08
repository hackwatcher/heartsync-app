import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sync_colors.dart';

class SyncTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SyncColors.background,
      primaryColor: SyncColors.coral,
      colorScheme: const ColorScheme.dark(
        primary: SyncColors.coral,
        secondary: SyncColors.violet,
        surface: SyncColors.surface,
        onPrimary: SyncColors.textPrimary,
        onSurface: SyncColors.textPrimary,
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          color: SyncColors.textPrimary,
          letterSpacing: -0.02,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          color: SyncColors.textPrimary,
          letterSpacing: -0.01,
        ),
        headlineLarge: GoogleFonts.syne(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: SyncColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: SyncColors.textPrimary,
          letterSpacing: 0.01,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: SyncColors.textPrimary,
          letterSpacing: 0.02,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: SyncColors.textSecondary,
          letterSpacing: 0.05,
        ),
      ),
      
      // Components
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SyncColors.coral,
          foregroundColor: SyncColors.textPrimary,
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),
    );
  }
}
