import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:spikey/components/component.dart';
import 'package:spikey/components/parameter.dart';
import 'package:spikey/logging.dart';

class ADC extends Component {
  ADC({
    required super.name,
    required super.parentPath,
    required this.min,
    required this.max,
  }) {
    functions.addAll([
      ComponentFunction(
        name: "Read",
        function: () => Logging.manual(state.value.toString()),
        parentPath: path,
      ),
    ]);

    widgets.addAll([
      ComponentWidget(
        name: "State",
        builder: (c) => _State(adc: this),
        parentPath: path,
      ),
    ]);
  }

  late final state = Parameter<int>(value: 0, parentPath: path, name: 'State');
  final num min;
  final num max;

  double get normalized => state.value / (max - min);
}

class _State extends HookWidget {
  const _State({required this.adc});

  final ADC adc;

  @override
  Widget build(BuildContext context) {
    useListenable(adc.state);
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          child: Container(
            height: 50 * adc.normalized,
            width: 50,
            color: Colors.lightBlue.shade300,
          ),
        ),
        Container(
          decoration: BoxDecoration(border: .all(width: 1)),
          width: 50,
          height: 50,
          child: Center(child: Text((adc.normalized * 100).toStringAsFixed(0))),
        ),
      ],
    );
  }
}
