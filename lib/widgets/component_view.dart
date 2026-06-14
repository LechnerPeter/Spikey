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
          children: [for (var f in component.functions) _Function(function: f)],
        ),
        for (var p in component.parameter) ParameterWidget(parameter: p),
        if (component.references.isNotEmpty) const Text("References"),
        for (var r in component.references.entries)
          _Reference(reference: r.key, component: r.value),
        if (component.widgets.isNotEmpty) const Text("Widgets"),
        Wrap(children: [for (var w in component.widgets) _Widget(widget: w)]),
      ],
    );
  }
}

class _Widget extends StatelessWidget {
  const _Widget({required this.widget});

  final ComponentWidget widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.name),
        widget.builder(context),
        ChangeParameter(parameter: widget.show),
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
  const _Function({required this.function});

  final ComponentFunction function;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FunctionWidget(function: function),
        Switch(
          value: useValueListenable(function.show),
          onChanged: (value) => function.show.value = value,
        ),
      ],
    );
  }
}
