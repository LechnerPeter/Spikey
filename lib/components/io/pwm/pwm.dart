import 'package:dart_periphery/dart_periphery.dart';
import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/io/pwm/pwm_base.dart';
import 'package:thornstrike/logging.dart';

// ignore: camel_case_types
class PWM_Rpi_Component extends PWM_Base_Component {
  PWM_Rpi_Component({
    required super.name,
    required super.parentPath,
    required this.pwm,
  }) {
    functions.addAll([
      ComponentFunction(
        name: "Info",
        function: () => Logging.manual(pwm.getPWMinfo()),
      ),
    ]);
  }

  final PWM pwm;

  @override
  void init() {
    setDuty(duty.value);
    setFrequency(frequency.value);
    setEnabled(enabled.value);
  }

  @override
  void setDuty(double duty) => pwm.setDutyCyclePercent(duty * 100);

  @override
  void setEnabled(bool state) => pwm.setEnabled(state);

  @override
  void setFrequency(int freq) => pwm.setFrequency(freq.toDouble());
}
