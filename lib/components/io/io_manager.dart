import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/widgets.dart';
import 'package:spikey/components/component.dart';
import 'package:spikey/components/io/adc/adc_dummy.dart';
import 'package:spikey/components/io/adc/i2c_adc.dart';
import 'package:spikey/components/io/gpio/io_dummy.dart';
import 'package:spikey/components/io/gpio/rpi_io.dart';
import 'package:spikey/components/io/pwm/pwm_dummy.dart';
import 'package:spikey/components/io/pwm/pwm_i2c.dart';
import 'package:spikey/components/io/pwm/rpi_pwm.dart';
import 'package:spikey/logging.dart';

class DFRobotIOHat extends Component {
  DFRobotIOHat({required super.name, required super.parentPath}) {
    _initI2C();
    _initADC();
    _initI2CPWM();
    _initRPIPWM();
    _initGPIO();
  }

  final ready = ValueNotifier(false);
  I2C? i2c;

  bool _initI2C() {
    try {
      i2c = I2C(1);
      return true;
    } catch (e) {
      Logging.error(e.toString());
      return false;
    }
  }

  bool _initADC() {
    try {
      if (i2c == null) throw Exception("ADC init requires I2C");
      for (int i in [0, 1, 2, 3]) {
        children.add(
          ADCoverI2C(
            name: "ADC$i",
            parentPath: path,
            index: i,
            i2c: i2c!,
            min: 0,
            max: 4095,
          ),
        );
      }
      Logging.info("ADC Done");
      return true;
    } catch (e) {
      Logging.error(e.toString());
      Logging.warning("Using ADC dummies");
      for (int i in [0, 1, 2, 3]) {
        children.add(ADCDummy(name: "ADC$i", parentPath: path));
      }
    }
    return false;
  }

  bool _initGPIO() {
    try {
      for (int i = 1; i <= 26; i++) {
        // 2,3 are i2c 18,19 are the onboard pwm
        if ([2, 3, 18, 19].contains(i)) continue;
        children.add(
          i.isEven
              ? RpiReadComponent(name: "GPIO$i", parentPath: path, index: i)
              : RpiWriteComponent(name: "GPIO$i", parentPath: path, index: i),
        );
      }
      Logging.info("IO Done");
      return true;
    } catch (e) {
      for (int i = 1; i <= 26; i++) {
        if ([2, 3, 18, 19].contains(i)) {
          continue; // 2,3 are i2c 18,19 are the onboard pwm
        }
        children.add(
          i.isEven
              ? DummyReadComponent(name: "GPIO$i", parentPath: path)
              : DummyWriteComponent(name: "GPIO$i", parentPath: path),
        );
      }
    }
    return false;
  }

  bool _initI2CPWM() {
    try {
      if (i2c == null) throw Exception("ADC init requires I2C");
      for (var i in [0, 1, 2, 3]) {
        children.add(
          PwmI2CComponent(name: "PWM$i", parentPath: path, i2c: i2c!, index: i),
        );
      }
      Logging.info("PWM Done");
      return true;
    } catch (e) {
      Logging.error(e.toString());
      Logging.warning("Adding dummy PWM instead of the I2C pwms");
      for (var i in [0, 1, 2, 3]) {
        children.add(DummyPwm(name: "PWM$i", parentPath: path));
      }
    }
    return false;
  }

  bool _initRPIPWM() {
    try {
      for (int i in [2, 3]) {
        children.add(
          RpiPwmComponent(name: "RPI PWM $i", parentPath: path, pwm: PWM(0, i)),
        );
      }
      return true;
    } catch (e) {
      for (int i in [2, 3]) {
        children.add(DummyPwm(name: "RPI PWM $i", parentPath: path));
      }
    }
    return false;
  }
}
