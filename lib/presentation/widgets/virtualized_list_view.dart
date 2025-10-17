import 'package:flutter/widgets.dart';

/// Lightweight wrapper around [ListView.custom] that enables list virtualization
/// with fine-grained control over repaint and keep-alive behavior.
class VirtualizedListView extends StatelessWidget {
  const VirtualizedListView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.controller,
    this.padding,
    this.physics,
    this.cacheExtent,
    this.scrollDirection = Axis.vertical,
    this.addAutomaticKeepAlives = false,
    this.addRepaintBoundaries = true,
    this.shrinkWrap = false,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final Axis scrollDirection;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.custom(
      controller: controller,
      padding: padding,
      physics: physics,
      scrollDirection: scrollDirection,
      cacheExtent: cacheExtent,
      shrinkWrap: shrinkWrap,
      childrenDelegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: itemCount,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
      ),
    );
  }
}

class VirtualizedSeparatedListView extends StatelessWidget {
  const VirtualizedSeparatedListView({
    super.key,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.itemCount,
    this.controller,
    this.padding,
    this.physics,
    this.cacheExtent,
    this.scrollDirection = Axis.vertical,
    this.addAutomaticKeepAlives = false,
    this.addRepaintBoundaries = true,
    this.shrinkWrap = false,
  });

  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final int itemCount;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final Axis scrollDirection;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return ListView(
        controller: controller,
        padding: padding,
        physics: physics,
        scrollDirection: scrollDirection,
        shrinkWrap: shrinkWrap,
      );
    }

    return ListView.custom(
      controller: controller,
      padding: padding,
      physics: physics,
      scrollDirection: scrollDirection,
      cacheExtent: cacheExtent,
      shrinkWrap: shrinkWrap,
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isEven) {
            final itemIndex = index ~/ 2;
            return itemBuilder(context, itemIndex);
          }
          final separatorIndex = (index - 1) ~/ 2;
          return separatorBuilder(context, separatorIndex);
        },
        childCount: itemCount * 2 - 1,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
      ),
    );
  }
}
