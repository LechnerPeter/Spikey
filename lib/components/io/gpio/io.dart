import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:spikey/components/component.dart';
import 'package:spikey/logging.dart';

import '../../parameter.dart';

abstract class IOReadComponent extends Component {
  IOReadComponent({required super.name, required super.parentPath}) {
    parameter.add(state);
    functions.addAll([
      ComponentFunction(
        name: "Log Value",
        function: () => Logging.manual(state.value.toString()),
      ),
    ]);

    widgets.add(
      ComponentWidget(
        name: "Switch",
        builder: (_) => _Read(gpio: this),
      ),
    );
  }

  final state = Parameter<bool>(name: "State", value: false);
}

class _Read extends HookWidget {
  const _Read({required this.gpio});

  final IOReadComponent gpio;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: BoxBorder.all(width: 1)),
      width: 60,
      child: Column(
        children: [
          Text(gpio.name),
          Switch(value: useValueListenable(gpio.state), onChanged: null),
        ],
      ),
    );
  }
}

abstract class IOWriteComponent extends Component {
  IOWriteComponent({required super.name, required super.parentPath}) {
    parameter.add(state);

    state.addListener(() => state.value ? turnOn() : turnOff());
    functions.addAll([
      ComponentFunction(name: "ON", function: () => state.value = true),
      ComponentFunction(name: "OFF", function: () => state.value = false),
    ]);

    widgets.add(
      ComponentWidget(
        name: "Switch",
        builder: (context) => _Write(gpio: this),
      ),
    );
  }

  final state = Parameter<bool>(name: "State", value: false);

  void turnOn();

  void turnOff();
}

class _Write extends HookWidget {
  const _Write({required this.gpio});

  final IOWriteComponent gpio;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: BoxBorder.all(width: 1)),
      width: 60,
      child: Column(
        children: [
          Text(gpio.name),
          Switch(
            value: useValueListenable(gpio.state),
            onChanged: (value) => gpio.state.value = value,
          ),
        ],
      ),
    );
  }
}
