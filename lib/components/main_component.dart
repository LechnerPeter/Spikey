import 'package:thornstrike/components/io/io_manager.dart';
import 'package:thornstrike/components/hardware.dart';
import 'package:thornstrike/components/ui_settings.dart';
import 'package:thornstrike/logging.dart';

import 'component.dart';

class MainComponent extends Component {
  MainComponent({
    super.name = "Main",
    super.parentPath = const [],
    super.parameter = const [],
  }) {
    hardware = Hardware(
      filepath: "configs/test.json",
      name: "Hardware",
      parentPath: path,
    );
    children.add(hardware);
    Logging.info("HW Done ");
    gpioManager = DFRobotIOHat(name: "GPIOManager", parentPath: path);
    children.add(gpioManager);
    Logging.info("GPIODone");
    settings = UISettings(name: "UISettings", parentPath: path);
    children.add(settings);
    Logging.info("UI Settings done");
  }

  late final Hardware hardware;
  late final DFRobotIOHat gpioManager;
  late final UISettings settings;
}
