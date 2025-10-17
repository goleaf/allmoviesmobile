import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AccessibilityThemeOptions {
  const AccessibilityThemeOptions({
    this.highContrast = false,
    this.emphasizeFocus = true,
    this.colorBlindFriendlyPalette = false,
  });

  final bool highContrast;
  final bool emphasizeFocus;
  final bool colorBlindFriendlyPalette;
}

class AppTheme {
  AppTheme._();

  static final ColorScheme _fallbackLightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
  );

  static final ColorScheme _fallbackDarkScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: AppColors.primary,
  );

  static ThemeData light({
    ColorScheme? dynamicScheme,
    AccessibilityThemeOptions options = const AccessibilityThemeOptions(),
  }) {
    return _buildTheme(dynamicScheme ?? _fallbackLightScheme, options);
  }

  static ThemeData dark({
    ColorScheme? dynamicScheme,
    AccessibilityThemeOptions options = const AccessibilityThemeOptions(),
  }) {
    return _buildTheme(dynamicScheme ?? _fallbackDarkScheme, options);
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    AccessibilityThemeOptions options,
  ) {
    colorScheme = _resolveColorScheme(colorScheme, options);
    final isDark = colorScheme.brightness == Brightness.dark;
    // Avoid runtime font fetching during tests or when fonts are unavailable
    final baseTextTheme = ThemeData(
      brightness: colorScheme.brightness,
    ).textTheme;
    final textTheme = baseTextTheme.apply(
      bodyColor: colorScheme.onBackground,
      displayColor: colorScheme.onBackground,
    );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );

    Color surfaceTint(double opacity) => Color.alphaBlend(
      colorScheme.primary.withOpacity(opacity),
      colorScheme.surface,
    );

    final surfaceMuted = surfaceTint(isDark ? 0.24 : 0.08);
    final surfaceElevated = surfaceTint(isDark ? 0.32 : 0.12);
    final surfaceHighest = surfaceTint(isDark ? 0.4 : 0.16);

    final focusGlowColor = options.emphasizeFocus
        ? colorScheme.tertiary.withOpacity(isDark ? 0.85 : 0.7)
        : colorScheme.primary.withOpacity(0.4);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      visualDensity: VisualDensity.standard,
      applyElevationOverlayColor: isDark,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      // cardTheme removed to avoid SDK type conflicts; rely on defaults
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface.withOpacity(0.92),
        actionTextColor: colorScheme.onInverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        disabledColor: colorScheme.surfaceVariant.withOpacity(0.4),
        labelStyle: textTheme.bodyMedium,
        secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: StadiumBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.6)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.3),
        thickness: 1,
        space: 32,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // dialogTheme removed to avoid SDK type conflicts; rely on defaults
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 4,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.titleMedium,
        ),
      ),
      focusTheme: FocusThemeData(glowColor: focusGlowColor),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurfaceVariant,
        backgroundColor: surfaceElevated,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        selectedColor: colorScheme.primary,
        iconColor: colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: surfaceHighest,
      ),
    );
  }

  static ColorScheme _resolveColorScheme(
    ColorScheme baseScheme,
    AccessibilityThemeOptions options,
  ) {
    var scheme = baseScheme;

    if (options.highContrast) {
      scheme = baseScheme.brightness == Brightness.dark
          ? ColorScheme.highContrastDark(
              primary: baseScheme.primary,
              onPrimary: baseScheme.onPrimary,
              secondary: baseScheme.secondary,
              onSecondary: baseScheme.onSecondary,
              background: baseScheme.background,
              onBackground: baseScheme.onBackground,
              surface: baseScheme.surface,
              onSurface: baseScheme.onSurface,
              error: baseScheme.error,
              onError: baseScheme.onError,
            )
          : ColorScheme.highContrastLight(
              primary: baseScheme.primary,
              onPrimary: baseScheme.onPrimary,
              secondary: baseScheme.secondary,
              onSecondary: baseScheme.onSecondary,
              background: baseScheme.background,
              onBackground: baseScheme.onBackground,
              surface: baseScheme.surface,
              onSurface: baseScheme.onSurface,
              error: baseScheme.error,
              onError: baseScheme.onError,
            );
    }

    if (options.colorBlindFriendlyPalette) {
      // Palette inspired by color-blind-safe combinations (blue/orange/purple).
      const primary = Color(0xFF1B4F72); // deep blue
      const onPrimary = Colors.white;
      const secondary = Color(0xFFAF601A); // burnt orange
      const onSecondary = Colors.white;
      const tertiary = Color(0xFF7D3C98); // royal purple
      const onTertiary = Colors.white;
      final neutralSurface = scheme.brightness == Brightness.dark
          ? const Color(0xFF121417)
          : const Color(0xFFF5F5F7);

      scheme = scheme.copyWith(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primary.withOpacity(0.85),
        onPrimaryContainer: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondary.withOpacity(0.85),
        onSecondaryContainer: onSecondary,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiary.withOpacity(0.85),
        onTertiaryContainer: onTertiary,
        surface: neutralSurface,
        background: neutralSurface,
        surfaceTint: primary,
      );
    }

    return scheme;
  }
}
