import 'package:dart_periphery/dart_periphery.dart';
import 'package:spikey/components/component.dart';
import 'package:spikey/components/io/pwm/pwm.dart';
import 'package:spikey/logging.dart';

class PwmI2CComponent extends PwmBaseComponent {
  PwmI2CComponent({
    required super.name,
    required super.parentPath,
    required this.i2c,
    required this.index,
  }) {
    functions.addAll([
      ComponentFunction(name: "Info", function: printMemory, parentPath: path),
    ]);
  }

  final I2C i2c;
  final address = 0x10;
  final int index;

  void printMemory() =>
      Logging.manual(i2c.readBytesReg(address, 0x00, 10).toString());

  @override
  void setDuty(double duty) {
    if (!enabled.value) duty = 0;
    duty *= 100;
    duty = duty.clamp(0, 100);
    i2c.writeBytesReg(address, 0x06 + index * 2, [
      duty.toInt(),
      (duty * 10 % 10).round(),
    ]);
  }

  void masterState(bool value) {
    i2c.writeByteReg(address, 0x03, value ? 0x01 : 0x00); // Enable
  }

  @override
  void setEnabled(bool state) {
    setDuty(state ? duty.value : 0);
  }

  @override
  void setFrequency(int freq) {
    // This writes frequency to all pwm channels
    masterState(false);
    i2c.writeBytesReg(address, 0x04, [(freq >> 8) & 0xFF, freq & 0xFF]);
    masterState(true);
    if (enabled.value) setDuty(duty.value);
  }

  @override
  void init() {
    final pid = i2c.readByteReg(address, 0x01);
    final vid = i2c.readByteReg(address, 0x02);
    if (pid == 223 && vid == 16) {
      setFrequency(frequency.value);
      setDuty(duty.value);
    }
  }
}
