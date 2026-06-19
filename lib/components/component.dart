import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'parameter.dart';

class Component {
  Component({
    required this.name,
    required List<String> parentPath,
    List<Parameter> parameter = const [],
    List<Component> children = const [],
    Map<String, Component> references = const {},
    this.isDummy = false,
  }) {
    path.addAll(parentPath);
    path.add(name);
    this.parameter.addAll(parameter);
    this.children.addAll(children);
    this.references.addAll(references);
  }

  final String name;
  final List<String> path = [];
  List<Component> children = [];
  List<Parameter> parameter = [];
  Map<String, Component> references = {};
  final functions = <ComponentFunction>[];
  final widgets = <ComponentWidget>[];
  final changed = ValueNotifier(false);

  final bool isDummy;

  bool hasCurated() =>
      functions.any((f) => f.show.value) ||
      widgets.any((w) => w.show.value) ||
      parameter.any((p) => p.show.value);

  void ping() => changed.value = !changed.value;
}

class ComponentFunction {
  ComponentFunction({
    required this.name,
    required this.function,
    required List<String> parentPath,
    bool show = false,
  }) {
    path = [...parentPath, name];
    this.show = PersistentParameter<bool>(
      name: "Show",
      value: show,
      parentPath: path,
    );
  }

  final String name;
  final void Function() function;
  final enabled = ValueNotifier(true);
  late final List<String> path;
  late final PersistentParameter<bool> show;
}

class FunctionWidget extends HookWidget {
  const FunctionWidget({super.key, required this.function});

  final ComponentFunction function;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: useValueListenable(function.enabled)
          ? () => function.function()
          : null,
      child: Text(function.name),
    );
  }
}

class ComponentWidget {
  ComponentWidget({
    required this.name,
    required this.builder,
    required List<String> parentPath,
    bool show = false,
  }) {
    path = [...parentPath, name];
    this.show = PersistentParameter<bool>(
      name: "Show",
      value: show,
      parentPath: path,
    );
  }

  final String name;
  final WidgetBuilder builder;
  late final List<String> path;
  late final PersistentParameter<bool> show;
}
