import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:spikey/components/component.dart';

import 'parameter.dart';

class UISettings extends Component {
  UISettings({required super.name, required super.parentPath}) {
    rotation = PersistentParameter<int>(
      name: "Rotation",
      value: 0,
      parentPath: path,
      userEditable: true,
    );

    visualName = PersistentParameter<String>(
      name: "VisualName",
      value: "Spikey",
      parentPath: path,
    );

    lockTimeout = PersistentParameter<int>(
      name: "LockTimeout",
      value: 15,
      parentPath: path,
      userEditable: true,
    );

    final dir = backlightDir();
    maxBrightness = _readMaxBrightness(dir);

    brightness = PersistentParameter<double>(
      name: "Brightness",
      value: 128.0,
      parentPath: path,
      userEditable: true,
    );

    lockedBrightness = PersistentParameter<double>(
      name: "LockedBrightness",
      value: (maxBrightness / 4).roundToDouble(),
      parentPath: path,
      userEditable: true,
    );
    brightness.addListener(applyBrightness);
    lockedBrightness.addListener(applyBrightness);

    parameter.addAll([
      rotation,
      visualName,
      lockTimeout,
      brightness,
      lockedBrightness,
    ]);
  }

  late final PersistentParameter<int> rotation;
  late final PersistentParameter<String> visualName;
  late final PersistentParameter<int> lockTimeout;
  late final PersistentParameter<double> brightness;
  late final PersistentParameter<double> lockedBrightness;
  late final double maxBrightness;
  final locked = ValueNotifier<bool>(false);

  void applyBrightness() {
    final dir = backlightDir();
    if (dir == null) return;
    final value = locked.value ? lockedBrightness.value : brightness.value;
    try {
      File('$dir/brightness').writeAsStringSync(value.round().toString());
    } catch (_) {}
  }

  static String? backlightDir() {
    final dir = Directory('/sys/class/backlight');
    if (!dir.existsSync()) return null;
    final entries = dir.listSync();
    return entries.isEmpty ? null : entries.first.path;
  }

  static double _readMaxBrightness(String? dir) {
    if (dir == null) return 255.0;
    final f = File('$dir/max_brightness');
    if (!f.existsSync()) return 255.0;
    try {
      return double.parse(f.readAsStringSync().trim());
    } catch (_) {
      return 255.0;
    }
  }
}
