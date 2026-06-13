import 'dart:convert';
import 'dart:io';

import 'package:spikey/components/component.dart';
import 'package:spikey/components/generic/analog_pwm_connector.dart';
import 'package:spikey/components/generic/switch.dart';
import 'package:spikey/logging.dart';

import 'parameter.dart';

class Loader {
  static Component load(
    Map<String, dynamic> json, [
    List<String> parent = const [],
  ]) {
    final String name = json["name"];
    final List<String> path = [...parent, name];
    final List<Component> children;
    if (json.containsKey("children")) {
      children = [for (var child in json["children"]) load(child, path)];
    } else {
      children = [];
    }
    final List<Parameter> parameter;
    if (json.containsKey("parameter")) {
      parameter = [for (var p in json["parameter"]) Loader.parameter(p)];
    } else {
      parameter = [];
    }

    Logging.info(
      "Initialising: $path with Parameters ${[for (var p in parameter) p.name]}",
    );
    String? type = json["type"];
    switch (type) {
      case "switch":
        return Switch.create(
          name: name,
          parentPath: parent,
          parameter: parameter,
          children: children,
          json: json,
        );
      case "connector":
        return AnalogPwmConnector.create(
          name: name,
          parentPath: parent,
          parameter: parameter,
          children: children,
          json: json,
        );
      default:
        if (type != null) {
          Logging.error("Type $type not found using base component instead");
        }
        return Component(
          name: name,
          parentPath: parent,
          parameter: parameter,
          children: children,
        );
    }
  }

  static Parameter parameter(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "int":
        return Parameter<int>(
          name: json["name"],
          value: json["default"] as int,
        );
      default:
        throw Exception("Parameter type does not exist ${json["type"]}");
    }
  }

  static Future<Map<String, dynamic>?> file(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        Logging.error("File does not exist");
        return null;
      }
      String raw = await file.readAsString();
      return jsonDecode(raw);
    } catch (e) {
      Logging.error("File Loader Error: ${e.toString()}");
      return null;
    }
  }
}
