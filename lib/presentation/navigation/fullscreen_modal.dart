import 'package:flutter/material.dart';

Future<T?> pushFullscreenModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
}) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(
      fullscreenDialog: true,
      builder: (ctx) {
        final child = builder(ctx);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(ctx).maybePop(),
            ),
            title: title != null ? Text(title) : null,
          ),
          body: child,
        );
      },
    ),
  );
}


