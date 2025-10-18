import 'package:flutter/foundation.dart';

import '../presentation/navigation/app_destination.dart';

/// Describes a single breadcrumb segment that can be rendered for a deep link.
///
/// Each breadcrumb carries the localized [label] that should be shown to the
/// user alongside optional navigation metadata:
///
/// * [destination] describes the bottom navigation destination that should be
///   activated when the breadcrumb is tapped.
/// * [routeName] / [arguments] are forwarded to the root navigator so that the
///   correct modal route can be opened after the shell has switched tabs.
@immutable
class DeepLinkBreadcrumb {
  const DeepLinkBreadcrumb({
    required this.label,
    this.destination,
    this.routeName,
    this.arguments,
  });

  /// Localized label presented to the user.
  final String label;

  /// Target bottom navigation destination. When this is `null` the breadcrumb
  /// is considered informational only and therefore not tappable.
  final AppDestination? destination;

  /// Optional named route that should be pushed after switching tabs.
  final String? routeName;

  /// Optional arguments that accompany [routeName] when it is pushed.
  final Object? arguments;

  /// Whether the breadcrumb can be interacted with.
  bool get isActionable => destination != null && routeName != null;
}

/// Central state holder that exposes the breadcrumb segments associated with
/// the most recently opened deep link.
class DeepLinkBreadcrumbsProvider extends ChangeNotifier {
  List<DeepLinkBreadcrumb> _breadcrumbs = const <DeepLinkBreadcrumb>[];

  /// Immutable list of active breadcrumbs. The list is empty when there is no
  /// deep link context to display.
  List<DeepLinkBreadcrumb> get breadcrumbs => List.unmodifiable(_breadcrumbs);

  /// Convenience flag used by the UI to hide the bar entirely when there are
  /// no breadcrumbs to render.
  bool get hasBreadcrumbs => _breadcrumbs.isNotEmpty;

  /// Updates the breadcrumb list and notifies listeners.
  void setBreadcrumbs(List<DeepLinkBreadcrumb> breadcrumbs) {
    _breadcrumbs = List<DeepLinkBreadcrumb>.unmodifiable(breadcrumbs);
    notifyListeners();
  }

  /// Clears the breadcrumb state entirely.
  void clear() {
    if (_breadcrumbs.isEmpty) {
      return;
    }
    _breadcrumbs = const <DeepLinkBreadcrumb>[];
    notifyListeners();
  }
}
