import 'package:dart_periphery/dart_periphery.dart';
import 'package:spikey/components/component.dart';
import 'package:spikey/components/io/pwm/pwm.dart';
import 'package:spikey/logging.dart';

class RpiPwmComponent extends PwmBase {
  RpiPwmComponent({
    required super.name,
    required super.parentPath,
    required this.pwm,
  }) {
    functions.addAll([
      ComponentFunction(
        name: "Info",
        function: () => Logging.manual(pwm.getPWMinfo()),
        parentPath: path,
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
