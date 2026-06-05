import 'package:thornstrike/components/io/pwm/pwm_base.dart';

// ignore: camel_case_types
class Dummy_Pwm extends PWM_Base_Component {
  Dummy_Pwm({required super.name, required super.parentPath});

  @override
  void init() {}

  @override
  void setDuty(double duty) {}

  @override
  void setEnabled(bool state) {}

  @override
  void setFrequency(int freq) {}
}
