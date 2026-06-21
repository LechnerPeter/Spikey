import 'package:spikey/components/component.dart';
import 'package:spikey/components/io/gpio/io.dart';
import 'package:spikey/components/parameter.dart';
import 'package:spikey/data.dart';

class Keepalive extends Component {
  Keepalive({
    required super.name,
    required super.parentPath,
    super.parameter,
    super.children,
    super.references,
    required this.output,
    required this.controll,
  }) {
    references.addAll({"Output": output, "Controll": controll});
    _keepAlive();
  }

  final IOWrite output;
  final IORead controll;

  factory Keepalive.create({
    required String name,
    required List<String> parentPath,
    required Map json,
    List<Component> children = const [],
    List<Parameter> parameter = const [],
  }) {
    final output = Data.getComponent<IOWrite>(json["output"]);
    final controll = Data.getComponent<IORead>(json["controll"]);
    return Keepalive(
      name: name,
      parentPath: parentPath,
      children: children,
      parameter: parameter,
      output: output,
      controll: controll,
    );
  }

  Future<void> _keepAlive() async {
    while (true) {
      output.state.value = true;
      await Future.delayed(Duration(milliseconds: 1000));
      output.state.value = false;
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }
}
