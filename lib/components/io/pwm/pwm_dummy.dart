import 'package:spikey/components/io/pwm/pwm.dart';

class DummyPwm extends PwmBaseComponent {
  DummyPwm({required super.name, required super.parentPath});

  @override
  void init() {}

  @override
  void setDuty(double duty) {}

  @override
  void setEnabled(bool state) {}

  @override
  void setFrequency(int freq) {}
}
