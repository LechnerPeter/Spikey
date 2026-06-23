import 'dart:async';

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

  Completer<void>? _cancel;

  void _startLoop() async {
    _cancel = Completer();
    while (true) {
      state.value = (state.value + 1) % 4095;
      await Future.any([Future.delayed(const Duration(milliseconds: 1)), _cancel!.future]);
      if (_cancel!.isCompleted) break;
    }
  }

  void _stopLoop() {
    _cancel?.complete();
  }
}
