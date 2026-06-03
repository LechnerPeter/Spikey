import 'package:flutter/widgets.dart';
import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/loader.dart';

class Hardware extends Component {
  Hardware({
    required this.filepath,
    required super.name,
    required super.parentPath,
  }) {
    functions.addAll([ComponentFunction(name: "Load", function: load)]);
    load();
  }

  final String filepath;
  final initialised = ValueNotifier(false);

  Future<bool> load() async {
    // Realoading while running might cause issues
    children.clear();
    parameter.clear();
    initialised.value = false;
    final json = await Loader.file(filepath);
    if (json == null) {
      initialised.value = false;
      return false;
    }
    final component = Loader.load(json);
    children.addAll(component.children);
    parameter.addAll(component.parameter);
    initialised.value = true;
    functions.singleWhere((e) => e.name == "Load").enabled.value = false;
    ping();
    return true;
  }
}
