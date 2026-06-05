import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/io/adc/adc.dart';
import 'package:thornstrike/components/io/pwm/pwm_base.dart';

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
  }

  final PwmBaseComponent pwm;
  final ADC adc;
}
