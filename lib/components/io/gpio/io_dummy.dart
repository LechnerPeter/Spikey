import 'dart:async';

import 'package:spikey/components/component.dart';
import 'package:spikey/components/io/gpio/io.dart';

class DummyReadComponent extends IORead {
  DummyReadComponent({
    required super.name,
    required super.parentPath,
    super.isDummy = true,
  }) {
    functions.addAll([
      ComponentFunction(
        name: "Fake ON",
        function: () => state.value = true,
        parentPath: path,
      ),
      ComponentFunction(
        name: "Fake OFF",
        function: () => state.value = false,
        parentPath: path,
      ),
      ComponentFunction(name: "1sec cycle", function: _start, parentPath: path),
      ComponentFunction(name: "Stop cycle", function: _stop, parentPath: path),
    ]);
  }

  Completer<void>? _cancel;

  void _start() async {
    _cancel = Completer();
    while (true) {
      state.value = !state.value;
      await Future.any([
        Future.delayed(const Duration(seconds: 1)),
        _cancel!.future,
      ]);
      if (_cancel!.isCompleted) break;
    }
  }

  void _stop() {
    _cancel?.complete();
  }
}

class DummyWriteComponent extends IOWrite {
  DummyWriteComponent({required super.name, required super.parentPath});

  @override
  void turnOn() {}

  @override
  void turnOff() {}
}
