import 'package:flutter/material.dart';

/// {@template accessibility_options}
/// Describes a user-selected set of accessibility affordances that influence
/// theming, semantics, and input feedback throughout the application.
///
/// The data displayed using these options originates from TMDB JSON payloads
/// delivered by endpoints like `GET /3/configuration` for color branding hints
/// and list endpoints such as `GET /3/movie/popular` for content metadata.
/// {@endtemplate}
class AccessibilityOptions {
  /// Creates a new immutable collection of accessibility preferences.
  const AccessibilityOptions({
    required this.highContrast,
    required this.colorBlindFriendly,
    required this.boldText,
    required this.showFocusIndicators,
    required this.keyboardNavigationHints,
  });

  /// Requests high contrast surfaces by promoting stronger tonal separations.
  final bool highContrast;

  /// Requests color palettes that remain distinguishable for color-blind users.
  final bool colorBlindFriendly;

  /// Requests an elevated baseline font weight for improved legibility.
  final bool boldText;

  /// Requests visible focus indicators for keyboard and remote input users.
  final bool showFocusIndicators;

  /// Requests extra keyboard navigation hints within semantics annotations.
  final bool keyboardNavigationHints;

  /// Applies the appropriate high-contrast `ColorScheme` when requested.
  ColorScheme resolveScheme(ColorScheme base) {
    if (!highContrast) {
      return _applyColorBlindOverrides(base);
    }

    final contrastScheme = base.brightness == Brightness.dark
        ? ColorScheme.highContrastDark(
            primary: base.primary,
            surface: base.surface,
            secondary: base.secondary,
          )
        : ColorScheme.highContrastLight(
            primary: base.primary,
            surface: base.surface,
            secondary: base.secondary,
          );
    return _applyColorBlindOverrides(contrastScheme);
  }

  /// Applies bold-text requests to the provided [TextTheme].
  TextTheme resolveTextTheme(TextTheme base) {
    if (!boldText) {
      return base;
    }
    return base.apply(fontWeightDelta: 2);
  }

  ColorScheme _applyColorBlindOverrides(ColorScheme scheme) {
    if (!colorBlindFriendly) {
      return scheme;
    }
    // The palette prioritizes blue/orange accents that remain legible for the
    // most common color vision deficiencies (protanopia/deuteranopia).
    return scheme.copyWith(
      primary: const Color(0xFF005A9C),
      onPrimary: Colors.white,
      secondary: const Color(0xFFCC7722),
      onSecondary: Colors.black,
      error: const Color(0xFFB00020),
      onError: Colors.white,
    );
  }
}
