import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/parameter.dart';

// ignore: camel_case_types
abstract class PWM_Base_Component extends Component {
  PWM_Base_Component({required super.name, required super.parentPath}) {
    parameter.add(frequency);
    parameter.add(duty);
    parameter.add(enabled);

    enabled.addListener(() => setEnabled(enabled.value));
    frequency.addListener(() => setFrequency(frequency.value));
    duty.addListener(() => setDuty(duty.value));

    // init
    init_();

    functions.addAll([
      ComponentFunction(name: "ON", function: () => enabled.value = true),
      ComponentFunction(name: "OFF", function: () => enabled.value = false),
      ComponentFunction(
        name: "Halve",
        function: () => frequency.value = (frequency.value / 2).round(),
      ),
      ComponentFunction(
        name: "Double",
        function: () => frequency.value = frequency.value * 2,
      ),
    ]);

    widgets.add(
      ComponentWidget(
        name: "Slider",
        builder: (context) => _Slider(pwm: this),
      ),
    );
  }

  final frequency = Parameter<int>(name: "Frequency", value: 1_000);
  final duty = Parameter<double>(name: "Duty", value: 0.5);
  final enabled = Parameter<bool>(name: "Enabled", value: false);

  void init_();
  void setEnabled(bool state);
  void setDuty(double duty);
  void setFrequency(int freq);
}

class _Slider extends HookWidget {
  const _Slider({required this.pwm});

  final PWM_Base_Component pwm;

  @override
  Widget build(BuildContext context) {
    final on = useValueListenable(pwm.enabled);
    return Container(
      decoration: BoxDecoration(border: BoxBorder.all(width: 1)),
      width: 290,
      child: Column(
        children: [
          Text(pwm.name),
          Row(
            children: [
              Switch(
                onChanged: (value) => pwm.enabled.value = value,
                value: on,
              ),
              Slider(
                value: useValueListenable(pwm.duty),
                onChanged: on ? (value) => pwm.duty.value = value : null,
                min: 0,
                max: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
