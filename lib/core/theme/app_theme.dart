import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const lightPrimary = Color(0xFF6200EE);
    const lightBackground = Color(0xFFFAFAFA);
    const lightSurface = Color(0xFFFFFFFF);
    const lightSurfaceVariant = Color(0xFFF5F5F5);
    const lightOnBackground = Color(0xFF212121);
    const lightOnSurface = Color(0xFF212121);
    const lightCardBackground = Color(0xFFFFFFFF);
    const lightDivider = Color(0xFFE0E0E0);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: Color(0xFF03DAC6),
        surface: lightSurface,
        error: Color(0xFFB00020),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: lightOnSurface,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: const TextStyle(color: lightOnBackground),
          displayMedium: const TextStyle(color: lightOnBackground),
          displaySmall: const TextStyle(color: lightOnBackground),
          headlineLarge: const TextStyle(color: lightOnBackground),
          headlineMedium: const TextStyle(color: lightOnBackground),
          headlineSmall: const TextStyle(color: lightOnBackground),
          titleLarge: const TextStyle(color: lightOnBackground),
          titleMedium: const TextStyle(color: lightOnBackground),
          titleSmall: const TextStyle(color: lightOnBackground),
          bodyLarge: const TextStyle(color: lightOnBackground),
          bodyMedium: const TextStyle(color: lightOnBackground),
          bodySmall: const TextStyle(color: lightOnBackground),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        iconTheme: const IconThemeData(color: lightOnSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB00020), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: lightOnSurface),
        hintStyle: TextStyle(color: lightOnSurface.withValues(alpha: 0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightDivider,
        thickness: 1,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: lightSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(color: AppColors.onBackground),
          displayMedium: const TextStyle(color: AppColors.onBackground),
          displaySmall: const TextStyle(color: AppColors.onBackground),
          headlineLarge: const TextStyle(color: AppColors.onBackground),
          headlineMedium: const TextStyle(color: AppColors.onBackground),
          headlineSmall: const TextStyle(color: AppColors.onBackground),
          titleLarge: const TextStyle(color: AppColors.onBackground),
          titleMedium: const TextStyle(color: AppColors.onBackground),
          titleSmall: const TextStyle(color: AppColors.onBackground),
          bodyLarge: const TextStyle(color: AppColors.onBackground),
          bodyMedium: const TextStyle(color: AppColors.onBackground),
          bodySmall: const TextStyle(color: AppColors.onBackground),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.onSurface),
        hintStyle: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.movieCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
      ),
    );
  }
}

