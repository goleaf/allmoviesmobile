import 'package:flutter/material.dart';

import '../../providers/accessibility_provider.dart';

/// Applies accessibility aware adjustments on top of the base [ThemeData].
///
/// High contrast mode increases color contrast, widens borders, and ensures text always renders
/// against the highest contrast background.  The color-blind palette swap uses a blue/orange palette
/// that remains distinguishable for the most common color vision deficiencies.
class AccessibilityTheme {
  const AccessibilityTheme._();

  /// Builds a theme that incorporates every enabled flag from [settings].
  static ThemeData adapt(ThemeData base, AccessibilityProvider settings) {
    ThemeData themed = base;

    if (settings.colorBlindFriendly) {
      themed = _applyColorBlindPalette(themed);
    }

    if (settings.highContrast) {
      themed = _applyHighContrast(themed);
    }

    if (settings.focusIndicatorsEnabled) {
      themed = _boostFocusIndicators(themed);
    } else {
      themed = themed.copyWith(
        focusColor: themed.colorScheme.primary.withOpacity(0.2),
        highlightColor: Colors.transparent,
        hoverColor: themed.colorScheme.primary.withOpacity(0.04),
      );
    }

    return themed;
  }

  static ThemeData _applyColorBlindPalette(ThemeData base) {
    final ColorScheme scheme = base.colorScheme;
    final Color primary = const Color(0xFF2459C3); // Deep blue
    final Color primaryContainer = const Color(0xFF1E3F91);
    final Color secondary = const Color(0xFFF5A623); // Accessible amber
    final Color secondaryContainer = const Color(0xFFBB6B00);
    final Color error = const Color(0xFFB00020);

    final ColorScheme remapped = scheme.copyWith(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: secondary,
      onSecondary: Colors.black,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: Colors.white,
      error: error,
      onError: Colors.white,
      surfaceTint: primary,
    );

    return base.copyWith(
      colorScheme: remapped,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: secondary,
        foregroundColor: Colors.black,
      ),
      checkboxTheme: base.checkboxTheme.copyWith(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : scheme.outline,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : scheme.outline,
        ),
      ),
    );
  }

  static ThemeData _applyHighContrast(ThemeData base) {
    final ColorScheme scheme = base.colorScheme;

    Color increaseContrast(Color color) {
      final hsl = HSLColor.fromColor(color);
      final double lightness = hsl.lightness;
      final double newLightness = lightness < 0.5
          ? (lightness * 0.6).clamp(0.0, 1.0)
          : (lightness + 0.2).clamp(0.0, 1.0);
      return hsl.withLightness(newLightness).toColor();
    }

    final ColorScheme contrasted = scheme.copyWith(
      primary: increaseContrast(scheme.primary),
      onPrimary: Colors.white,
      secondary: increaseContrast(scheme.secondary),
      onSecondary: Colors.black,
      surface: increaseContrast(scheme.surface),
      onSurface: scheme.brightness == Brightness.dark ? Colors.white : Colors.black,
      background: increaseContrast(scheme.background),
      onBackground: scheme.brightness == Brightness.dark ? Colors.white : Colors.black,
      outline: increaseContrast(scheme.outline),
    );

    return base.copyWith(
      colorScheme: contrasted,
      textTheme: base.textTheme.apply(
        bodyColor: contrasted.onBackground,
        displayColor: contrasted.onBackground,
      ),
      dividerTheme: base.dividerTheme.copyWith(
        thickness: base.dividerTheme.thickness ?? 1.0 + 0.5,
        color: contrasted.onSurface.withOpacity(0.4),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: contrasted.onSurface, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: contrasted.primary,
          foregroundColor: contrasted.onPrimary,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      focusColor: contrasted.primary,
      hoverColor: contrasted.primary.withOpacity(0.12),
      highlightColor: contrasted.primary.withOpacity(0.18),
    );
  }

  static ThemeData _boostFocusIndicators(ThemeData base) {
    final ColorScheme scheme = base.colorScheme;
    return base.copyWith(
      focusColor: scheme.primary,
      splashColor: scheme.primary.withOpacity(0.18),
      highlightColor: scheme.primary.withOpacity(0.24),
      hoverColor: scheme.primary.withOpacity(0.12),
    );
  }
}
