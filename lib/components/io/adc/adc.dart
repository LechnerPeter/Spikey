import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/logging.dart';

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
      ),
    ]);

    widgets.addAll([
      ComponentWidget(
        name: "State",
        builder: (c) => _State(adc: this),
      ),
    ]);
  }

  final state = ValueNotifier<int>(0);
  final num min;
  final num max;

  double get normalized => state.value / (max - min);
}

class _State extends HookWidget {
  const _State({required this.adc});

  final ADC adc;

  @override
  Widget build(BuildContext context) {
    final state = useValueListenable(adc.state);
    return Container(
      decoration: BoxDecoration(border: .all(width: 1)),
      width: 50,
      height: 50,
      child: Center(child: Text(state.toString())),
    );
  }
}
