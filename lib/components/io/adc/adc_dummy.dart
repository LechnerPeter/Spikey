import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/io/adc/adc.dart';

class ADCDummy extends ADC {
  ADCDummy({required super.name, required super.parentPath})
    : super(min: 0, max: 4095) {
    functions.addAll([
      ComponentFunction(name: "Start Loop", function: _startLoop),
      ComponentFunction(name: "Stop Loop", function: _stopLoop),
    ]);
  }

  bool looping = false;

  void _startLoop() async {
    looping = true;
    while (looping) {
      state.value = (state.value + 1) % 4095;
      await Future.delayed(Duration(milliseconds: 1));
    }
  }

  void _stopLoop() {
    looping = false;
  }
}
