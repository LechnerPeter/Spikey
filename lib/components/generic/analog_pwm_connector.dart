import 'package:spikey/components/component.dart';
import 'package:spikey/components/io/adc/adc.dart';
import 'package:spikey/components/io/pwm/pwm_base.dart';
import 'package:spikey/components/parameter.dart';
import 'package:spikey/data.dart';

class AnalogPwmConnector extends Component {
  AnalogPwmConnector({
    required super.name,
    required super.parentPath,
    super.children = const [],
    super.parameter = const [],
    required this.pwm,
    required this.adc,
  }) {
    adc.state.addListener(() => pwm.duty.value = adc.normalized);
    references.addAll({"ADC": adc, "PWM": pwm});
    pwm.setEnabled(true);
  }

  final PwmBaseComponent pwm;
  final ADC adc;

  factory AnalogPwmConnector.create({
    required String name,
    required List<String> parentPath,
    required Map json,
    List<Component> children = const [],
    List<Parameter> parameter = const [],
  }) {
    final pwm = Data.getComponent<PwmBaseComponent>(json["pwm"]);
    final adc = Data.getComponent<ADC>(json["adc"]);
    return AnalogPwmConnector(
      name: name,
      parentPath: parentPath,
      pwm: pwm,
      adc: adc,
    );
  }
}
