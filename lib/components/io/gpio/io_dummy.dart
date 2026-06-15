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

  bool loop = false;

  void _start() async {
    loop = true;
    while (loop) {
      state.value = true;
      await Future.delayed(Duration(seconds: 1));
      state.value = false;
      await Future.delayed(Duration(seconds: 1));
    }
  }

  void _stop() {
    loop = false;
  }
}

class DummyWriteComponent extends IOWrite {
  DummyWriteComponent({required super.name, required super.parentPath});

  @override
  void turnOn() {}

  @override
  void turnOff() {}
}
