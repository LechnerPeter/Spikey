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
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            SizedBox(width: 150, child: Text(component.name)),
            Text(component.runtimeType.toString()),
          ],
        ),
        Text(component.path.toString()),
        Wrap(
          children: [for (var fun in component.functions) _Function(fun: fun)],
        ),
        for (var p in component.parameter) ParameterWidget(parameter: p),
        if (component.references.isNotEmpty) const Text("References"),
        for (var r in component.references.entries)
          _Reference(reference: r.key, component: r.value),
      ],
    );
  }
}

class _Reference extends StatelessWidget {
  const _Reference({required this.reference, required this.component});

  final String reference;
  final Component component;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
      children: [
        SizedBox(width: 60, child: Text(reference)),
        Text("->"),
        Text(component.name),
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
