import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/widgets.dart';
import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/io/adc/i2c_adc.dart';
import 'package:thornstrike/components/io/gpio/io_dummy.dart';
import 'package:thornstrike/components/io/gpio/rpi_io.dart';
import 'package:thornstrike/components/io/pwm/pwm_dummy.dart';
import 'package:thornstrike/components/io/pwm/pwm_i2c.dart';
import 'package:thornstrike/components/io/pwm/pwm.dart';
import 'package:thornstrike/logging.dart';

class IOManager extends Component {
  IOManager({required super.name, required super.parentPath}) {
    _initADC();
    _initI2CPWM();
    _initRPIPWM();
    _initGPIO();
  }

  final ready = ValueNotifier(false);

  bool _initADC() {
    try {
      for (int i in [0, 1, 2, 3]) {
        children.add(ADCoverI2C(name: "ADC$i", parentPath: path, index: i));
      }
      return true;
    } catch (e) {
      Logging.error(e.toString());
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
              ? RPI_Read_Component(name: "GPIO$i", parentPath: path, index: i)
              : RPI_Write_Component(name: "GPIO$i", parentPath: path, index: i),
        );
      }
      return false;
    } catch (e) {
      for (int i = 1; i <= 26; i++) {
        if ([2, 3, 18, 19].contains(i)) {
          continue; // 2,3 are i2c 18,19 are the onboard pwm
        }

        children.add(
          i.isEven
              ? Dummy_Read_Component(name: "GPIO$i", parentPath: path)
              : Dummy_Write_Component(name: "GPIO$i", parentPath: path),
        );
      }
    }
    return true;
  }

  bool _initI2CPWM() {
    try {
      for (var i in [0, 1, 2, 3]) {
        children.add(
          I2C_PWM_Component(
            name: "PWM$i",
            parentPath: path,
            i2c: I2C(1),
            index: i,
          ),
        );
      }
      return true;
    } catch (e) {
      Logging.error(e.toString());
      Logging.warning("Adding dummy PWM instead of the I2C pwms");
      for (var i in [0, 1, 2, 3]) {
        children.add(Dummy_Pwm(name: "I2C -PWM $i", parentPath: path));
      }
    }
    return false;
  }

  bool _initRPIPWM() {
    try {
      for (int i in [2, 3]) {
        children.add(
          PWM_Rpi_Component(
            name: "RPI PWM $i",
            parentPath: path,
            pwm: PWM(0, i),
          ),
        );
      }
      return true;
    } catch (e) {
      for (int i in [2, 3]) {
        children.add(Dummy_Pwm(name: "RPI PWM $i", parentPath: path));
      }
    }
    return false;
  }
}
