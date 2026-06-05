import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/io/adc/adc.dart';
import 'package:thornstrike/logging.dart';

class ADCoverI2C extends ADC {
  ADCoverI2C({
    required super.name,
    required super.parentPath,
    required this.index,
  }) {
    i2c.writeByteReg(address, 14, 0x01);
    _stream = createStream();
    _stream.listen((data) => state.value = data);
  }

  final i2c = I2C(1);
  final address = 0x10;
  final int index;
  late final Stream<int> _stream;

  Stream<int> createStream({
    Duration interval = const Duration(milliseconds: 50),
  }) async* {
    try {
      while (true) {
        final reads = i2c.readBytesReg(address, 15 + index * 2, 2);
        yield reads[0] * 256 + reads[1];
        await Future.delayed(interval);
      }
    } catch (e) {
      Logging.error(e.toString());
    }
  }
}

class _State extends HookWidget {
  const _State({required this.adc});

  final ADC adc;

  @override
  Widget build(BuildContext context) {
    final state = useValueListenable(adc.state);
    return Container(
      decoration: BoxDecoration(border: .all(width: 1)),
      width: 50,
      height: 50,
      child: Center(child: Text(state.toString())),
    );
  }
}
