import 'package:flutter/material.dart';

import '../accessibility/accessibility_options.dart';
import '../constants/app_colors.dart';

/// {@template app_theme}
/// Centralized theme builder that composes Material 3 theming while honoring
/// dynamic color surfaces and persisted accessibility options gathered from
/// TMDB metadata endpoints such as `GET /3/configuration`.
/// {@endtemplate}
class AppTheme {
  AppTheme._();

  static final ColorScheme _fallbackLightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
  );

  static final ColorScheme _fallbackDarkScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: AppColors.primary,
  );

  /// Builds the default light [ThemeData] including optional dynamic color and
  /// [AccessibilityOptions] overrides that stem from TMDB powered settings.
  static ThemeData light({
    ColorScheme? dynamicScheme,
    AccessibilityOptions? accessibilityOptions,
  }) {
    return _buildTheme(
      dynamicScheme ?? _fallbackLightScheme,
      accessibilityOptions: accessibilityOptions,
    );
  }

  /// Builds the default dark [ThemeData] including optional dynamic color and
  /// [AccessibilityOptions] overrides.
  static ThemeData dark({
    ColorScheme? dynamicScheme,
    AccessibilityOptions? accessibilityOptions,
  }) {
    return _buildTheme(
      dynamicScheme ?? _fallbackDarkScheme,
      accessibilityOptions: accessibilityOptions,
    );
  }

  static ThemeData _buildTheme(
    ColorScheme baseScheme, {
    AccessibilityOptions? accessibilityOptions,
  }) {
    final resolvedScheme =
        accessibilityOptions?.resolveScheme(baseScheme) ?? baseScheme;
    final showFocusIndicators =
        accessibilityOptions?.showFocusIndicators ?? true;
    final isDark = resolvedScheme.brightness == Brightness.dark;

    // Avoid runtime font fetching during tests or when fonts are unavailable
    final baseTextTheme = ThemeData(
      brightness: resolvedScheme.brightness,
    ).textTheme;
    final appliedTextTheme = baseTextTheme.apply(
      bodyColor: resolvedScheme.onBackground,
      displayColor: resolvedScheme.onBackground,
    );
    final textTheme =
        accessibilityOptions?.resolveTextTheme(appliedTextTheme) ??
            appliedTextTheme;

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );

    Color surfaceTint(double opacity) => Color.alphaBlend(
          resolvedScheme.primary.withOpacity(opacity),
          resolvedScheme.surface,
        );

    final surfaceMuted = surfaceTint(isDark ? 0.24 : 0.08);
    final surfaceElevated = surfaceTint(isDark ? 0.32 : 0.12);
    final surfaceHighest = surfaceTint(isDark ? 0.4 : 0.16);
    final focusOpacity = showFocusIndicators ? 0.35 : 0;

    return ThemeData(
      useMaterial3: true,
      colorScheme: resolvedScheme,
      brightness: resolvedScheme.brightness,
      visualDensity: VisualDensity.standard,
      applyElevationOverlayColor: isDark,
      scaffoldBackgroundColor: resolvedScheme.surface,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: resolvedScheme.onSurfaceVariant),
      focusColor: resolvedScheme.secondary.withOpacity(focusOpacity),
      hoverColor: resolvedScheme.secondary.withOpacity(0.08),
      highlightColor: resolvedScheme.secondary.withOpacity(0.12),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: resolvedScheme.inverseSurface.withOpacity(0.92),
        actionTextColor: resolvedScheme.onInverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: resolvedScheme.onInverseSurface,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? resolvedScheme.primary
              : resolvedScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: resolvedScheme.primaryContainer,
        secondarySelectedColor: resolvedScheme.secondaryContainer,
        disabledColor: resolvedScheme.surfaceVariant.withOpacity(0.4),
        labelStyle: textTheme.bodyMedium,
        secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
          color: resolvedScheme.onSecondaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: StadiumBorder(
          side: BorderSide(color: resolvedScheme.outlineVariant),
        ),
        side:
            BorderSide(color: resolvedScheme.outlineVariant.withOpacity(0.6)),
      ),
      dividerTheme: DividerThemeData(
        color: resolvedScheme.outlineVariant.withOpacity(0.3),
        thickness: 1,
        space: 32,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: resolvedScheme.primaryContainer,
        foregroundColor: resolvedScheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: resolvedScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: resolvedScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: resolvedScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: resolvedScheme.onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: resolvedScheme.surface,
        foregroundColor: resolvedScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 4,
        surfaceTintColor: resolvedScheme.surfaceTint,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: resolvedScheme.primary,
          foregroundColor: resolvedScheme.onPrimary,
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
          foregroundColor: resolvedScheme.primary,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: resolvedScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: resolvedScheme.primary,
          textStyle: textTheme.titleMedium,
        ),
      ),
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
        dragHandleColor: resolvedScheme.onSurfaceVariant,
        backgroundColor: surfaceElevated,
        surfaceTintColor: resolvedScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        selectedColor: resolvedScheme.primary,
        iconColor: resolvedScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: resolvedScheme.surface,
        indicatorColor: showFocusIndicators
            ? resolvedScheme.secondaryContainer
            : Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: resolvedScheme.primary,
        linearTrackColor: surfaceHighest,
      ),
      cardTheme: CardTheme(shape: cardShape),
    );
  }
}
