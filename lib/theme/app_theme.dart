import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFF6FFF2);
  static const cardBackground = Color(0xFFE8F5E3);
  static const navBackground = Color(0xFFFFFFFF);
  static const photoButton = Color(0xFFD9D9D9);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF888888);
  static const textOnPhoto = Color(0xFFF6FFF2);
  static const navIconActive = Color(0xFF4A7C59);
  static const navIconInactive = Color(0xFFAAAAAA);
  static const backButton = Color(0xFFE8F5E3);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.navIconActive,
          surface: AppColors.background,
        ),
        textTheme: GoogleFonts.juaTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
      );
}
