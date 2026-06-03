import 'package:flutter/material.dart';

import 'parameter.dart';

class Component {
  Component({
    required this.name,
    required List<String> parentPath,
    List<Parameter> parameter = const [],
    List<Component> children = const [],
    List<Component> references = const [],
    this.isDummy = true,
  }) {
    path.addAll(parentPath);
    path.add(name);
    this.parameter.addAll(parameter);
    this.children.addAll(children);
    this.references.addAll(references);
  }

  final String name;
  List<String> path = [];
  List<Component> children = [];
  List<Parameter> parameter = [];
  List<Component> references = [];
  final functions = <ComponentFunction>[];
  final widgets = <ComponentWidget>[];
  final bool isDummy;
  final changed = ValueNotifier(false);

  void ping() => changed.value = !changed.value;
}

class ComponentFunction {
  ComponentFunction({required this.name, required this.function});

  final String name;
  final void Function() function;
  final enabled = ValueNotifier(true);
}

class ComponentWidget {
  ComponentWidget({required this.name, required this.builder});

  final String name;
  final WidgetBuilder builder;
  final enabled = ValueNotifier(true);
}
