import 'package:shared_preferences/shared_preferences.dart';
import 'package:thornstrike/components/component.dart';
import 'package:thornstrike/components/main_component.dart';

class Data {
  Data._internal();
  static final Data instance = Data._internal();
  static SharedPreferences? _prefs;

  static SharedPreferences get memory => _prefs!;
  static set memory(SharedPreferences prefs) => _prefs = prefs;

  final MainComponent main = MainComponent();

  T getComponent<T extends Component>(List path) {
    Component ret = main;
    for (var str in path.skip(1)) {
      ret = ret.children.singleWhere((c) => c.name == str.toString());
    }
    return ret as T;
  }
}
