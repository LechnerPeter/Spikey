import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:spikey/components/component.dart';
import 'package:spikey/components/parameter.dart';

abstract class PwmBase extends Component {
  PwmBase({required super.name, required super.parentPath, super.isDummy}) {
    parameter.addAll([frequency, duty, enabled]);

    enabled.addListener(() => setEnabled(enabled.value));
    frequency.addListener(() => setFrequency(frequency.value));
    duty.addListener(() => setDuty(duty.value.clamp(0, 1)));

    // init
    init();

    functions.addAll([
      ComponentFunction(
        name: "ON",
        function: () => enabled.value = true,
        parentPath: path,
      ),
      ComponentFunction(
        name: "OFF",
        function: () => enabled.value = false,
        parentPath: path,
      ),
      ComponentFunction(
        name: "Halve",
        function: () => frequency.value = (frequency.value / 2).round(),
        parentPath: path,
      ),
      ComponentFunction(
        name: "Double",
        function: () => frequency.value = frequency.value * 2,
        parentPath: path,
      ),
    ]);

    widgets.add(
      ComponentWidget(
        name: "Slider",
        builder: (_) => _Slider(pwm: this),
        parentPath: path,
      ),
    );
  }

  late final frequency = Parameter<int>(
    name: "Frequency",
    value: 1_000,
    parentPath: path,
  );
  late final duty = Parameter<double>(
    name: "Duty",
    value: 0.5,
    parentPath: path,
  );
  late final enabled = Parameter<bool>(
    name: "Enabled",
    value: false,
    parentPath: path,
  );

  void init();
  void setEnabled(bool state);
  void setDuty(double duty);
  void setFrequency(int freq);
}

class _Slider extends HookWidget {
  const _Slider({required this.pwm});

  final PwmBase pwm;

  @override
  Widget build(BuildContext context) {
    final on = useValueListenable(pwm.enabled);
    return SizedBox(
      width: 190,
      child: Column(
        children: [
          Switch(onChanged: (value) => pwm.enabled.value = value, value: on),
          Slider(
            value: useValueListenable(pwm.duty),
            onChanged: on ? (value) => pwm.duty.value = value : null,
            min: 0,
            max: 1,
          ),
        ],
      ),
    );
  }
}
