import 'package:flutter/material.dart';
import 'package:spikey/data.dart';

class PopupButton<T> extends StatelessWidget {
  const PopupButton({
    super.key,
    required this.child,
    required this.builder,
    this.after,
  });

  final Widget child;
  final Widget Function(BuildContext) builder;
  final void Function(T? value)? after;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTap: () async {
        final value = await showDialog<T>(
          context: context,
          builder: (c) => RotatedBox(
            quarterTurns: Data.instance.main.settings.rotation.value,
            child: builder(c),
          ),
        );
        if (after != null) after!(value);
      },
    );
  }
}
