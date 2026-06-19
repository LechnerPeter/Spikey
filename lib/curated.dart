import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:spikey/components/component.dart';
import 'package:spikey/components/parameter.dart';

class Curated extends HookWidget {
  const Curated({super.key, required this.main});

  final Component main;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: [
          for (var component in getAll(main)) _One(component: component),
        ],
      ),
    );
  }

  List<Component> getAll(Component component) {
    final ret = <Component>[];
    ret.addAll(component.children.where((c) => c.hasCurated()));
    ret.addAll([for (var c in component.children) ...getAll(c)]);
    return ret;
  }
}

class _One extends StatelessWidget {
  const _One({required this.component});

  final Component component;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(2),
      child: Container(
        decoration: BoxDecoration(border: .all(width: 1)),
        child: Padding(
          padding: const .all(2),
          child: Column(
            children: [
              Text(component.name),
              ...[
                for (var p in component.parameter.where((e) => e.show.value))
                  _Parameter(parameter: p),
                for (var f in component.functions.where((e) => e.show.value))
                  FunctionWidget(function: f),
                for (var w in component.widgets.where((e) => e.show.value))
                  Column(children: [Text(w.name), w.builder(context)]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Parameter extends HookWidget {
  const _Parameter({required this.parameter});

  final Parameter<dynamic> parameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(parameter.name),
          Text(useValueListenable(parameter).toString()),
        ],
      ),
    );
  }
}
