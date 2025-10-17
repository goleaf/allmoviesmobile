import 'package:flutter/material.dart';

/// A reusable full-screen modal scaffold with an AppBar.
///
/// - Provides a consistent full-screen dialog experience when pushed with
///   `fullscreenDialog: true`.
/// - Accepts either a standard body (non-sliver) or a sliver body via
///   [slivers].
/// - Renders a default close/back button that pops the current route.
class FullscreenModalScaffold extends StatelessWidget {
  const FullscreenModalScaffold({
    super.key,
    this.title,
    this.actions,
    this.body,
    this.slivers,
    this.bottom,
    this.centerTitle,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.includeAppBarInBodyMode = true,
    this.includeDefaultSliverAppBar = true,
    this.sliverScrollWrapper,
  }) : assert(
         (body != null) ^ (slivers != null),
         'Provide either body or slivers',
       );

  final Widget? title;
  final List<Widget>? actions;
  final Widget? body;
  final List<Widget>? slivers;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;
  final bool includeAppBarInBodyMode;
  final bool includeDefaultSliverAppBar;
  final Widget Function(Widget scrollView)? sliverScrollWrapper;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final leading = canPop
        ? IconButton(
            icon: const Icon(Icons.close),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          )
        : null;

    final appBar = AppBar(
      leading: leading,
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      bottom: bottom,
    );

    final scaffoldBody = slivers == null
        ? body
        : CustomScrollView(
            slivers: <Widget>[
              if (includeDefaultSliverAppBar)
                SliverAppBar(
                  pinned: true,
                  leading: leading,
                  title: title,
                  actions: actions,
                ),
              ...slivers!,
            ],
          );

    final wrappedBody = slivers != null && sliverScrollWrapper != null
        ? sliverScrollWrapper!(scaffoldBody!)
        : scaffoldBody;

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: slivers == null && includeAppBarInBodyMode ? appBar : null,
      body: wrappedBody,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
