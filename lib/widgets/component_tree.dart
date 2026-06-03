import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../components/component.dart';

class ComponentTree extends HookWidget {
  const ComponentTree({
    super.key,
    required this.component,
    required this.selected,
  });

  final Component component;
  final ValueNotifier<Component> selected;

  @override
  Widget build(BuildContext context) {
    useListenable(component.changed);
    final selectedC = useValueListenable(selected);
    final isSelected = selectedC == component;
    var expanded = false;
    var subPath = <String>[];
    if (listEquals(component.path, subPath)) expanded = true;
    for (var str in selectedC.path) {
      subPath.add(str);
      if (listEquals(subPath, component.path)) {
        expanded = true;
        break;
      }
    }
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: .circular(4),
          onTap: () => selected.value = component,
          child: AnimatedContainer(
            decoration: BoxDecoration(
              borderRadius: .circular(6),
              color: isSelected ? Colors.green : Colors.amber,
            ),
            width: 120,
            height: 40,
            padding: .all(8),
            duration: Durations.medium1,
            child: Text(component.name),
          ),
        ),
        expanded
            ? Row(
                mainAxisAlignment: .start,
                children: [
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      for (var child in component.children)
                        ComponentTree(component: child, selected: selected),
                    ],
                  ),
                ],
              )
            : SizedBox(),
      ],
    );
  }
}
