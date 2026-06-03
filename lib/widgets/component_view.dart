import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../components/component.dart';
import 'parameter.dart';

class ComponentView extends StatelessWidget {
  const ComponentView({super.key, required this.component});

  final Component component;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          children: [for (var fun in component.functions) _Function(fun: fun)],
        ),
        for (var p in component.parameter) ParameterWidget(parameter: p),
      ],
    );
  }
}

class _Function extends HookWidget {
  const _Function({required this.fun});

  final ComponentFunction fun;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: useValueListenable(fun.enabled) ? () => fun.function() : null,
      child: Text(fun.name),
    );
  }
}
