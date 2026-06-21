import 'package:dart_periphery/dart_periphery.dart';
import 'package:spikey/components/io/gpio/io.dart';

class RpiRead extends IORead {
  RpiRead({
    required super.name,
    required super.parentPath,
    required this.index,
  }) {
    gpio = GPIO(index, .gpioDirIn);
    _stream = createStream();
    _stream.listen((data) => state.value = data);
  }

  final int index;
  late final GPIO gpio;
  late final Stream<bool> _stream;

  Stream<bool> createStream({
    Duration interval = const Duration(milliseconds: 50),
  }) async* {
    try {
      while (true) {
        yield gpio.read(); // read current value
        await Future.delayed(interval);
      }
    } finally {
      gpio.dispose();
    }
  }
}

class RpiWrite extends IOWrite {
  RpiWrite({
    required super.name,
    required super.parentPath,
    required this.index,
  }) {
    gpio = GPIO(index, .gpioDirOut);
  }

  final int index;
  late final GPIO gpio;

  @override
  void turnOn() {
    gpio.write(true);
  }

  @override
  void turnOff() {
    gpio.write(false);
  }
}
