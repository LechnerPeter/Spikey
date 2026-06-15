import 'package:spikey/components/component.dart';
import 'package:spikey/components/io/adc/adc.dart';

class ADCDummy extends ADCBase {
  ADCDummy({required super.name, required super.parentPath})
    : super(min: 0, max: 4095, isDummy: true) {
    functions.addAll([
      ComponentFunction(
        name: "Start Loop",
        function: _startLoop,
        parentPath: path,
      ),
      ComponentFunction(
        name: "Stop Loop",
        function: _stopLoop,
        parentPath: path,
      ),
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
