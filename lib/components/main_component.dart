import 'package:spikey/components/io/io_manager.dart';
import 'package:spikey/components/hardware.dart';
import 'package:spikey/components/ui_settings.dart';
import 'package:spikey/logging.dart';

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
