import 'package:thornstrike/components/component.dart';

import 'parameter.dart';

class UISettings extends Component {
  UISettings({required super.name, required super.parentPath}) {
    rotation = PersistentParameter<int>(
      name: "Rotation",
      value: 0,
      parentPath: path,
    );

    visualName = PersistentParameter<String>(
      name: "VisualName",
      value: "ThornStrike",
      parentPath: path,
    );

    parameter.addAll([rotation, visualName]);
  }

  late final PersistentParameter<int> rotation;
  late final PersistentParameter<String> visualName;
}
