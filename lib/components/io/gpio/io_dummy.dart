import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/io/gpio/io.dart';

class DummyReadComponent extends IOReadComponent {
  DummyReadComponent({required super.name, required super.parentPath}) {
    functions.addAll([
      ComponentFunction(name: "Fake ON", function: () => state.value = true),
      ComponentFunction(name: "Fake OFF", function: () => state.value = false),
      ComponentFunction(name: "1sec cycle", function: () => _start()),
      ComponentFunction(name: "Stop cycle", function: () => _stop()),
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

class DummyWriteComponent extends IOWriteComponent {
  DummyWriteComponent({required super.name, required super.parentPath});

  @override
  void turnOn() {}

  @override
  void turnOff() {}
}
