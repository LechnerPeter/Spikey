import 'package:spikey/components/component.dart';
import 'package:spikey/components/io/adc/adc.dart';
import 'package:spikey/components/io/pwm/pwm.dart';
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
    pwm.duty.value = adc.normalized;
    references.addAll({"ADC": adc, "PWM": pwm});
    pwm.enabled.value = true;
  }

  final PwmBase pwm;
  final ADCBase adc;

  factory AnalogPwmConnector.create({
    required String name,
    required List<String> parentPath,
    required Map json,
    List<Component> children = const [],
    List<Parameter> parameter = const [],
  }) {
    final pwm = Data.getComponent<PwmBase>(json["pwm"]);
    final adc = Data.getComponent<ADCBase>(json["adc"]);
    return AnalogPwmConnector(
      name: name,
      parentPath: parentPath,
      pwm: pwm,
      adc: adc,
    );
  }
}
